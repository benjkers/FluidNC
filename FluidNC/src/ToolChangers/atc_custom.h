// Copyright (c) 2024 -	Bart Dring
// Use of this source code is governed by a GPLv3 license that can be found in the LICENSE file.

#pragma once

#include "Config.h"

#include "Configuration/Configurable.h"

#include "Channel.h"
#include "Module.h"
#include "atc.h"
#include "../Machine/Macros.h"
#include <string>

namespace ATCs {

    // ---------------------------------------------------------------------
    // Special, fixed tool numbers. These are NOT part of the rack range.
    //
    //   T0   = no tool / reset (unchanged FluidNC convention)
    //
    //   T100 (GAUGE_SETTER_TOOL) = a physical reference tool with a KNOWN,
    //        fixed gauge length (spindle-end to tip), entered as the
    //        gauge_setter_length_mm config item -- it is never measured.
    //        Installing it and running M6T100 touches it off on the
    //        toolsetter automatically (a normal probe cycle -- T100 has no
    //        trigger-order ambiguity). That single probed Z, combined with
    //        the known gauge_setter_length_mm, calibrates the conversion
    //        from "raw toolsetter trigger Z" to "absolute tool gauge
    //        length" for every other tool. This is _ets_reference_probe_z.
    //
    //   T1 (PROBE_TOOL) = the electrical touch probe. Its gauge length
    //        CANNOT be measured by touching it on the toolsetter directly
    //        (you can't know whether the probe's electrical trigger or the
    //        toolsetter's mechanical trigger fires first). Instead, it is
    //        computed off-machine using a gauge/1-2-3 block:
    //          1. Jog T100 down onto the block until it just touches, and
    //             read the resulting machine Z off the DRO.
    //          2. Probe down onto the same block with T1 (a real G38.2
    //             cycle), and read the probed machine Z.
    //          3. probe_gauge_length = gauge_setter_length_mm
    //                                  + (T100's block Z - T1's block Z)
    //             (sign convention: matches how gauge lengths and probed Z
    //             move together elsewhere in this file -- see
    //             absolute_gauge_from_probe() below.)
    //        That number is then entered directly with:
    //             M101 T1 Q<value>
    //        which stores it without any probing.
    //
    // Rack tools (T2..T7 by default) are ordinary mechanical tools, so they
    // ARE probed normally on the toolsetter, and their absolute gauge
    // length is computed automatically from the T100 calibration -- see
    // absolute_gauge_from_probe(). M101 T<n> re-masters one on demand, and
    // M101 T<n> Q<value> can also directly override one manually if you
    // ever measure it some other way (calipers, CMM, etc.).
    // ---------------------------------------------------------------------
    constexpr tool_t PROBE_TOOL        = 1;
    constexpr tool_t GAUGE_SETTER_TOOL = 100;

    // Maximum number of tool pockets a single atc_custom instance can be
    // configured with. This is just an array size, not the number of tools
    // in use -- bump it (and add matching handler.item() lines in group())
    // if you ever need more than this many pockets in ONE rack.
    constexpr int MAX_TOOL_SLOTS = 12;

    class Custom_ATC : public ATC {
    public:
        Custom_ATC(const char* name) : ATC(name) {}

        Custom_ATC(const Custom_ATC&)            = delete;
        Custom_ATC(Custom_ATC&&)                 = delete;
        Custom_ATC& operator=(const Custom_ATC&) = delete;
        Custom_ATC& operator=(Custom_ATC&&)      = delete;

        virtual ~Custom_ATC() = default;

        // Called by the $ATC/SaveGauge bridge command (see ProcessSettings.cpp)
        // after a macro has stashed a freshly-probed toolsetter Z into the
        // global named parameter #<_atc_measured_z>. tool_number ==
        // GAUGE_SETTER_TOOL means "this calibrates the toolsetter
        // reference"; otherwise it must be one of this instance's rack
        // tools. Returns true on success.
        bool commit_measured_gauge(tool_t tool_number);

        // Look up a live instance by config name, used by the $ATC/SaveGauge
        // command handler so it works with multiple atc_custom instances.
        static Custom_ATC* find(const std::string& name);

    private:
        // ------------------------ config items ------------------------
        std::vector<float> _ets_mpos           = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        std::vector<float> _manual_change_mpos  = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        std::vector<float> _manual_gauge        = { 25.0, 200.0 };  // minimum and maximum tool gauge length for manual tool change, used for safe rapid approach to the toolsetter
        // Clearance height ABOVE the toolsetter top surface at which the
        // TOOL TIP may be rapided. Applied to the tip; converted to a
        // spindle-nose Z by adding the tool gauge length.
        float              _ets_rapid_z_offset = 5.0;
        std::vector<float> _tool_holder        = { 0.0, -60, 60, 0.0, 0.0, 0.0 };

