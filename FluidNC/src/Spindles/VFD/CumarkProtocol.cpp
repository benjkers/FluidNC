#include "CumarkProtocol.h"
#include "../VFDSpindle.h"
#include "../../System.h"
#include "../../Config.h"
#include "../../GCode.h"
#include "../../Protocol.h"  // protocol_send_event, feedOverrideEvent
#include <algorithm>

namespace Spindles {
    namespace VFD {
        void CumarkProtocol::direction_command(SpindleState mode, ModbusCommand& data) {
            bool was_ccw = _is_Ccw;
            _is_Ccw = (mode == SpindleState::Ccw);

            if (mode == SpindleState::Disable) {
                data.tx_length = 6;
                data.rx_length = 6;
                data.msg[1] = 0x06;  // Function code: Write Single Register
                data.msg[2] = 0x00;  // Register address high byte
                data.msg[3] = 0x01;  // Register address low byte
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop command
                log_info("Spindle Disabled");
                return;
            }

            bool direction_changed = (_is_Ccw != was_ccw);

            if (direction_changed) {
                // This drive does NOT appear to honor a live sign change on
                // the speed register while already running -- it needs to
                // see a genuine stop, then a fresh start with the
                // corrected sign, to actually reverse. This callback's own
                // output is the STOP; the restart is queued as a single
                // follow-up transaction, since only one Modbus message can
                // be built per callback invocation. That follow-up lands
                // back in this same function (direction_changed will be
                // false by then) and falls through to the combined
                // start+speed write below.
                data.tx_length = 6;
                data.rx_length = 6;
                data.msg[1] = 0x06;
                data.msg[2] = 0x00;
                data.msg[3] = 0x01;
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop
                log_warn("CumarkProtocol: direction changed to " << (_is_Ccw ? "CCW" : "CW") << " -- stopping before reversing");

                if (vfd_cmd_queue) {
                    VFDaction start_action;
                    start_action.action   = actionSetMode;
                    start_action.arg      = uint32_t(mode);
                    start_action.critical = false;
                    if (xQueueSend(vfd_cmd_queue, &start_action, 0) != pdTRUE) {
                        log_warn("CumarkProtocol: VFD queue full, could not queue restart after direction change");
                    }
                }
                return;
            }

            // Combined Start + correctly-signed Speed, written together in
            // ONE Modbus transaction (function code 0x10, "Write Multiple
            // Registers", covering 0x0001-0x0002). This is the key piece:
            // it means the corrected-sign speed always accompanies the
            // start command, so this never goes through the framework's
            // queued actionSetSpeed path at all -- and therefore never
            // hits VFDProtocol::prepareSetSpeedCommand()'s "don't resend
            // the same speed twice" guard, which doesn't know about
            // direction and was silently swallowing an earlier version of
            // this fix (confirmed via debug log: no "set_speed_command
            // called" line ever appeared for a same-RPM reversal before).
            // This keeps the whole fix inside this file -- no
            // VFDProtocol.h/.cpp changes needed.
            //
            // NOTE: 0x10 is confirmed supported by this drive (see the
            // function code table in the manual), but I could not find a
            // byte-level worked example for it specifically to check
            // against, unlike 0x03/0x06 -- the framing below follows the
            // standard Modbus RTU spec for this function code. Worth
            // testing carefully.
            int32_t effective_speed = _is_Ccw ? -static_cast<int32_t>(last_speed) : static_cast<int32_t>(last_speed);

            data.tx_length = 11;  // addr + func + start_hi + start_lo + qty_hi + qty_lo + byte_count + 4 data bytes
            data.rx_length = 6;   // addr + func + start_hi + start_lo + qty_hi + qty_lo (echoed, no data)

            data.msg[1] = 0x10;  // Function code: Write Multiple Registers
            data.msg[2] = 0x00;  // Starting register address high byte (0x0001)
            data.msg[3] = 0x01;  // Starting register address low byte
            data.msg[4] = 0x00;  // Number of registers high byte
            data.msg[5] = 0x02;  // Number of registers low byte (2: control word + speed)
            data.msg[6] = 0x04;  // Byte count (2 registers x 2 bytes)
            data.msg[7] = 0x08;  // Control word high byte
            data.msg[8] = 0x82;  // Control word low byte (Start command)
            data.msg[9]  = uint8_t(effective_speed >> 8);
            data.msg[10] = uint8_t(effective_speed & 0xFF);

            log_info("Spindle Enabled in " << (_is_Ccw ? "CCW" : "CW") << " mode (combined start+speed=" << effective_speed << ")");
        }

