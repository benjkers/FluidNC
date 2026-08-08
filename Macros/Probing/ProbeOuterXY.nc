(ProbeOuterXY.nc)
(Centre of an EXTERNAL feature -- a boss -- by going out past each face)
(in turn and probing back INWARD. Fusion cycles:)
(   probing-xy-circular-boss       width_x = width_y = diameter)
(   probing-xy-rectangular-boss    width_x, width_y independent)
(Probe starts at the nominal centre, ABOVE the boss.)
(#<_probe_safe_z> MUST be greater than zero -- it is the lift used to)
(clear the top of the boss while repositioning. Without it the stylus)
(would drag across the boss.)
(Stylus radius cancels in each midpoint; it is SUBTRACTED to report size,)
(because these touches are on the outside of the feature.)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_standx>=[[#<_probe_width_x> / 2] + #<_probe_clearance>]
#<_standy>=[[#<_probe_width_y> / 2] + #<_probe_clearance>]
#<_startx>=#5420
#<_starty>=#5421

o240 if [#<_probe_safe_z> LE 0]
    (MSG: PROBE ERROR - boss probing needs a positive clearance lift)
    $Alarm/Send=3
    M30
o240 endif

(--- -X face, probing toward +X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 X[#<_startx> + [0 - #<_standx>]]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 X[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_xa>=#5061

(--- +X face, probing toward -X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 X[#<_startx> + [#<_standx>]]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 X[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[#<_probe_backoff>]
G38.2 X[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_xb>=#5061

#<_cx>=[[#<_xa> + #<_xb>] / 2]
#<_probe_meas_x>=[ABS[#<_xb> - #<_xa>] - [2 * #<_probe_eff_radius>]]

(--- centre up in X before doing Y ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G0 X#<_cx>
G91
G0 Z[0 - #<_probe_safe_z>]
G90

(--- -Y face, probing toward +Y ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 Y[#<_starty> + [0 - #<_standy>]]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 Y[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_ya>=#5062

(--- +Y face, probing toward -Y ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 Y[#<_starty> + [#<_standy>]]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 Y[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[#<_probe_backoff>]
G38.2 Y[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_yb>=#5062

#<_cy>=[[#<_ya> + #<_yb>] / 2]
#<_probe_meas_y>=[ABS[#<_yb> - #<_ya>] - [2 * #<_probe_eff_radius>]]
#<_probe_meas_dia>=[[#<_probe_meas_x> + #<_probe_meas_y>] / 2]

#<_probe_dev_size>=[[[#<_probe_meas_x> - #<_probe_width_x>] + [#<_probe_meas_y> - #<_probe_width_y>]] / 2]
#<_probe_dev_pos>=[SQRT[[[#<_cx> - #<_abs_x>] * [#<_cx> - #<_abs_x>]] + [[#<_cy> - #<_abs_y>] * [#<_cy> - #<_abs_y>]]]]

(--- lift clear, settle on the true centre, zero the active WCS ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G0 X#<_cx> Y#<_cy>
G10 L20 P0 X0 Y0
(MSG: Boss centred, WCS X0 Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
