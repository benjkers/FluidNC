(ProbeXWall.nc)
(Centre of a wall pair - the two outside faces either side of a part, across X)
(Fusion cycles: "probing-x-wall")
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

o700 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o700 endif

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing +X ---)
o701 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o701 endif
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o702 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o702 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>

(--- +X face, probing -X ---)
o703 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o703 endif
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o704 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o704 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] - [2 * #<_probe_eff_radius>]]

o705 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o705 endif

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_abs_x>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]]
(MSG: X wall pair centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