        void CumarkProtocol::set_speed_command(uint32_t dev_speed, ModbusCommand& data){
            last_speed = dev_speed;  // Store the current speed for future direction changes
            int32_t effective_speed = _is_Ccw ? -static_cast<int32_t>(dev_speed) : dev_speed;

            log_info("set_speed_command called. Speed: " << dev_speed << " | Effective Speed: " << effective_speed);
            data.tx_length = 6;
            data.rx_length = 6;

            data.msg[1] = 0x06;
            data.msg[2] = 0x00;
            data.msg[3] = 0x02;
            data.msg[4] = effective_speed >> 8;
            data.msg[5] = effective_speed & 0xFF;
        }

        // ---------------------------------------------------------------
        // Single block read of the fieldbus data set, registers 0x0004-0x0006.
        //
        // This one transaction replaces what used to be three separate
        // polls (speed / torque / status), so every signal the adaptive
        // feed control needs arrives on EVERY poll instead of every third.
        //
        //   0x0004  Fieldbus status word  -- fixed, needs no drive config.
        //             bit 7  Alarm
        //             bit 9  Torque limited
        //             bit 14 Direction reverse
        //             bit 15 Fault
        //   0x0005  Field bus actual value 1  -- REQUIRES drive param
        //             50.03 Act1 src = P.01.22 (motor torque, 0.1% units)
        //   0x0006  Field bus actual value 2  -- REQUIRES drive param
        //             50.04 Act2 src = P.01.00 (motor speed)
        //
        // These sit in the same fieldbus data set as the control word
        // (0x0001) and speed reference (0x0002) this driver already writes
        // successfully, so the block is known to be reachable over Modbus.
        //
        // tx 6 bytes / rx 9 bytes, both comfortably inside the 16-byte
        // VFD_RS485_MAX_MSG_SIZE -- no shared buffer change needed.
        //
        // All three polling hooks below return this same parser, so the
        // framework's round-robin runs it on every iteration. That is safe
        // here because Cumark uses use_delay_settings() == true, so the
        // speed-sync path in VFDSpindle::setState() is never taken and the
        // old dedicated speed poll served no purpose.
        // ---------------------------------------------------------------
        VFDProtocol::response_parser CumarkProtocol::fieldbus_block_read(ModbusCommand& data) {
            data.tx_length = 6;
            data.rx_length = 9;  // addr + func + byte_count + 3 registers (6 bytes)

            data.msg[1] = 0x03;  // Read Holding Registers
            data.msg[2] = 0x00;  // start 0x0004 high
            data.msg[3] = 0x04;  // start 0x0004 low
            data.msg[4] = 0x00;  // count high
            data.msg[5] = 0x03;  // count low (3 registers: 0x0004, 0x0005, 0x0006)

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                uint16_t status = (uint16_t)((response[3] << 8) | response[4]);   // 0x0004
                int16_t  act1   = (int16_t)((response[5] << 8) | response[6]);    // 0x0005 -> torque
                int16_t  act2   = (int16_t)((response[7] << 8) | response[8]);    // 0x0006 -> speed

                bool fault          = (status & (1 << 15)) != 0;
                bool alarm          = (status & (1 << 7)) != 0;
                bool torque_limited = (status & (1 << 9)) != 0;
                bool is_reverse     = (status & (1 << 14)) != 0;
                (void)is_reverse;  // available as direction feedback, not acted on yet

                auto* self = static_cast<CumarkProtocol*>(detail);

                // RAW torque, SIGNED. Do not take the magnitude: negative
                // means the spindle is being driven rather than loaded, so
                // abs() invents load at idle and inverts the response during
                // a pull-out -- exactly the wrong way round.
                float raw_torque = float(act1) / 10.0f;
                float rpm        = float(std::abs((int)act2));

                // The drive's estimate carries a speed-dependent NEGATIVE
                // offset. Flux-angle lag leaks magnetising current into the
                // torque axis; the lag grows with output frequency while the
                // magnetising current is fixed below base speed and falls
                // above it -- so the offset peaks near base speed. Measured
                // on this machine: -1.6% at 3000, -4.5% at 6000, easing to
                // -1.6% by 18000. Subtracting the measured curve makes zero
                // mean zero load, and also removes windage and iron loss.
                float net_torque = raw_torque - self->torque_baseline(rpm);

                self->_last_torque_raw     = raw_torque;   // keep for diagnostics
                self->_last_rpm            = rpm;
                self->_last_torque_percent = std::max(net_torque, 0.0f);
                self->_last_torque_limited = torque_limited;
                self->_last_warning        = alarm;

                vfd->_sync_dev_speed = (uint32_t)std::abs((int)act2);

                // Diagnostic: if torque reads exactly zero for a long run
                // while the spindle is turning, drive param 50.03 is most
                // likely not pointed at P.01.22, so 0x0005 is never being
                // populated. Warn once rather than silently goal-seeking
                // against a dead signal.
                if (act1 == 0 && act2 != 0) {
                    if (self->_zero_torque_polls < 200) {
                        self->_zero_torque_polls++;
                        if (self->_zero_torque_polls == 100) {
                            log_warn("CumarkProtocol: torque has read 0 for 100 polls while the spindle is turning -- check drive "
                                     "param 50.03 Act1 src = P.01.22, and 50.00 Fieldbus enable");
                        }
                    }
                } else if (act1 != 0) {
                    self->_zero_torque_polls = 0;
                }

                self->apply_adaptive_feed();

                if (fault || alarm) {
                    log_warn("VFD Has Fault or Warning");
                    return false;
                }
                return true;
            };
        }

