(ProbeInnerXY.nc)
(Centre of an internal feature - bore or rectangular pocket)
(Fusion cycles: "probing-xy-circular-hole", "probing-xy-rectangular-hole" and their island variants)
()
(INTERNAL feature: the probe starts at the nominal centre, at probing)
(depth, and works OUTWARD to each wall. Every wall is touched twice with)
(a 180 degree spindle rotation between - see _ProbeSurface.nc - because)
(runout does NOT cancel in a midpoint the way tip radius does.)
()
(Set #<_probe_safe_z> to lift the probe over an island while crossing.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X wall ---)
o280 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o280 endif
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> - #<_probe_clearance>]]] F#<_probe_feed_link>
o281 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o281 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>
o282 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o282 endif
G53 G38.3 X#<_start_abs_x> F#<_probe_feed_link>
o283 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o283 endif

(--- +X wall ---)
o284 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o284 endif
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> - #<_probe_clearance>]]] F#<_probe_feed_link>
o285 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o285 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>
o286 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o286 endif
G53 G38.3 X#<_start_abs_x> F#<_probe_feed_link>
o287 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o287 endif

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] + [2 * #<_probe_eff_radius>]]

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y wall ---)
o288 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o288 endif
G53 G38.3 Y[#<_start_abs_y> + [-1 * [#<_halfy> - #<_probe_clearance>]]] F#<_probe_feed_link>
o289 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o289 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_y>
o290 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o290 endif
G53 G38.3 Y#<_start_abs_y> F#<_probe_feed_link>
o291 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o291 endif

(--- +Y wall ---)
o292 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o292 endif
G53 G38.3 Y[#<_start_abs_y> + [1 * [#<_halfy> - #<_probe_clearance>]]] F#<_probe_feed_link>
o293 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o293 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_y>
o294 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o294 endif
G53 G38.3 Y#<_start_abs_y> F#<_probe_feed_link>
o295 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o295 endif

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] + [2 * #<_probe_eff_radius>]]

#<_probe_meas_dia>=[[#<_probe_meas_x> + #<_probe_meas_y>] / 2]
#<_probe_dev_size>=[[[#<_probe_meas_x> - #<_probe_width_x>] + [#<_probe_meas_y> - #<_probe_width_y>]] / 2]
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
(MSG: Inner feature centred, WCS X0 Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
