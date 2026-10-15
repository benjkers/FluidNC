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

(--- where we started, in LATERAL-PLANE coordinates ---)
(l1 is the written direction that comes out as machine X; l2 is written Y,)
(which B never rotates. Both are perpendicular to the tool axis, so a move in)
(this plane never changes height.)
()
(This used to capture #<_abs_*> and replay it under G53. Those are different)
(frames once TCP is on -- see _LateralMove.nc -- and at B90 the mismatch was)
(worth 67 mm. Everything here is now the WORK frame, start to finish.)
#<_start_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_start_l2>=#<_y>

o1600 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o1600 endif

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing +X ---)
o1601 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1601 endif
#<_lm_l1>=[#<_start_l1> + [-1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l2>=#<_y>
$SD/Run=/Probing/_LateralMove.nc
o1602 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1602 endif
o1603 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1604 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1604 endif
o1603 endif
#<_ps_ux>=[#<_probe_lat_ux>]
#<_ps_uy>=[#<_probe_lat_uy>]
#<_ps_uz>=[#<_probe_lat_uz>]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]

(--- +X face, probing -X ---)
o1605 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1605 endif
#<_lm_l1>=[#<_start_l1> + [1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l2>=#<_y>
$SD/Run=/Probing/_LateralMove.nc
o1606 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1606 endif
o1607 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1608 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1608 endif
o1607 endif
#<_ps_ux>=[0 - #<_probe_lat_ux>]
#<_ps_uy>=[0 - #<_probe_lat_uy>]
#<_ps_uz>=[0 - #<_probe_lat_uz>]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] - [2 * #<_probe_eff_radius>]]

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y face, probing +Y ---)
o1609 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1609 endif
#<_sy>=[#<_start_l2> + [-1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l1>=#<_cx>
#<_lm_l2>=#<_sy>
$SD/Run=/Probing/_LateralMove.nc
o1610 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1610 endif
o1611 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1611 endif
o1612 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1613 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1613 endif
o1612 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_wy>

(--- +Y face, probing -Y ---)
o1614 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1614 endif
#<_sy>=[#<_start_l2> + [1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l1>=#<_cx>
#<_lm_l2>=#<_sy>
$SD/Run=/Probing/_LateralMove.nc
o1615 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1615 endif
o1616 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1616 endif
o1617 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1618 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1618 endif
o1617 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_wy>

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] - [2 * #<_probe_eff_radius>]]

o1619 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1619 endif

#<_probe_meas_dia>=[[#<_probe_meas_x> + #<_probe_meas_y>] / 2]
#<_probe_dev_size>=[[[#<_probe_meas_x> - #<_probe_width_x>] + [#<_probe_meas_y> - #<_probe_width_y>]] / 2]
#<_ex>=[#<_cx> - #<_start_l1>]
#<_ey>=[#<_cy> - #<_start_l2>]
#<_probe_dev_pos>=[SQRT[[#<_ex> * #<_ex>] + [#<_ey> * #<_ey>]]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
o2701 if [#<_probe_set_origin> GT 0]
(--- declare the origin WITHOUT moving ---)
(Where the probe stands, in the same three coordinates.)
#<_o_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_o_l2>=#<_y>
#<_o_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_a>=[#<_probe_nom_l1> + [#<_o_l1> - #<_cx>]]
#<_o_b>=[#<_probe_nom_l2> + [#<_o_l2> - #<_cy>]]
#<_o_x>=[[#<_o_a> * #<_probe_lat_ux>] + [#<_o_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_o_a> * #<_probe_lat_uy>] + #<_o_b> + [#<_o_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_o_a> * #<_probe_lat_uz>] + [#<_o_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2701 else
(MSG: measure only - work offset left untouched)
o2701 endif
(MSG: Boss centred, WCS X0 Y0 set)

(--- echo the result if Fusion asked for it ---)
o1620 if [#<_probe_print> GT 0]
(PRINT, PROBE boss:)
(PRINT,   centre X %.4f#<_cx>  Y %.4f#<_cy> )
(PRINT,   size X %.4f#<_probe_meas_x>  Y %.4f#<_probe_meas_y>  mean %.4f#<_probe_meas_dia> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2601 if [#<_probe_pause> GT 0]
M0
o2601 endif
o1620 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=9
#<_probe_log_x>=#<_cx>
#<_probe_log_y>=#<_cy>
#<_probe_log_nomsize>=#<_probe_width_x>
#<_probe_log_size>=#<_probe_meas_dia>
o2808 if [#<_probe_log> GT 0]
$Probe/Log
o2808 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
