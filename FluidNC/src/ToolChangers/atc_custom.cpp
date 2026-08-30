// Copyright (c) 2024 -	Bart Dring
// Use of this source code is governed by a GPLv3 license that can be found in the LICENSE file.

#include "atc_custom.h"
#include "../Machine/MachineConfig.h"
#include "../FluidPath.h"
#include "../Parameters.h"
#include "../Settings.h"
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <map>

/*
  See the big comment block in atc_custom.h for the full explanation of the
  T100 / T1 calibration model. Short version:

    T100  known, fixed gauge length (gauge_setter_length_mm, a config
          constant). Probed normally on the toolsetter via M6T100 -- this
          calibrates _ets_reference_probe_z, the raw toolsetter Z that
          corresponds to a tool of exactly gauge_setter_length_mm.

    T1    the probe. Its gauge length can't be measured on the toolsetter
          (electrical vs. mechanical trigger-order ambiguity), so it's
          computed off-machine with a 1-2-3 block and entered directly:
              M101 T1 Q<value>

    T2..T7 (rack tools) probed normally; their absolute gauge length is
          computed from the T100 calibration and persisted to SD.

  gcode variables exposed for other macros
  ------------------------------------------
  #<_etsx> #<_etsy> #<_etsz>       toolsetter machine position
  #<_etszrapid>                    Z used for the fast approach probe
  #<_current_tool_gauge>           absolute gauge length of whatever tool is
                                    currently in the spindle
  #<_current_tool_probe_z>         the raw toolsetter-trigger machine Z we'd
                                    EXPECT for that tool right now -- this is
                                    what Macros/BreakDetection.nc compares a
                                    fresh probe against
  #<_atc_probe_gauge>              T1's absolute gauge length (constant)

  #<_current_tool_gauge> and #<_atc_probe_gauge> are exactly what
  Macros/ProbeZSetZero.nc and Macros/SetZZero.nc use to set work Z zero
  directly from machine coordinates, independent of G43.1/TLO modal state.
*/

namespace ATCs {

    // Registry so the $ATC/SaveGauge bridge command (see below) can find the
    // right instance even if there's more than one atc_custom on the machine.
    static std::map<std::string, Custom_ATC*> s_atc_instances;

    Custom_ATC* Custom_ATC::find(const std::string& name) {
        auto it = s_atc_instances.find(name);
        return it == s_atc_instances.end() ? nullptr : it->second;
    }

    void Custom_ATC::init() {
        s_atc_instances[name()] = this;
        load_gauge_table();

        log_info("ATC:" << name() << " rack T" << _first_tool_number << "-T"
                         << (_first_tool_number + (_tool_count ? _tool_count - 1 : 0)));

        if (!_ets_reference_probe_z_valid) {
            log_warn("ATC:" << name() << " no toolsetter reference yet -- install T" << int(GAUGE_SETTER_TOOL) << " and run M6T"
                             << int(GAUGE_SETTER_TOOL));
        }
        
        if (_prev_tool != 0) {
            log_warn("ATC:" << name() << " last known tool was T" << int(_prev_tool) << " -- confirm it's still correct");
        }
    }

    void Custom_ATC::probe_notification() {}

    // ------------------------------------------------------------------
    // Persistence
    // ------------------------------------------------------------------
    std::string Custom_ATC::gauge_file_path() {
        if (!_gauge_filename.empty()) {
            return _gauge_filename;
        }
        return std::string("/atc_") + name() + "_gauge.txt";
    }

    void Custom_ATC::load_gauge_table() {
        std::error_code ec;
        FluidPath       fpath(gauge_file_path(), SD, ec);
        if (ec) {
            log_info("ATC:" << name() << " SD card not available, starting with an empty gauge table");
            return;
        }
        FILE* f = fopen(fpath.c_str(), "r");
        if (!f) {
            log_info("ATC:" << name() << " no saved gauge table yet at " << gauge_file_path().c_str());
            return;
        }
        char line[160];
        while (fgets(line, sizeof(line), f)) {
            int   tool;
            float value;
            int   valid;
            if (sscanf(line, "prev_tool=%d", &tool) == 1) {
                _prev_tool = tool_t(tool);
                continue;
            }
            if (sscanf(line, "ets_reference_z=%f %d", &value, &valid) == 2) {
                _ets_reference_probe_z       = value;
                _ets_reference_probe_z_valid = valid != 0;
                continue;
            }
            if (sscanf(line, "probe_gauge=%f %d", &value, &valid) == 2) {
                _probe_gauge_length       = value;
                _probe_gauge_length_valid = valid != 0;
                continue;
            }
            if (sscanf(line, "tool%d_gauge=%f %d", &tool, &value, &valid) == 3) {
                if (is_rack_tool(tool_t(tool))) {
                    int slot                = slot_index(tool_t(tool));
                    _tool_gauge[slot]       = value;
                    _tool_gauge_valid[slot] = valid != 0;
                }
                continue;
            }
        }
        fclose(f);
        log_info("ATC:" << name() << " loaded gauge table from " << gauge_file_path().c_str());
    }