        // All three framework polling hooks share the one block read above.
        VFDProtocol::response_parser CumarkProtocol::get_current_speed(ModbusCommand& data) {
            return fieldbus_block_read(data);
        }

        VFDProtocol::response_parser CumarkProtocol::get_current_direction(ModbusCommand& data) {
            return fieldbus_block_read(data);
        }

        VFDProtocol::response_parser CumarkProtocol::get_status_ok(ModbusCommand& data) {
            return fieldbus_block_read(data);
        }

        void CumarkProtocol::set_adaptive_feed(float goal_fraction) {
            // Clamp per policy: goal fraction max 0.9 (90% torque target --
            // tier 2's >=100% aggressive slowdown owns anything above
            // that). <= 0 disables goal-seeking (tier 3) only -- tiers 1/2
            // (hard stall, aggressive overtorque) stay active regardless.
            if (goal_fraction > 0.9f) {
                log_warn("CumarkProtocol: adaptive feed goal " << goal_fraction << " clamped to 0.9 (90% torque)");
                goal_fraction = 0.9f;
            }
            if (goal_fraction < 0.0f) {
                goal_fraction = 0.0f;
            }

            _adaptive_feed_goal_percent = goal_fraction * 100.0f;
            _goal_clamp_logged          = false;  // re-arm the clamp warning for this new goal

            if (_adaptive_feed_goal_percent > 0.0f) {
                // Capture whatever the operator already has dialed in right
                // now as the baseline, so enabling this doesn't yank the
                // override to some unrelated value.
                _baseline_override      = sys.f_override();
                _last_applied_override  = _baseline_override;
                _target_override_f      = float(_baseline_override);
                // Remember the goal as commanded by M52, so that if the
                // operator later turns the feed override dial we can
                // rescale the ACTIVE goal relative to it (see
                // apply_adaptive_feed) without losing what M52 asked for.
                _commanded_goal_percent = _adaptive_feed_goal_percent;
                _goal_scale             = 1.0f;
                log_info("CumarkProtocol: adaptive feed goal-seeking enabled, target torque = " << _adaptive_feed_goal_percent
                                                                                                  << "%, baseline override = "
                                                                                                  << int(_baseline_override) << "%");
            } else {
                log_info("CumarkProtocol: adaptive feed goal-seeking disabled (hard stall / overtorque tiers remain active)");
            }
        }

