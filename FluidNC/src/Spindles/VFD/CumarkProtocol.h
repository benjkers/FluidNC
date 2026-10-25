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
            uint32_t last_speed;  // last speed written to the drive, rpm
            int16_t speed;
            int16_t _maxSpeed=18000;
            int16_t _minSpeed=0;
            uint32_t _speed_tolerance_rpm = 200;

            // Latched in direction_command(), which runs as the block EXECUTES.
            // Not gc_state.modal.spindle: that is parser state and flips on M5
            // while the cut is still in the planner buffer.
            bool _spindle_enabled = false;

            // Adaptive feed, in evaluation order:
            //   LAYER 0  always on. Scales feed by the speed droop factor to
            //            hold chip load h = feed/(rpm*teeth) constant.
            //   TIER 1   always on. Drive torque-limit/warning bit -> floor.
            //   TIER 2   always on. Net torque >= pullout_trip_fraction x
            //            measured pull-out -> ramp to floor.
            //   TIER 3   only on a nonzero M52 Pn goal. Inverse static model
            //            under a slew limit:
            //              dest = ovr * [goal/measured]^(1/load_exponent)

            // Protection. Always on, independent of M52. protect_floor_pct is
            // separate from goal_min_pct, which is tier 3's own bound.
            uint32_t _protect_floor_pct        = 20;
            uint32_t _protect_ramp_pct_per_sec = 50;
            float    _pullout_trip_fraction    = 0.85f;

            // Tier 3.
            uint32_t _goal_min_pct          = 25;
            uint32_t _goal_max_pct          = 150;   // >100 exceeds programmed feed
            uint32_t _goal_deadband_pct     = 2;
            float    _pullout_goal_fraction = 0.70f;
            float    _goal_max_rpm          = 14000.0f;  // above: protection only

            // Below this NET torque, tier 3 holds instead of seeking.
            //
            // ABSOLUTE, not a fraction of the goal. As a fraction it scaled
            // with the goal, so a clamped or low goal put the threshold above
            // the torque of a light cut and tier 3 never engaged at all.
            //
            // FLOAT, because the useful range is below 1%. net = raw - offset
            // straddles zero in air, so the reading there is noise either side
            // of 0 clamped at 0, not a clean zero:
            //   0.0  seek always, including on an exactly-zero reading
            //   0.5  seek on anything above the zero-flicker  <- "above zero"
            //   2.0  ignore the noise band; holds in air
            // Only a value above the noise band actually keeps the override
            // down in air. Below that it ramps to goal_max and the next cut
            // starts there.
            float _engage_torque_pct = 0.5f;

            // load ~ override^n. Material dependent -- measure it: straight
            // slot at constant engagement, step the override, slope of
            // log(torque) vs log(override).
            float _load_exponent = 0.75f;

            // Bound on override travel, % per SECOND. Asymmetric because
            // shedding load is the safe direction. Keep _goal_slew_down at or
            // below _protect_ramp_pct_per_sec.
            float _goal_slew_up   = 15.0f;
            float _goal_slew_down = 50.0f;

            // Operator-dial tracking. The dial and this code share
            // sys.f_override() and we only see the sum. Comparing LEVELS
            // cannot separate our own in-flight command from a dial move, so
            // it needs a tolerance of one slew step and silently discards any
            // move smaller than that. Comparing DELTAS is exact: our own
            // increment is accounted for, so whatever is left is the operator.
            Percent _prev_read_override = FeedOverride::Default;
            float   _last_increment     = 0.0f;

            TickType_t _last_eval_ticks = 0;

            // Tier 3's target, CHIP-FREE: the chip-load factor is applied at
            // the output, not compounded in here. Float because per-poll
            // corrections are often under 1% and rounding each poll would
            // discard them.
            float _target_override_f = 0.0f;

            float _last_torque_percent = 0.0f;   // net, offset removed, >= 0
            bool  _last_torque_limited = false;
            bool  _last_warning        = false;
            float _goal_pct            = 0.0f;   // 0 = no goal (M52 P0)

            // The operator's dial, tracked, so the protection floor does not
            // force the feed up above a low value they chose deliberately.
            Percent _baseline_override = FeedOverride::Default;

            uint32_t _zero_torque_polls = 0;

            // Measured, 8-pole (400 Hz at 6000 rpm):
            //   rpm    offset   net torque at pull-out
            //   3000    -1.6%        101.6%
            //   6000    -4.5%         74.5%
            //   9000    -3.2%         38.2%
            //  12000    -2.3%         22.3%
            //  15000    -1.9%         11.9%
            //  18000    -1.6%          4.6%
            // No single power law fits pull-out, so the tables are used directly.
            float _last_torque_raw = 0.0f;   // signed, before offset removal
            float _last_rpm        = 0.0f;

            std::vector<float> _torque_offset_rpm;
            std::vector<float> _torque_offset_pct;
            std::vector<float> _pullout_rpm;
            std::vector<float> _pullout_pct;

            bool _goal_clamp_logged = false;

            float torque_offset(float rpm) const;
            float pullout_torque_pct(float rpm) const;

            void apply_adaptive_feed();

            // 0x0004-0x0006 in one transaction. All three polling hooks return
            // it, so every signal arrives on every poll.
            response_parser fieldbus_block_read(ModbusCommand& data);

            // Hands the change to the main loop as an INCREMENT: this runs in
            // the VFD task on core 0, the planner on core 1.
            void set_override(Percent target, bool is_hard_trigger);

            void direction_command(SpindleState mode, ModbusCommand& data) override;
            void set_speed_command(uint32_t rpm, ModbusCommand& data) override;
            void updateRPM(VFDSpindle* vfd);

            response_parser initialization_sequence(int index, ModbusCommand& data, VFDSpindle* vfd) override;
            response_parser get_current_speed(ModbusCommand& data) override;
            response_parser get_current_direction(ModbusCommand& data) override;
            response_parser get_status_ok(ModbusCommand& data) override;
            bool use_speed_feedback() const override { return true; }

            void set_adaptive_feed(float goal_fraction) override;

        public:
            void group(Configuration::HandlerBase& handler) override {
                handler.item("protect_floor_pct", _protect_floor_pct, 5, 100);
                handler.item("protect_ramp_pct_per_sec", _protect_ramp_pct_per_sec, 1, 500);
                handler.item("pullout_trip_fraction", _pullout_trip_fraction, 0.5f, 1.0f);

                handler.item("goal_min_pct", _goal_min_pct, 5, 100);
                handler.item("goal_max_pct", _goal_max_pct, 100, 200);
                handler.item("goal_deadband_pct", _goal_deadband_pct, 0, 50);
                handler.item("goal_max_rpm", _goal_max_rpm);
                handler.item("pullout_goal_fraction", _pullout_goal_fraction, 0.1f, 1.0f);
                handler.item("engage_torque_pct", _engage_torque_pct, 0.0f, 50.0f);
                handler.item("load_exponent", _load_exponent, 0.3f, 1.2f);
                handler.item("goal_slew_up_pct_per_sec", _goal_slew_up);
                handler.item("goal_slew_down_pct_per_sec", _goal_slew_down);

                handler.item("torque_offset_rpm", _torque_offset_rpm);
                handler.item("torque_offset_pct", _torque_offset_pct);
                handler.item("pullout_torque_rpm", _pullout_rpm);
                handler.item("pullout_torque_pct", _pullout_pct);

                handler.item("speed_tolerance_rpm", _speed_tolerance_rpm, 50, 2000);
            }
        };
    }
}