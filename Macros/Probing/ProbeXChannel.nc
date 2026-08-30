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
o200 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o200 endif
G53 G38.3 X[#<_start_abs_x> + [-1 * [#<_halfx> - #<_probe_clearance> - #<_probe_tool_radius>]]] F#<_probe_feed_link>
o201 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o201 endif
#<_ps_ux>=-1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxa>=#<_ps_x>

(--- +X face, probing +X ---)
o202 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o202 endif
G53 G38.3 X[#<_start_abs_x> + [1 * [#<_halfx> - #<_probe_clearance> - #<_probe_tool_radius>]]] F#<_probe_feed_link>
o203 if [#<_probe_lift> GT 0]
G90
G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>
o203 endif
#<_ps_ux>=1
#<_ps_uy>=0
#<_ps_uz>=0
#<_ps_rotate>=1
$SD/Run=/Probing/_ProbeSurface.nc
#<_wxb>=#<_ps_x>

#<_cx>=[[#<_wxa> + #<_wxb>] / 2]
#<_probe_meas_x>=[ABS[#<_wxb> - #<_wxa>] + [2 * #<_probe_eff_radius>]]

o204 if [#<_probe_lift> GT 0]
G90
G0 Z#<_probe_retract_z>
o204 endif

#<_probe_dev_size>=[#<_probe_meas_x> - #<_probe_width_x>]
#<_probe_dev_pos>=[ABS[#<_cx> - #<_start_abs_x>]]

(--- declare the origin WITHOUT moving ---)
(G10 L20 sets the offset from wherever the probe is standing:)
(    offset = MPos - TLO - value)
(so emitting  N + [P - found]  puts the origin on the feature)
(without the probe ever driving back toward it.)
G10 L20 P#<_probe_wcs> X[#<_probe_nom_x> + [#<_abs_x> - #<_cx>]]
(MSG: X channel centred, WCS X0 set)

$SD/Run=/Probing/ProbeCheckTolerance.nc
