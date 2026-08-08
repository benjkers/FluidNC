(ProbeYEdge.nc)
(Single-axis Y edge probe. Fusion cycle "probing-y", and one half of)
(XY corner probing. Sets Y0 in the active work offset at the true)
(surface, compensating for the effective probe radius -- tip radius minus)
(pre-travel -- so the zero lands on the surface, not past it.)
()
(  #<_probe_axis_dir>     +1 to probe toward +Y, -1 to probe toward -Y)
(  #<_probe_clearance>    standoff at which the fast probe begins)
(  #<_probe_overtravel>   how far past nominal before it is a miss)
(  #<_probe_feed_fast>    first touch feed)
(  #<_probe_feed_slow>    second, accurate touch feed)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_dir>=#<_probe_axis_dir>
#<_start>=#<_abs_y>

(--- fast find, back off, slow accurate touch ---)
G91
G38.2 Y[#<_dir> * [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y[0 - [#<_dir> * #<_probe_backoff>]]
G38.2 Y[#<_dir> * [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90

(--- true surface = trigger + dir * effective radius ---)
#<_surface>=[#5062 + [#<_dir> * #<_probe_eff_radius>]]

(--- an edge has no size, only position: how far from where we expected)
(the surface, which was #<_probe_clearance> along dir from the start ---)
#<_expected>=[#<_start> + [#<_dir> * #<_probe_clearance>]]
#<_probe_dev_pos>=[ABS[#<_surface> - #<_expected>]]
#<_probe_dev_size>=0

G10 L20 P0 Y[0 - [#<_dir> * #<_probe_eff_radius>]]
G91
G0 Y[0 - [#<_dir> * #<_probe_clearance>]]
G90
(MSG: Y edge probed, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