    void Custom_ATC::save_gauge_table() {
        std::error_code ec;
        FluidPath       fpath(gauge_file_path(), SD, ec);
        if (ec) {
            log_error("ATC:" << name() << " cannot save gauge table, SD card not available");
            return;
        }
        FILE* f = fopen(fpath.c_str(), "w");
        if (!f) {
            log_error("ATC:" << name() << " failed to open " << gauge_file_path().c_str() << " for writing");
            return;
        }
        fprintf(f, "# FluidNC atc_custom gauge table for '%s' -- auto-generated\n", name());
        fprintf(f, "prev_tool=%d\n", int(_prev_tool));
        fprintf(f, "ets_reference_z=%0.4f %d\n", _ets_reference_probe_z, _ets_reference_probe_z_valid ? 1 : 0);
        fprintf(f, "probe_gauge=%0.4f %d\n", _probe_gauge_length, _probe_gauge_length_valid ? 1 : 0);
        for (uint32_t i = 0; i < _tool_count; i++) {
            fprintf(f, "tool%d_gauge=%0.4f %d\n", int(_first_tool_number + i), _tool_gauge[i], _tool_gauge_valid[i] ? 1 : 0);
        }
        fclose(f);
    }

    // tool_number == GAUGE_SETTER_TOOL -> this is the T100 toolsetter
    // reference calibration. Otherwise tool_number must be a rack tool,
    // and the raw probe is converted to an absolute gauge length here.
    bool Custom_ATC::commit_measured_gauge(tool_t tool_number) {
        float v;
        if (!get_global_named_param("_atc_measured_z", v)) {
            log_error("ATC:" << name() << " no measured value to save (missing #<_atc_measured_z>)");
            return false;
        }
        if (tool_number == GAUGE_SETTER_TOOL) {
            if (_ets_reference_probe_z_valid) {
                float shift = v - _ets_reference_probe_z;
                log_info("ATC:" << name() << " toolsetter reference was " << _ets_reference_probe_z << ", now " << v
                                << ", shift " << shift << " mm");
            } else {
                log_info("ATC:" << name() << " toolsetter reference set for the first time");
            }
            _ets_reference_probe_z       = v;
            _ets_reference_probe_z_valid = true;
            log_info("ATC:" << name() << " toolsetter reference set (raw Z=" << v << ", T" << int(GAUGE_SETTER_TOOL)
                             << " gauge=" << _gauge_setter_length << ")");
        } else if (is_rack_tool(tool_number)) {
            int   slot  = slot_index(tool_number);
            float gauge = absolute_gauge_from_probe(v);
            _tool_gauge[slot]       = gauge;
            _tool_gauge_valid[slot] = true;
            log_info("ATC:" << name() << " T" << int(tool_number) << " gauge length set to " << gauge);
        } else {
            log_error("ATC:" << name() << " T" << int(tool_number) << " is not a rack tool, refusing to store a gauge length");
            return false;
        }
        save_gauge_table();
        return true;
    }

