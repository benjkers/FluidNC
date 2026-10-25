#include "CumarkProtocol.h"
#include "../VFDSpindle.h"
#include "../../System.h"
#include "../../Config.h"
#include "../../GCode.h"
#include "../../MotionControl.h"  // probing
#include "../../Protocol.h"       // protocol_send_event, feedOverrideEvent
#include <algorithm>
#include <cmath>

namespace Spindles {
    namespace VFD {
        void CumarkProtocol::direction_command(SpindleState mode, ModbusCommand& data) {
            bool was_ccw = _is_Ccw;
            _is_Ccw = (mode == SpindleState::Ccw);

            if (mode == SpindleState::Disable) {
                _spindle_enabled = false;
                data.tx_length = 6;
                data.rx_length = 6;
                data.msg[1] = 0x06;  // Write Single Register
                data.msg[2] = 0x00;
                data.msg[3] = 0x01;  // register 0x0001
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop
                log_info("Spindle Disabled");
                return;
            }

            bool direction_changed = (_is_Ccw != was_ccw);

            if (direction_changed) {
                // This drive will not reverse on a live sign change -- it needs
                // a genuine stop, then a fresh start with the corrected sign.
                // Only one Modbus message can be built per callback, so this
                // one is the STOP and the restart is queued; the restart
                // re-enters with direction_changed false.
                data.tx_length = 6;
                data.rx_length = 6;
                data.msg[1] = 0x06;
                data.msg[2] = 0x00;
                data.msg[3] = 0x01;
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop
                _spindle_enabled = false;
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

            // Start + signed speed in ONE transaction. Writing them together
            // keeps this off the queued actionSetSpeed path, and so clear of
            // prepareSetSpeedCommand()'s "don't resend the same speed twice"
            // guard, which knows nothing about direction and silently
            // swallowed a same-RPM reversal.
            _spindle_enabled = true;
            int32_t effective_speed = _is_Ccw ? -static_cast<int32_t>(last_speed) : static_cast<int32_t>(last_speed);

            data.tx_length = 11;
            data.rx_length = 6;   // request echoed, no data

            data.msg[1] = 0x10;  // Write Multiple Registers
            data.msg[2] = 0x00;
            data.msg[3] = 0x01;  // starting register 0x0001
            data.msg[4] = 0x00;
            data.msg[5] = 0x02;  // 2 registers: control word + speed
            data.msg[6] = 0x04;  // byte count
            data.msg[7] = 0x08;
            data.msg[8] = 0x82;  // control word: Start
            data.msg[9]  = uint8_t(effective_speed >> 8);
            data.msg[10] = uint8_t(effective_speed & 0xFF);

            log_info("Spindle Enabled in " << (_is_Ccw ? "CCW" : "CW") << " mode (combined start+speed=" << effective_speed << ")");
        }

        void CumarkProtocol::set_speed_command(uint32_t dev_speed, ModbusCommand& data){
            last_speed = dev_speed;
            int32_t effective_speed = _is_Ccw ? -static_cast<int32_t>(dev_speed) : dev_speed;

            log_info("set_speed_command called. Speed: " << dev_speed << " | Effective Speed: " << effective_speed);
            data.tx_length = 6;
            data.rx_length = 6;

            data.msg[1] = 0x06;
            data.msg[2] = 0x00;
            data.msg[3] = 0x02;  // register 0x0002, speed reference
            data.msg[4] = effective_speed >> 8;
            data.msg[5] = effective_speed & 0xFF;
        }

        //   0x0004  status word: bit 7 Alarm, bit 9 Torque limited,
        //                       bit 14 Direction reverse, bit 15 Fault
        //   0x0005  torque, 0.1% units -- REQUIRES drive param 50.03 = P.01.22
        //   0x0006  speed              -- REQUIRES drive param 50.04 = P.01.00
        VFDProtocol::response_parser CumarkProtocol::fieldbus_block_read(ModbusCommand& data) {
            data.tx_length = 6;
            data.rx_length = 9;

            data.msg[1] = 0x03;  // Read Holding Registers
            data.msg[2] = 0x00;
            data.msg[3] = 0x04;  // start 0x0004
            data.msg[4] = 0x00;
            data.msg[5] = 0x03;  // 3 registers

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                uint16_t status = (uint16_t)((response[3] << 8) | response[4]);   // 0x0004
                int16_t  act1   = (int16_t)((response[5] << 8) | response[6]);    // 0x0005
                int16_t  act2   = (int16_t)((response[7] << 8) | response[8]);    // 0x0006

                bool fault          = (status & (1 << 15)) != 0;
                bool alarm          = (status & (1 << 7)) != 0;
                bool torque_limited = (status & (1 << 9)) != 0;
                bool is_reverse     = (status & (1 << 14)) != 0;
                (void)is_reverse;

                auto* self = static_cast<CumarkProtocol*>(detail);

                // SIGNED. Do not abs(): negative means driven rather than
                // loaded, so abs() invents load at idle and inverts the
                // response during a pull-out.
                float raw_torque = float(act1) / 10.0f;
                float rpm        = float(std::abs((int)act2));
                float net_torque = raw_torque - self->torque_offset(rpm);

                self->_last_torque_raw     = raw_torque;
                self->_last_rpm            = rpm;
                self->_last_torque_percent = std::max(net_torque, 0.0f);
                self->_last_torque_limited = torque_limited;
                self->_last_warning        = alarm;

                vfd->_sync_dev_speed = (uint32_t)std::abs((int)act2);

                // The speed-sync wait in VFDSpindle::setState BLOCKS on this
                // queue and only re-reads _sync_dev_speed after
                // xQueueReceive returns, so without a send it times out after
                // 3 s and alarms. Temporary because the member is volatile;
                // timeout 0 so this task never blocks.
                uint32_t sync_speed = (uint32_t)std::abs((int)act2);
                xQueueSend(VFD::VFDProtocol::vfd_speed_queue, &sync_speed, 0);

                // Torque stuck at exactly zero while turning means 50.03 is
                // not pointed at P.01.22. Warn once rather than goal-seek
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

        // Sharing one read across all three hooks is safe because Cumark uses
        // use_delay_settings() == true, so setState()'s speed-sync path is
        // never taken.
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
            // Caps at 0.9; tier 2 owns anything above. <= 0 disables tier 3
            // only, tiers 1/2 stay active.
            if (goal_fraction > 0.9f) {
                log_warn("CumarkProtocol: adaptive feed goal " << goal_fraction << " clamped to 0.9 (90% torque)");
                goal_fraction = 0.9f;
            }
            if (goal_fraction < 0.0f) {
                goal_fraction = 0.0f;
            }

            _goal_pct          = goal_fraction * 100.0f;
            _goal_clamp_logged = false;

            if (_goal_pct > 0.0f) {
                // Adopt what the operator already has dialled in, so enabling
                // this does not yank the override somewhere unrelated.
                _baseline_override  = sys.f_override();
                _target_override_f  = float(_baseline_override);
                _prev_read_override = _baseline_override;
                _last_increment     = 0.0f;
                log_info("CumarkProtocol: adaptive feed goal-seeking enabled, target torque = " << _goal_pct
                                                                                                << "%, baseline override = "
                                                                                                << int(_baseline_override) << "%");
            } else {
                log_info("CumarkProtocol: adaptive feed goal-seeking disabled (hard stall / overtorque tiers remain active)");
            }
        }

        void CumarkProtocol::set_override(Percent target, bool is_hard_trigger) {
            Percent current = sys.f_override();
            if (target == current) {
                _last_increment = 0.0f;  // nothing sent, so nothing to explain
                return;
            }
            // Do NOT call sys.set_f_override() or touch the planner here: this
            // is the VFD task on core 0 and plan_update_velocity_profile_
            // parameters() mutates the block buffer while core 1 adds blocks
            // and the stepper ISR consumes them, unlocked. Go through the same
            // event the pendant uses, which takes an INCREMENT and clamps to
            // FeedOverride::Max/Min.
            int32_t increment = int32_t(target) - int32_t(current);
            // FeedOverride::Default is that handler's magic "reset to 100%".
            if (increment == FeedOverride::Default) {
                increment -= 1;
            }
            protocol_send_event(&feedOverrideEvent, reinterpret_cast<void*>(intptr_t(increment)));
            // Record what we sent, AFTER the Default fix-up, so the dial
            // tracking next poll can account for it exactly.
            _last_increment = float(increment);
            if (is_hard_trigger) {
                log_warn("CumarkProtocol: torque limited/warning (drive-reported), feed override dropped to " << int(target) << "%");
            }
        }

        // Ends held flat. Returns fallback when no table is configured, so an
        // uncalibrated machine behaves as it did before.
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

        float CumarkProtocol::torque_offset(float rpm) const {
            return interp_table(_torque_offset_rpm, _torque_offset_pct, rpm, 0.0f);
        }

        float CumarkProtocol::pullout_torque_pct(float rpm) const {
            return interp_table(_pullout_rpm, _pullout_pct, rpm, 100.0f);
        }

        void CumarkProtocol::apply_adaptive_feed() {
            // Outside State::Cycle a feed-override event reaches the planner
            // while core 1 may be building unrelated moves -- a
            // StoreProhibited crash during an M6 pick_tool move. Spindle off
            // means nothing is cutting, so no tier has anything to regulate;
            // that covers probing, tool setting and every other spindle-off
            // move in one test. probing also catches a probe with the spindle
            // turning.
            if (!state_is(State::Cycle) || !_spindle_enabled || last_speed == 0 || probing) {
                _last_eval_ticks = 0;
                return;
            }
            Percent current = sys.f_override();

            TickType_t now  = xTaskGetTickCount();
            float      dt_s = 0.0f;
            if (_last_eval_ticks != 0) {
                dt_s = float((now - _last_eval_ticks) * portTICK_PERIOD_MS) / 1000.0f;
            }
            _last_eval_ticks = now;
            if (dt_s <= 0.0f || dt_s > 1.0f) {
                dt_s = 0.25f;  // first call, or a comms dropout
            }

            // LAYER 0. h = feed/(rpm*teeth), so scaling feed by the factor the
            // speed fell by holds h exactly -- rpm_actual cancels. An identity,
            // not a loop. It holds torque too, so tier 3 never sees a droop.
            // Applied at the OUTPUT, bottom of this function; compounding it
            // into _target_override_f walked the target away from the dial.
            //
            // Both speeds above 500: what is left after the spindle gate is
            // spin-up (not a droop, nothing cutting) and a collapse to near
            // zero, which is already tier 2's. The 1.0 clamp stops a noisy
            // over-read RAISING feed. No settle window -- during a ramp the
            // chip load genuinely IS high, so cutting feed is correct.
            float chip = 1.0f;
            if (float(last_speed) >= 500.0f && _last_rpm >= 500.0f) {
                chip = std::max(0.5f, std::min(1.0f, _last_rpm / float(last_speed)));
            }

            // OPERATOR DIAL, from the delta. Whatever the read-back moved that
            // our own increment does not account for is the dial. Exact when
            // the event lands within a poll; a slower one only slows our ramp.
            if (_target_override_f <= 0.0f) {
                _target_override_f = float(current) / chip;
                _baseline_override = Percent(_target_override_f + 0.5f);
            } else {
                const float unexplained = float(current) - float(_prev_read_override) - _last_increment;
                if (fabsf(unexplained) >= 1.0f) {
                    _target_override_f += unexplained / chip;
                    const float b = float(_baseline_override) + unexplained / chip;
                    _baseline_override = Percent(std::max(float(FeedOverride::Min),
                                                          std::min(float(FeedOverride::Max), b)) + 0.5f);
                }
            }
            _prev_read_override = current;
            _last_increment     = 0.0f;

            // Respect a dial already below the floor.
            Percent effective_floor = std::min(Percent(_protect_floor_pct), _baseline_override);
            float   target_f        = _target_override_f;

            // ---- Tier 1 ----
            if (_last_torque_limited || _last_warning) {
                // Both protection tiers sync the target. Without it the target
                // keeps its pre-stall value while the override sits at the
                // floor, and the poll after release jumps the feed back to it.
                _target_override_f = float(effective_floor);
                set_override(Percent(float(effective_floor) * chip + 0.5f), true);
                return;
            }

            // ---- Tier 2 ----
            // Tracks the measured curve: a fixed 100% is unreachable above
            // base speed, so tier 2 was off where it mattered most.
            const float t2_trip = _pullout_trip_fraction * pullout_torque_pct(_last_rpm);
            if (_last_torque_percent >= t2_trip) {
                const float step = std::max(float(_protect_ramp_pct_per_sec) * dt_s, 1.0f);
                const float t    = std::max(float(effective_floor), float(current) / chip - step);
                _target_override_f = t;
                set_override(Percent(t * chip + 0.5f), false);
                return;
            }

            // ---- Tier 3. The gates below skip the LAW, never the apply:
            // layer 0 still has to reach the output, with or without M52. ----
            if (_goal_pct > 0.0f && (_goal_max_rpm <= 0.0f || _last_rpm <= _goal_max_rpm)) {
                // Clamp to what the spindle can hold at this speed, or the
                // loop chases an unreachable target and rides the override to
                // maximum.
                const float goal_cap = _pullout_goal_fraction * pullout_torque_pct(_last_rpm);
                float effective_goal = std::min(_goal_pct, goal_cap);
                if (effective_goal < _goal_pct && !_goal_clamp_logged) {
                    _goal_clamp_logged = true;
                    log_warn("CumarkProtocol: adaptive goal " << _goal_pct << "% clamped to "
                             << effective_goal << "% -- unreachable at " << int(_last_rpm) << " rpm");
                }

                // _last_torque_percent is max(net,0), so it reads zero in air
                // and a ratio against that slams the override to the ceiling.
                const float error = _last_torque_percent - effective_goal;
                if (_last_torque_percent >= std::max(1.0f, 0.30f * effective_goal) &&
                    fabsf(error) > float(_goal_deadband_pct)) {
                    // load ~ override^n, so the override that lands the
                    // measured load on the goal is that ratio raised to 1/n.
                    // chip cancels out of the ratio, so this works unchanged
                    // in chip-free space. No accumulated state, no wind-up.
                    float dest = target_f * powf(effective_goal / _last_torque_percent, 1.0f / _load_exponent);
                    dest = std::max(float(_goal_min_pct), std::min(float(_goal_max_pct), dest));
                    const float lim = (dest < target_f ? _goal_slew_down : _goal_slew_up) * dt_s;
                    target_f += std::max(-lim, std::min(lim, dest - target_f));
                }
                target_f = std::max(float(_goal_min_pct), std::min(float(_goal_max_pct), target_f));
            }

            target_f = std::max(float(effective_floor), target_f);
            _target_override_f = target_f;
            // chip can take the COMMANDED override below tier 3's minimum.
            // That is layer 0 doing its job, not tier 3 giving up.
            set_override(Percent(target_f * chip + 0.5f), false);
        }

        VFDProtocol::response_parser CumarkProtocol::initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) {
            switch (index) {
                case -1:
                    data.tx_length = 6;
                    data.rx_length = 5;  // framework adds 2 more for the CRC

                    data.msg[1] = 0x03;  // READ
                    data.msg[2] = 0x14;  // P20.00 Maximum speed: group 20
                    data.msg[3] = 0x00;  //                       index 0
                    data.msg[4] = 0x00;
                    data.msg[5] = 0x01;  // 1 element

                    return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                        // First register is at [3], as in fieldbus_block_read.
                        // Reading [4]/[5] returns the low byte OR'd with the
                        // CRC, which is why the value never matched the drive.
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
            vfd->_slop = _speed_tolerance_rpm;
        }

        namespace {
            SpindleFactory::DependentInstanceBuilder<VFDSpindle, CumarkProtocol> registration("Cumark");
        }
    }
}