        // Shared apply/report/log helper for all three tiers.
        void CumarkProtocol::set_override(Percent target, bool is_hard_trigger) {
            Percent current = sys.f_override();
            if (target == current) {
                return;
            }
            // THREADING: this runs in the VFD task, pinned to
            // SUPPORT_TASK_CORE (core 0), while motion/planner code runs on
            // core 1. We must NOT call sys.set_f_override() or touch the
            // planner directly from here -- an earlier version did, and
            // plan_update_velocity_profile_parameters() walks and mutates
            // the planner block buffer while core 1 may be adding blocks
            // and the stepper ISR is consuming them, with no locking. That
            // is a real cross-core data race, made more likely the faster
            // we poll. Instead hand the change to the main loop via the
            // same event the pendant/UI override uses, which already does
            // set_f_override() + update_velocities() + gc_ovr_changed() in
            // the correct context. That handler takes an INCREMENT, and
            // clamps to FeedOverride::Max (200) / ::Min (10).
            int32_t increment = int32_t(target) - int32_t(current);
            // FeedOverride::Default is a magic "reset to 100%" value for
            // that handler, so avoid sending a delta of exactly +100.
            if (increment == FeedOverride::Default) {
                increment -= 1;
            }
            protocol_send_event(&feedOverrideEvent, reinterpret_cast<void*>(intptr_t(increment)));
            _last_applied_override = Percent(int32_t(current) + increment);
            if (is_hard_trigger) {
                log_warn("CumarkProtocol: torque limited/warning (drive-reported), feed override dropped to " << int(target) << "%");
            }
        }

        // --------------------------------------------------------------
        // Linear interpolation over a measured (rpm -> value) table, with
        // the end values held flat outside the measured range. Returns
        // fallback when no table is configured, so an uncalibrated machine
        // behaves exactly as before.
        // --------------------------------------------------------------
        static float interp_table(const std::vector<float>& xs, const std::vector<float>& ys, float x, float fallback) {
            const size_t n = xs.size();
            if (n == 0 || ys.size() != n) {
                return fallback;
            }
            if (x <= xs[0])     return ys[0];
            if (x >= xs[n - 1]) return ys[n - 1];
            for (size_t i = 1; i < n; ++i) {
                if (x <= xs[i]) {
                    const float span = xs[i] - xs[i - 1];
                    if (span <= 0.0f) return ys[i];
                    const float t = (x - xs[i - 1]) / span;
                    return ys[i - 1] + t * (ys[i] - ys[i - 1]);
                }
            }
            return ys[n - 1];
        }

        // Measured no-load torque reading at this speed. NEGATIVE by nature
        // -- see the note in the block-read parser. Zero if uncalibrated.
        float CumarkProtocol::torque_baseline(float rpm) const {
            return interp_table(_baseline_rpm, _baseline_pct, rpm, 0.0f);
        }

        // Measured NET torque (baseline already removed) at which the
        // spindle actually pulls out, as a percent of rated. This is a
        // measured table rather than a formula because no single power law
        // fits: the falloff steepens with speed as pull-out torque (which
        // falls as 1/f^2) overtakes torque capability (1/f). Measured here
        // as roughly 102% at 3000 rpm collapsing to under 5% at 18000.
        // Returns 100% if uncalibrated, i.e. no clamping.
        float CumarkProtocol::available_torque_percent(float rpm) const {
            return interp_table(_available_rpm, _available_pct, rpm, 100.0f);
        }