        // How far BELOW the toolsetter top surface (ets_mpos_mm Z) the
        // final G38.2 measurement move is allowed to travel before it is
        // treated as a failed probe. The setter should always trigger
        // well before this; it is a safety limit, not a target. Positive
        // value = millimetres of permitted over-travel past the surface.
        float              _ets_probe_overtravel = 10.0;

        // T100's known, fixed, physical gauge length (spindle-end to tip).
        // This is a config constant -- it is NEVER measured or persisted.
        // T100 reference-tool gauge length (the "gauge line" length),
        // spindle-nose to tip. Known physical constant, never measured.
        float _gauge_setter_length = 63.666;

        // T-number of the first rack pocket (e.g. 2, so T2..T(2+tool_count-1)
        // are rack tools). Change this to move/expand the rack range without
        // touching any code.
        uint32_t _first_tool_number = 2;

        // How many of the _tool_mpos[] slots below are actually populated.
        // Must be <= MAX_TOOL_SLOTS.
        uint32_t _tool_count = 6;

        // Optional override for where the gauge table lives on the SD card.
        // Defaults to "/atc_<name>_gauge.txt" if left empty, so multiple
        // atc_custom instances don't collide by default.
        std::string _gauge_filename = "";

        // Pocket positions, one per rack slot. Only the first _tool_count
        // are used. Add more handler.item() lines (and bump MAX_TOOL_SLOTS)
        // if you need more than 12 pockets in a single rack.
        std::vector<float> _tool_mpos[MAX_TOOL_SLOTS];

        // ------------------------ runtime / persisted state ------------------------
        // Absolute gauge lengths (spindle-end to tip), NOT raw probe
        // readings -- computed via absolute_gauge_from_probe() at the time
        // they're measured, so they stay correct even if the toolsetter
        // reference is later re-established with a fresh M6T100.
        //
        // _tool_gauge[i] can hold either a rough, not-yet-verified estimate
        // (set via M101 T<n> Q<value> before the tool has ever been probed
        // -- e.g. copied from Fusion 360's tool library) or the precise,
        // actually-measured value. _tool_gauge_valid[i] is what
        // distinguishes them: it's only set true once a REAL toolsetter
        // probe has run for that pocket. Until then, M6 to that tool still
        // does a full probe (an estimate alone never skips it) -- but that
        // probe's safe-approach stage uses the estimate instead of the
        // generic manual_gauge fallback, so it can rapid in closer.
        float _tool_gauge[MAX_TOOL_SLOTS]       = { 0.0 };
        bool  _tool_gauge_valid[MAX_TOOL_SLOTS] = { false };

        // The raw toolsetter-trigger Z recorded the last time T100 was
        // probed (M6T100). This is the calibration anchor, NOT a gauge
        // length itself -- see absolute_gauge_from_probe().
        float _ets_reference_probe_z       = 0.0;
        bool  _ets_reference_probe_z_valid = false;

        // T1's (the probe's) absolute gauge length. Can't be measured on
        // the toolsetter (see the big comment above), so this is only ever
        // set directly via M101 T1 Q<value>, never auto-probed.
        float _probe_gauge_length       = 0.0;
        bool  _probe_gauge_length_valid = false;

        bool    _is_OK     = false;
        tool_t  _prev_tool = 0;  // last tool actually in the spindle (persisted)

        bool is_rack_tool(tool_t t) const { return t >= _first_tool_number && t < _first_tool_number + _tool_count; }
        int  slot_index(tool_t t) const { return int(t) - int(_first_tool_number); }

        // True once both halves of the calibration chain are known: the
        // toolsetter reference (from M6T100) and the probe's own gauge
        // length (manually entered via M101 T1 Q<value>). Needed before
        // any rack/manual tool's TLO can be computed.
        bool calibration_ready() const { return _ets_reference_probe_z_valid && _probe_gauge_length_valid; }

        // Converts a raw toolsetter-trigger Z reading into an absolute
        // gauge length, using the T100 calibration:
        //   gauge(tool) = gauge_setter_length + (raw_z - ets_reference_probe_z)
        float absolute_gauge_from_probe(float raw_z) const { return _gauge_setter_length + (raw_z - _ets_reference_probe_z); }

        // TLO(tool) = absolute gauge_length(tool). Combined into
        // one constant so it can be embedded directly into gcode as a
        // literal when a tool is freshly probed:
        //   TLO = raw_z + tlo_constant()
        float tlo_constant() const { return _gauge_setter_length - _ets_reference_probe_z; }