    // ------------------------------------------------------------------
    // M101 Tn [Qvalue]
    // ------------------------------------------------------------------
    bool Custom_ATC::master_gauge_tool(tool_t tool_number, bool has_manual_value, float manual_value) {
        bool was_inch_mode = (gc_state.modal.units == Units::Inches);

        if (has_manual_value) {
            // Direct manual entry -- the only way to set T1's gauge length
            // (see the trigger-order note in atc_custom.h), and also handy
            // to override a rack tool's gauge if you measured it some
            // other way.
            if (tool_number == PROBE_TOOL) {
                _probe_gauge_length       = manual_value;
                _probe_gauge_length_valid = true;
                log_info("ATC:" << name() << " T" << int(PROBE_TOOL) << " gauge length manually set to " << manual_value);
                save_gauge_table();
                return true;
            }
            if (is_rack_tool(tool_number)) {
                int slot          = slot_index(tool_number);
                _tool_gauge[slot] = manual_value;
                // NOT marked valid/mastered -- this is only an approach
                // estimate (e.g. copied from Fusion's tool library) until
                // the tool is actually probed on the toolsetter. The next
                // M6 to this tool will still do a full probe, just using
                // this value for a closer, safer approach instead of the
                // generic manual_gauge fallback.
                log_info("ATC:" << name() << " T" << int(tool_number) << " approach estimate set to " << manual_value
                                 << " (will still be probed/mastered on next use)");
                save_gauge_table();
                return true;
            }
            log_error("ATC:" << name() << " T" << int(tool_number) << " can't have a gauge length set");
            return false;
        }

        // Auto-probe path: only for rack tools, and only the one currently
        // in the spindle (T100 is re-measured via M6T100; T1 can't be
        // auto-probed at all -- see above).
        if (!is_rack_tool(tool_number)) {
            log_error("ATC:" << name() << " T" << int(tool_number)
                              << " can't be auto-probed -- use M6T" << int(GAUGE_SETTER_TOOL) << " for the toolsetter reference, or M101 T"
                              << int(tool_number) << " Q<value> to enter a gauge length directly");
            return false;
        }
        if (tool_number != _prev_tool) {
            log_error("ATC:" << name() << " T" << int(tool_number) << " is not the tool currently in the spindle (T" << int(_prev_tool)
                              << "), M101 ignored");
            return false;
        }
        if (!_ets_reference_probe_z_valid) {
            log_error("ATC:" << name() << " no toolsetter reference yet. Install T" << int(GAUGE_SETTER_TOOL) << " and run M6T"
                              << int(GAUGE_SETTER_TOOL) << " first.");
            return false;
        }

        protocol_buffer_synchronize();
        _macro.erase();

        try {
            int   slot     = slot_index(tool_number);
            float approach = (_tool_gauge[slot] != 0.0f) ? _tool_gauge[slot] : _manual_gauge[0];

            move_to_safe_z();
            move_over_toolsetter();
            probe_toolsetter(approach, false);
            _macro.addf("#<_atc_measured_z>=[#5063]");
            if (_probe_gauge_length_valid) {
                _macro.addf("#<_my_tlo_z>=[#5063 + %0.4f]", tlo_constant());
                _macro.addf("G43.1Z#<_my_tlo_z>");
            }
            request_save_gauge(tool_number);
            move_to_safe_z();

            if (was_inch_mode) {
                _macro.addf("G20");
            }

            _macro.run(nullptr);
            return true;
        } catch (...) {
            log_info("Exception caught");
            return false;
        }
    }

