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
o600 if [EXISTS[#<_probe_angle_1>]]
o600 else
#<_probe_angle_1>=210
o600 endif
o601 if [EXISTS[#<_probe_angle_2>]]
o601 else
#<_probe_angle_2>=270
o601 endif
o602 if [EXISTS[#<_probe_angle_3>]]
o602 else
#<_probe_angle_3>=330
o602 endif
o603 if [EXISTS[#<_probe_diameter>]]
o603 else
#<_probe_diameter>=0
o603 endif

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

(--- ball-centre standoff: bore radius, less the gap, less the ball ---)
#<_stand>=[[#<_probe_diameter> / 2] - #<_probe_clearance> - #<_probe_tool_radius>]
o604 if [#<_stand> LT 0]
#<_stand>=0
o604 endif

(--- touch 1 ---)
#<_ang>=#<_probe_angle_1>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o605 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o605 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o606 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o606 endif
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
o607 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o607 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o608 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o608 endif
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
o609 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o609 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o610 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o610 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p3x>=#<_ps_x>
#<_p3y>=#<_ps_y>

o611 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o611 endif

(--- circumcentre of the three averaged touch points ---)
(All three ball centres lie on a circle CONCENTRIC with the feature, so)
(their circumcentre IS its centre. The tip radius cancels for the centre)
(and is added only to report the diameter.)
#<_s1>=[[#<_p1x> * #<_p1x>] + [#<_p1y> * #<_p1y>]]
#<_s2>=[[#<_p2x> * #<_p2x>] + [#<_p2y> * #<_p2y>]]
#<_s3>=[[#<_p3x> * #<_p3x>] + [#<_p3y> * #<_p3y>]]
#<_d>=[2 * [[#<_p1x> * [#<_p2y> - #<_p3y>]] + [#<_p2x> * [#<_p3y> - #<_p1y>]] + [#<_p3x> * [#<_p1y> - #<_p2y>]]]]

o612 if [ABS[#<_d>] LT 0.000001]
    (MSG: PROBE ERROR - the three touch points are collinear, cannot solve a circle)
    $Alarm/Send=3
    G4 P0.1
o612 endif

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
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]] Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
(MSG: Partial hole centred from 3 points, WCS X0 Y0 set)

(--- echo the result if Fusion asked for it ---)
o922 if [#<_probe_print> GT 0]
(PRINT, PROBE partial hole:)
(PRINT,   centre X %.4f#<_cx> Y %.4f#<_cy>)
(PRINT,   diameter %.4f#<_probe_meas_dia> nominal %.4f#<_probe_diameter>)
(PRINT,   dev size %.4f#<_probe_dev_size> pos %.4f#<_probe_dev_pos> runout %.4f#<_probe_runout>)
o922 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
