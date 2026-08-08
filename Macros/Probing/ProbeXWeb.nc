(ProbeXWeb.nc)
(Centre of an EXTERNAL feature measured across X -- a "web": the two)
(outside walls either side of a part or rib. Fusion cycle "probing-x-web".)
()
(This is the outside counterpart of ProbeXChannel.nc. A channel probes)
(OUTWARD from inside a slot; a web goes OUT past each face and probes back)
(INWARD, so it needs a Z lift to clear the top of the part while)
(repositioning -- #<_probe_safe_z> must be greater than zero.)
()
(Probe starts at the nominal centre, ABOVE the part.)
(Effective radius cancels in the midpoint, so the centre needs no)
(compensation; it is SUBTRACTED to report the width, because these)
(touches are on the outside of the feature.)

(--- shared prelude: guarantees every value below is DEFINED ---)
$SD/Run=/Probing/ProbeInit.nc

#<_halfx>=[#<_probe_width_x> / 2]
#<_stand>=[#<_halfx> + #<_probe_clearance>]
#<_start>=#<_abs_x>

o250 if [#<_probe_safe_z> LE 0]
    (MSG: PROBE ERROR - web probing needs a positive clearance lift)
    $Alarm/Send=3
    M30
o250 endif

(--- -X face: out past it, drop, probe back toward +X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 X[#<_start> - #<_stand>]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 X[#<_probe_clearance> + #<_probe_overtravel>] F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X[#<_probe_backoff> * 2] F#<_probe_feed_slow>
G90
#<_wall_a>=#5061

(--- +X face: out past it, drop, probe back toward -X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 X[#<_start> + #<_stand>]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 X[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 X#<_probe_backoff>
G38.2 X[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_b>=#5061

#<_centre>=[[#<_wall_a> + #<_wall_b>] / 2]
#<_probe_meas_x>=[ABS[#<_wall_b> - #<_wall_a>] - [2 * #<_probe_eff_radius>]]
#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_centre> - #<_start>]]

(--- lift clear, settle on the centre, zero the active WCS ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G0 X#<_centre>
G10 L20 P0 X0
(MSG: X web centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
