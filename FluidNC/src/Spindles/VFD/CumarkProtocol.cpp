#include "CumarkProtocol.h"
#include "../VFDSpindle.h"
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
            } else {
                data.msg[4] = 0x08;
                data.msg[5] = 0x82;  // Enable command (Start Drive)
                log_info("Spindle Enabled in " << (_is_Ccw ? "CCW" : "CW") << " mode");
                // Re-send speed if direction has changed without speed command
                if (_is_Ccw != was_ccw) {
                    log_debug("Direction changed. Re-sending speed with updated direction.");
                    set_speed_command(last_speed, data);  // Re-send last speed with new direction
                }
            }
        }

        void CumarkProtocol::set_speed_command(uint32_t dev_speed, ModbusCommand& data){
            last_speed = dev_speed;  // Store the current speed for future direction changes
            int32_t effective_speed = _is_Ccw ? -static_cast<int32_t>(dev_speed) : dev_speed;

            log_debug("set_speed_command called. Speed: " << dev_speed << " | Effective Speed: " << effective_speed);
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

            // data.msg[0] is omitted (modbus address is filled in later)
            data.msg[1] = 0x03;
            data.msg[2] = 0x01;
            data.msg[3] = 0x00;  // Output frequency
            data.msg[4] = 0x00;
            data.msg[5] = 0x01;

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                uint32_t RPM = (response[4] << 8) | response[5];

                // Store speed for synchronization
                vfd->_sync_dev_speed = RPM;
                return true;
            };
        }

        VFDProtocol::response_parser CumarkProtocol::get_status_ok(ModbusCommand& data) {
            // NOTE: data length is excluding the CRC16 checksum.
            data.tx_length = 6;
            data.rx_length = 5;

            // Modbus command to read register 06.00 (Status Word 1)
            data.msg[1] = 0x03;   // Function code: Read Holding Register
            data.msg[2] = 0x06;   // Starting address high byte
            data.msg[3] = 0x00;   // Starting address low byte
            data.msg[4] = 0x00;   // Number of registers high byte
            data.msg[5] = 0x01;   // Number of registers low byte (1 register)

            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                // Extract the 16-bit Status Word 1 from the response (response[3] and response[4])
                uint16_t status_word = (response[3] << 8) | response[4];

                // Check Bit 1 (Drive Fault) and Bit 2 (Drive Warning)
                bool has_fault = (status_word & (1 << 1)) != 0;
                bool has_warning = (status_word & (1 << 2)) != 0;

                // Return false if either a fault or warning is present
                if (has_fault || has_warning) {
                    log_warn("VFD Has Fault or Warning")
                    return false;
                }

                return true;
            };
        }


        VFDProtocol::response_parser CumarkProtocol::get_current_direction(ModbusCommand& data) {
            data.tx_length = 6;
            data.rx_length = 5;
            // read speed status word
            data.msg[1] = 0x03;
            data.msg[2] = 0x06;
            data.msg[3] = 0x03;
            data.msg[4] = 0x00;
            data.msg[5] = 0x01;

            
           return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                // Extract the 16-bit register value from the response (response[3] and response[4])
                uint16_t status_word = (response[3] << 8) | response[4];

                // Check bit 1 to determine direction: 0 = Forward, 1 = Reverse
                bool is_reverse = (status_word & (1 << 1)) != 0;
                // what to do with now?

                return true;
           };
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
                        log_debug("Max Speed is: " << (value))
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
