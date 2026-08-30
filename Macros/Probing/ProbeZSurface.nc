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

#<_start_abs_x>=#<_abs_x>
#<_start_abs_y>=#<_abs_y>
#<_start_abs_z>=#<_abs_z>

#<_ps_ux>=0
#<_ps_uy>=0
#<_ps_uz>=-1
#<_ps_rotate>=0
$SD/Run=/Probing/_ProbeSurface.nc

(--- position deviation: expected surface was clearance below the start ---)
#<_expected>=[#<_start_abs_z> - #<_probe_clearance>]
#<_probe_dev_pos>=[ABS[#<_ps_z> - #<_expected>]]
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
G10 L20 P#<_probe_wcs> Z[#<_probe_nom_z> + [#<_abs_z> - #<_ps_z>]]
(MSG: Z surface probed, WCS Z0 set)

(--- echo the result if Fusion asked for it ---)
o1900 if [#<_probe_print> GT 0]
(PRINT, PROBE Z surface:)
(PRINT,   Z found %.4f#<_ps_z>  nominal %.4f#<_probe_nom_z> )
(PRINT,   dev size %.4f#<_probe_dev_size>  pos %.4f#<_probe_dev_pos>  runout %.4f#<_probe_runout> )
o2610 if [#<_probe_pause> GT 0]
M0
o2610 endif
o1900 endif

$SD/Run=/Probing/ProbeCheckTolerance.nc
