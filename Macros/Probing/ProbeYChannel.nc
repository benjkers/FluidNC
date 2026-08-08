(ProbeYChannel.nc)
(Centre of a channel/slot measured across Y. Fusion cycles)
("probing-y-channel" and "probing-y-channel-with-island".)
(Mirror of ProbeXChannel.nc -- see that file for the full explanation.)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_halfy>=[#<_probe_width_y> / 2]
#<_starty>=#5421

(--- -Y wall ---)
#<_stand>=[#<_halfy> - #<_probe_clearance>]
o220 if [#<_stand> LT 0]
#<_stand>=0
o220 endif
G91
G0 Y[0 - #<_stand>]
G38.2 Y[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[#<_probe_backoff>]
G38.2 Y[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_a>=#5062

o221 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o221 endif
G0 Y#<_starty>
o222 if [#<_probe_safe_z> GT 0]
G91
G0 Z[0 - #<_probe_safe_z>]
G90
o222 endif

(--- +Y wall ---)
#<_stand>=[#<_halfy> - #<_probe_clearance>]
o223 if [#<_stand> LT 0]
#<_stand>=0
o223 endif
G91
G0 Y[#<_stand>]
G38.2 Y[[#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y[[#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_b>=#5062

#<_cy>=[[#<_wall_a> + #<_wall_b>] / 2]
#<_probe_meas_y>=[ABS[#<_wall_b> - #<_wall_a>] + [2 * #<_probe_eff_radius>]]
#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_cy> - #<_abs_y>]]

G53 G0 Y#<_cy>
G10 L20 P0 Y0
(MSG: Y channel centred, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
