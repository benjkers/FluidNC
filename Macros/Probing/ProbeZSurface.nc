(ProbeZSurface.nc)
(Probes downward onto a surface and sets Z0 in the active work offset)
(there. Fusion cycle "probing-z".)
()
(No radius compensation: the touch is on the BOTTOM of the stylus ball,)
(so the tip is already the reference the tool length offset was set from.)
(Probe yaw is an X/Y correction and deliberately does not apply here.)
()
(  #<_probe_clearance>    standoff at which the fast probe begins)
(  #<_probe_overtravel>   how far past nominal before it is a miss)
(  #<_probe_feed_fast>    first touch feed)
(  #<_probe_feed_slow>    second, accurate touch feed)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_startz>=#<_abs_z>

(--- fast find, back off, slow accurate touch, all downward ---)
G91
G38.2 Z[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Z#<_probe_backoff>
G38.2 Z[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90

(--- position deviation: expected surface was clearance below the start ---)
#<_expected>=[#<_startz> - #<_probe_clearance>]
#<_probe_dev_pos>=[ABS[#5063 - #<_expected>]]
#<_probe_dev_size>=0

G10 L20 P0 Z0
G91
G0 Z#<_probe_clearance>
G90
(MSG: Z surface probed, WCS Z0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
