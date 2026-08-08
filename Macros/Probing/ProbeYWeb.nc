(ProbeYWeb.nc)
(Centre of an EXTERNAL feature measured across Y -- a "web": the two)
(outside walls either side of a part or rib. Fusion cycle "probing-y-web".)
()
(This is the outside counterpart of ProbeYChannel.nc. A channel probes)
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

#<_halfy>=[#<_probe_width_y> / 2]
#<_stand>=[#<_halfy> + #<_probe_clearance>]
#<_start>=#<_abs_y>

o255 if [#<_probe_safe_z> LE 0]
    (MSG: PROBE ERROR - web probing needs a positive clearance lift)
    $Alarm/Send=3
    M30
o255 endif

(--- -Y face: out past it, drop, probe back toward +Y ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 Y[#<_start> - #<_stand>]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 Y[#<_probe_clearance> + #<_probe_overtravel>] F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y[#<_probe_backoff> * 2] F#<_probe_feed_slow>
G90
#<_wall_a>=#5062

(--- +Y face: out past it, drop, probe back toward -Y ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G0 Y[#<_start> + #<_stand>]
G91
G0 Z[0 - #<_probe_safe_z>]
G38.2 Y[0 - [#<_probe_clearance> + #<_probe_overtravel>]] F#<_probe_feed_fast>
G0 Y#<_probe_backoff>
G38.2 Y[0 - [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_wall_b>=#5062

#<_centre>=[[#<_wall_a> + #<_wall_b>] / 2]
#<_probe_meas_y>=[ABS[#<_wall_b> - #<_wall_a>] - [2 * #<_probe_eff_radius>]]
#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_centre> - #<_start>]]

(--- lift clear, settle on the centre, zero the active WCS ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G0 Y#<_centre>
G10 L20 P0 Y0
(MSG: Y web centred, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
