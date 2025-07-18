(Break Detection Macro)
G53 G0 Z-1
G53 G0 X[#<_etsx>] Y[#<_etsy>]

G53 G38.3 Z[#<_etszrapid>] F3500

G53 G38.2 Z[#<_etsz>] F200
G53 G38.5 Z0 F200
G53 G0 Z[#5063 + 2]
M62 P1
G4 P1
G53 G38.2 Z[#<_etsz>] F50

#<_tool_break_check>=[ABS[#5063-#<_ets_tool_first_z>-#<_my_tlo_z >]]
D#<_tool_break_check>
o100 if [#<_tool_break_check> GT 0.2]
    G53G0Z0
    G53G0X0Y0
    M5
    M9
    (Tool Broken)
    $Alarm/Send=3
    M30 
o100 elseif
    G53G0Z0
o100 endif 