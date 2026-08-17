(ProbeXChannel.nc)
(Centre of a channel or slot measured across X)
(Fusion cycles: "probing-x-channel" and "probing-x-channel-with-island")
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
o200 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o200 endif
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> - #<_probe_clearance>]]] F#<_probe_feed_link>
o201 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o201 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>
o202 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o202 endif
G53 G38.3 X#<_start_abs_x> F#<_probe_feed_link>
o203 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o203 endif

(--- +X wall ---)
o204 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o204 endif
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> - #<_probe_clearance>]]] F#<_probe_feed_link>
o205 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o205 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>
o206 if [#<_probe_safe_z> GT 0]
G91
G0 Z[#<_probe_safe_z>]
G90
o206 endif
G53 G38.3 X#<_start_abs_x> F#<_probe_feed_link>
o207 if [#<_probe_safe_z> GT 0]
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
o207 endif

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] + [2 * #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_abs_x>]]

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
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]]
(MSG: X channel centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