    // ------------------------------------------------------------------
    // Tool change
    // ------------------------------------------------------------------
    bool Custom_ATC::tool_change(tool_t new_tool, bool pre_select, bool set_tool, bool master_gauge, bool has_manual_gauge,
                                  float manual_gauge_value) {
        // M101 Tn [Qvalue] - re-gauge (or manually set) a tool's gauge
        // length. Entirely separate from selecting/loading a tool.
        if (master_gauge) {
            return master_gauge_tool(new_tool, has_manual_gauge, manual_gauge_value);
        }

        bool spindle_was_on = false;  // used to restore the spindle state
        bool was_inch_mode  = false;  // allows use to restore inch mode if req'd

        protocol_buffer_synchronize();  // wait for all motion to complete
        _macro.erase();                 // clear previous gcode

        // Storing Gcode parameters to be used in break detection code, and
        // by Macros/ProbeZSetZero.nc / Macros/SetZZero.nc
        _macro.addf("#<_etsx>=%0.3f", _ets_mpos[0]);
        _macro.addf("#<_etsy>=%0.3f", _ets_mpos[1]);
        _macro.addf("#<_etsz>=%0.3f", _ets_mpos[2]);
        _macro.addf("#<_etszrapidoffset>=%0.3f", _ets_rapid_z_offset);
        _macro.addf("#<_etsovertravel>=%0.3f", _ets_probe_overtravel);
        
        if (_probe_gauge_length_valid) {
            _macro.addf("#<_atc_probe_gauge>=%0.4f", _probe_gauge_length);
        }

        // M61 performs NO motion and NO probing: it tells the controller which
        // tool is *already* in the spindle. Because this ATC persists gauge
        // lengths, we go one step beyond bare LinuxCNC: if we already KNOW this
        // tool's gauge (from the SD table / prior probe), we also apply it as the
        // active TLO. If the gauge is NOT known, we set the number only and cancel
        // any stale TLO (G49) so a wrong offset can't silently persist.
        // We NEVER probe or move here. Use M6 to measure, M101 T<n> to re-gauge.
        if (set_tool) {
            _prev_tool = new_tool;

            if (new_tool == 0) {
                reset();                                    // T0 = no tool
            } else if (is_rack_tool(new_tool) && _tool_gauge_valid[slot_index(new_tool)]) {
                const int slot = slot_index(new_tool);      // rack tool, measured gauge
                apply_tlo_from_gauge(_tool_gauge[slot]);
                expose_current_tool_gauge(_tool_gauge[slot]);
                log_info("ATC:" << name() << " M61 set T" << int(new_tool)
                                << " -- applied stored gauge " << _tool_gauge[slot]);
            } else if (new_tool == PROBE_TOOL && _probe_gauge_length_valid) {
                apply_tlo_from_gauge(_probe_gauge_length);  // touch probe T1
                expose_current_tool_gauge(_probe_gauge_length);
                log_info("ATC:" << name() << " M61 set T" << int(PROBE_TOOL)
                                << " -- applied probe gauge " << _probe_gauge_length);
            } else {
                _macro.addf("G49");                          // unknown gauge: cancel TLO
                log_warn("ATC:" << name() << " M61 set T" << int(new_tool)
                                << " -- no stored gauge; TLO cancelled (G49). "
                                << "Use M6 T" << int(new_tool)
                                << " to measure, or M101 T" << int(new_tool)
                                << " Q<value> to set it.");
            }

            save_gauge_table();     // persist _prev_tool for power-loss recovery
            _macro.run(nullptr);
            return true;
        }

        // M6T0 is used to reset this ATC and allows the probe to be used to determine the z offset
        if (new_tool == 0) {
            if (is_rack_tool(_prev_tool)) {
                move_to_safe_z();
                drop_tool(slot_index(_prev_tool));
            }
            _prev_tool = new_tool;
            move_to_safe_z();
            move_over_toolsetter();
            reset();
            save_gauge_table();
            _macro.run(nullptr);
            return true;
        }

        // Repeat request for the same tool that's already loaded: no physical
        // change, but the TLO may need restoring. A soft-reset (STOP button)
        // runs gc_init(), which zeroes the active TLO (#5401-#5403). On resume
        // the program re-issues T<n> M6 for the tool still in the spindle, so
        // without restoring the offset we would cut with TLO = 0.
        // Gcode NAMED parameters are NOT cleared by a reset, so
        // #<_current_tool_gauge> still holds the right value -- just re-apply
        // it. The else branch covers a power cycle, where the param is gone.
        if (_prev_tool == new_tool && new_tool != GAUGE_SETTER_TOOL) {
            _macro.addf("o160 if [EXISTS[#<_current_tool_gauge>]]");
            _macro.addf("G43.1Z#<_current_tool_gauge>");
            _macro.addf("o160 else");
            if (is_rack_tool(new_tool) && _tool_gauge_valid[slot_index(new_tool)]) { // rack tool, with known gauge: restore TLO and expose the gauge for other macros
                const int slot = slot_index(new_tool);
                apply_tlo_from_gauge(_tool_gauge[slot]); 
                expose_current_tool_gauge(_tool_gauge[slot]);
            } else if (new_tool == PROBE_TOOL && _probe_gauge_length_valid) {
                apply_tlo_from_gauge(_probe_gauge_length);  // touch probe T1`
                expose_current_tool_gauge(_probe_gauge_length);
            } else { // unknown gauge & manual tool: re-measure on the toolsetter
                log_info("ATC:" << name() << " T" << int(new_tool)
                                << " already loaded but gauge unknown -- re-measuring on toolsetter");
                if (!_ets_reference_probe_z_valid) {
                    log_error("ATC:" << name() << " no toolsetter reference yet -- run M6T"
                                      << int(GAUGE_SETTER_TOOL) << " first; TLO not restored.");
                } else {
                    move_to_safe_z();
                    move_over_toolsetter();
                    probe_toolsetter(0.0f, true);
                    _macro.addf("#<_my_tlo_z>=[#5063 + %0.4f]", tlo_constant());
                    _macro.addf("G43.1Z#<_my_tlo_z>");
                    _macro.addf("#<_current_tool_gauge>=[#5063 + %0.4f]", _gauge_setter_length - _ets_reference_probe_z);
                    _macro.addf("#<_current_tool_probe_z>=[#5063]");
                    move_to_safe_z();
                }
            }
            _macro.addf("o160 endif");
            _macro.run(nullptr);
            return true;
        }

        was_inch_mode = (gc_state.modal.units == Units::Inches);
        if (was_inch_mode) {
            _macro.addf("G21");
        }

        try {
            // turn off the spindle
            if (gc_state.modal.spindle != SpindleState::Disable) {
                spindle_was_on = true;
                _macro.addf("M5");
            }

            // ---------------------------------------------------------------
            // T100: known-gauge-length reference tool. Fully automatic once
            // the operator installs it and resumes -- it's an ordinary
            // mechanical tool, so it's touched off on the toolsetter just
            // like a rack tool.
            // ---------------------------------------------------------------
            if (new_tool == GAUGE_SETTER_TOOL) {
                if (is_rack_tool(_prev_tool)) {
                    move_to_safe_z();
                    drop_tool(slot_index(_prev_tool));
                } else if (_prev_tool != 0) {
                    move_to_safe_z();
                    move_over_toolsetter();
                    _macro.addf("G4P0.1");
                    _macro.addf("(MSG: Remove tool #%d then resume to continue)", _prev_tool);
                    _macro.addf("M0");
                }
                move_to_safe_z();
                move_over_toolsetter();
                _macro.addf("G4P0.1");
                _macro.addf("$hz");
                _macro.addf("G4P0.1");
                _macro.addf("(MSG: Install T%d - known gauge length %0.4f - then resume, it will be measured automatically)",
                             GAUGE_SETTER_TOOL, _gauge_setter_length);
                _macro.addf("M0");
                move_to_safe_z();
                move_over_toolsetter();
                probe_toolsetter(_gauge_setter_length, false);  // T100's own known gauge length makes a precise approach estimate
                _macro.addf("#<_atc_measured_z>=[#5063]");
                request_save_gauge(GAUGE_SETTER_TOOL);
                move_to_safe_z();
                _prev_tool = new_tool;
                save_gauge_table();
                if (was_inch_mode) {
                    _macro.addf("G20");
                }
                _macro.run(nullptr);
                return true;
            }

            // Every tool (including T1) carries its own absolute-gauge-length
            // TLO, so a rack or manual tool's result depends ONLY on the
            // toolsetter reference (from M6T100) -- NOT on T1's gauge length.
            // T1's gauge matters only for T1 itself, which is checked in its
            // own branch below. So the general gate here is just the
            // toolsetter reference; requiring T1 too would needlessly block
            // rack/manual changes.
            if (!_ets_reference_probe_z_valid) {
                log_error("ATC:" << name() << " no toolsetter reference yet -- run M6T"
                                  << int(GAUGE_SETTER_TOOL) << " to establish it.");
                send_alarm(ExecAlarm::SpindleControl);
                return false;
            }

            // ---------------------------------------------------------------
            // T1: the probe. Fixed gauge length (manually entered), never
            // touched off.
            // ---------------------------------------------------------------
            if (new_tool == PROBE_TOOL) {
                if (is_rack_tool(_prev_tool)) {
                    move_to_safe_z();
                    drop_tool(slot_index(_prev_tool));
                    move_over_toolsetter();
                } else {
                    move_to_safe_z();
                    move_over_toolsetter();
                }
                if (!_probe_gauge_length_valid) {
                    log_warn("ATC:" << name() << " T" << int(PROBE_TOOL) << "'s gauge length isn't set yet -- see M101 T" << int(PROBE_TOOL)
                             << " Q<value>");
                    return false;
                } else {
                    _macro.addf("G4P0.1");
                    _macro.addf("(MSG: Install probe #%d)", PROBE_TOOL);
                    _macro.addf("M0");
                    apply_tlo_from_gauge(_probe_gauge_length);  // TLO = absolute gauge length
                    expose_current_tool_gauge(_probe_gauge_length);
                    _prev_tool = new_tool;
                    move_to_safe_z();
                    save_gauge_table();
                    if (spindle_was_on) {
                        _macro.addf("M3");
                    }
                    if (was_inch_mode) {
                        _macro.addf("G20");
                    }
                    _macro.run(nullptr);
                    return true;
                }
                
            }

            // ---------------------------------------------------------------
            // Rack tool
            // ---------------------------------------------------------------
            if (is_rack_tool(new_tool)) {
                int slot = slot_index(new_tool);

                if (is_rack_tool(_prev_tool)) {
                    move_to_safe_z();
                    drop_tool(slot_index(_prev_tool));
                } else if (_prev_tool != 0) {
                    move_to_safe_z();
                    move_over_toolsetter();
                    _macro.addf("G4P0.1");
                    _macro.addf("(MSG: Remove tool #%d then resume to continue)", _prev_tool);
                    _macro.addf("M0");
                }

                move_to_safe_z();
                pick_tool(slot);

                if (_tool_gauge_valid[slot]) {
                    // Known gauge length -- traditional-changer behaviour,
                    // no touch-off needed.
                    apply_tlo_from_gauge(_tool_gauge[slot]);
                    expose_current_tool_gauge(_tool_gauge[slot]);
                } else {
                    // First time this pocket has been used -- master it.
                    // If an approach estimate was pre-set via M101 Tn
                    // Q<value> (e.g. copied from Fusion's tool library),
                    // use it for a closer, safer approach; otherwise fall
                    // back to the generic manual_gauge constant.
                    float approach = (_tool_gauge[slot] != 0.0f) ? _tool_gauge[slot] : _manual_gauge[0];
                    move_to_safe_z();
                    move_over_toolsetter();
                    probe_toolsetter(approach, false);
                    _macro.addf("#<_atc_measured_z>=[#5063]");
                    _macro.addf("#<_my_tlo_z>=[#5063 + %0.4f]", tlo_constant());
                    _macro.addf("G43.1Z#<_my_tlo_z>");
                    _macro.addf("#<_current_tool_gauge>=[#5063 + %0.4f]", _gauge_setter_length - _ets_reference_probe_z);
                    _macro.addf("#<_current_tool_probe_z>=[#5063]");
                    request_save_gauge(new_tool);
                }

                _prev_tool = new_tool;
                move_to_safe_z();
                save_gauge_table();

                if (spindle_was_on) {
                    _macro.addf("M3");
                }
                if (was_inch_mode) {
                    _macro.addf("G20");
                }
                _macro.run(nullptr);
                return true;
            }

            // ---------------------------------------------------------------
            // Manual tool, outside the rack. Always touched off -- no gauge
            // length is stored for these.
            // ---------------------------------------------------------------
            if (is_rack_tool(_prev_tool)) {
                move_to_safe_z();
                drop_tool(slot_index(_prev_tool));
                move_over_toolsetter();
            } else {
                move_to_safe_z();
                move_over_toolsetter();
            }
            _macro.addf("G4P0.1");
            _macro.addf("(MSG: Install tool #%d then resume to continue)", new_tool);
            _macro.addf("M0");

            move_to_safe_z();
            move_over_toolsetter();
            probe_toolsetter(0.0f, true);  // manual/non-rack tool: uses #<_fusion_tool_gauge> if the post set it, else manual_gauge
            _macro.addf("#<_my_tlo_z>=[#5063 + %0.4f]", tlo_constant());
            _macro.addf("G43.1Z#<_my_tlo_z>");
            _macro.addf("#<_current_tool_gauge>=[#5063 + %0.4f]", _gauge_setter_length - _ets_reference_probe_z);
            _macro.addf("#<_current_tool_probe_z>=[#5063]");

            _prev_tool = new_tool;
            move_to_safe_z();
            save_gauge_table();

            if (spindle_was_on) {
                _macro.addf("M3");
            }
            if (was_inch_mode) {
                _macro.addf("G20");
            }
            _macro.run(nullptr);
            return true;
        } catch (...) { log_info("Exception caught"); }

        return false;
    }

