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

            data.tx_length = 6;
            data.rx_length = 6;

            data.msg[1] = 0x06;  // Function code for writing a single register
            data.msg[2] = 0x00;  // Register address high byte 
            data.msg[3] = 0x01;  // Register address low byte 

            if (mode == SpindleState::Disable) {
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop command
                log_info("Spindle Disabled");
                return;
            }

            bool direction_changed = (_is_Ccw != was_ccw);

            if (direction_changed) {
                // This drive does NOT appear to honor a live sign change on
                // the speed register while already running -- it needs to
                // see a genuine stop, then a fresh speed write with the
                // corrected sign, then a fresh start, to actually reverse.
                // (An earlier version of this fix only re-sent the speed
                // value, which turned out not to be enough in practice.)
                //
                // This callback's own output is the STOP command; the
                // corrected-sign speed and the restart are queued as two
                // separate follow-up transactions, since only one Modbus
                // message can be built per callback invocation.
                data.msg[4] = 0x08;
                data.msg[5] = 0x81;  // Stop
                log_warn("CumarkProtocol: direction changed to " << (_is_Ccw ? "CCW" : "CW")
                                                                   << " -- stopping before reversing (queuing speed + restart)");

                if (vfd_cmd_queue) {
                    VFDaction speed_action;
                    speed_action.action   = actionSetSpeed;
                    speed_action.arg      = last_speed;
                    speed_action.critical = false;
                    if (xQueueSend(vfd_cmd_queue, &speed_action, 0) != pdTRUE) {
                        log_warn("CumarkProtocol: VFD queue full, could not queue corrected-direction speed resend");
                    }

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

            data.msg[4] = 0x08;
            data.msg[5] = 0x82;  // Enable command (Start Drive)
            log_info("Spindle Enabled in " << (_is_Ccw ? "CCW" : "CW") << " mode");
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

        void CumarkProtocol::set_adaptive_feed(bool enable) {
            _adaptive_feed_enabled = enable;
            if (enable) {
                // Capture whatever the operator already has dialed in right
                // now as the baseline, so enabling this doesn't yank the
                // override to some unrelated value.
                _baseline_override     = sys.f_override();
                _last_applied_override = _baseline_override;
                log_info("CumarkProtocol: adaptive feed enabled, baseline override = " << int(_baseline_override) << "%");
            } else {
                log_info("CumarkProtocol: adaptive feed disabled");
            }
        }

        void CumarkProtocol::apply_adaptive_feed() {
            if (!_adaptive_feed_enabled) {
                return;
            }

            Percent current = sys.f_override();

            // If the override differs from what we last wrote ourselves,
            // the operator changed it via the pendant/UI in the meantime --
            // adopt it as the new baseline rather than fighting it.
            if (current != _last_applied_override) {
                _baseline_override = current;
            }

            // Absolute safety floor, except when the operator's own
            // baseline is already lower -- respect their lower choice
            // rather than forcing it up.
            Percent effective_floor = std::min(Percent(_adaptive_feed_floor_percent), _baseline_override);

            Percent target;
            bool    hard_trigger = _last_torque_limited || _last_warning || _last_torque_percent >= float(_adaptive_feed_limit_percent);

            if (hard_trigger) {
                target = effective_floor;
            } else if (_last_torque_percent <= float(_adaptive_feed_warn_percent)) {
                target = _baseline_override;
            } else {
                // Linear interpolation between warn% (-> baseline) and
                // limit% (-> effective_floor).
                float span   = float(_adaptive_feed_limit_percent) - float(_adaptive_feed_warn_percent);
                float frac   = (_last_torque_percent - float(_adaptive_feed_warn_percent)) / span;
                float scaled = float(_baseline_override) - frac * (float(_baseline_override) - float(effective_floor));
                target       = Percent(scaled);
            }

            Percent applied = current;
            if (target < current) {
                // React immediately when backing off -- don't wait for a ramp.
                applied = target;
            } else if (target > current) {
                // Ramp up gradually on recovery, to avoid snapping straight
                // back into the load that just triggered the throttle.
                applied = Percent(std::min(uint32_t(target), uint32_t(current) + _adaptive_feed_recover_step));
            }


            if (applied != current) {
                sys.set_f_override(applied);
                plan_update_velocity_profile_parameters();  // force already-buffered blocks to recompute at the new override
                _last_applied_override = applied;
                gc_ovr_changed();  // report the new override immediately rather than waiting for the next status poll
                if (hard_trigger) {
                    log_warn("CumarkProtocol: torque limited/warning (drive-reported), feed override dropped to " << int(applied) << "%");
                }
            }
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
