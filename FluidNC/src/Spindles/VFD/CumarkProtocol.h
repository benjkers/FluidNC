#pragma once

#include "VFDProtocol.h"
#include "../../Types.h"
#include "../../Config.h"
#include <vector>

namespace Spindles {
    namespace VFD {
        class CumarkProtocol : public VFDProtocol {
        protected:
            bool _is_Ccw = false;
            uint32_t last_speed;  // Store the last speed set
            int16_t speed;
            int16_t _maxSpeed=18000;
            int16_t _minSpeed=0;

            // ---------------------------------------------------------------
            // Adaptive feed control (M52 Pn, LinuxCNC-style) -- three tiers.
            //
            // Tier 1 -- hard stall trigger. ALWAYS active, independent of
            //   M52. Drive-reported "Torque limit" or "Warning" bit (part
            //   of get_status_ok()'s merged 06.00-06.03 read) -> snap
            //   straight to adaptive_feed_floor_percent.
            //
            // Tier 2 -- aggressive overtorque slowdown. ALWAYS active,
            //   independent of M52. Measured torque% (01.22, register 278,
            //   read by get_current_direction(), repurposed for this) at
            //   or above 100% -> fast fixed-step reduction toward the
            //   floor (adaptive_feed_aggressive_step per poll), even
            //   though tier 1 hasn't fired yet.
            //
            // Tier 3 -- goal-seeking. ONLY active when M52 Pn has set a
            //   nonzero goal (P is a torque FRACTION, e.g. P0.5 = target
            //   50% torque; clamped to a max of 0.9; P0 disables this tier
            //   -- tiers 1/2 are unaffected either way). A proportional
            //   controller, not fixed steps, so the override converges
            //   smoothly to whatever produces the target torque instead of
            //   hunting up and down in fixed increments:
            //     error = measured_torque% - goal%
            //     override -= gain_down * error        (error > deadband)
            //     override += gain_up   * (-error)      (error < -deadband)
            //   clamped to [adaptive_feed_min_percent, adaptive_feed_max_percent].
            //   gain_down > gain_up by default -- react promptly to rising
            //   load, recover more cautiously. adaptive_feed_max_percent
            //   CAN be set above 100 in config, letting the controller push
            //   faster than programmed if torque supports it -- that's a
            //   deliberate, opt-in choice, not a default.
            //
            // IMPORTANT: "baseline" is NOT a fixed 100% -- it's whatever
            // override the operator last set via the pendant/UI. Every
            // poll, if sys.f_override() differs from the value we last
            // wrote ourselves, that means the operator changed it in the
            // meantime, so we adopt it rather than fighting it. This
            // applies to all three tiers.
            //
            // The round-robin is 3 slots (speed / torque% / merged status)
            // since the registers involved are too far apart to combine
            // into one Modbus transaction (the message buffer is a hard 16
            // bytes -- VFD_RS485_MAX_MSG_SIZE in VFDProtocol.h) -- each
            // signal updates roughly every 3rd poll (~750ms at the default
            // poll_ms=250). Every evaluation logs at log_debug; actual
            // hard-trigger drops also log at log_warn.
            // ---------------------------------------------------------------
            uint32_t _adaptive_feed_floor_percent    = 25;   // absolute safety minimum, tiers 1/2/3 (10-100)
            uint32_t _adaptive_feed_min_percent      = 50;   // tier 3 lower output bound
            uint32_t _adaptive_feed_max_percent      = 100;  // tier 3 upper output bound; can be set up to 200 (the FeedOverride::Max hard cap), opt-in
            float    _adaptive_feed_gain_down        = 2.0f; // % override change per % torque error per SECOND, above goal
            float    _adaptive_feed_gain_up          = 0.5f; // % override change per % torque error per SECOND, below goal
            uint32_t _adaptive_feed_deadband_percent = 2;    // tolerance band around goal before adjusting
            uint32_t _adaptive_feed_aggressive_step  = 150;  // tier 2 drop toward floor, % override per SECOND

            // Tick count at the last apply_adaptive_feed() call, used to
            // time-scale the gains so tuning survives a poll_ms change.
            TickType_t _last_eval_ticks = 0;

            // Accumulated goal-seeking target as a float. The applied
            // override is an integer, but per-poll corrections are often
            // <1%; keeping the target as a float here stops that fraction
            // being truncated away every poll (the stuck-override bug).
            float _target_override_f = 0.0f;

            // The torque goal as originally commanded by M52 Pn, and a
            // persistent multiplier the operator applies to it by turning
            // the feed-override dial while goal-seeking is active. Effective
            // goal = _commanded_goal_percent * _goal_scale.
            float _commanded_goal_percent = 0.0f;
            float _goal_scale             = 1.0f;

            // Latest known values, each updated from its own poll slot (see
            // above) and combined by apply_adaptive_feed() whenever either
            // one comes in fresh.
            float _last_torque_percent = 0.0f;
            bool  _last_torque_limited = false;
            bool  _last_warning        = false;