    void Custom_ATC::reset() {
        _is_OK = true;
        _macro.addf("G4 P0.1");
        _macro.addf("G49");  // reset the TLO to 0
        _macro.addf("#<_current_tool_gauge>=0");
        _macro.addf("(MSG: TLO Z reset to 0)");
    }

    void Custom_ATC::move_to_safe_z() { _macro.addf("G53 G0 Z0"); }

    void Custom_ATC::move_over_toolsetter() {
        move_to_safe_z();
        _macro.addf("G53G0X%0.3fY%0.3f", _ets_mpos[0], _ets_mpos[1]);
    }

    // gauge_length here is an absolute gauge length (spindle-end to tip),
    // e.g. from the stored table -- NOT a raw probe reading.
    void Custom_ATC::apply_tlo_from_gauge(float gauge_length) { _macro.addf("G43.1Z%0.4f", gauge_length); }

    void Custom_ATC::expose_current_tool_gauge(float gauge_length) {
        _macro.addf("#<_current_tool_gauge>=%0.4f", gauge_length);
        _macro.addf("#<_current_tool_probe_z>=%0.4f", probe_z_from_absolute_gauge(gauge_length));
    }

    void Custom_ATC::request_save_gauge(tool_t tool_number) { _macro.addf("$ATC/SaveGauge=%s,%d", name(), int(tool_number)); }

