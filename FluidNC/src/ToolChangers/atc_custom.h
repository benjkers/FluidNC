#pragma once

#include "src/Config.h"

#include "src/Configuration/Configurable.h"

#include "src/Channel.h"
#include "src/Module.h"
#include "atc.h"
#include "../Machine/Macros.h"
namespace ATCs {

    const int TOOL_COUNT = 6;

    class Custom_ATC : public ATC {
    public:
        Custom_ATC(const char* name) : ATC(name) {}

        Custom_ATC(const Custom_ATC&)            = delete;
        Custom_ATC(Custom_ATC&&)                 = delete;
        Custom_ATC& operator=(const Custom_ATC&) = delete;
        Custom_ATC& operator=(Custom_ATC&&)      = delete;

        virtual ~Custom_ATC() = default;

    private:
        // config items
        float              _safe_z           = 50.0;
        float              _probe_seek_rate  = 200.0;
        float              _probe_feed_rate  = 80.0;
        std::vector<float> _ets_mpos         = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        std::vector<float> _manual_change_mpos= { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        float              _manual_gauge     = 100.0;
        float              _ets_rapid_z_mpos = 0;
        std::vector<float> _tool_holder      ={ 0.0, -60, 60, 0.0, 0.0, 0.0 };
        std::vector<float> _tool_mpos[TOOL_COUNT];
        std::vector<float> _tool_gauge ={0.0, 0.0 , 0.0, 0.0, 0.0, 0.0 };;

        bool    _is_OK                   = false;
        uint8_t _prev_tool               = 0;  // TODO This could be a NV setting
        bool    _have_tool_setter_offset = false;
        float   _tool_setter_offset      = 0.0;  // have we established an offset.
        


        void  move_to_safe_z();
        void  move_over_toolsetter();
        void  ets_probe(uint8_t tool_index);
        void  get_ets_offset();
        void  reset();
        void  drop_tool(uint8_t tool_index);
        void  pick_tool(uint8_t tool_index);


        Macro _macro;
    public:
        void init() override;
        void probe_notification() override;
        virtual bool tool_change(uint8_t value, bool pre_select, bool set_tool) override;
        void validate() override {}
       
        void group(Configuration::HandlerBase& handler) override {
            handler.item("safe_z_mpos_mm", _safe_z, -100000, 100000);
            handler.item("probe_seek_rate_mm_per_min", _probe_seek_rate, 1, 10000);
            handler.item("probe_feed_rate_mm_per_min", _probe_feed_rate, 1, 10000);
            handler.item("ets_mpos_mm", _ets_mpos);
            handler.item("manual_gauge_mm", _manual_gauge);
            handler.item("ets_rapid_z_mpos_mm", _ets_rapid_z_mpos);
            handler.item("tool1_mpos_mm", _tool_mpos[0]);
            handler.item("tool2_mpos_mm", _tool_mpos[1]);
            handler.item("tool3_mpos_mm", _tool_mpos[2]);
            handler.item("tool4_mpos_mm", _tool_mpos[3]);
            handler.item("tool5_mpos_mm", _tool_mpos[4]);
            handler.item("tool6_mpos_mm", _tool_mpos[5]);
            handler.item("tool1_gauge_mm", _tool_gauge[0]);
            handler.item("tool2_gauge_mm", _tool_gauge[1]);
            handler.item("tool3_gauge_mm", _tool_gauge[2]);
            handler.item("tool4_gauge_mm", _tool_gauge[3]);
            handler.item("tool5_gauge_mm", _tool_gauge[4]);
            handler.item("tool6_gauge_mm", _tool_gauge[5]);
            handler.item("tool_holder_pulloff_mm", _tool_holder);
           
        }

    };   
}

