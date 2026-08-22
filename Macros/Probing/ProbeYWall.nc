(ProbeYWall.nc)
(Centre of a wall pair - the two outside faces either side of a part, across Y)
(Fusion cycles: "probing-y-wall")
()
(EXTERNAL: the probe goes OUT past each face and probes back INWARD.)
(It lifts to #<_probe_retract_z> -- Fusion's Retract Height, which is)
(referenced to stock top and so clears the part -- before every)
(traverse, and descends only once it is beside the face.)
()
(The probe NEVER descends at a feature centre -- only at a standoff)
(beside a face it is about to touch. Descending at the centre would)
(mean landing on an island, or inside a boss.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

o720 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o720 endif

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y face, probing +Y ---)
o721 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o721 endif
G53 G38.3 Y[#<_start_abs_y> + [-1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o722 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o722 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_y>

(--- +Y face, probing -Y ---)
o723 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o723 endif
G53 G38.3 Y[#<_start_abs_y> + [1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o724 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o724 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_y>

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] - [2 * #<_probe_eff_radius>]]

o725 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o725 endif

#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_cy> - #<_start_abs_y>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
G10 L20 P#<_probe_wcs> Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
(MSG: Y wall pair centred, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