    void Custom_ATC::drop_tool(uint8_t slot) {
        tool_t tool_number = tool_t(_first_tool_number + slot);
        move_to_safe_z();
        _macro.addf("(MSG : Dropping off tool #%d)", tool_number);
        float feed_point  = _tool_mpos[slot][1] + _tool_holder[1];  // move z to above tool holder height
        float feed_height = _tool_mpos[slot][2] + _tool_holder[2];  // move z to above tool holder height
        _macro.addf("G53G0X%0.3fY%0.3f", _tool_mpos[slot][0], feed_point);  // move to tool location xy with feed distance offset
        _macro.addf("G53G0Z%0.3f", _tool_mpos[slot][2]);                    // move to tool location z
        _macro.addf("M5");                                                      // turn off spindle
        _macro.addf("G4 P%0.3f", _spindle_stop_time);                                                    // wait for spindle to stop
        _macro.addf("G53G0Y%0.3f", _tool_mpos[slot][1]);                    // move tool into rack
        _macro.addf("M62 P0");                                              // air on
        _macro.addf("G4 P1");                                             // wait for air to unlock
        _macro.addf("G53G0Z%0.3f", feed_height);                            // lift off tool holder
        _macro.addf("M63 P0");                                              // air off
        move_to_safe_z();
    }