        void CumarkProtocol::apply_adaptive_feed() {
            // STATE GATE -- critical for correctness and safety.
            // Runs in the VFD task (core 0) every poll, independent of core 1.
            // Adaptive feed must only ACT while a program is actually cutting
            // (State::Cycle). Firing a feed-override event in any other state
            // -- tool-change macro, homing, jogging, idle -- pushes an
            // override change into the planner while core 1 may be building or
            // executing unrelated moves, corrupting planner state (seen as a
            // StoreProhibited crash + reboot during the pick_tool move of an
            // M6). It is also meaningless to regulate feed with no cutting
            // move in progress. Outside State::Cycle: do nothing, and reset
            // the timing base so dt is sane on the next real evaluation.
            if (!state_is(State::Cycle)) {
                _last_eval_ticks = 0;
                return;
            }
            Percent current = sys.f_override();

            // Elapsed time since the last evaluation, used to make the gains
            // poll-rate independent (see tier 2/3 below).
            TickType_t now  = xTaskGetTickCount();
            float      dt_s = 0.0f;
            if (_last_eval_ticks != 0) {
                dt_s = float((now - _last_eval_ticks) * portTICK_PERIOD_MS) / 1000.0f;
            }
            _last_eval_ticks = now;
            if (dt_s <= 0.0f || dt_s > 1.0f) {
                dt_s = 0.25f;  // first call, or a long gap (comms dropout) -- use a sane nominal
            }

            // NOTE: we deliberately do NOT try to detect operator feed-
            // override changes by reading sys.f_override() back here. We
            // drive the override through async events, so the live value
            // lags what we last commanded by a poll or two -- comparing the
            // two cannot distinguish "our own change still in flight" from
            // "operator turned the dial". An earlier version did that and
            // mis-attributed its own in-flight changes to the operator,
            // ratcheting the goal down into a death spiral that stopped the
            // feed under load and never recovered. Tier 3 below is now
            // self-contained: it tracks only its own float target and never
            // treats the read-back override as ground truth. (Respecting a
            // manual override during goal-seeking needs a reliable signal
            // from the override handler itself; that is future work.)

            // Absolute safety floor, except when the operator's own
            // baseline is already lower -- respect their lower choice
            // rather than forcing it up. Applies to all three tiers.
            Percent effective_floor = std::min(Percent(_adaptive_feed_floor_percent), _baseline_override);

            // ---- Tier 1: hard stall trigger -- ALWAYS active. ----
            if (_last_torque_limited || _last_warning) {
                set_override(effective_floor, true);
                return;
            }

            // ---- Tier 2: aggressive overtorque slowdown -- ALWAYS active. ----
            // Threshold TRACKS the measured torque ceiling. A fixed 100%
            // was unreachable above base speed -- this spindle pulls out at
            // 20% by 12000 rpm and 3% by 18000 -- so tier 2 was effectively
            // switched off exactly where it mattered most.
            const float t2_trip = _tier2_fraction * available_torque_percent(_last_rpm);
            if (_last_torque_percent >= t2_trip) {
                uint32_t rate_step = uint32_t(float(_adaptive_feed_aggressive_step) * dt_s + 0.5f);
                if (rate_step < 1) {
                    rate_step = 1;  // always make some progress toward the floor
                }
                Percent step = Percent(std::min(uint32_t(current > effective_floor ? current - effective_floor : 0), rate_step));
                Percent target = Percent(current - step);
                _target_override_f = float(target);  // keep accumulator in sync (see tier 1 note)
                set_override(target, false);
                return;
            }

            // ---- Tier 3: goal-seeking -- only when M52 has set a goal. ----
            if (_adaptive_feed_goal_percent <= 0.0f) {return;}  // disabled by M52 P0

            // REGIME GATE. Above this speed there is nothing worth
            // regulating: measured net available torque is 11.9% at 15000
            // and 4.6% at 18000, so the deadband alone would be a quarter
            // to two thirds of the entire goal. The torque and speed
            // estimates are also least trustworthy up here. Stop
            // REGULATING and leave protection to tiers 1 and 2. Full RPM
            // stays available -- we simply stop pretending to modulate it.
            if (_adaptive_max_rpm > 0.0f && _last_rpm > _adaptive_max_rpm) {
                return;
            }

            // Clamp the goal to something the spindle can actually hold at
            // this speed. Without it the loop chases an unreachable target
            // and rides the override to maximum, which is how a pull-out
            // begins.
            const float goal_cap = _goal_safety_fraction * available_torque_percent(_last_rpm);
            float effective_goal = std::min(_adaptive_feed_goal_percent, goal_cap);
            if (effective_goal < _adaptive_feed_goal_percent && !_goal_clamp_logged) {
                _goal_clamp_logged = true;
                log_warn("CumarkProtocol: adaptive goal " << _adaptive_feed_goal_percent << "% clamped to "
                         << effective_goal << "% -- unreachable at " << int(_last_rpm) << " rpm");
            }

            float error    = _last_torque_percent - effective_goal;
            float deadband = float(_adaptive_feed_deadband_percent);
            // Tier 3 seeks using its own float accumulator so sub-1% per-poll
            // steps are not truncated away. But reconcile it safely with the
            // real override each poll, so it can never run away from reality:
            //  - if the actual override is BELOW the accumulator, something
            //    outside tier 3 lowered it (a hard trigger, or the operator).
            //    Snap the accumulator down to match -- never fight a lower
            //    override, and never command a sudden jump back up.
            //  - if the actual override is far ABOVE the accumulator, re-sync
            //    up to it too (e.g. operator raised it, or first run).
            // This is a clamp, not a ratio, so it cannot feed back on itself
            // the way the old goal-rescaling did.
            if (_target_override_f <= 0.0f) {
                _target_override_f = float(current);
            }
            if (float(current) < _target_override_f) {
                _target_override_f = float(current);
            } else if (float(current) > _target_override_f + 1.5f) {
                _target_override_f = float(current);
            }
            float target_f = _target_override_f;

            // Gains are per SECOND, scaled by the measured interval, so the
            // closed-loop behaviour stays the same whatever poll_ms is set to.
            // Without this the controller effectively integrates at the poll
            // rate -- halving poll_ms would double its aggression.
            if (error > deadband) {
                // Above goal -- back off promptly, proportional to how far over.
                target_f = _target_override_f - _adaptive_feed_gain_down * (error - deadband) * dt_s;
            } else if (error < -deadband) {
                // Below goal -- recover cautiously, proportional to how far under.
                target_f = _target_override_f + _adaptive_feed_gain_up * (-error - deadband) * dt_s;
            }
            // else: within the deadband, hold steady.

            float   min_f  = float(_adaptive_feed_min_percent);
            float   max_f  = float(_adaptive_feed_max_percent);  // can be configured above 100 -- opt-in, not default
            // Clamp the FLOAT target, then remember it across polls. The
            // applied override is an integer (Percent), but each poll's
            // correction can be well under 1% -- at fast poll rates it
            // almost always is. If we rounded to int every poll the
            // fractional part would be discarded every time and the
            // override would never move (the "stuck at 50%" bug). So we
            // keep the accumulated target as a float in _target_override_f
            // and only round when handing it to set_override().
            target_f = std::max(min_f, std::min(max_f, target_f));
            target_f = std::max(target_f, float(effective_floor));
            _target_override_f = target_f;

            Percent target = Percent(target_f + 0.5f);  // round, don't truncate
            set_override(target, false);
        }

