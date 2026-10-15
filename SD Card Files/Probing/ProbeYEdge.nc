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

(--- where we started, in LATERAL-PLANE coordinates ---)
(l1 is the written direction that comes out as machine X; l2 is written Y,)
(which B never rotates. This used to capture #<_abs_*> for comparison with a)
(part-frame result -- consistent, but neither of them a lateral once the part)
(is indexed. Everything here is the WORK frame now.)
#<_start_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_start_l2>=#<_y>
#<_dir>=#<_probe_axis_dir>

(Touch along LATERAL 2, which is written Y. B turns about Y, so written Y is)
(always the second lateral: this direction needs no basis vector and was)
(never wrong. Kept exactly as it was.)
#<_ps_ux>=0
#<_ps_uy>=[#<_dir>]
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc

(--- true surface = averaged trigger + dir * effective radius ---)
#<_surface>=[#<_ps_wy> + [#<_dir> * #<_probe_eff_radius>]]

(--- an edge has no size, only position ---)
#<_expected>=#<_start_l2>
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
o2708 if [#<_probe_set_origin> GT 0]
(Lateral 2 is written Y at any angle, so only the Y nominal is involved --)
(but all three axes are written so the l1 and height readings are carried)
(through unchanged rather than inherited.)
#<_cur_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_cur_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_b>=[#<_probe_nom_l2> + [#<_y> - #<_surface>]]
#<_o_x>=[[#<_cur_l1> * #<_probe_lat_ux>] + [#<_cur_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_cur_l1> * #<_probe_lat_uy>] + #<_o_b> + [#<_cur_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_cur_l1> * #<_probe_lat_uz>] + [#<_cur_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2708 else
(MSG: measure only - work offset left untouched)
o2708 endif
(MSG: Y edge probed, WCS Y0 set)

(--- echo the result if Fusion asked for it ---)
o2100 if [#<_probe_print> GT 0]
(PRINT, PROBE Y edge:)
(PRINT,   Y surface %.4f#<_surface>  nominal %.4f#<_probe_nom_y> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2608 if [#<_probe_pause> GT 0]
M0
o2608 endif
o2100 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=3
#<_probe_log_y>=#<_surface>
o2802 if [#<_probe_log> GT 0]
$Probe/Log
o2802 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