        // Inverse of absolute_gauge_from_probe(): given a stored absolute
        // gauge length, what raw toolsetter Z would we expect to read if we
        // probed that tool right now (assuming no wear/damage)? Used to
        // expose #<_current_tool_probe_z> for break detection when a tool
        // was loaded from the table rather than freshly probed this time.
        float probe_z_from_absolute_gauge(float gauge_length) const { return _ets_reference_probe_z + (gauge_length - _gauge_setter_length); }

        void move_to_safe_z();
        void move_over_toolsetter();
        // Runs the physical probe cycle in three stages: (1) a plain, always-
        // safe rapid down to a height based on the conservative manual_gauge
        // constant, regardless of tool; (2) a fast, PROBE-PROTECTED move
        // (G38.3) down to a height based on approach_gauge_estimate (falls
        // back to manual_gauge if 0) -- this is where "rapid closer" happens,
        // safely, since a wrong estimate is caught by the probe trigger
        // rather than crashing; (3) the existing precision measurement.
        // Leaves the final result in #5063.
        // Single unified toolsetter probe. approach_gauge_estimate is this
        // tool's best-known gauge length for a close, safe rapid; pass 0 to
        // fall back to manual_gauge. If use_dynamic_fusion_gauge is true,
        // the stage-2 approach instead reads #<_fusion_tool_gauge> at
        // runtime (for manual/non-rack tools whose gauge isn't known in
        // C++ at macro-build time), falling back to manual_gauge.
        void probe_toolsetter(float approach_gauge_estimate, bool use_dynamic_fusion_gauge = false);
        void reset();
        void drop_tool(uint8_t slot);
        void pick_tool(uint8_t slot);
        void apply_tlo_from_gauge(float gauge_length);  // emits G43.1Z<...> using a known absolute gauge length
        void expose_current_tool_gauge(float gauge_length);
        void request_save_gauge(tool_t tool_number);  // emits the $ATC/SaveGauge=... bridge call

        // M101 Tn [Qvalue]. If has_manual_value, directly stores
        // manual_value as tool_number's gauge length (the only way to set
        // T1's, since it can't be auto-probed). Otherwise re-probes
        // tool_number on the toolsetter, but only if it's a rack tool AND
        // it's the one currently in the spindle.
        bool master_gauge_tool(tool_t tool_number, bool has_manual_value, float manual_value);

        std::string gauge_file_path();
        void        load_gauge_table();
        void        save_gauge_table();

        Macro _macro;

    public:
        void init() override;
        void probe_notification() override;
        bool tool_change(tool_t value, bool pre_select, bool set_tool, bool master_gauge = false, bool has_manual_gauge = false,
                          float manual_gauge_value = 0.0f) override;
        void validate() override {}

        void group(Configuration::HandlerBase& handler) override {
            handler.item("ets_mpos_mm", _ets_mpos);
            handler.item("manual_gauge_range_mm", _manual_gauge);
            handler.item("ets_rapid_z_offset_mm", _ets_rapid_z_offset);
            handler.item("ets_probe_overtravel_mm", _ets_probe_overtravel, 0.5f, 100.0f);
            handler.item("gauge_line_length_mm", _gauge_setter_length);
            handler.item("first_tool_number", _first_tool_number, 2, 250);
            handler.item("tool_count", _tool_count, 0, uint32_t(MAX_TOOL_SLOTS));
            handler.item("gauge_filename", _gauge_filename);
            // Named by RACK SLOT, not T-number, since first_tool_number is
            // configurable. slot1 == T<first_tool_number>, slot2 ==
            // T<first_tool_number + 1>, and so on.
            handler.item("slot1_mpos_mm", _tool_mpos[0]);
            handler.item("slot2_mpos_mm", _tool_mpos[1]);
            handler.item("slot3_mpos_mm", _tool_mpos[2]);
            handler.item("slot4_mpos_mm", _tool_mpos[3]);
            handler.item("slot5_mpos_mm", _tool_mpos[4]);
            handler.item("slot6_mpos_mm", _tool_mpos[5]);
            handler.item("slot7_mpos_mm", _tool_mpos[6]);
            handler.item("slot8_mpos_mm", _tool_mpos[7]);
            handler.item("slot9_mpos_mm", _tool_mpos[8]);
            handler.item("slot10_mpos_mm", _tool_mpos[9]);
            handler.item("slot11_mpos_mm", _tool_mpos[10]);
            handler.item("slot12_mpos_mm", _tool_mpos[11]);
            handler.item("tool_holder_pulloff_mm", _tool_holder);
        }
    };
}