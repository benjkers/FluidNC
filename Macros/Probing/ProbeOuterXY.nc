(ProbeOuterXY.nc)
(Centre of an external feature - circular or rectangular boss)
(Fusion cycles: "probing-xy-circular-boss" and "probing-xy-rectangular-boss")
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

o360 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o360 endif

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing +X ---)
o361 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o361 endif
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o362 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o362 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>

(--- +X face, probing -X ---)
o363 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o363 endif
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]] F#<_probe_feed_link>
o364 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o364 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] - [2 * #<_probe_eff_radius>]]

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y face, probing +Y ---)
o365 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o365 endif
#<_sy>=[#<_start_abs_y> + [-1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
G53 G38.3 X#<_cx> Y#<_sy> F#<_probe_feed_link>
o366 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o366 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_y>

(--- +Y face, probing -Y ---)
o367 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o367 endif
#<_sy>=[#<_start_abs_y> + [1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
G53 G38.3 X#<_cx> Y#<_sy> F#<_probe_feed_link>
o368 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o368 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_y>

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] - [2 * #<_probe_eff_radius>]]

o369 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o369 endif

#<_probe_meas_dia>=[[#<_probe_meas_x> + #<_probe_meas_y>] / 2]
#<_probe_dev_size>=[[[#<_probe_meas_x> - #<_probe_width_x>] + [#<_probe_meas_y> - #<_probe_width_y>]] / 2]
#<_ex>=[#<_cx> - #<_start_abs_x>]
#<_ey>=[#<_cy> - #<_start_abs_y>]
#<_probe_dev_pos>=[SQRT[[#<_ex> * #<_ex>] + [#<_ey> * #<_ey>]]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]] Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
(MSG: Boss centred, WCS X0 Y0 set)

(--- echo the result if Fusion asked for it ---)
o918 if [#<_probe_print> GT 0]
(PRINT, PROBE boss:)
(PRINT,   centre X %.4f#<_cx>  Y %.4f#<_cy> )
(PRINT,   size X %.4f#<_probe_meas_x>  Y %.4f#<_probe_meas_y>  mean %.4f#<_probe_meas_dia> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o918 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
