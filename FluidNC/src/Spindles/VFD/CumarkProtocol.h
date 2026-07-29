#pragma once

#include "VFDProtocol.h"
#include "../../Types.h"
#include "../../Config.h"

namespace Spindles {
    namespace VFD {
        class CumarkProtocol : public VFDProtocol {
        protected:
            bool _is_Ccw = false;
            uint32_t last_speed;  // Store the last speed set
            int16_t speed;
            int16_t _maxSpeed=18000;
            int16_t _minSpeed=500;

            // ---------------------------------------------------------------
            // Adaptive feed control (M52 Pn, LinuxCNC-style).
            //
            // Two complementary signals, each in its own poll slot (see the
            // .cpp) since the registers involved are too far apart to
            // combine into one Modbus transaction (the message buffer is a
            // hard 16 bytes -- VFD_RS485_MAX_MSG_SIZE in VFDProtocol.h):
            //
            //   1. Continuous torque% (01.22, register 278) -- read by
            //      get_current_direction(), repurposed for this. Drives a
            //      smooth, PROPORTIONAL feed reduction: flat at baseline
            //      below adaptive_feed_warn_percent, linearly scaled down
            //      toward adaptive_feed_floor_percent as torque% climbs
            //      toward adaptive_feed_limit_percent.
            //   2. The drive's own "Torque limit" bit, and separately its
            //      "Warning" bit (06.00 bit 2 / 06.03 bit 13, part of
            //      get_status_ok()'s merged 06.00-06.03 read) -- hard
            //      safety nets. Either one snaps straight to the floor
            //      regardless of what the proportional curve says.
            //
            // IMPORTANT: "baseline" above is NOT a fixed 100% -- it's
            // whatever override the operator last set via the pendant/UI.
            // Every poll, if sys.f_override() differs from the value we
            // last wrote ourselves, that means the operator changed it in
            // the meantime, so we adopt it as the new baseline rather than
            // fighting it. Without this, enabling M52 would silently snap
            // any manually-set override back to 100% the moment load was
            // calm, and creep a manually-lowered override back up over
            // time -- both wrong. The floor is still an absolute safety
            // minimum, except when the operator's own baseline is already
            // below it, in which case we respect their lower choice
            // instead of forcing it up.
            //
            // This means the round-robin is back to 3 slots (speed / torque%
            // / merged status) instead of the 2 we had before adding this --
            // each signal updates roughly every 3rd poll (~750ms at the
            // default poll_ms=250) rather than every 2nd. Recovery (moving
            // the override back toward baseline) is rate-limited by
            // adaptive_feed_recover_step per poll; dropping the override is
            // always immediate. Every evaluation logs at log_debug; actual
            // hard-trigger drops also log at log_warn.
            //
            // Entirely inert unless M52 P1 has been run -- set via
            // set_adaptive_feed() below, called directly by GCode.cpp
            // through Spindle::set_adaptive_feed() / VFDSpindle's override,
            // no gcode variable involved.
            // ---------------------------------------------------------------
            uint32_t _adaptive_feed_floor_percent = 25;  // absolute safety minimum (10-100)
            uint32_t _adaptive_feed_warn_percent   = 50;  // torque% where throttling starts
            uint32_t _adaptive_feed_limit_percent  = 90;  // torque% where we're fully at the floor
            uint32_t _adaptive_feed_recover_step  = 5;   // % to ramp up per poll once clear
            bool     _adaptive_feed_enabled       = false;

            // Latest known values, each updated from its own poll slot (see
            // above) and combined by apply_adaptive_feed() whenever either
            // one comes in fresh.
            float _last_torque_percent = 0.0f;
            bool  _last_torque_limited = false;
            bool  _last_warning        = false;

            // What the operator actually wants (see the big comment above),
            // and what we last wrote ourselves -- used to detect external
            // (pendant/UI) changes so we scale relative to them instead of
            // overwriting them.
            Percent _baseline_override     = FeedOverride::Default;
            Percent _last_applied_override = FeedOverride::Default;

            void apply_adaptive_feed();

            void direction_command(SpindleState mode, ModbusCommand& data) override;
            void set_speed_command(uint32_t rpm, ModbusCommand& data) override;
            void updateRPM(VFDSpindle* vfd);
           
            response_parser initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) override;
            response_parser get_current_speed(ModbusCommand& data) override;
            response_parser get_current_direction(ModbusCommand& data) override;
            response_parser get_status_ok(ModbusCommand& data) override;

            void set_adaptive_feed(bool enable) override;

        public:
            void group(Configuration::HandlerBase& handler) override {
                handler.item("adaptive_feed_floor_percent", _adaptive_feed_floor_percent, 10, 100);
                handler.item("adaptive_feed_warn_percent", _adaptive_feed_warn_percent, 1, 100);
                handler.item("adaptive_feed_limit_percent", _adaptive_feed_limit_percent, 1, 100);
                handler.item("adaptive_feed_recover_step", _adaptive_feed_recover_step, 1, 50);
            }
        };
    }
}