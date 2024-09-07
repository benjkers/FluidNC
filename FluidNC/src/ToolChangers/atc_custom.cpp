
#include "atc_custom.h"
#include "../Machine/MachineConfig.h"
#include <cstdio>
#include <iostream>



namespace ATCs {
    void Custom_ATC::init() {
        log_info("ATC:" << name());
    }

    void Custom_ATC::probe_notification() {}

    bool Custom_ATC::tool_change(uint8_t new_tool, bool pre_select, bool set_tool) {
        bool spindle_was_on = false;  // used to restore the spindle state
        bool was_inch_mode  = false;  // allows use to restore inch mode if req'd

        protocol_buffer_synchronize();  // wait for all motion to complete
        _macro.erase();             // clear previous gcode

        // M6T0 is used to reset this ATC and allow us to start a new job
        if (new_tool == 0 || set_tool) {
            
            if(_prev_tool>0 && _prev_tool<=TOOL_COUNT){
                move_to_safe_z();
                drop_tool(_prev_tool);
            }
            _prev_tool = new_tool;
            move_to_safe_z();
            move_over_toolsetter();
            reset();
            _macro.run(nullptr);
            return true;
        }
        if (new_tool == 100 || set_tool) { // if new tool is 100 hard reset doesnt drop off tool
            _prev_tool = new_tool;
            move_to_safe_z();
            move_over_toolsetter();
            reset();
            _macro.run(nullptr);
            return true;
        }

        was_inch_mode = (gc_state.modal.units == Units::Inches);

        if (was_inch_mode) {
            _macro.addf("G21");
        }

        try {
            if (_prev_tool == 0) {  // M6T<anything> from T0 is used for a change before zero'ing

                if(new_tool<=TOOL_COUNT){
                    move_to_safe_z();
                    pick_tool(new_tool); 
                } 
                else{
                    move_over_toolsetter();
                    _macro.addf("G4P0 0.1");
                    _macro.addf("G43.1Z0.000");
                    _macro.addf("(MSG : Install tool #%d)", new_tool);
                }
                
                if (was_inch_mode) {
                    _macro.addf("G20");
                }
                _macro.run(nullptr);
                _prev_tool = new_tool;
                return true;
            }

            // save current location, so we can return after the tool change.
            _macro.addf("#<start_x >= #<_x>");
            _macro.addf("#<start_y >= #<_y>");
            _macro.addf("#<start_z >= #<_z>");

            move_to_safe_z();

            // turn off the spindle
            if (gc_state.modal.spindle != SpindleState::Disable) {
                spindle_was_on = true;
                _macro.addf("M5");
            }

            // if we have not determined the tool setter offset yet, we need to do that.
            if (!_have_tool_setter_offset) {
                move_over_toolsetter();
                ets_probe(_prev_tool);
                _macro.addf("#<_ets_tool1_z>=[#5063]");  // save the value of the tool1 ETS Z
                _have_tool_setter_offset = true;
            }

            // if new and old tool live in the ATC rack 
            if((new_tool<=TOOL_COUNT) && (_prev_tool<=TOOL_COUNT)){ 
                    move_to_safe_z();
                    drop_tool(_prev_tool);
                    pick_tool(new_tool); 
            }
            // is new tool lives in the ATC rack but old tool is manual
            else if ((new_tool<=TOOL_COUNT) && !(_prev_tool<=TOOL_COUNT)){
                move_to_safe_z();
                move_over_toolsetter();
                _macro.addf("G4P0 0.1");
                _macro.addf("(MSG: Remove tool #%d then resume to continue)", _prev_tool);
                _macro.addf("M0");
                pick_tool(new_tool);
            }
            // is new tool is manual but old tool lives in the ATC rack
            else if(!(new_tool<=TOOL_COUNT) && (_prev_tool<=TOOL_COUNT)){
                move_to_safe_z();
                drop_tool(_prev_tool);
                move_over_toolsetter();
                _macro.addf("G4P0 0.1");
                _macro.addf("(MSG: Install tool #%d then resume to continue)", new_tool);
                _macro.addf("M0");
            }
            // else both tools are manual 
            else{
                move_to_safe_z();
                _macro.addf("G4P0 0.1");
                move_over_toolsetter();
                _macro.addf("G4P0 0.1");
                _macro.addf("(MSG: Install tool #%d then resume to continue)", new_tool);
                _macro.addf("M0");
            } 

            

            // probe the new tool
            move_to_safe_z();
            move_over_toolsetter();
            ets_probe(new_tool);

            _prev_tool = new_tool; // reseting the old tool as the neww new tool

            // TLO is simply the difference between the tool1 probe and the new tool probe.
            _macro.addf("#<_my_tlo_z >=[#5063 - #<_ets_tool1_z>]");
            _macro.addf("G43.1Z#<_my_tlo_z>");

            move_to_safe_z();

            if (spindle_was_on) {
                _macro.addf("M3");  // spindle should handle spinup delay
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
        _is_OK                   = true;
        _have_tool_setter_offset = false;
       // _prev_tool               = gc_state.tool;  // Double check this
        _macro.addf("G4 P0.1");     
        _macro.addf("G49");                 // reset the TLO to 0
        _macro.addf("(MSG: TLO Z reset to 0)");    //
    }

    void Custom_ATC::move_to_safe_z() {
        _macro.addf("G53G0Z%0.3f", _safe_z);
    }

    void Custom_ATC::move_over_toolsetter() {
        move_to_safe_z();
        _macro.addf("G53G0X%0.3fY%0.3f", _ets_mpos[0], _ets_mpos[1]);
    }

    void Custom_ATC::drop_tool(uint8_t tool_index) {
        move_to_safe_z();
        _macro.addf("(MSG : Dropping of tool #%d)", tool_index);
        tool_index -= 1;
        float feed_point=0;
        float feed_height=0;
        feed_point=_tool_mpos[tool_index][1]+_tool_holder[1]; // move z to above tool holder height
        feed_height=_tool_mpos[tool_index][2]+_tool_holder[2]; // move z to above tool holder height
        _macro.addf("G53G0X%0.3fY%0.3f",_tool_mpos[tool_index][0],feed_point); // move to tool location xy with feed distance offset
        _macro.addf("G53G0Z%0.3f",_tool_mpos[tool_index][2]); // move to tool location z
        _macro.addf("G53G0Y%0.3f",_tool_mpos[tool_index][1]); // move tool into rack
        _macro.addf("M62 P0"); // air on
        _macro.addf("G4 P0.5"); // wait for air to unlock 
        _macro.addf("G53G0Z%0.3f",feed_height); // lift off tool holder
        _macro.addf("M63 P0"); // air off
        move_to_safe_z();
        
    }

    void Custom_ATC::pick_tool(uint8_t tool_index) {
        move_to_safe_z();
        _macro.addf("(MSG : Picking up tool #%d)", tool_index);
        tool_index -= 1;
        float feed_height=0;
        float feed_point=0;
        feed_height=_tool_mpos[tool_index][2]+_tool_holder[2]; // move z to above tool holder height
        feed_point=_tool_mpos[tool_index][1]+_tool_holder[1]; // move z to above tool holder height
        _macro.addf("G53G0X%0.3fY%0.3f",_tool_mpos[tool_index][0],_tool_mpos[tool_index][1]); // move to tool location
        _macro.addf("G53G0Z%0.3f",feed_height);
        _macro.addf("M62 P0"); // air on
        _macro.addf("G53G0Z%0.3f",_tool_mpos[tool_index][2]); // Drop down ontop of tool
        _macro.addf("M63 P0"); // air on 
        _macro.addf("G4 P0.5"); // wait for air to lock 
        _macro.addf("G53G0Y%0.3f",feed_point); // move tool into rack
        move_to_safe_z();
    }


    void Custom_ATC::ets_probe(uint8_t tool_index) { 
        tool_index -= 1;
        if (tool_index<=TOOL_COUNT-1){
            float probe_height_offset=_ets_rapid_z_mpos+_tool_gauge[tool_index]; 
            _macro.addf("G53G0Z%0.3f",probe_height_offset);  // rapid down
            
        }
        else{
            float probe_height_offset=_ets_rapid_z_mpos+_manual_gauge; 
            _macro.addf("G53G0Z%0.3f",probe_height_offset);  // rapid down
             
        }
        // do a fast probe if there is a seek that is faster than feed
        if (_probe_seek_rate > _probe_feed_rate) {
            _macro.addf("G53 G38.2 Z%0.3f F%0.3f", _ets_mpos[2], _probe_seek_rate);
            _macro.addf("G0Z[#<_z> + 5]");  // retract befor next probe
        }

        // do the feed rate probe
        _macro.addf("M62 P1"); // air on for dust off
        _macro.addf("G4P1"); // wait for dust off
        _macro.addf("G53 G38.2 Z%0.3f F%0.3f", _ets_mpos[2], _probe_feed_rate);
        _macro.addf("M63 P1"); // air off for dust off
    }

    namespace {
        ATCFactory::InstanceBuilder<Custom_ATC> registration("atc_custom");
    }
}