    void Custom_ATC::pick_tool(uint8_t slot) {
        tool_t tool_number = tool_t(_first_tool_number + slot);
        move_to_safe_z();
        _macro.addf("(MSG : Picking up tool #%d)", tool_number);
        float feed_height = _tool_mpos[slot][2] + _tool_holder[2];  // move z to above tool holder height
        float feed_point  = _tool_mpos[slot][1] + _tool_holder[1];  // move z to above tool holder height
        _macro.addf("G53G0X%0.3fY%0.3f", _tool_mpos[slot][0], _tool_mpos[slot][1]);  // move to tool location
        _macro.addf("M8"); 
        _macro.addf("G4 P%0.3f", _coolant_on_time);                                                          // Flood coolant to wash chips off taper
        _macro.addf("G53G0Z%0.3f", feed_height);
        _macro.addf("M9");
        _macro.addf("M62 P0"); 
        _macro.addf("G4 P1");                                // air on
        _macro.addf("G53G1Z%0.3fF1000", _tool_mpos[slot][2]);   // drop down onto tool
        _macro.addf("M63 P0");                                  // air off
        _macro.addf("G4 P1");                                   // wait for air to lock
        _macro.addf("G53G0Y%0.3f", feed_point);                 // move tool into rack
        move_to_safe_z();
    }

    // Unified toolsetter probe. Three staged descents:
    //   Stage 1  blind but always-safe rapid: positions the spindle nose so
    //            that even the LONGEST possible tool (manual_gauge) has its
    //            tip at the rapid clearance plane above the setter.
    //   Stage 2  fast probe-protected (G38.3) approach using this tool's
    //            best-known gauge, so we can rapid in close without risk --
    //            a wrong estimate just trips the probe early instead of
    //            crashing.
    //   Stage 3  precision G38.2 measurement (coarse then fine), driving no
    //            further than the configured over-travel below the setter
    //            top surface.
    //
    // Geometry (machine coords, Z negative-down, setter top = _ets_mpos[2]):
    //   tip target plane   = _ets_mpos[2] + _ets_rapid_z_offset
    //   spindle-nose Z      = tip target plane + gauge_length
    //   (longer tool => bigger gauge => higher/less-negative nose => tip
    //    still lands on the same plane)
    //
    // approach_gauge_estimate: this tool's gauge length for the stage-2
    //   close approach; 0 => fall back to manual_gauge.
    // use_dynamic_fusion_gauge: if true, stage-2's approach gauge is read at
    //   runtime from #<_fusion_tool_gauge> (set by the post processor for
    //   manual/non-rack tools), falling back to manual_gauge.
    void Custom_ATC::probe_toolsetter(float approach_gauge_estimate, bool use_dynamic_fusion_gauge) {
        // The tip plane we rapid the tool tip down to (a bit above the top
        // surface). Spindle-nose Z is this plus the gauge length.
        const float tip_plane = _ets_mpos[2] + _ets_rapid_z_offset;

        // Resolve the stage-2 approach gauge AND feed.
        //
        // Two cases, both handled the same way conceptually:
        //  - A GOOD per-tool estimate is known -> stage 2 can rapid-approach
        //    (fast feed) to just above the surface, because we know where the
        //    tip is.
        //  - NO estimate (first-time/unknown tool) -> we must assume the tool
        //    is as LONG as possible (max gauge), so the approach stops HIGH
        //    (safe for any real tool), and we go SLOW because we don't
        //    actually know where the tip is.
        //
        // Using the MAX gauge for the unknown case is essential: a longer
        // tool's tip reaches the setter with the nose higher up, so assuming
        // max keeps the nose target above any real tool's trigger point.
        // Using min here (an earlier bug) drove the nose deep and plunged a
        // real, longer tool's tip well past the setter at rapid speed.
        // Stage 1: always-safe rapid to the LONGEST-tool clearance plane. Any
        // real tool's tip stops at or above here regardless of its true gauge.
        const float rapid_plane = tip_plane + _manual_gauge[1];
        _macro.addf("G90 G53 G38.3 Z%0.3f F%0.1f", rapid_plane, _ets_fast_approach_feed);

        // Stage 2: OPTIONAL fast close approach, emitted ONLY when it would
        // actually descend below stage 1. If the approach gauge equals the
        // maximum (i.e. we have no better estimate), stage 2's target is the
        // SAME Z as stage 1 -> a zero-distance G38.3 -> GCode error. So stage 2
        // is skipped in that case and we go straight to the slow stage-3 probe.
        //
        // The approach gauge/feed and the skip decision differ by path:
        if (use_dynamic_fusion_gauge) {
            // Manual/non-rack tool: the gauge is only known at RUNTIME from
            // #<_fusion_tool_gauge>. Default to the safe unknown values, then
            // override if the post set a real gauge. Because the value is
            // runtime, the stage-2 skip must also be a runtime (o-code) guard:
            // emit stage 2 only if the resolved approach gauge is LESS THAN
            // the max (i.e. a real, shorter tool that can descend further).
            _macro.addf("#<_atc_approach_gauge>=%0.3f", _manual_gauge[1]);
            _macro.addf("#<_atc_approach_feed>=%0.1f", _ets_slow_approach_feed);
            _macro.addf("o150 if [EXISTS[#<_fusion_tool_gauge>]]");
            _macro.addf("o151 if [#<_fusion_tool_gauge> GT 0]");
            _macro.addf("#<_atc_approach_gauge>=#<_fusion_tool_gauge>");
            _macro.addf("#<_atc_approach_feed>=%0.1f", _ets_fast_approach_feed);
            _macro.addf("#<_fusion_tool_gauge>=-1");  // invalidate so it can't be reused
            _macro.addf("o151 endif");
            _macro.addf("o150 endif");
            // Runtime skip: only descend if the approach is shorter than max.
            _macro.addf("o152 if [#<_atc_approach_gauge> LT %0.3f]", _manual_gauge[1]);
            _macro.addf("G53 G38.3 Z[%0.3f + #<_atc_approach_gauge>] F#<_atc_approach_feed>", tip_plane);
            _macro.addf("o152 endif");
        } else {
            // Rack tool: the gauge estimate is known HERE in C++, so the skip
            // is a plain C++ decision -- no o-code needed. A real estimate
            // (> the minimum) descends closer and fast; otherwise there is no
            // estimate and stage 2 would collide with stage 1, so we omit it
            // entirely and let the slow stage-3 probe do the work.
            bool have_estimate = (approach_gauge_estimate > _manual_gauge[0]);
            if (have_estimate) {
                _macro.addf("G53 G38.3 Z[%0.3f + %0.3f] F%0.1f", tip_plane, approach_gauge_estimate, _ets_fast_approach_feed);
            }
            // else: no stage 2 -- stage 1 already positioned us; go to stage 3.
        }
        // Stage 3: precision measurement.
        //
        // The G38.2 target is a hard failure FLOOR: the deepest the nose may
        // go before we call the probe failed. Crucially this uses the MIN
        // gauge (shortest possible tool), NOT the approach gauge -- a shorter
        // tool needs the nose deeper to bring its tip to the surface, so min
        // gauge gives the deepest safe target. Any real tool (gauge >= min)
        // therefore triggers BEFORE the nose reaches this floor. Using the
        // approach gauge here (which is MAX for an unknown tool) would make
        // the floor too shallow to ever reach the trigger -> failed-probe
        // alarm. The floor is independent of the stage-2 approach.
        const float probe_floor_tip = _ets_mpos[2] - _ets_probe_overtravel;
        _macro.addf("#<_atc_probe_floor>=[%0.3f + %0.3f]", probe_floor_tip, _manual_gauge[0]);
        _macro.addf("G53 G38.2 Z#<_atc_probe_floor> F200");
        _macro.addf("G53 G38.5 Z0 F200");
        _macro.addf("G53 G0 Z[#5063 + 2]");  // retract before next probe
        _macro.addf("M62 P1");               // air on for dust off
        _macro.addf("G4P1");                 // wait for dust off
        _macro.addf("G53 G38.2 Z#<_atc_probe_floor> F50");
        _macro.addf("M63 P1");  // air off for dust off
    }

