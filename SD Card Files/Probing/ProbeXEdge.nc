(ProbeXEdge.nc)
(Single axis X edge probe. Fusion cycle "probing-x", and one half)
(of XY corner probing.)
()
(Sets X0 in the TARGET work offset at the true surface, compensating for)
(the effective probe radius - tip radius minus pre travel - so the zero)
(lands on the surface rather than at the ball centre.)
()
(Runout is cancelled by _ProbeSurface: it touches, retracts, pauses for a)
(180 degree spindle rotation, touches again and averages. On a single)
(edge this matters more than on a centre, because there is no opposite)
(wall for the error to partly offset against.)

$SD/Run=/Probing/ProbeInit.nc

(--- where we started, in LATERAL-PLANE coordinates ---)
(l1 is the written direction that comes out as machine X; l2 is written Y,)
(which B never rotates. This used to capture #<_abs_*> for comparison with a)
(part-frame result -- consistent, but neither of them a lateral once the part)
(is indexed. Everything here is the WORK frame now.)
#<_start_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_start_l2>=#<_y>
#<_dir>=#<_probe_axis_dir>

(Touch along LATERAL 1. Written X is that direction only at B0 -- at B90 it)
(is the tool axis, so this drove the stylus straight down instead of at the)
(edge.)
#<_ps_ux>=[#<_dir> * #<_probe_lat_ux>]
#<_ps_uy>=[#<_dir> * #<_probe_lat_uy>]
#<_ps_uz>=[#<_dir> * #<_probe_lat_uz>]
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc

(--- true surface = averaged trigger + dir * effective radius ---)
#<_touch_l1>=[[#<_ps_wx> * #<_probe_lat_ux>] + [#<_ps_wy> * #<_probe_lat_uy>] + [#<_ps_wz> * #<_probe_lat_uz>]]
#<_surface>=[#<_touch_l1> + [#<_dir> * #<_probe_eff_radius>]]

(--- an edge has no size, only position ---)
#<_expected>=#<_start_l1>
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
o2705 if [#<_probe_set_origin> GT 0]
(The edge was measured along LATERAL 1, so the origin shifts along lateral 1)
(-- not along written X, which is a different direction once indexed. All)
(three axes are written: the l2 and height terms reproduce the readings those)
(axes already have, so they are no-ops, exactly as not naming them was at B0.)
#<_cur_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_cur_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_a>=[#<_probe_nom_l1> + [#<_cur_l1> - #<_surface>]]
#<_o_x>=[[#<_o_a> * #<_probe_lat_ux>] + [#<_cur_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_o_a> * #<_probe_lat_uy>] + #<_y> + [#<_cur_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_o_a> * #<_probe_lat_uz>] + [#<_cur_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2705 else
(MSG: measure only - work offset left untouched)
o2705 endif
(MSG: X edge probed, WCS X0 set)

(--- echo the result if Fusion asked for it ---)
o2000 if [#<_probe_print> GT 0]
(PRINT, PROBE X edge:)
(PRINT,   X surface %.4f#<_surface>  nominal %.4f#<_probe_nom_x> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2605 if [#<_probe_pause> GT 0]
M0
o2605 endif
o2000 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=2
#<_probe_log_x>=#<_surface>
o2801 if [#<_probe_log> GT 0]
$Probe/Log
o2801 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
