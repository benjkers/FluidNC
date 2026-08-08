(ProbeXChannel.nc)
(Centre of a channel/slot measured across X. Fusion cycles)
("probing-x-channel" and "probing-x-channel-with-island".)
(Probe starts at the nominal centre, already at probing depth.)
(Stylus radius cancels in the midpoint, so the centre needs no radius)
(compensation; it is added back to report the width.)
(Set #<_probe_safe_z> to lift over an island while crossing.)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_halfx>=[#<_probe_width_x> / 2]
#<_startx>=#5420

(--- -X wall ---)
#<_stand>=[#<_halfx> - #<_probe_clearance>]
o210 if [#<_stand> LT 0]
#<_stand>=0
o210 endif
G91
G0 X[0 - #<_stand>]
G38.2 X[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[#<_probe_backoff>]
G38.2 X[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_a>=#5061

(--- back to centre, hopping an island if declared ---)
o211 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o211 endif
G0 X#<_startx>
o212 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o212 endif

(--- +X wall ---)
#<_stand>=[#<_halfx> - #<_probe_clearance>]
o213 if [#<_stand> LT 0]
#<_stand>=0
o213 endif
G91
G0 X[#<_stand>]
G38.2 X[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_b>=#5061

#<_cx>=[[#<_wall_a> + #<_wall_b>] / 2]
#<_probe_meas_x>=[ABS[#<_wall_b> - #<_wall_a>] + [2 * #<_probe_eff_radius>]]
#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_abs_x>]]

G53 G0 X#<_cx>
G10 L20 P0 X0
(MSG: X channel centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
