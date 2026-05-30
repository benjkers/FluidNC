#pragma once

#include "VFDProtocol.h"
#include <esp_timer.h>
#include "System.h" // Needed for sys and Percent types

namespace Spindles {
    namespace VFD {
        class CumarkProtocol : public VFDProtocol {
        protected:
            // --- Original Members ---
            bool _is_Ccw = false;
            uint32_t last_speed = 0;
            int16_t speed = 0;
            int16_t _maxSpeed = 18000;
            int16_t _minSpeed = 500;

            // --- Optimization/Telemetry Members ---
            uint16_t _cached_speed = 0;
            uint16_t _cached_status = 0;
            uint16_t _cached_torque = 0;
            bool _is_data_initialized = false;
            uint32_t _last_poll_ms = 0;

            // --- Override Tracker ---
            // Percent is treated as an integer type
            Percent _user_target_override = 100;
            Percent _last_sys_override = 100;

            // --- Optimization Methods ---
            void smart_poll_request(ModbusCommand& data);
            void adjust_feed_override();
            static bool response_parser_callback(const uint8_t* response, VFDSpindle* vfd, VFDProtocol* detail);

            // --- Required VFDProtocol Overrides ---
            void direction_command(SpindleState mode, ModbusCommand& data) override;
            void set_speed_command(uint32_t rpm, ModbusCommand& data) override;
            void updateRPM(VFDSpindle* vfd);
           
            response_parser initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) override;
            response_parser get_current_speed(ModbusCommand& data) override;
            response_parser get_current_direction(ModbusCommand& data) override;
            response_parser get_status_ok(ModbusCommand& data) override;
        };
    }
}