#pragma once

#include "VFDProtocol.h"

namespace Spindles {
    namespace VFD {
        class CumarkProtocol : public VFDProtocol {
        protected:
            bool _is_Ccw; 
            uint32_t last_speed;  // Store the last speed set
            int16_t speed;
            int16_t _maxSpeed=18000;
            int16_t _minSpeed=500;

            void direction_command(SpindleState mode, ModbusCommand& data) override;
            void set_speed_command(uint32_t rpm, ModbusCommand& data) override;

           void updateRPM(VFDSpindle* vfd);
           
            response_parser initialization_sequence(int index, ModbusCommand& data) override;
            response_parser get_current_speed(ModbusCommand& data) override;
            response_parser get_current_direction(ModbusCommand& data) override;
            response_parser get_status_ok(ModbusCommand& data) override;
        };
    }
}