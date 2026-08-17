(ProbeYChannel.nc)
(Centre of a channel or slot measured across Y)
(Fusion cycles: "probing-y-channel" and "probing-y-channel-with-island")
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

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y wall ---)
o240 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o240 endif
G53 G38.3 Y[#<_start_abs_y> + [-1 * [#<_halfy> - #<_probe_clearance>]]] F#<_probe_feed_link>
o241 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o241 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_y>
o242 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o242 endif
G53 G38.3 Y#<_start_abs_y> F#<_probe_feed_link>
o243 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o243 endif

(--- +Y wall ---)
o244 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o244 endif
G53 G38.3 Y[#<_start_abs_y> + [1 * [#<_halfy> - #<_probe_clearance>]]] F#<_probe_feed_link>
o245 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o245 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_y>
o246 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o246 endif
G53 G38.3 Y#<_start_abs_y> F#<_probe_feed_link>
o247 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o247 endif

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] + [2 * #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_cy> - #<_start_abs_y>]]

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
G10 L20 P#<_probe_wcs> Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
(MSG: Y channel centred, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