        VFDProtocol::response_parser CumarkProtocol::initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) {
            switch (index) {
                case -1:
                    data.tx_length = 6;
                    data.rx_length = 5;  // addr + func + byte_count + 1 register (2 bytes); the
                                        // framework adds 2 more for the CRC itself

                    data.msg[1] = 0x03;  // READ
                    data.msg[2] = 0x14;  // P20.00 Maximum speed: high byte = group 20 (0x14)
                    data.msg[3] = 0x00;  //                       low byte  = index 0
                    data.msg[4] = 0x00;  // Number of elements, high byte
                    data.msg[5] = 0x01;  // Number of elements, low byte

                    return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                        // Modbus 03H reply: [0]addr [1]func [2]byte_count [3]data_hi [4]data_lo
                        // (CRC follows at [5]/[6]). The first register therefore starts at
                        // index 3 -- same as fieldbus_block_read. Reading from [4]/[5]
                        // returns the low data byte OR'd with the CRC, which is why the
                        // reported value never matched the drive.
                        uint16_t value  = (response[3] << 8) | response[4];
                        auto     cumark = static_cast<CumarkProtocol*>(detail);
                        log_debug("Max Speed is: " << value);
                        //cumark->_maxSpeed = value;
                        cumark->updateRPM(vfd);
                        return true;
                    };
                    break;
                default:
                    break;
            }
            return nullptr;
        }

        void CumarkProtocol::updateRPM(VFDSpindle* vfd) {
            

            if (_minSpeed > _maxSpeed) {
                _minSpeed = _maxSpeed;
            }
            if (vfd->_speeds.size() == 0) {
                SpindleSpeed minRPM = _minSpeed;
                SpindleSpeed maxRPM = _maxSpeed;
                vfd->shelfSpeeds(minRPM, maxRPM);
            }
            vfd->setupSpeeds(_maxSpeed);
            vfd->_slop = 200;
        }


        namespace {
            SpindleFactory::DependentInstanceBuilder<VFDSpindle, CumarkProtocol> registration("Cumark");
        }
    }
}