    namespace {
        ATCFactory::InstanceBuilder<Custom_ATC> registration("atc_custom");
    }
}

// ------------------------------------------------------------------
// $ATC/SaveGauge=<atc_name>,<tool_number>  bridge command.
//
// This exists because a running macro executes asynchronously relative to
// the C++ code that queued it (see Job::nest()/MacroChannel), so the ATC
// class can't just read back a freshly-probed value after calling
// _macro.run(). Instead, the macro stores the probed value into the global
// named parameter #<_atc_measured_z>, then calls this command, which reads
// it back (via get_global_named_param(), Parameters.h) and hands it to the
// matching Custom_ATC instance to persist to the SD card.
// tool_number == GAUGE_SETTER_TOOL (100) means "this calibrates the
// toolsetter reference", otherwise it must be one of that instance's rack
// tools. Registered in ProcessSettings.cpp's make_user_commands().
// ------------------------------------------------------------------
Error atc_save_gauge_command(const char* value, AuthenticationLevel auth_level, Channel& out) {
    if (!value) {
        return Error::InvalidValue;
    }
    std::string s(value);
    auto        comma = s.find(',');
    if (comma == std::string::npos) {
        return Error::InvalidValue;
    }
    std::string name = s.substr(0, comma);
    int         tool = atoi(s.substr(comma + 1).c_str());
    auto*       atc  = ATCs::Custom_ATC::find(name);
    if (!atc) {
        log_error("ATC '" << name.c_str() << "' not found for $ATC/SaveGauge");
        return Error::InvalidValue;
    }
    return atc->commit_measured_gauge(tool_t(tool)) ? Error::Ok : Error::InvalidValue;
}