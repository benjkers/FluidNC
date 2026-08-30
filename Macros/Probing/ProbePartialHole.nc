(ProbePartialHole.nc)
(Centre of a PARTIAL circular hole - an arc that cannot be reached all the way round)
(Fusion cycles: "probing-xy-circular-partial-hole" and its island variant)
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
(INTERNAL: the probe works outward from the nominal centre. Set)
(#<_probe_lift> for an island, and it travels at #<_probe_retract_z>)
(between touches instead of through it.)

$SD/Run=/Probing/ProbeInit.nc
o1700 if [EXISTS[#<_probe_angle_1>]]
o1700 else
#<_probe_angle_1>=210
o1700 endif
o1701 if [EXISTS[#<_probe_angle_2>]]
o1701 else
#<_probe_angle_2>=270
o1701 endif
o1702 if [EXISTS[#<_probe_angle_3>]]
o1702 else
#<_probe_angle_3>=330
o1702 endif
o1703 if [EXISTS[#<_probe_diameter>]]
o1703 else
#<_probe_diameter>=0
o1703 endif

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

(--- ball-centre standoff: bore radius, less the gap, less the ball ---)
#<_stand>=[[#<_probe_diameter> / 2] - #<_probe_clearance> - #<_probe_tool_radius>]
o1704 if [#<_stand> LT 0]
#<_stand>=0
o1704 endif

(--- touch 1 ---)
#<_ang>=#<_probe_angle_1>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1705 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1705 endif
#<_tgx>=[#<_start_abs_x> + [#<_ux> * #<_stand>]]
#<_tgy>=[#<_start_abs_y> + [#<_uy> * #<_stand>]]
G53 G38.3 X#<_tgx> Y#<_tgy> F#<_probe_feed_link>
o1706 if [ABS[#<_abs_x> - #<_tgx>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1706 endif
o1707 if [ABS[#<_abs_y> - #<_tgy>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1707 endif
o1708 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1709 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1709 endif
o1708 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p1x>=#<_ps_x>
#<_p1y>=#<_ps_y>

(--- touch 2 ---)
#<_ang>=#<_probe_angle_2>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1710 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1710 endif
#<_tgx>=[#<_start_abs_x> + [#<_ux> * #<_stand>]]
#<_tgy>=[#<_start_abs_y> + [#<_uy> * #<_stand>]]
G53 G38.3 X#<_tgx> Y#<_tgy> F#<_probe_feed_link>
o1711 if [ABS[#<_abs_x> - #<_tgx>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1711 endif
o1712 if [ABS[#<_abs_y> - #<_tgy>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1712 endif
o1713 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1714 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1714 endif
o1713 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p2x>=#<_ps_x>
#<_p2y>=#<_ps_y>

(--- touch 3 ---)
#<_ang>=#<_probe_angle_3>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o1715 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1715 endif
#<_tgx>=[#<_start_abs_x> + [#<_ux> * #<_stand>]]
#<_tgy>=[#<_start_abs_y> + [#<_uy> * #<_stand>]]
G53 G38.3 X#<_tgx> Y#<_tgy> F#<_probe_feed_link>
o1716 if [ABS[#<_abs_x> - #<_tgx>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1716 endif
o1717 if [ABS[#<_abs_y> - #<_tgy>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1717 endif
o1718 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1719 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1719 endif
o1718 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p3x>=#<_ps_x>
#<_p3y>=#<_ps_y>

o1720 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1720 endif

(--- circumcentre of the three averaged touch points ---)
(All three ball centres lie on a circle CONCENTRIC with the feature, so)
(their circumcentre IS its centre. The tip radius cancels for the centre)
(and is added only to report the diameter.)
#<_s1>=[[#<_p1x> * #<_p1x>] + [#<_p1y> * #<_p1y>]]
#<_s2>=[[#<_p2x> * #<_p2x>] + [#<_p2y> * #<_p2y>]]
#<_s3>=[[#<_p3x> * #<_p3x>] + [#<_p3y> * #<_p3y>]]
#<_d>=[2 * [[#<_p1x> * [#<_p2y> - #<_p3y>]] + [#<_p2x> * [#<_p3y> - #<_p1y>]] + [#<_p3x> * [#<_p1y> - #<_p2y>]]]]

o1721 if [ABS[#<_d>] LT 0.000001]
    (MSG: PROBE ERROR - the three touch points are collinear, cannot solve a circle)
    $Alarm/Send=3
    G4 P0.1
o1721 endif

#<_cx>=[[[#<_s1> * [#<_p2y> - #<_p3y>]] + [#<_s2> * [#<_p3y> - #<_p1y>]] + [#<_s3> * [#<_p1y> - #<_p2y>]]] / #<_d>]
#<_cy>=[[[#<_s1> * [#<_p3x> - #<_p2x>]] + [#<_s2> * [#<_p1x> - #<_p3x>]] + [#<_s3> * [#<_p2x> - #<_p1x>]]] / #<_d>]

#<_fit_r>=[SQRT[[[#<_p1x> - #<_cx>] * [#<_p1x> - #<_cx>]] + [[#<_p1y> - #<_cy>] * [#<_p1y> - #<_cy>]]]]
#<_probe_meas_dia>=[2 * [#<_fit_r> + #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_dia> - #<_probe_diameter>]
#<_ex>=[#<_cx> - #<_start_abs_x>]
#<_ey>=[#<_cy> - #<_start_abs_y>]
#<_probe_dev_pos>=[SQRT[[#<_ex> * #<_ex>] + [#<_ey> * #<_ey>]]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing, so emitting)
(N + [P - found] puts the origin on the feature without the probe ever)
(driving back toward it.)
o2703 if [#<_probe_set_origin> GT 0]
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]] Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
o2703 else
(MSG: measure only - work offset left untouched)
o2703 endif
(MSG: Partial hole centred from 3 points, WCS X0 Y0 set)

(--- echo the result if Fusion asked for it ---)
o1722 if [#<_probe_print> GT 0]
(PRINT, PROBE partial hole:)
(PRINT,   centre X %.4f#<_cx>  Y %.4f#<_cy> )
(PRINT,   diameter %.4f#<_probe_meas_dia>  nominal %.4f#<_probe_diameter> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2603 if [#<_probe_pause> GT 0]
M0
o2603 endif
o1722 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=10
#<_probe_log_x>=#<_cx>
#<_probe_log_y>=#<_cy>
#<_probe_log_nomsize>=#<_probe_diameter>
#<_probe_log_size>=#<_probe_meas_dia>
o2809 if [#<_probe_log> GT 0]
$Probe/Log
o2809 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
