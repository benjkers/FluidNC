(ProbeYWall.nc)
(Centre of a wall pair - the two outside faces either side of a part, across Y)
(Fusion cycles: "probing-y-wall")
()
(EXTERNAL: the probe goes OUT past each face and probes back INWARD.)
(It lifts to #<_probe_retract_z> -- Fusion's Retract Height, which is)
(referenced to stock top and so clears the part -- before every)
(traverse, and descends only once it is beside the face.)
()
(The probe NEVER descends at a feature centre -- only at a standoff)
(beside a face it is about to touch. Descending at the centre would)
(mean landing on an island, or inside a boss.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

o1500 if [#<_probe_retract_z> LE #<_probe_depth_z>]
    (MSG: PROBE ERROR - external probing needs a retract height above the probing depth)
    $Alarm/Send=3
    G4 P0.1
o1500 endif

#<_halfy>=[#<_probe_width_y> / 2]

(--- -Y face, probing +Y ---)
o1501 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1501 endif
#<_tgy>=[#<_start_abs_y> + [-1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
G53 G38.3 Y#<_tgy> F#<_probe_feed_link>
o1502 if [ABS[#<_abs_y> - #<_tgy>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1502 endif
o1503 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1504 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1504 endif
o1503 endif
#<_ps_ux>=0
#<_ps_uy>=1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wya>=#<_ps_y>

(--- +Y face, probing -Y ---)
o1505 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1505 endif
#<_tgy>=[#<_start_abs_y> + [1 * [#<_halfy> + #<_probe_clearance> + #<_probe_tool_radius>]]]
G53 G38.3 Y#<_tgy> F#<_probe_feed_link>
o1506 if [ABS[#<_abs_y> - #<_tgy>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1506 endif
o1507 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1508 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1508 endif
o1507 endif
#<_ps_ux>=0
#<_ps_uy>=-1
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wyb>=#<_ps_y>

#<_cy>=[[#<_wya> + #<_wyb>] / 2]
#<_probe_meas_y>=[ABS[#<_wyb> - #<_wya>] - [2 * #<_probe_eff_radius>]]

o1509 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1509 endif

#<_probe_dev_size>=[#<_probe_meas_y> - #<_probe_width_y>]
#<_probe_dev_pos>=[ABS[#<_cy> - #<_start_abs_y>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
o2709 if [#<_probe_set_origin> GT 0]
G10 L20 P#<_probe_wcs> Y[#<_probe_nom_y> + [#<_abs_y> - #<_cy>]]
o2709 else
(MSG: measure only - work offset left untouched)
o2709 endif
(MSG: Y wall pair centred, WCS Y0 set)

(--- echo the result if Fusion asked for it ---)
o1510 if [#<_probe_print> GT 0]
(PRINT, PROBE Y wall pair:)
(PRINT,   centre %.4f#<_cy>  width %.4f#<_probe_meas_y>  nominal %.4f#<_probe_width_y> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2609 if [#<_probe_pause> GT 0]
M0
o2609 endif
o1510 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=7
#<_probe_log_y>=#<_cy>
#<_probe_log_nomsize>=#<_probe_width_y>
#<_probe_log_size>=#<_probe_meas_y>
o2806 if [#<_probe_log> GT 0]
$Probe/Log
o2806 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
