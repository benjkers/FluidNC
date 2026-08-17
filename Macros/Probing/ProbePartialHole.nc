(ProbePartialHole.nc)
(Centre of a PARTIAL circular hole - an arc that cannot be reached at all)
(four cardinal points. Fusion cycles "probing-xy-circular-partial-hole")
(and its island variant.)
()
(Three touches on the reachable arc, solved as the exact circle through)
(three points. Three points define a circle uniquely, so there is no)
(fitting or averaging involved.)
()
(Each touch is itself runout compensated by _ProbeSurface.nc, which is)
(what makes the three point solution trustworthy: with raw touches the)
(eccentricity would shift each point by a different amount depending on)
(its approach angle, and the fitted centre would be wrong in a way that)
(is hard to see.)
()
(Angles are degrees CCW from +X and must all lie inside the arc the probe)
(can actually reach, or the stylus will be driven into material.)

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

#<_stand>=[[#<_probe_diameter> / 2] - #<_probe_clearance>]
o604 if [#<_stand> LT 0]
#<_stand>=0
o604 endif

(--- touch 1 ---)
#<_ang>=#<_probe_angle_1>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o611 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o611 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o621 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o621 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p1x>=#<_ps_x>
#<_p1y>=#<_ps_y>
o631 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o631 endif
G53 G38.3 X#<_start_abs_x> Y#<_start_abs_y> F#<_probe_feed_link>
o641 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o641 endif

(--- touch 2 ---)
#<_ang>=#<_probe_angle_2>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o612 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o612 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o622 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o622 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p2x>=#<_ps_x>
#<_p2y>=#<_ps_y>
o632 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o632 endif
G53 G38.3 X#<_start_abs_x> Y#<_start_abs_y> F#<_probe_feed_link>
o642 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o642 endif

(--- touch 3 ---)
#<_ang>=#<_probe_angle_3>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
o613 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o613 endif
G53 G38.3 X[#<_start_abs_x> + [#<_ux> * #<_stand>]] Y[#<_start_abs_y> + [#<_uy> * #<_stand>]] F#<_probe_feed_link>
o623 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o623 endif
#<_ps_ux>=#<_ux>
#<_ps_uy>=#<_uy>
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_p3x>=#<_ps_x>
#<_p3y>=#<_ps_y>
o633 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o633 endif
G53 G38.3 X#<_start_abs_x> Y#<_start_abs_y> F#<_probe_feed_link>
o643 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o643 endif

(--- circumcentre of the three averaged touch points ---)
(Each recorded point is a ball centre, and all three ball centres lie on)
(a circle concentric with the bore, so their circumcentre IS the bore)
(centre. The tip radius cancels and is added back only to report size.)
#<_s1>=[[#<_p1x> * #<_p1x>] + [#<_p1y> * #<_p1y>]]
#<_s2>=[[#<_p2x> * #<_p2x>] + [#<_p2y> * #<_p2y>]]
#<_s3>=[[#<_p3x> * #<_p3x>] + [#<_p3y> * #<_p3y>]]
#<_d>=[2 * [[#<_p1x> * [#<_p2y> - #<_p3y>]] + [#<_p2x> * [#<_p3y> - #<_p1y>]] + [#<_p3x> * [#<_p1y> - #<_p2y>]]]]

o650 if [ABS[#<_d>] LT 0.000001]
    (MSG: PROBE ERROR - the three touch points are collinear, cannot solve a circle)
    $Alarm/Send=3
    G4 P0.1
o650 endif

#<_cx>=[[[#<_s1> * [#<_p2y> - #<_p3y>]] + [#<_s2> * [#<_p3y> - #<_p1y>]] + [#<_s3> * [#<_p1y> - #<_p2y>]]] / #<_d>]
#<_cy>=[[[#<_s1> * [#<_p3x> - #<_p2x>]] + [#<_s2> * [#<_p1x> - #<_p3x>]] + [#<_s3> * [#<_p2x> - #<_p1x>]]] / #<_d>]

#<_fit_r>=[SQRT[[[#<_p1x> - #<_cx>] * [#<_p1x> - #<_cx>]] + [[#<_p1y> - #<_cy>] * [#<_p1y> - #<_cy>]]]]
#<_probe_meas_dia>=[2 * [#<_fit_r> + #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_dia> - #<_probe_diameter>]
#<_probe_dev_pos>=[SQRT[[[#<_cx> - #<_start_abs_x>] * [#<_cx> - #<_start_abs_x>]] + [[#<_cy> - #<_start_abs_y>] * [#<_cy> - #<_start_abs_y>]]]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(To make the found feature read its nominal N while parked at P, emit)
(    N + [P - found]      -- the TLO cancels out.)
()
(This way the probe NEVER drives back toward the surface it just measured.)
(Parking the controlled point ON the surface would bury the ball by a full)
(tip radius and snap the stylus, and any over-travel past the deflection)
(limit of the probe would do the same.)
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]] Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
(MSG: Partial hole centred from 3 points, WCS X0 Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
