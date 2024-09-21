(Break Detection Macro)
#<_tool_break_check>=[ABS[#5063-#<_ets_tool_first_z>-#<_my_tlo_z >]]
D#<_tool_break_check>)
o102 if [#<_tool_break_check> GT 0.2].
G53G0Z0
G53G0X0Y0
M5
M9
(Tool Broken)
$Alarm/Send=13
M30 
o102 endif 