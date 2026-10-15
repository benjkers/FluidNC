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

o1400 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o1400 endif

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing +X ---)
o1401 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1401 endif
#<_lm_l1>=[#<_start_l1> + [-1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l2>=#<_y>
$SD/Run=/Probing/_LateralMove.nc
o1402 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1402 endif
o1403 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1404 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1404 endif
o1403 endif
#<_ps_ux>=[#<_probe_lat_ux>]
#<_ps_uy>=[#<_probe_lat_uy>]
#<_ps_uz>=[#<_probe_lat_uz>]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]

(--- +X face, probing -X ---)
o1405 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1405 endif
#<_lm_l1>=[#<_start_l1> + [1 * [#<_halfx> + #<_probe_clearance> + #<_probe_tool_radius>]]]
#<_lm_l2>=#<_y>
$SD/Run=/Probing/_LateralMove.nc
o1406 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1406 endif
o1407 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1408 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1408 endif
o1407 endif
#<_ps_ux>=[0 - #<_probe_lat_ux>]
#<_ps_uy>=[0 - #<_probe_lat_uy>]
#<_ps_uz>=[0 - #<_probe_lat_uz>]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] - [2 * #<_probe_eff_radius>]]

o1409 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1409 endif

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_l1>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
o2706 if [#<_probe_set_origin> GT 0]
(--- declare the origin WITHOUT moving ---)
(Where the probe stands, in the same three coordinates.)
#<_o_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_o_l2>=#<_y>
#<_o_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_a>=[#<_probe_nom_l1> + [#<_o_l1> - #<_cx>]]
#<_o_x>=[[#<_o_a> * #<_probe_lat_ux>] + [#<_o_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_o_a> * #<_probe_lat_uy>] + #<_o_l2> + [#<_o_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_o_a> * #<_probe_lat_uz>] + [#<_o_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2706 else
(MSG: measure only - work offset left untouched)
o2706 endif
(MSG: X wall pair centred, WCS X0 set)

(--- echo the result if Fusion asked for it ---)
o1410 if [#<_probe_print> GT 0]
(PRINT, PROBE X wall pair:)
(PRINT,   centre %.4f#<_cx>  width %.4f#<_probe_meas_x>  nominal %.4f#<_probe_width_x> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2606 if [#<_probe_pause> GT 0]
M0
o2606 endif
o1410 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=6
#<_probe_log_x>=#<_cx>
#<_probe_log_nomsize>=#<_probe_width_x>
#<_probe_log_size>=#<_probe_meas_x>
o2805 if [#<_probe_log> GT 0]
$Probe/Log
o2805 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
