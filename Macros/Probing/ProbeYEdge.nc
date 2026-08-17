(ProbeYEdge.nc)
(Single axis Y edge probe. Fusion cycle "probing-y", and one half)
(of XY corner probing.)
()
(Sets Y0 in the TARGET work offset at the true surface, compensating for)
(the effective probe radius - tip radius minus pre travel - so the zero)
(lands on the surface rather than at the ball centre.)
()
(Runout is cancelled by _ProbeSurface: it touches, retracts, pauses for a)
(180 degree spindle rotation, touches again and averages. On a single)
(edge this matters more than on a centre, because there is no opposite)
(wall for the error to partly offset against.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>
#<_dir>=#<_probe_axis_dir>

#<_ps_ux>=0
#<_ps_uy>=[#<_dir>]
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc

(--- true surface = averaged trigger + dir * effective radius ---)
#<_surface>=[#<_ps_y> + [#<_dir> * #<_probe_eff_radius>]]

(--- an edge has no size, only position ---)
#<_expected>=#<_start_abs_y>
#<_probe_dev_pos>=[ABS[#<_surface> - #<_expected>]]
#<_probe_dev_size>=0

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
G10 L20 P#<_probe_wcs> Y[#<_probe_nom_y> + [#<_abs_y> - #<_surface>]]
(MSG: Y edge probed, WCS Y0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
