(SetZZero.nc)
(Run this AFTER manually jogging whatever tool is currently in the spindle)
(down until it just touches the reference surface -- e.g. the paper/feeler)
(method. Sets work Z0 directly from the current raw machine Z and this)
(tool's persisted absolute gauge length, independent of G43.1/TLO modal)
(state. If you used a shim/feeler gauge, set #1 to its thickness below.)

#1=0   (shim/feeler thickness, e.g. paper ~0.05mm -- edit as needed, 0 = none)

o120 if [EXISTS[#<_current_tool_gauge>] EQ 0]
    (MSG: No tool gauge length available -- change to a tool first)
    M30
o120 endif
o121 if [EXISTS[#<_atc_probe_gauge>] EQ 0]
    (MSG: T1 gauge length not set -- run M101 T1 Q<value> first)
    M30
o121 endif

#<_work_z0_offset>=[#<_abs_z> + #<_current_tool_gauge> - #<_atc_probe_gauge> - #1]
G10 L2 P0 Z#<_work_z0_offset>

(MSG: Work Z0 set from current tool's gauge length)
