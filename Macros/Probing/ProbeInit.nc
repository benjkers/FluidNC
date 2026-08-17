(ProbeInit.nc)
(Shared prelude run by EVERY probing macro via)
(    $SD/Run=/Probing/ProbeInit.nc)
(Its job is to guarantee that every value a probing macro reads is)
(DEFINED. Reading an undefined #<param> is a hard gcode error in FluidNC)
(and aborts the controller, so nothing downstream is allowed to assume.)
()
(Values you may want to edit are the CALIBRATION block below. Everything)
(else is a safety default that the post normally overwrites.)
()
(You can also set the calibration values from a controller startup macro)
(instead -- this file only fills in anything still missing, so a value)
(set earlier always wins.)

(================= CALIBRATION -- edit these =================)

(How far to back off between the fast and the slow touch, mm.)
o303 if [EXISTS[#<_probe_backoff>]]
o303 else
#<_probe_backoff>=1.000
o303 endif

(================= SAFETY DEFAULTS =================)
(The post normally writes all of these. Defaults exist only so a macro)
(run by hand from the console cannot fault on an undefined read.)
o310 if [EXISTS[#<_probe_clearance>]]
o310 else
#<_probe_clearance>=2.000
o310 endif
o311 if [EXISTS[#<_probe_overtravel>]]
o311 else
#<_probe_overtravel>=3.000
o311 endif
o312 if [EXISTS[#<_probe_feed_fast>]]
o312 else
#<_probe_feed_fast>=300.000
o312 endif
o313 if [EXISTS[#<_probe_feed_slow>]]
o313 else
#<_probe_feed_slow>=50.000
o313 endif
o314 if [EXISTS[#<_probe_tool_radius>]]
o314 else
#<_probe_tool_radius>=1.500
o314 endif

(PROBE YAW -- the stylus PRE-TRAVEL, i.e. how far the probe keeps moving)
(after the tip touches the surface before the switch actually fires. The)
(trigger is therefore recorded slightly PAST the true surface, always in)
(the direction of travel.)
()
(Correcting for it: surface = trigger + dir * [tip_radius - yaw], so the)
(EFFECTIVE radius used for every X/Y result is  tip_radius - yaw.)
(Leaving yaw at 0 overshoots INTO the material by the deflection amount,)
(which is the dangerous direction, so it is worth calibrating.)
()
(Applies to X/Y probing only. Z probing touches on the bottom of the ball)
(and its deflection is absorbed by the tool length offset instead.)
()
(To calibrate: probe a bore of known diameter and increase _probe_yaw)
(until the reported #<_probe_meas_dia> matches the true size.)
()
(Set it here, or in a controller startup macro -- a value set earlier)
(always wins, because this only fills in what is still missing.)
o302 if [EXISTS[#<_probe_yaw>]]
o302 else
#<_probe_yaw>=0.000
o302 endif

(Effective X/Y radius actually used by every macro below.)
#<_probe_eff_radius>=[#<_probe_tool_radius> - #<_probe_yaw>]
o304 if [#<_probe_eff_radius> LE 0]
    (MSG: PROBE ERROR - probe yaw is >= the stylus radius, check calibration)
    $Alarm/Send=3
    G4 P0.1
o304 endif
o315 if [EXISTS[#<_probe_safe_z>]]
o315 else
#<_probe_safe_z>=0.000
o315 endif
o316 if [EXISTS[#<_probe_width_x>]]
o316 else
#<_probe_width_x>=0.000
o316 endif
o317 if [EXISTS[#<_probe_width_y>]]
o317 else
#<_probe_width_y>=0.000
o317 endif

(================= TARGET OFFSET AND NOMINAL POSITION =================)
(WHICH work offset the result is written to. 0 = whichever offset is)
(currently active, 1 = G54, 2 = G55, and so on. Fusion's WCS probing lets)
(you drive the probe from one offset while writing the result into a)
(different one, so this must not be assumed to be the active offset.)
o324 if [EXISTS[#<_probe_wcs>]]
o324 else
#<_probe_wcs>=0
o324 endif

(The NOMINAL position of the probed feature, in the TARGET offset. The)
(feature being probed is very often NOT at the origin -- a bore might sit)
(at X50 Y30 in the setup. The origin is therefore placed so that the found)
(feature lands on these coordinates, rather than forcing the origin onto)
(the feature itself. Leave them 0 and the feature becomes the origin,)
(which is the old behaviour.)
o325 if [EXISTS[#<_probe_nom_x>]]
o325 else
#<_probe_nom_x>=0.000
o325 endif
o326 if [EXISTS[#<_probe_nom_y>]]
o326 else
#<_probe_nom_y>=0.000
o326 endif
o327 if [EXISTS[#<_probe_nom_z>]]
o327 else
#<_probe_nom_z>=0.000
o327 endif

(================= RUNOUT COMPENSATION =================)
(Retract distance used while the operator rotates the spindle 180 degrees)
(between the two touches of a surface. Must clear the surface but stay)
(close enough that the second touch is quick. Defaults to the clearance.)
o328 if [EXISTS[#<_probe_runout>]]
o328 else
#<_probe_runout>=0
o328 endif

(Direction of travel for a single axis edge probe: +1 toward positive,)
(-1 toward negative. The post always writes this, but a default belongs)
(here too so running an edge macro by hand from the console cannot fault)
(on an undefined parameter.)
o329 if [EXISTS[#<_probe_axis_dir>]]
o329 else
#<_probe_axis_dir>=1
o329 endif

(Feed for PROTECTED positioning moves. Every move made with the probe in)
(the spindle is a G38.3 rather than a G0 -- it stops on contact instead of)
(snapping the stylus on a clamp or a part that is not where CAM thinks.)
(This is how fast those moves travel. The post passes Fusion's link feed.)
o332 if [EXISTS[#<_probe_feed_link>]]
o332 else
#<_probe_feed_link>=1000.000
o332 endif

(================= TOLERANCE DEFAULTS =================)
(0 = no check. Actions: 0 = warn only, 1 = alarm and stop.)
o320 if [EXISTS[#<_probe_tol_size>]]
o320 else
#<_probe_tol_size>=0.000
o320 endif
o321 if [EXISTS[#<_probe_tol_pos>]]
o321 else
#<_probe_tol_pos>=0.000
o321 endif
o322 if [EXISTS[#<_probe_action_size>]]
o322 else
#<_probe_action_size>=1
o322 endif
o323 if [EXISTS[#<_probe_action_pos>]]
o323 else
#<_probe_action_pos>=1
o323 endif

(Deviations are filled in by each macro before it calls the checker.)
o330 if [EXISTS[#<_probe_dev_size>]]
o330 else
#<_probe_dev_size>=0.000
o330 endif
o331 if [EXISTS[#<_probe_dev_pos>]]
o331 else
#<_probe_dev_pos>=0.000
o331 endif
