(CheckToolGauge.nc)
(Safety check: compares the tool gauge length Fusion's post processor)
(thinks this tool has (#<_fusion_tool_gauge>, set by the post right before)
(calling this file) against what the machine has recorded for the tool)
(now in the spindle -- #<_current_tool_gauge>, which atc_custom.cpp sets)
(after EVERY tool change: from the stored table for a known rack tool, or)
(from a fresh toolsetter probe for a manual tool. Same check works for)
(both, since #<_current_tool_gauge> is populated either way.)
(If the two disagree by more than the tolerance below, this alarms and)
(stops the job rather than cutting with a wrong/mismeasured tool.)

#2=0.5   (tolerance, mm -- edit for your setup)

o130 if [EXISTS[#<_fusion_tool_gauge>] EQ 0]
    (MSG: CheckToolGauge -- post processor did not provide #<_fusion_tool_gauge>, skipping check)
o130 else
    o131 if [EXISTS[#<_current_tool_gauge>] EQ 0]
        (MSG: CheckToolGauge -- machine has no recorded gauge length for this tool, skipping check)
    o131 else
        #<_gauge_diff>=[ABS[#<_fusion_tool_gauge> - #<_current_tool_gauge>]]
        o132 if [#<_gauge_diff> GT #2]
            (MSG: TOOL LENGTH MISMATCH -- Fusion and machine gauge lengths disagree)
            $Alarm/Send=3
            M30
        o132 endif
    o131 endif
o130 endif