            // Tier 3's goal, as a torque PERCENT (already converted from
            // the M52 Pn fraction by GCode.cpp/the Spindle chain). 0 means
            // "no goal set" -- tiers 1/2 still run regardless.
            float _adaptive_feed_goal_percent = 0.0f;

            // What the operator actually wants (see the big comment
            // above), and what we last wrote ourselves -- used to detect
            // external (pendant/UI) changes so we scale relative to them
            // instead of overwriting them.
            Percent _baseline_override     = FeedOverride::Default;
            Percent _last_applied_override = FeedOverride::Default;

            // Consecutive polls where torque read exactly 0 while the
            // spindle was turning -- used to warn once if drive param
            // 50.03 Act1 src isn't pointed at P.01.22.
            uint32_t _zero_torque_polls = 0;

            // ---------------------------------------------------------------
            // Speed-dependent behaviour, all driven by MEASURED tables.
            //
            // This spindle is 8-pole: 400 Hz at 6000 rpm, 1200 Hz at 18000.
            // Above base speed the drive is voltage-capped, flux thins, and
            // both the available torque and the trustworthiness of the
            // drive's estimates fall away sharply. Measured on this machine:
            //
            //   rpm    idle torque   net torque at pull-out
            //   3000      -1.6%              101.6%
            //   6000      -4.5%               74.5%
            //   9000      -3.2%               38.2%
            //  12000      -2.3%               22.3%
            //  15000      -1.9%               11.9%
            //  18000      -1.6%                4.6%
            //
            // No single power law fits the pull-out curve (the fitted
            // exponent drifts from 0.5 to 2.0 as pull-out torque, falling
            // as 1/f^2, overtakes capability, falling as 1/f), so the
            // measured table is used directly.
            // ---------------------------------------------------------------
            float _last_torque_raw = 0.0f;   // signed, BEFORE baseline subtraction
            float _last_rpm        = 0.0f;   // actual speed from the same poll

            std::vector<float> _baseline_rpm;    // no-load torque calibration
            std::vector<float> _baseline_pct;
            std::vector<float> _available_rpm;   // net torque at pull-out
            std::vector<float> _available_pct;

            // Above this speed tier 3 stops regulating and leaves the job to
            // tiers 1 and 2. Full RPM remains available.
            float _adaptive_max_rpm     = 12000.0f;
            float _goal_safety_fraction = 0.70f;  // tier 3 goal ceiling, x available
            float _tier2_fraction       = 0.85f;  // tier 2 trip point, x available
            bool  _goal_clamp_logged    = false;

            float torque_baseline(float rpm) const;
            float available_torque_percent(float rpm) const;

            void apply_adaptive_feed();

            // One Modbus transaction covering the whole fieldbus data set
            // we care about (0x0004-0x0006). See the .cpp for the register
            // map and the required drive parameters. All three polling
            // hooks below return this, so it runs every poll.
            response_parser fieldbus_block_read(ModbusCommand& data);
            void set_override(Percent target, bool is_hard_trigger);  // shared apply/report/log helper

            void direction_command(SpindleState mode, ModbusCommand& data) override;
            void set_speed_command(uint32_t rpm, ModbusCommand& data) override;
            void updateRPM(VFDSpindle* vfd);
           
            response_parser initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) override;
            response_parser get_current_speed(ModbusCommand& data) override;
            response_parser get_current_direction(ModbusCommand& data) override;
            response_parser get_status_ok(ModbusCommand& data) override;

            void set_adaptive_feed(float goal_fraction) override;

        public:
            void group(Configuration::HandlerBase& handler) override {
                handler.item("adaptive_feed_floor_percent", _adaptive_feed_floor_percent, 10, 100);
                handler.item("adaptive_feed_min_percent", _adaptive_feed_min_percent, 1, 500);
                handler.item("adaptive_feed_max_percent", _adaptive_feed_max_percent, 1, 500);
                handler.item("adaptive_feed_gain_down", _adaptive_feed_gain_down);
                handler.item("adaptive_feed_gain_up", _adaptive_feed_gain_up);
                handler.item("adaptive_feed_deadband_percent", _adaptive_feed_deadband_percent, 0, 50);
                handler.item("adaptive_feed_aggressive_step", _adaptive_feed_aggressive_step, 1, 100);
                handler.item("adaptive_max_rpm", _adaptive_max_rpm);
                handler.item("goal_safety_fraction", _goal_safety_fraction, 0.1f, 1.0f);
                handler.item("tier2_fraction", _tier2_fraction, 0.5f, 1.0f);
                handler.item("torque_baseline_rpm", _baseline_rpm);
                handler.item("torque_baseline_pct", _baseline_pct);
                handler.item("available_torque_rpm", _available_rpm);
                handler.item("available_torque_pct", _available_pct);
            }
        };
    }
}