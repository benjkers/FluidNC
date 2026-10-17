(ProbeZSurface.nc)
(Probes downward onto a surface and sets Z0 in the TARGET work offset.)
(Fusion cycle "probing-z".)
()
(NO radius compensation: the touch is on the BOTTOM of the ball, which is)
(already the reference the tool length offset was set from.)
()
(NO runout compensation either, and this is deliberate. Runout is a RADIAL)
(offset of the tip from the spindle axis. Rotating the spindle sweeps the)
(ball around a cone but does not move the ball centre in Z, so the lowest)
(point of the ball - and therefore the Z reading - is unchanged. A 180)
(degree rotation here would cost the operator a pause and measure nothing.)

$SD/Run=/Probing/ProbeInit.nc

(--- the height we started at, along the TOOL AXIS ---)
(Written Z is only a height when nothing is indexed. At B90 a plane of)
(constant written Z is vertical, so the start Z said nothing about how far)
(above the surface the probe was. The projection is a height at any angle,)
(and in the WORK frame throughout.)
(=================== SETTLE BEFORE READING POSITION ===================)
(#<_x>/#<_y>/#<_z> are evaluated through get_mpos with NO buffer sync, so)
(a read taken while a previous move is still decelerating returns an)
(IN-FLIGHT position, not the end of the queued motion.)
()
(That is harmless for a plain G90 move, whose endpoint comes from the word)
(itself. It is NOT harmless here: the delta below is computed FROM this)
(read, so a stale read moves the machine wrong by however far the previous)
(move still had to run.)
()
(It only bites when this macro is entered straight after an UNPROTECTED)
(rapid. After a G38.x there is no race at all, because mc_probe_cycle ends)
(in a wait for State::Idle. A plain G0 has no such wait -- which is why one)
(5 mm descent entered after a bare G0 overshot by 0.803 mm while every)
(other call in the same program, each following a probe move, was exact.)
()
(G4 synchronises the planner before it dwells, so this is the drain.)
G4 P0.01
#<_start_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]

(Direction INTO the surface, in the frame the caller is writing in.)
()
(DERIVED from the tool axis, every time. A surface probe goes down the)
(spindle by definition, so the direction is minus the tool axis and there is)
(nothing for a caller to choose.)
()
(This used to be forced to 0,0,-1. With TCP on and the part indexed, written)
(Z is NOT the tool axis -- at B90 it is a lateral direction -- so that drove)
(the probe sideways: the post had set the right vector and this threw it)
(away. Deriving it here also beats reading #<_ps_ux> from the post, because)
(named parameters persist: a stale -1 left by the last posted program would)
(otherwise aim a HAND-RUN probe sideways with nothing on screen to explain)
(it.)
()
(_probe_axis_u* defaults to straight up, so a 3-axis machine, a TCP-disabled)
(job and an un-indexed section all give 0,0,-1 exactly as before.)
o2363 if [EXISTS[#<_probe_lat_ux>] EQ 0]
#<_probe_lat_ux>=1
o2363 endif
o2364 if [EXISTS[#<_probe_lat_uy>] EQ 0]
#<_probe_lat_uy>=0
o2364 endif
o2365 if [EXISTS[#<_probe_lat_uz>] EQ 0]
#<_probe_lat_uz>=0
o2365 endif
o2366 if [EXISTS[#<_probe_nom_h>] EQ 0]
#<_probe_nom_h>=#<_probe_nom_z>
o2366 endif
o2360 if [EXISTS[#<_probe_axis_ux>] EQ 0]
#<_probe_axis_ux>=0
o2360 endif
o2361 if [EXISTS[#<_probe_axis_uy>] EQ 0]
#<_probe_axis_uy>=0
o2361 endif
o2362 if [EXISTS[#<_probe_axis_uz>] EQ 0]
#<_probe_axis_uz>=1
o2362 endif
#<_ps_ux>=[0 - #<_probe_axis_ux>]
#<_ps_uy>=[0 - #<_probe_axis_uy>]
#<_ps_uz>=[0 - #<_probe_axis_uz>]
#<_ps_rotate>=0
$SD/Run=/Probing/_ProbeSurface.nc

(--- position deviation: expected surface was clearance below the start ---)
#<_found_h>=[[#<_ps_wx> * #<_probe_axis_ux>] + [#<_ps_wy> * #<_probe_axis_uy>] + [#<_ps_wz> * #<_probe_axis_uz>]]
#<_expected>=[#<_start_h> - #<_probe_clearance>]
#<_probe_dev_pos>=[ABS[#<_found_h> - #<_expected>]]
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
o2710 if [#<_probe_set_origin> GT 0]
(The correction is a distance along the TOOL AXIS -- that is the only)
(direction this cycle measured. Writing it to Z alone is right only at B0:)
(at B90 the tool axis is written X, so the whole correction went into a)
(LATERAL axis and left the measured one untouched.)
()
(So shift the origin ALONG the tool axis, and write all three axes. The two)
(lateral terms reproduce the readings those axes already have, which makes)
(them no-ops -- exactly what not naming them used to achieve at B0.)
#<_cur_l1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_cur_h>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_o_h>=[#<_probe_nom_h> + [#<_cur_h> - #<_found_h>]]
#<_o_x>=[[#<_cur_l1> * #<_probe_lat_ux>] + [#<_o_h> * #<_probe_axis_ux>]]
#<_o_y>=[[#<_cur_l1> * #<_probe_lat_uy>] + #<_y> + [#<_o_h> * #<_probe_axis_uy>]]
#<_o_z>=[[#<_cur_l1> * #<_probe_lat_uz>] + [#<_o_h> * #<_probe_axis_uz>]]
G10 L20 P#<_probe_wcs> X#<_o_x> Y#<_o_y> Z#<_o_z>
o2710 else
(MSG: measure only - work offset left untouched)
o2710 endif
(MSG: Z surface probed, WCS Z0 set)

(--- echo the result if Fusion asked for it ---)
o1900 if [#<_probe_print> GT 0]
(PRINT, PROBE Z surface:)
(PRINT,   height found %.4f#<_found_h>  nominal %.4f#<_probe_nom_h> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2610 if [#<_probe_pause> GT 0]
M0
o2610 endif
o1900 endif

(--- hand the result to the SD log if it is enabled ---)
(The generic column names let one C++ writer serve every cycle;)
(each macro maps its own values onto them here.)
#<_probe_log_kind>=1
#<_probe_log_z>=#<_found_h>
o2800 if [#<_probe_log> GT 0]
$Probe/Log
o2800 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
