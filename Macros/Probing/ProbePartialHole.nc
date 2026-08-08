(ProbePartialHole.nc)
(Finds the centre of a PARTIAL circular hole -- an arc you cannot probe)
(at all four cardinal points. Covers the Fusion cycles:)
(   probing-xy-circular-partial-hole)
(   probing-xy-circular-partial-hole-with-island)
()
(Method: touch three points on the bore wall at three operator-chosen)
(angles, then solve the circle through them. Three points define a)
(circle exactly, so no fitting or averaging is involved.)
()
(Because every touch records the TOOL CENTRE, and every tool centre sits)
(on a circle concentric with the true bore, the circumcentre of the three)
(recorded points IS the true bore centre -- the stylus radius cancels. It)
(is added back only to report the diameter.)
()
(Angles are measured CCW from +X, in degrees, and must all lie inside the)
(reachable arc. The post supplies them; ProbeInit.nc guarantees defaults.)
()
(  #<_probe_angle_1/2/3>  probe directions, degrees CCW from +X)
(  #<_probe_diameter>     nominal bore diameter)
(  #<_probe_safe_z>       lift used to hop an island between touches)

$SD/Run=/Probing/ProbeInit.nc

o360 if [EXISTS[#<_probe_angle_1>]]
o360 else
#<_probe_angle_1>=0.000
o360 endif
o361 if [EXISTS[#<_probe_angle_2>]]
o361 else
#<_probe_angle_2>=120.000
o361 endif
o362 if [EXISTS[#<_probe_angle_3>]]
o362 else
#<_probe_angle_3>=240.000
o362 endif
o363 if [EXISTS[#<_probe_diameter>]]
o363 else
#<_probe_diameter>=0.000
o363 endif

#<_r_nom>=[#<_probe_diameter> / 2]
#<_startx>=#5420
#<_starty>=#5421

(--- touch 1 ---)
#<_ang>=#<_probe_angle_1>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
#<_standoff>=[#<_r_nom> - #<_probe_clearance>]
o370 if [#<_standoff> LT 0]
#<_standoff>=0
o370 endif
G91
G0 X[#<_ux> * #<_standoff>] Y[#<_uy> * #<_standoff>]
#<_reach>=[#<_probe_clearance> + #<_probe_overtravel>]
G38.2 X[#<_ux> * #<_reach>] Y[#<_uy> * #<_reach>] F#<_probe_feed_fast>
G0 X[0 - #<_ux> * #<_probe_backoff>] Y[0 - #<_uy> * #<_probe_backoff>]
G38.2 X[#<_ux> * [#<_probe_backoff> * 2]] Y[#<_uy> * [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_p1x>=#5061
#<_p1y>=#5062
o371 if [#<_probe_safe_z> GT 0]
G91
G0 Z#<_probe_safe_z>
G90
o371 endif
G0 X#<_startx> Y#<_starty>
o372 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o372 endif

(--- touch 2 ---)
#<_ang>=#<_probe_angle_2>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
G91
G0 X[#<_ux> * #<_standoff>] Y[#<_uy> * #<_standoff>]
G38.2 X[#<_ux> * #<_reach>] Y[#<_uy> * #<_reach>] F#<_probe_feed_fast>
G0 X[0 - #<_ux> * #<_probe_backoff>] Y[0 - #<_uy> * #<_probe_backoff>]
G38.2 X[#<_ux> * [#<_probe_backoff> * 2]] Y[#<_uy> * [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_p2x>=#5061
#<_p2y>=#5062
o373 if [#<_probe_safe_z> GT 0]
G91
G0 Z#<_probe_safe_z>
G90
o373 endif
G0 X#<_startx> Y#<_starty>
o374 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o374 endif

(--- touch 3 ---)
#<_ang>=#<_probe_angle_3>
#<_ux>=[COS[#<_ang>]]
#<_uy>=[SIN[#<_ang>]]
G91
G0 X[#<_ux> * #<_standoff>] Y[#<_uy> * #<_standoff>]
G38.2 X[#<_ux> * #<_reach>] Y[#<_uy> * #<_reach>] F#<_probe_feed_fast>
G0 X[0 - #<_ux> * #<_probe_backoff>] Y[0 - #<_uy> * #<_probe_backoff>]
G38.2 X[#<_ux> * [#<_probe_backoff> * 2]] Y[#<_uy> * [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_p3x>=#5061
#<_p3y>=#5062
o375 if [#<_probe_safe_z> GT 0]
G91
G0 Z#<_probe_safe_z>
G90
o375 endif
G0 X#<_startx> Y#<_starty>
o376 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o376 endif

(--- circumcentre of the three recorded tool-centre points ---)
#<_s1>=[[#<_p1x> * #<_p1x>] + [#<_p1y> * #<_p1y>]]
#<_s2>=[[#<_p2x> * #<_p2x>] + [#<_p2y> * #<_p2y>]]
#<_s3>=[[#<_p3x> * #<_p3x>] + [#<_p3y> * #<_p3y>]]
#<_d>=[2 * [[#<_p1x> * [#<_p2y> - #<_p3y>]] + [#<_p2x> * [#<_p3y> - #<_p1y>]] + [#<_p3x> * [#<_p1y> - #<_p2y>]]]]

o380 if [ABS[#<_d>] LT 0.000001]
    (MSG: PROBE ERROR - the three touch points are collinear, cannot solve a circle)
    $Alarm/Send=3
    M30
o380 endif

#<_cx>=[[[#<_s1> * [#<_p2y> - #<_p3y>]] + [#<_s2> * [#<_p3y> - #<_p1y>]] + [#<_s3> * [#<_p1y> - #<_p2y>]]] / #<_d>]
#<_cy>=[[[#<_s1> * [#<_p3x> - #<_p2x>]] + [#<_s2> * [#<_p1x> - #<_p3x>]] + [#<_s3> * [#<_p2x> - #<_p1x>]]] / #<_d>]

(--- fitted radius, plus stylus radius, gives the true bore ---)
#<_fit_r>=[SQRT[[[#<_p1x> - #<_cx>] * [#<_p1x> - #<_cx>]] + [[#<_p1y> - #<_cy>] * [#<_p1y> - #<_cy>]]]]
#<_probe_meas_dia>=[2 * [#<_fit_r> + #<_probe_eff_radius>]]


(--- deviations for the tolerance check ---)
#<_probe_dev_size>=[#<_probe_meas_dia> - #<_probe_diameter>]
#<_exp_x>=#<_abs_x>
#<_exp_y>=#<_abs_y>
#<_probe_dev_pos>=[SQRT[[[#<_cx> - #<_exp_x>] * [#<_cx> - #<_exp_x>]] + [[#<_cy> - #<_exp_y>] * [#<_cy> - #<_exp_y>]]]]

G53 G0 X#<_cx> Y#<_cy>
G10 L20 P0 X0 Y0
(MSG: Partial hole centred from 3 points, WCS X0 Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
