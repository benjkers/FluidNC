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

(================= SAFETY DEFAULTS =================)
(The post normally writes all of these. Defaults exist only so a macro run)
(by hand from the console cannot fault on an undefined read.)
o2401 if [EXISTS[#<_probe_clearance>]]
o2401 else
#<_probe_clearance>=2.000
o2401 endif

(RETRACT between the fast and the slow touch, and before the rotation)
(pause. Set UNCONDITIONALLY, not EXISTS-guarded: the clamp below writes to)
(this same parameter, so a guard would leave a tight bore's reduced value)
(in place for every later cycle in the program.)
#<_probe_backoff>=2.000

(It cannot exceed the approach distance -- that is all the room there is)
(between the trigger point and where the approach began.)
o2402 if [#<_probe_backoff> GT #<_probe_clearance>]
#<_probe_backoff>=#<_probe_clearance>
o2402 endif
o2404 if [EXISTS[#<_probe_overtravel>]]
o2404 else
#<_probe_overtravel>=3.000
o2404 endif
o2405 if [EXISTS[#<_probe_feed_fast>]]
o2405 else
#<_probe_feed_fast>=300.000
o2405 endif
o2406 if [EXISTS[#<_probe_feed_slow>]]
o2406 else
#<_probe_feed_slow>=50.000
o2406 endif
o2407 if [EXISTS[#<_probe_tool_radius>]]
o2407 else
#<_probe_tool_radius>=1.500
o2407 endif

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
o2408 if [EXISTS[#<_probe_yaw>]]
o2408 else
#<_probe_yaw>=0.000
o2408 endif

(Effective X/Y radius actually used by every macro below.)
#<_probe_eff_radius>=[#<_probe_tool_radius> - #<_probe_yaw>]
o2409 if [#<_probe_eff_radius> LE 0]
    (MSG: PROBE ERROR - probe yaw is >= the stylus radius, check calibration)
    $Alarm/Send=3
    G4 P0.1
o2409 endif
(ABSOLUTE heights from Fusion, in the DRIVING work offset.)
()
(_probe_retract_z is Fusion's Retract Height -- stock top plus an offset,)
(so it is guaranteed to clear the part. _probe_depth_z is the Bottom)
(Height, the depth features are probed at.)
()
(These replaced a RELATIVE lift, which was unsafe: lifting a fixed 12.5 mm)
(from probing depth clears the part only if the part happens to be shorter)
(than that. On a tall boss it leaves the stylus buried in material.)
o2410 if [EXISTS[#<_probe_retract_z>]]
o2410 else
#<_probe_retract_z>=0.000
o2410 endif
o2411 if [EXISTS[#<_probe_depth_z>]]
o2411 else
#<_probe_depth_z>=0.000
o2411 endif

(1 = lift to the retract height between touches, for an island or an)
(external feature. 0 = stay at probing depth throughout.)
o2412 if [EXISTS[#<_probe_lift>]]
o2412 else
#<_probe_lift>=0
o2412 endif
o2413 if [EXISTS[#<_probe_width_x>]]
o2413 else
#<_probe_width_x>=0.000
o2413 endif
o2414 if [EXISTS[#<_probe_width_y>]]
o2414 else
#<_probe_width_y>=0.000
o2414 endif

(================= TARGET OFFSET AND NOMINAL POSITION =================)
(WHICH work offset the result is written to. 0 = whichever offset is)
(currently active, 1 = G54, 2 = G55, and so on. Fusion's WCS probing lets)
(you drive the probe from one offset while writing the result into a)
(different one, so this must not be assumed to be the active offset.)
o2415 if [EXISTS[#<_probe_wcs>]]
o2415 else
#<_probe_wcs>=0
o2415 endif

(The NOMINAL position of the probed feature, in the TARGET offset. The)
(feature being probed is very often NOT at the origin -- a bore might sit)
(at X50 Y30 in the setup. The origin is therefore placed so that the found)
(feature lands on these coordinates, rather than forcing the origin onto)
(the feature itself. Leave them 0 and the feature becomes the origin,)
(which is the old behaviour.)
o2416 if [EXISTS[#<_probe_nom_x>]]
o2416 else
#<_probe_nom_x>=0.000
o2416 endif
o2417 if [EXISTS[#<_probe_nom_y>]]
o2417 else
#<_probe_nom_y>=0.000
o2417 endif
o2418 if [EXISTS[#<_probe_nom_z>]]
o2418 else
#<_probe_nom_z>=0.000
o2418 endif

(================= RUNOUT COMPENSATION =================)
(Retract distance used while the operator rotates the spindle 180 degrees)
(between the two touches of a surface. Must clear the surface but stay)
(close enough that the second touch is quick. Defaults to the clearance.)
o2419 if [EXISTS[#<_probe_runout>]]
o2419 else
#<_probe_runout>=0
o2419 endif

(Direction of travel for a single axis edge probe: +1 toward positive,)
(-1 toward negative. The post always writes this, but a default belongs)
(here too so running an edge macro by hand from the console cannot fault)
(on an undefined parameter.)
o2420 if [EXISTS[#<_probe_axis_dir>]]
o2420 else
#<_probe_axis_dir>=1
o2420 endif

(Feed for PROTECTED positioning moves. Every move made with the probe in)
(the spindle is a G38.3 rather than a G0 -- it stops on contact instead of)
(snapping the stylus on a clamp or a part that is not where CAM thinks.)
(This is how fast those moves travel. The post passes Fusion's link feed.)
o2421 if [EXISTS[#<_probe_feed_link>]]
o2421 else
#<_probe_feed_link>=1000.000
o2421 endif

(1 = echo the measured result to the console after each cycle. Driven by)
(Fusion's "Print Results" checkbox. PRINT interpolates parameter values, so)
(the operator sees the actual numbers rather than just a pass or fail.)
(1 = hold with a pause after the result is printed, so it can be read)
(before the program moves on. Only has an effect when printing is on --)
(there is nothing to wait for otherwise.)
o2440 if [EXISTS[#<_probe_pause>]]
o2440 else
#<_probe_pause>=0
o2440 endif

(1 = write the found feature into the work offset. 0 = MEASURE ONLY.)
()
(Fusion's Probe Geometry operations are inspection: they measure a feature)
(during a job and report it, and must NOT move the work offset. Its WCS)
(probing operations do the opposite. The post tells them apart by the)
(section strategy and sets this accordingly.)
()
(Defaults to 1 so a macro run by hand behaves as it always has.)
o2450 if [EXISTS[#<_probe_set_origin>]]
o2450 else
#<_probe_set_origin>=1
o2450 endif

(1 = also append the result to /probe_log.csv on the SD card. Driven by a)
(post property. Independent of printing: a long unattended job may want)
(the file without the console chatter, or the reverse.)
o2460 if [EXISTS[#<_probe_log>]]
o2460 else
#<_probe_log>=0
o2460 endif

o2422 if [EXISTS[#<_probe_print>]]
o2422 else
#<_probe_print>=0
o2422 endif

(================= TOLERANCE DEFAULTS =================)
(0 = no check. Actions: 0 = warn only, 1 = alarm and stop.)
o2423 if [EXISTS[#<_probe_tol_size>]]
o2423 else
#<_probe_tol_size>=0.000
o2423 endif
o2424 if [EXISTS[#<_probe_tol_pos>]]
o2424 else
#<_probe_tol_pos>=0.000
o2424 endif
o2425 if [EXISTS[#<_probe_action_size>]]
o2425 else
#<_probe_action_size>=1
o2425 endif
o2426 if [EXISTS[#<_probe_action_pos>]]
o2426 else
#<_probe_action_pos>=1
o2426 endif

(Deviations are filled in by each macro before it calls the checker.)
o2427 if [EXISTS[#<_probe_dev_size>]]
o2427 else
#<_probe_dev_size>=0.000
o2427 endif
o2428 if [EXISTS[#<_probe_dev_pos>]]
o2428 else
#<_probe_dev_pos>=0.000
o2428 endif
