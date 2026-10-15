(ProbePartialBoss.nc)
(Centre of a PARTIAL circular BOSS - an external arc that cannot be reached all the way round)
(Fusion cycles: "probing-xy-circular-partial-boss")
()
(Three touches on the reachable arc, solved as the exact circle through)
(three points. Three points define a circle uniquely, so there is no)
(fitting or averaging involved -- but each touch is itself runout)
(compensated by _ProbeSurface.nc, which is what makes the solution)
(trustworthy: with raw touches the eccentricity would shift each point by)
(a different amount depending on its approach angle, and the fitted centre)
(would be wrong in a way that is hard to see.)
()
(The three angles are degrees CCW from +X and come from FUSION, which)
(knows which part of the arc is actually reachable.)
()
(EXTERNAL: the nominal centre is solid material, so the probe can never)
(pass through it. Each touch lifts to #<_probe_retract_z>, traverses to a)
(point OUTSIDE the boss, descends beside it, and probes INWARD.)

$SD/Run=/Probing/ProbeInit.nc
o1800 if [EXISTS[#<_probe_angle_1>]]
o1800 else
#<_probe_angle_1>=210
o1800 endif
o1801 if [EXISTS[#<_probe_angle_2>]]
o1801 else
#<_probe_angle_2>=270
o1801 endif
o1802 if [EXISTS[#<_probe_angle_3>]]
o1802 else
#<_probe_angle_3>=330
o1802 endif
o1803 if [EXISTS[#<_probe_diameter>]]
o1803 else
#<_probe_diameter>=0
o1803 endif

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

o1804 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - partial boss probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o1804 endif

(--- ball-centre standoff: boss radius, plus the gap, plus the ball ---)
#<_stand>=[[#<_probe_diameter> / 2] + #<_probe_clearance> + #<_probe_tool_radius>]

(--- touch 1 ---)
#<_ang>=#<_probe_angle_1>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1805 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1805 endif
#<_lm_l1>=[#<_start_l1> + [#<_ux> * #<_stand>]]
#<_lm_l2>=[#<_start_l2> + [#<_uy> * #<_stand>]]
$SD/Run=/Probing/_LateralMove.nc
o1806 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1806 endif
o1807 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1807 endif
o1808 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1809 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1809 endif
o1808 endif
#<_ps_ux>=[0 - [#<_ux> * #<_probe_lat_ux>]]
#<_ps_uy>=[0 - [[#<_ux> * #<_probe_lat_uy>] + #<_uy>]]
#<_ps_uz>=[0 - [#<_ux> * #<_probe_lat_uz>]]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p1x>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]
#<_p1y>=#<_ps_wy>

(--- touch 2 ---)
#<_ang>=#<_probe_angle_2>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1810 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1810 endif
#<_lm_l1>=[#<_start_l1> + [#<_ux> * #<_stand>]]
#<_lm_l2>=[#<_start_l2> + [#<_uy> * #<_stand>]]
$SD/Run=/Probing/_LateralMove.nc
o1811 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1811 endif
o1812 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1812 endif
o1813 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1814 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1814 endif
o1813 endif
#<_ps_ux>=[0 - [#<_ux> * #<_probe_lat_ux>]]
#<_ps_uy>=[0 - [[#<_ux> * #<_probe_lat_uy>] + #<_uy>]]
#<_ps_uz>=[0 - [#<_ux> * #<_probe_lat_uz>]]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p2x>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]
#<_p2y>=#<_ps_wy>

(--- touch 3 ---)
#<_ang>=#<_probe_angle_3>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1815 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1815 endif
#<_lm_l1>=[#<_start_l1> + [#<_ux> * #<_stand>]]
#<_lm_l2>=[#<_start_l2> + [#<_uy> * #<_stand>]]
$SD/Run=/Probing/_LateralMove.nc
o1816 if [ABS[#<_lm_at1> - #<_lm_l1>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1816 endif
o1817 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1817 endif
o1818 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1819 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1819 endif
o1818 endif
#<_ps_ux>=[0 - [#<_ux> * #<_probe_lat_ux>]]
#<_ps_uy>=[0 - [[#<_ux> * #<_probe_lat_uy>] + #<_uy>]]
#<_ps_uz>=[0 - [#<_ux> * #<_probe_lat_uz>]]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p3x>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]
#<_p3y>=#<_ps_wy>

o1820 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1820 endif

(--- circumcentre of the three averaged touch points ---)
(All three ball centres lie on a circle CONCENTRIC with the feature, so)
(their circumcentre IS its centre. The tip radius cancels for the centre)
(and is subtracted only to report the diameter.)
#<_s1>=[[#<_p1x> * #<_p1x>] + [#<_p1y> * #<_p1y>]]
#<_s2>=[[#<_p2x> * #<_p2x>] + [#<_p2y> * #<_p2y>]]
#<_s3>=[[#<_p3x> * #<_p3x>] + [#<_p3y> * #<_p3y>]]
#<_d>=[2 * [[#<_p1x> * [#<_p2y> - #<_p3y>]] + [#<_p2x> * [#<_p3y> - #<_p1y>]] + [#<_p3x> * [#<_p1y> - #<_p2y>]]]]

o1806 if [ABS[#<_d>] LT 0.000001]
    (MSG: PROBE ERROR - the three touch points are collinear, cannot solve a circle)
    $Alarm/Send=3
    G4 P0.1
o1806 endif

#<_cx>=[[[#<_s1> * [#<_p2y> - #<_p3y>]] + [#<_s2> * [#<_p3y> - #<_p1y>]] + [#<_s3> * [#<_p1y> - #<_p2y>]]] / #<_d>]
#<_cy>=[[[#<_s1> * [#<_p3x> - #<_p2x>]] + [#<_s2> * [#<_p1x> - #<_p3x>]] + [#<_s3> * [#<_p2x> - #<_p1x>]]] / #<_d>]

#<_fit_r>=[SQRT[[[#<_p1x> - #<_cx>] * [#<_p1x> - #<_cx>]] + [[#<_p1y> - #<_cy>] * [#<_p1y> - #<_cy>]]]]
#<_probe_meas_dia>=[2 * [#<_fit_r> - #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_dia> - #<_probe_diameter>]
#<_ex>=[#<_cx> - #<_start_l1>]
#<_ey>=[#<_cy> - #<_start_l2>]
#<_probe_dev_pos>=[SQRT[[#<_ex> * #<_ex>] + [#<_ey> * #<_ey>]]]


(--- finish at the measured centre ---)
(Fusion ends the cycle back over the feature centre, so the machine does too:)
(the path it simulated is the path that runs, start to finish.)
()
(The probe is at the retract height by now, and the centre is where the cycle)
(started, so this is the mirror of the move out to the first face.)
#<_lm_l1>=#<_cx>
#<_lm_l2>=#<_cy>
$SD/Run=/Probing/_LateralMove.nc

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing, so emitting)
(N + [P - found] puts the origin on the feature without the probe ever)
(driving back toward it.)
o2702 if [#<_probe_set_origin> GT 0]
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
o2702 else
(MSG: measure only - work offset left untouched)
o2702 endif
(MSG: Partial boss centred from 3 points, WCS X0 Y0 set)

(--- echo the result if Fusion asked for it ---)
o1821 if [#<_probe_print> GT 0]
(PRINT, PROBE partial boss:)
(PRINT,   centre X %.4f#<_cx>  Y %.4f#<_cy> )
(PRINT,   diameter %.4f#<_probe_meas_dia>  nominal %.4f#<_probe_diameter> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2602 if [#<_probe_pause> GT 0]
M0
o2602 endif
o1821 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=11
#<_probe_log_x>=#<_cx>
#<_probe_log_y>=#<_cy>
#<_probe_log_nomsize>=#<_probe_diameter>
#<_probe_log_size>=#<_probe_meas_dia>
o2810 if [#<_probe_log> GT 0]
$Probe/Log
o2810 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
