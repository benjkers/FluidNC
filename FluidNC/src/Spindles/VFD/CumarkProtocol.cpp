#include "CumarkProtocol.h"
#include "../VFDSpindle.h"
#include "../../System.h"
#include "../../Config.h"
#include "../../GCode.h"
#include "../../Planner.h"
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

        VFDProtocol::response_parser CumarkProtocol::get_current_speed(ModbusCommand& data) {
            // NOTE: data length is excluding the CRC16 checksum.
            data.tx_length = 6;
            data.rx_length = 5;

            data.msg[1] = 0x03;
            data.msg[2] = 0x01;
            data.msg[3] = 0x00;  // Register 01.00 (Motor speed)
            data.msg[4] = 0x00;
            data.msg[5] = 0x01;

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                // NOTE: this fixes a pre-existing offset bug -- previously
                // read response[4]/response[5], but the Modbus RTU response
                // format is [addr][func][byte_count][data...], so the
                // first register's data starts at response[3], matching
                // the convention used in get_status_ok() below. This bug
                // predates the adaptive-feed work and isn't introduced by
                // it -- flagging it since it's directly adjacent to code
                // touched here.
                uint32_t RPM = (response[3] << 8) | response[4];

                // Store speed for synchronization
                vfd->_sync_dev_speed = RPM;
                return true;
            };
        }

        VFDProtocol::response_parser CumarkProtocol::get_status_ok(ModbusCommand& data) {
            // NOTE: data length is excluding the CRC16 checksum.
            data.tx_length = 6;
            data.rx_length = 11;  // addr + func + byte_count + 4 registers (8 bytes)

            // Read 4 CONSECUTIVE registers in one transaction, spanning
            // 06.00 (Status word1) through 06.03 (Speed control status
            // word) -- 06.01/06.02 are read too (unused) purely because
            // they sit in between and Modbus reads a contiguous block.
            // This merges what used to be two separate polls
            // (get_status_ok + get_current_direction) into one, which
            // halves this poll's contribution to the round-robin cadence:
            // the adaptive-feed check (driven by 06.03's torque-limit bit)
            // now runs every 2nd poll cycle instead of every 3rd.
            data.msg[1] = 0x03;   // Function code: Read Holding Register
            data.msg[2] = 0x06;   // Starting address high byte (06.00)
            data.msg[3] = 0x00;   // Starting address low byte
            data.msg[4] = 0x00;   // Number of registers high byte
            data.msg[5] = 0x04;   // Number of registers low byte (4 registers)

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                // response[3..4] = 06.00 Status word1, response[9..10] = 06.03 Speed control status word.
                uint16_t status_word1  = (response[3] << 8) | response[4];
                uint16_t status_word4  = (response[9] << 8) | response[10];

                // Bit 1 to determine direction: 0 = Forward, 1 = Reverse
                bool is_reverse = (status_word4 & (1 << 1)) != 0;
                (void)is_reverse;  // not currently acted on

                // Check Bit 1 (Drive Fault) and Bit 2 (Drive Warning)
                bool has_fault   = (status_word1 & (1 << 1)) != 0;
                bool has_warning = (status_word1 & (1 << 2)) != 0;

                // Bit 13 of 06.03: "Torque limit" -- the drive is already
                // clamping torque, i.e. as close to a stall as the drive
                // itself will allow. Both this and the warning bit above
                // drive the adaptive feed control (M52) as hard safety
                // nets alongside the proportional torque% signal.
                bool torque_limited = (status_word4 & (1 << 13)) != 0;
                auto* self               = static_cast<CumarkProtocol*>(detail);
                self->_last_torque_limited = torque_limited;
                self->_last_warning        = has_warning;
                self->apply_adaptive_feed();

                // Return false if either a fault or warning is present
                if (has_fault || has_warning) {
                    log_warn("VFD Has Fault or Warning")
                    return false;
                }

                return true;
            };
        }

        VFDProtocol::response_parser CumarkProtocol::get_current_direction(ModbusCommand& data) {
            // Repurposed to read 01.22 Motor torque (register 278, 0.1%
            // units) for the adaptive feed control's proportional scaling --
            // see the big comment in CumarkProtocol.h for why this needs
            // its own poll slot rather than being merged with another read.
            data.tx_length = 6;
            data.rx_length = 5;

            data.msg[1] = 0x03;
            data.msg[2] = 0x01;  // register 278 = 0x0116, high byte
            data.msg[3] = 0x16;  // low byte
            data.msg[4] = 0x00;
            data.msg[5] = 0x01;

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                // Signed: torque can read negative during regenerative
                // deceleration. We only care about magnitude here.
                int16_t raw = (int16_t)((response[3] << 8) | response[4]);

                auto* self               = static_cast<CumarkProtocol*>(detail);
                self->_last_torque_percent = std::abs(float(raw) / 10.0f);
                self->apply_adaptive_feed();

                return true;
            };
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

            if (_adaptive_feed_goal_percent > 0.0f) {
                // Capture whatever the operator already has dialed in right
                // now as the baseline, so enabling this doesn't yank the
                // override to some unrelated value.
                _baseline_override     = sys.f_override();
                _last_applied_override = _baseline_override;
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
            sys.set_f_override(target);
            plan_update_velocity_profile_parameters();  // force already-buffered blocks to recompute at the new override
            _last_applied_override = target;
            gc_ovr_changed();  // report the new override immediately rather than waiting for the next status poll
            if (is_hard_trigger) {
                log_warn("CumarkProtocol: torque limited/warning (drive-reported), feed override dropped to " << int(target) << "%");
            }
        }

        void CumarkProtocol::apply_adaptive_feed() {
            Percent current = sys.f_override();

            // If the override differs from what we last wrote ourselves,
            // the operator changed it via the pendant/UI in the meantime --
            // adopt it as the new baseline rather than fighting it. This
            // applies regardless of which tier ends up acting below.
            if (current != _last_applied_override) {
                _baseline_override = current;
                log_debug("CumarkProtocol adaptive feed: operator changed override to " << int(current) << "%, adopting as new baseline");
            }

            // Absolute safety floor, except when the operator's own
            // baseline is already lower -- respect their lower choice
            // rather than forcing it up. Applies to all three tiers.
            Percent effective_floor = std::min(Percent(_adaptive_feed_floor_percent), _baseline_override);

            // ---- Tier 1: hard stall trigger -- ALWAYS active. ----
            if (_last_torque_limited || _last_warning) {
                log_debug("CumarkProtocol adaptive feed: TIER1 torque=" << _last_torque_percent << "% limited="
                                                                         << (_last_torque_limited ? "yes" : "no") << " warning="
                                                                         << (_last_warning ? "yes" : "no") << " -> floor "
                                                                         << int(effective_floor) << "%");
                set_override(effective_floor, true);
                return;
            }

            // ---- Tier 2: aggressive overtorque slowdown -- ALWAYS active. ----
            if (_last_torque_percent >= 95.0f) {
                Percent step   = Percent(std::min(uint32_t(current > effective_floor ? current - effective_floor : 0),
                                                   _adaptive_feed_aggressive_step));
                Percent target = Percent(current - step);
                log_debug("CumarkProtocol adaptive feed: TIER2 torque=" << _last_torque_percent << "% (>=95%) override " << int(current)
                                                                         << "% -> " << int(target) << "%");
                set_override(target, false);
                return;
            }

            // ---- Tier 3: goal-seeking -- only when M52 has set a goal. ----
            if (_adaptive_feed_goal_percent <= 0.0f) {
                log_debug("CumarkProtocol adaptive feed: TIER3 disabled (torque=" << _last_torque_percent << "%, ignored)");
                return;
            }

            float error    = _last_torque_percent - _adaptive_feed_goal_percent;
            float deadband = float(_adaptive_feed_deadband_percent);
            float target_f = float(current);

            if (error > deadband) {
                // Above goal -- back off promptly, proportional to how far over.
                target_f = float(current) - _adaptive_feed_gain_down * (error - deadband);
            } else if (error < -deadband) {
                // Below goal -- recover cautiously, proportional to how far under.
                target_f = float(current) + _adaptive_feed_gain_up * (-error - deadband);
            }
            // else: within the deadband, hold steady.

            float   min_f  = float(_adaptive_feed_min_percent);
            float   max_f  = float(_adaptive_feed_max_percent);  // can be configured above 100 -- opt-in, not default
            Percent target = Percent(std::max(min_f, std::min(max_f, target_f)));
            target          = std::max(target, effective_floor);

            log_debug("CumarkProtocol adaptive feed: TIER3 torque=" << _last_torque_percent << "% goal=" << _adaptive_feed_goal_percent
                                                                     << "% error=" << error << " override " << int(current) << "% -> "
                                                                     << int(target) << "%");
            set_override(target, false);
        }

        VFDProtocol::response_parser CumarkProtocol::initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) {
            switch (index) {
                case -1:
                    data.tx_length = 6;
                    data.rx_length = 5;

                    data.msg[1] = 0x03;  // READ
                    data.msg[2] = 0x14;  // Register address, high byte (speed in RPM)
                    data.msg[3] = 0x00;  // Register address, low byte (speed in RPM)
                    data.msg[4] = 0x00;  // Number of elements, high byte
                    data.msg[5] = 0x01;  // Number of elements, low byte 

                    return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                        uint16_t value = (response[4] << 8) | response[5];
                        auto cumark           = static_cast<CumarkProtocol*>(detail);
                        log_debug("Max Speed is: " << (value));
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
                // Convert from Frequency in centiHz (the divisor of 100) to RPM (the factor of 60)
                SpindleSpeed minRPM = _minSpeed;
                SpindleSpeed maxRPM = _maxSpeed;
                vfd->shelfSpeeds(minRPM, maxRPM);
            }
            vfd->setupSpeeds(_maxSpeed);
            vfd->_slop = std::max(_maxSpeed/40, 1);
        }


        namespace {
            SpindleFactory::DependentInstanceBuilder<VFDSpindle, CumarkProtocol> registration("Cumark");
        }
    }
}
