#include "CumarkProtocol.h"
#include "../VFDSpindle.h"
#include <algorithm>
#include "System.h"

namespace Spindles {
    namespace VFD {

        // --- Optimization: Smart Polling Logic ---
        void CumarkProtocol::smart_poll_request(ModbusCommand& data) {
            uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
            if (!_is_data_initialized || (now - _last_poll_ms >= 50)) {
                data.tx_length = 6;
                data.rx_length = 49; 
                data.msg[1] = 0x03; 
                data.msg[2] = 0x01; data.msg[3] = 0x00; 
                data.msg[4] = 0x00; data.msg[5] = 0x17; 
                _last_poll_ms = now;
            } else {
                data.tx_length = 0; 
            }
        }

        // --- Static Parser Callback (Avoids Lambda/Pointer mismatch) ---
        bool CumarkProtocol::response_parser_callback(const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) {
            auto cumark = static_cast<CumarkProtocol*>(detail);
            
            if (response != nullptr) {
                cumark->_cached_speed = (response[3] << 8) | response[4];
                cumark->_cached_status = (response[15] << 8) | response[16];
                cumark->_cached_torque = (response[47] << 8) | response[48];
                cumark->_is_data_initialized = true;
                cumark->adjust_feed_override();
            }
            vfd->_sync_dev_speed = cumark->_cached_speed;
            return true;
        }

        // --- Logic: User-Aware Hysteresis ---
        void CumarkProtocol::adjust_feed_override() {
            if (!_is_data_initialized) return;

            Percent current_sys_override = sys.f_override();

            // Detect if user manually adjusted the slider
            if (current_sys_override != _last_sys_override) {
                _user_target_override = current_sys_override;
                _last_sys_override = current_sys_override;
            }

            int16_t current_val = (int16_t)current_sys_override;
            int16_t target_val = (int16_t)_user_target_override;

            // 60% Torque -> Slow down
            if (_cached_torque > 600) { 
                if (current_val > 50) { 
                    Percent new_val = (Percent)(current_val - 10);
                    sys.set_f_override(new_val);
                    _last_sys_override = new_val;
                }
            } 
            // 50% Torque -> Speed up back to user target
            else if (_cached_torque < 500) {
                if (current_val < target_val) {
                    Percent new_val = (Percent)(current_val + 10);
                    sys.set_f_override(new_val);
                    _last_sys_override = new_val;
                }
            }
        }

        // --- Interface Getters ---
        VFDProtocol::response_parser CumarkProtocol::get_current_speed(ModbusCommand& data) {
            smart_poll_request(data);
            return &CumarkProtocol::response_parser_callback;
        }

        VFDProtocol::response_parser CumarkProtocol::get_current_direction(ModbusCommand& data) {
            smart_poll_request(data);
            return &CumarkProtocol::response_parser_callback;
        }

        VFDProtocol::response_parser CumarkProtocol::get_status_ok(ModbusCommand& data) {
            smart_poll_request(data);
            return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                response_parser_callback(response, vfd, detail);
                auto cumark = static_cast<CumarkProtocol*>(detail);
                return (cumark->_cached_status & 0x06) == 0;
            };
        }

        // --- Original Control Functions ---
        void CumarkProtocol::direction_command(SpindleState mode, ModbusCommand& data) {
            bool was_ccw = _is_Ccw;
            _is_Ccw = (mode == SpindleState::Ccw);
            data.tx_length = 6; data.rx_length = 6;
            data.msg[1] = 0x06; data.msg[2] = 0x00; data.msg[3] = 0x01;
            data.msg[4] = 0x08; data.msg[5] = (mode == SpindleState::Disable) ? 0x81 : 0x82;
        }

        void CumarkProtocol::set_speed_command(uint32_t rpm, ModbusCommand& data) {
            data.tx_length = 6; data.rx_length = 6;
            data.msg[1] = 0x06; data.msg[2] = 0x00; data.msg[3] = 0x02;
            data.msg[4] = (rpm >> 8) & 0xFF; data.msg[5] = rpm & 0xFF;
        }

        void CumarkProtocol::updateRPM(VFDSpindle* vfd) {
            if (_minSpeed > _maxSpeed) _minSpeed = _maxSpeed;
            if (vfd->_speeds.size() == 0) vfd->shelfSpeeds(_minSpeed, _maxSpeed);
            vfd->setupSpeeds(_maxSpeed);
            vfd->_slop = std::max(_maxSpeed/40, 1);
        }

        VFDProtocol::response_parser CumarkProtocol::initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) {
            if (index == 0) {
                data.tx_length = 6; data.rx_length = 6;
                data.msg[1] = 0x03; data.msg[2] = 0x00; data.msg[3] = 0x03;
                data.msg[4] = 0x00; data.msg[5] = 0x01;
                return [](const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail) -> bool {
                    uint16_t value = (response[3] << 8) | response[4];
                    auto cumark = static_cast<CumarkProtocol*>(detail);
                    cumark->_maxSpeed = value;
                    cumark->updateRPM(vfd);
                    return true;
                };
            }
            return nullptr;
        }
    }
}