(ProbeInnerXY.nc)
(Centre of an INTERNAL feature, probing outward from the nominal centre)
(on all four sides. Fusion cycles:)
(   probing-xy-circular-hole          width_x = width_y = diameter)
(   probing-xy-rectangular-hole       width_x, width_y independent)
(   ...-with-island                   set #<_probe_safe_z> to hop the island)
(Probe starts at the nominal centre, already at probing depth.)
(Stylus radius cancels in each midpoint; it is added back to report size.)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_halfx>=[#<_probe_width_x> / 2]
#<_halfy>=[#<_probe_width_y> / 2]
#<_startx>=#5420
#<_starty>=#5421

(--- X axis ---)
#<_stand>=[#<_halfx> - #<_probe_clearance>]
o230 if [#<_stand> LT 0]
#<_stand>=0
o230 endif
G91
G0 X[0 - #<_stand>]
G38.2 X[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[#<_probe_backoff>]
G38.2 X[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_xa>=#5061
o231 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o231 endif
G0 X#<_startx>
o232 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o232 endif
#<_stand>=[#<_halfx> - #<_probe_clearance>]
o233 if [#<_stand> LT 0]
#<_stand>=0
o233 endif
G91
G0 X[#<_stand>]
G38.2 X[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_xb>=#5061

#<_cx>=[[#<_xa> + #<_xb>] / 2]
#<_probe_meas_x>=[ABS[#<_xb> - #<_xa>] + [2 * #<_probe_eff_radius>]]

(--- move to the found X centre before probing Y ---)
o234 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o234 endif
G53 G0 X#<_cx>
o235 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o235 endif

(--- Y axis ---)
#<_stand>=[#<_halfy> - #<_probe_clearance>]
o236 if [#<_stand> LT 0]
#<_stand>=0
o236 endif
G91
G0 Y[0 - #<_stand>]
G38.2 Y[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[#<_probe_backoff>]
G38.2 Y[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_ya>=#5062
o237 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o237 endif
G0 Y#<_starty>
o238 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o238 endif
#<_stand>=[#<_halfy> - #<_probe_clearance>]
o239 if [#<_stand> LT 0]
#<_stand>=0
o239 endif
G91
G0 Y[#<_stand>]
G38.2 Y[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_yb>=#5062

#<_cy>=[[#<_ya> + #<_yb>] / 2]
#<_probe_meas_y>=[ABS[#<_yb> - #<_ya>] + [2 * #<_probe_eff_radius>]]
#<_probe_meas_dia>=[[#<_probe_meas_x> + #<_probe_meas_y>] / 2]

(--- deviations for the tolerance check ---)
#<_probe_dev_size>=[[[#<_probe_meas_x> - #<_probe_width_x>] + [#<_probe_meas_y> - #<_probe_width_y>]] / 2]
#<_probe_dev_pos>=[SQRT[[[#<_cx> - #<_abs_x>] * [#<_cx> - #<_abs_x>]] + [[#<_cy> - #<_abs_y>] * [#<_cy> - #<_abs_y>]]]]

G53 G0 X#<_cx> Y#<_cy>
G10 L20 P0 X0 Y0
(MSG: Inner feature centred, WCS X0 Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
