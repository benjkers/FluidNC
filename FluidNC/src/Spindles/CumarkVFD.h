#pragma once

#include "VFDSpindle.h"

namespace Spindles {
    class CumarkVFD : public VFD {
    protected:
        int16_t _MinSpeed=-18000;
        int16_t _MaxSpeed=18000;

        void direction_command(SpindleState mode, ModbusCommand& data) override;
        void set_speed_command(uint32_t rpm, ModbusCommand& data) override;

        response_parser get_current_speed(ModbusCommand& data) override;
        response_parser get_status_ok(ModbusCommand& data) override { return nullptr; }
        response_parser get_current_direction(ModbusCommand& data) override { return nullptr; }
        response_parser initialization_sequence(int index, ModbusCommand& data) override { return nullptr; }

        bool safety_polling() const override { return false; }

    public:
        CumarkVFD(const char* name) : VFD(name) {}
    };
}