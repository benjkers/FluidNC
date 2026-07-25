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
M63 P1
(Compares this fresh probe reading to the raw toolsetter-trigger Z we)
(EXPECT for whatever tool is currently in the spindle -- see)
(atc_custom.cpp's #<_current_tool_probe_z>. Both are raw machine-Z)
(readings, so no further gauge-length math is needed here. Note this is)
(different from #<_current_tool_gauge>, which is an absolute physical)
(gauge length used by ProbeZSetZero.nc/SetZZero.nc, not a machine Z.)
#<_tool_break_check>=[ABS[#5063-#<_current_tool_probe_z>]]
D#<_tool_break_check>
o100 if [#<_tool_break_check> GT 0.2]
    G53G0Z0
    G53G0X0Y0
    M5
    M9
    (Tool Broken)
    $Alarm/Send=3
    M30 
o100 else
    G53 G0 Z0
o100 endif 