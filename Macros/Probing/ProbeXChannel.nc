(ProbeXChannel.nc)
(Centre of a channel or slot measured across X)
(Fusion cycles: "probing-x-channel" and "probing-x-channel-with-island")
()
(INTERNAL: the probe works OUTWARD from the nominal centre.)
(Set #<_probe_lift> for an island: it then travels at)
(#<_probe_retract_z> between touches instead of through the island.)
()
(The probe NEVER descends at a feature centre -- only at a standoff)
(beside a face it is about to touch. Descending at the centre would)
(mean landing on an island, or inside a boss.)

$SD/Run=/Probing/ProbeInit.nc

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

#<_halfx>=[#<_probe_width_x> / 2]

(--- -X face, probing -X ---)
o1100 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1100 endif
#<_tgx>=[#<_start_abs_x> + [-1 * [#<_halfx> - #<_probe_clearance> - #<_probe_tool_radius>]]]
G53 G38.3 X#<_tgx> F#<_probe_feed_link>
o1101 if [ABS[#<_abs_x> - #<_tgx>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1101 endif
o1102 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1103 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1103 endif
o1102 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>

(--- +X face, probing +X ---)
o1104 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1104 endif
#<_tgx>=[#<_start_abs_x> + [1 * [#<_halfx> - #<_probe_clearance> - #<_probe_tool_radius>]]]
G53 G38.3 X#<_tgx> F#<_probe_feed_link>
o1105 if [ABS[#<_abs_x> - #<_tgx>] GT 0.050]
    (MSG: PROBE ERROR - obstruction while traversing to the standoff)
    (MSG: the probe stopped short, so nothing is where it expects)
    $Alarm/Send=3
    G4 P0.1
o1105 endif
o1106 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o1107 if [ABS[#<_z> - #<_probe_depth_z>] GT 0.050]
    (MSG: PROBE ERROR - obstruction on the way down to probing depth)
    (MSG: the standoff is probably inside material, check the feature size)
    $Alarm/Send=3
    G4 P0.1
o1107 endif
o1106 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] + [2 * #<_probe_eff_radius>]]

o1108 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o1108 endif

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_abs_x>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
o2704 if [#<_probe_set_origin> GT 0]
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]]
o2704 else
(MSG: measure only - work offset left untouched)
o2704 endif
(MSG: X channel centred, WCS X0 set)

(--- echo the result if Fusion asked for it ---)
o1109 if [#<_probe_print> GT 0]
(PRINT, PROBE X channel:)
(PRINT,   centre %.4f#<_cx>  width %.4f#<_probe_meas_x>  nominal %.4f#<_probe_width_x> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2604 if [#<_probe_pause> GT 0]
M0
o2604 endif
o1109 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=4
#<_probe_log_x>=#<_cx>
#<_probe_log_nomsize>=#<_probe_width_x>
#<_probe_log_size>=#<_probe_meas_x>
o2803 if [#<_probe_log> GT 0]
$Probe/Log
o2803 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
