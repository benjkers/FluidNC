(ProbeXWall.nc)
(Centre of a wall pair - the two outside walls either side of a part, across X)
(Fusion cycles: "probing-x-wall")
()
(EXTERNAL feature: the probe starts at the nominal centre ABOVE the part,)
(lifts clear, moves out past each face, drops down beside it and probes)
(back INWARD. #<_probe_safe_z> must be greater than zero or the stylus)
(would drag across the top of the part.)
()
(Each face is touched twice with a 180 degree spindle rotation between,)
(so runout cancels - see _ProbeSurface.nc. The effective radius is)
(SUBTRACTED to report size here, because the touches are on the OUTSIDE.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

o700 if [#<_probe_safe_z> LE 0]
    (MSG: PROBE ERROR - external probing needs a positive clearance lift)
    $Alarm/Send=3
    G4 P0.1
o700 endif

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing back +X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> + #<_probe_clearance>]]] F#<_probe_feed_link>
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>

(--- +X face, probing back -X ---)
G91
G0 Z[#<_probe_safe_z>]
G90
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> + #<_probe_clearance>]]] F#<_probe_feed_link>
G91
G38.3 Z[0 - #<_probe_safe_z>] F#<_probe_feed_link>
G90
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] - [2 * #<_probe_eff_radius>]]

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_abs_x>]]

G91
G0 Z[#<_probe_safe_z>]
G90
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
(MSG: X wall pair centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
