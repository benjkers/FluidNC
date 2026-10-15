(ProbeYChannel.nc)
(Centre of a channel or slot measured across Y)
(Fusion cycles: "probing-y-channel" and "probing-y-channel-with-island")
()
(INTERNAL: the probe works OUTWARD from the nominal centre.)
(Set #<_probe_lift> for an island: it then travels at)
(#<_probe_retract_z> between touches instead of through the island.)
()
(The probe NEVER descends at a feature centre -- only at a standoff)
(beside a face it is about to touch. Descending at the centre would)
(mean landing on an island, or inside a boss.)

$SD/Run=/Probing/ProbeInit.nc

(--- where we started, in LATERAL-PLANE coordinates ---)
(l1 is the written direction that comes out as machine X; l2 is written Y,)
(which B never rotates. Both are perpendicular to the tool axis, so a move in)
(this plane never changes height.)
()
(This used to capture #<_abs_*> and replay it under G53. Those are different)
(frames once TCP is on -- see _LateralMove.nc -- and at B90 the mismatch was)
(worth 67 mm. Everything here is now the WORK frame, start to finish.)
#<_start_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_start_l2>=#<_y>

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y face, probing -Y ---)
o1200 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1200 endif
#<_lm_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_lm_l2>=[#<_start_l2> + [-1 * [#<_halfy> - #<_probe_clearance> - #<_probe_tool_radius>]]]
$SD/Run=/Probing/_LateralMove.nc
o1201 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1201 endif
o1202 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1203 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1203 endif
o1202 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_wy>

(--- +Y face, probing +Y ---)
o1204 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1204 endif
#<_lm_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_lm_l2>=[#<_start_l2> + [1 * [#<_halfy> - #<_probe_clearance> - #<_probe_tool_radius>]]]
$SD/Run=/Probing/_LateralMove.nc
o1205 if [ABS[#<_lm_at2> - #<_lm_l2>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1205 endif
o1206 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_depth_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1207 if [ABS[#<_ta_at> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1207 endif
o1206 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_wy>

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] + [2 * #<_probe_eff_radius>]]

o1208 if [#<_probe_lift> GT 0]
G90
#<_ta_target>=#<_probe_retract_z>
$SD/Run=/Probing/_ToolAxisZ.nc
o1208 endif

#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_cy> - #<_start_l2>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
o2707 if [#<_probe_set_origin> GT 0]
(--- declare the origin WITHOUT moving ---)
(Where the probe stands, in the same three coordinates.)
#<_o_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_o_l2>=#<_y>
#<_o_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_b>=[#<_probe_nom_l2> + [#<_o_l2> - #<_cy>]]
#<_o_x>=[[#<_o_l1> * #<_probe_lat_ux>] + [#<_o_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_o_l1> * #<_probe_lat_uy>] + #<_o_b> + [#<_o_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_o_l1> * #<_probe_lat_uz>] + [#<_o_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2707 else
(MSG: measure only - work offset left untouched)
o2707 endif
(MSG: Y channel centred, WCS Y0 set)

(--- echo the result if Fusion asked for it ---)
o1209 if [#<_probe_print> GT 0]
(PRINT, PROBE Y channel:)
(PRINT,   centre %.4f#<_cy>  width %.4f#<_probe_meas_y>  nominal %.4f#<_probe_width_y> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2607 if [#<_probe_pause> GT 0]
M0
o2607 endif
o1209 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=5
#<_probe_log_y>=#<_cy>
#<_probe_log_nomsize>=#<_probe_width_y>
#<_probe_log_size>=#<_probe_meas_y>
o2804 if [#<_probe_log> GT 0]
$Probe/Log
o2804 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
