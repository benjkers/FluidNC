(ProbeZSetZero.nc)
(Probes straight down at the current XY position with whatever tool is)
(currently in the spindle -- normally the probe, T1 -- and sets work Z0)
(directly from the raw machine-coordinate probe result and this tool's)
(persisted absolute gauge length. This does NOT rely on G43.1/TLO modal)
(state being correct at the time it runs; it computes the work offset)
(from #<_current_tool_gauge> and #<_atc_probe_gauge>, both maintained by)
(atc_custom.cpp on every tool change.)
(EDIT the travel distance (25mm) and feed rates for your machine before use.)

o110 if [EXISTS[#<_current_tool_gauge>] EQ 0]
    (MSG: No tool gauge length available -- change to a tool first)
    M30
o110 endif
o111 if [EXISTS[#<_atc_probe_gauge>] EQ 0]
    (MSG: T1 gauge length not set -- run M101 T1 Q<value> first)
    M30
o111 endif

(fast approach)
G53 G38.2 Z[#<_abs_z>-25] F200
G4 P0.1
G53 G0 Z[#5063+2]

(slow, accurate probe)
G53 G38.2 Z[#<_abs_z>-25] F40
G4 P0.1

#<_work_z0_offset>=[#5063 + #<_current_tool_gauge> - #<_atc_probe_gauge>]
G10 L2 P0 Z#<_work_z0_offset>

G53 G0 Z[#5063+5]
(MSG: Work Z0 set from probe)
