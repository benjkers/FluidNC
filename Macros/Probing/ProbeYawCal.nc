(ProbeYawCal.nc)
(Measures the probe PRE-TRAVEL -- the number that goes into _probe_yaw --)
(and the tip eccentricity, from 100 touches around a known pin.)
()
(SETUP)
(  A ground pin held rigidly, with G54 origin on its TOP CENTRE.)
()
(  MEASURE BOTH DIAMETERS WITH A MICROMETER and put the RADII below.)
(  Nominal sizes are not good enough: the yaw is [R + r] minus half the)
(  measured separation, so every 0.01 mm of error in either diameter puts)
(  0.005 mm straight into the answer. A pin and ruby both 0.035 mm under)
(  nominal shifted one result by 35 um.)
(  A 6 mm ruby stylus. Both radii are set below. Run from G54.)
()
(  SET THAT ORIGIN PROPERLY FIRST. Run an ordinary circular boss probe on)
(  the pin and let it set X0 Y0. A boss probe finds the CENTRE correctly)
(  even with the yaw uncalibrated, because the radius error cancels in a)
(  midpoint -- so there is no circular dependency.)
()
(  It matters because the standoff is measured from the ASSUMED centre. An)
(  origin off by more than a few millimetres makes the gap larger on the)
(  angles where the error adds, and the probe can run out of travel and)
(  report no contact -- on some touches but not others.)
()
(DO NOT ROTATE THE SPINDLE during this. Every touch must see the same tip)
(eccentricity; turning it between touches changes that and scrambles both)
(results. Set it once and leave it alone.)
()
(HOW IT WORKS)
(  Probing inward at angle T the spindle trips at)
(      P = C - e + n * [R + r - d])
(  with C the pin centre, e the eccentricity, n the outward unit vector,)
(  R the pin radius, r the ruby radius and d the pre-travel. So every)
(  touch lands on a circle of radius [R + r - d] centred on [C - e].)
()
(  OPPOSITE pairs make both fall out exactly, with no curve fitting:)
(      separation between the pair = 2 * [R + r - d]   -> gives d)
(      midpoint of the pair        = C - e             -> gives e)
()
(  This runs 50 pairs at 3.6 degree steps. Each pair is measured and)
(  accumulated immediately, so only two points are ever held at once.)
(  The min and max across pairs is the probe's LOBING -- its direction)
(  dependent pre-travel -- so you see how much one number can be trusted.)
()
(  Nothing here reads _probe_yaw or _probe_eff_radius, so the result)
(  cannot be biased by the value being measured.)
()
(READING THE PER-PAIR OUTPUT)
(  Every pair prints its own angle and yaw, so the SHAPE of the variation)
(  can be plotted. The shape says where the error comes from:)
(     three peaks per revolution  -> the probe's kinematic seat, inherent)
(     two peaks, aligned to X/Y   -> machine stiffness differing by axis)
(     one peak                    -> something eccentric or loose)
(     no shape, just scatter      -> stick-slip, or trigger noise)
(  A tight spread means one yaw value serves every direction. A wide one)
(  means it cannot, whatever number you enter.)
()
(RUNTIME is roughly 15 to 20 minutes for the full 100 touches.)

(================= EDIT THESE =================)
#<_cal_pin_r>=2.990
#<_cal_ruby_r>=2.975

(Probing depth below the pin top. The pin must stand proud by more than)
(this, and the ruby must meet the PIN, not a chamfer or the vice.)
#<_cal_z>=-6.000

(Height above the pin top used to cross over it between touches.)
#<_cal_safe_z>=10.000

(Approach gap and overtravel for the fast touch.)
#<_cal_appr>=5.000
#<_cal_over>=6.000

(Release backoff between the fast and slow touches.)
#<_cal_back>=2.000

(1 = append every pair to /probe_log.csv as well as printing it. Needs the)
(ProbeLog firmware; set 0 if that is not flashed, or the command will error)
(on every pair. The feature column reads YAWCAL so calibration rows can be)
(filtered out from real measurements.)
#<_cal_log>=1

(Feeds. The slow one MUST match the measure feed used in production --)
(pre-travel scales with probing speed, so a value calibrated at one feed)
(is wrong at another.)
#<_cal_fast>=300.000
#<_cal_slow>=50.000
#<_cal_link>=1000.000

(================= DERIVED =================)
#<_cal_sum_r>=[#<_cal_pin_r> + #<_cal_ruby_r>]
#<_cal_stand>=[#<_cal_sum_r> + #<_cal_appr>]
#<_cal_reach>=[#<_cal_appr> + #<_cal_over>]
(Slow travel: contact is expected one backoff in, so twice that is ample)
(margin without crawling any further than necessary at the measuring feed.)
#<_cal_slowtrav>=[#<_cal_back> * 2]

(================= ACCUMULATORS =================)
#<_yawsum>=0.000
#<_mxsum>=0.000
#<_mysum>=0.000
#<_yawmin>=999.000
#<_yawmax>=-999.000
(ProbeYawCal.nc)
(Measures the probe PRE-TRAVEL -- the number that goes into _probe_yaw --)
(and the tip eccentricity, from 100 touches around a known pin.)
()
(SETUP)
(  A ground pin held rigidly, with G54 origin on its TOP CENTRE.)
()
(  MEASURE BOTH DIAMETERS WITH A MICROMETER and put the RADII below.)
(  Nominal sizes are not good enough: the yaw is [R + r] minus half the)
(  measured separation, so every 0.01 mm of error in either diameter puts)
(  0.005 mm straight into the answer. A pin and ruby both 0.035 mm under)
(  nominal shifted one result by 35 um.)
(  A 6 mm ruby stylus. Both radii are set below. Run from G54.)
()
(  SET THAT ORIGIN PROPERLY FIRST. Run an ordinary circular boss probe on)
(  the pin and let it set X0 Y0. A boss probe finds the CENTRE correctly)
(  even with the yaw uncalibrated, because the radius error cancels in a)
(  midpoint -- so there is no circular dependency.)
()
(  It matters because the standoff is measured from the ASSUMED centre. An)
(  origin off by more than a few millimetres makes the gap larger on the)
(  angles where the error adds, and the probe can run out of travel and)
(  report no contact -- on some touches but not others.)
()
(DO NOT ROTATE THE SPINDLE during this. Every touch must see the same tip)
(eccentricity; turning it between touches changes that and scrambles both)
(results. Set it once and leave it alone.)
()
(HOW IT WORKS)
(  Probing inward at angle T the spindle trips at)
(      P = C - e + n * [R + r - d])
(  with C the pin centre, e the eccentricity, n the outward unit vector,)
(  R the pin radius, r the ruby radius and d the pre-travel. So every)
(  touch lands on a circle of radius [R + r - d] centred on [C - e].)
()
(  OPPOSITE pairs make both fall out exactly, with no curve fitting:)
(      separation between the pair = 2 * [R + r - d]   -> gives d)
(      midpoint of the pair        = C - e             -> gives e)
()
(  This runs 50 pairs at 3.6 degree steps. Each pair is measured and)
(  accumulated immediately, so only two points are ever held at once.)
(  The min and max across pairs is the probe's LOBING -- its direction)
(  dependent pre-travel -- so you see how much one number can be trusted.)
()
(  Nothing here reads _probe_yaw or _probe_eff_radius, so the result)
(  cannot be biased by the value being measured.)
()
(READING THE PER-PAIR OUTPUT)
(  Every pair prints its own angle and yaw, so the SHAPE of the variation)
(  can be plotted. The shape says where the error comes from:)
(     three peaks per revolution  -> the probe's kinematic seat, inherent)
(     two peaks, aligned to X/Y   -> machine stiffness differing by axis)
(     one peak                    -> something eccentric or loose)
(     no shape, just scatter      -> stick-slip, or trigger noise)
(  A tight spread means one yaw value serves every direction. A wide one)
(  means it cannot, whatever number you enter.)
()
(WHAT GOES TO THE SD LOG)
(  One row per touch, 100 of them, then a summary. In the CSV:)
(     meas_x  the angle in degrees)
(     meas_y  the touch X, in the work frame)
(     meas_z  the touch Y, in the work frame)
(  Plotting meas_z against meas_y draws the ring of touch points, so the)
(  shape can be judged directly: a circle offset from zero is plain tip)
(  eccentricity, while lobes or flats in the ring are the probe or the)
(  machine varying with direction.)
()
(  Radius from the FITTED centre is the honest roundness measure, and that)
(  centre is only known once every pair is done -- the summary row carries)
(  it, so the radii are best worked out in the spreadsheet afterwards)
(  rather than here.)
()
(RUNTIME is roughly 15 to 20 minutes for the full 100 touches.)

(================= EDIT THESE =================)
#<_cal_pin_r>=2.990
#<_cal_ruby_r>=2.975

(Probing depth below the pin top. The pin must stand proud by more than)
(this, and the ruby must meet the PIN, not a chamfer or the vice.)
#<_cal_z>=-6.000

(Height above the pin top used to cross over it between touches.)
#<_cal_safe_z>=10.000

(Approach gap and overtravel for the fast touch.)
#<_cal_appr>=5.000
#<_cal_over>=6.000

(Release backoff between the fast and slow touches.)
#<_cal_back>=2.000

(1 = append every pair to /probe_log.csv as well as printing it. Needs the)
(ProbeLog firmware; set 0 if that is not flashed, or the command will error)
(on every pair. The feature column reads YAWCAL so calibration rows can be)
(filtered out from real measurements.)
#<_cal_log>=1

(Feeds. The slow one MUST match the measure feed used in production --)
(pre-travel scales with probing speed, so a value calibrated at one feed)
(is wrong at another.)
#<_cal_fast>=300.000
#<_cal_slow>=50.000
#<_cal_link>=1000.000

(================= DERIVED =================)
#<_cal_sum_r>=[#<_cal_pin_r> + #<_cal_ruby_r>]
#<_cal_stand>=[#<_cal_sum_r> + #<_cal_appr>]
#<_cal_reach>=[#<_cal_appr> + #<_cal_over>]
(Slow travel: contact is expected one backoff in, so twice that is ample)
(margin without crawling any further than necessary at the measuring feed.)
#<_cal_slowtrav>=[#<_cal_back> * 2]

(================= ACCUMULATORS =================)
#<_yawsum>=0.000
#<_mxsum>=0.000
#<_mysum>=0.000
#<_yawmin>=999.000
#<_yawmax>=-999.000

(Clear the log file if logging is enabled, so the new run is at the top.)
$Probe/LogClear

G90
G0 Z#<_cal_safe_z>
(MSG: Yaw calibration - 100 touches - do NOT turn the spindle)

(--- pair 1 of 50: 0.0 and 180.0 degrees ---)
(PRINT, yaw cal: pair 1 of 50 )
#<_nx>=[COS[0.0000]]
#<_ny>=[SIN[0.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[180.0000]]
#<_ny>=[SIN[180.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2900 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=0.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=180.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2900 endif
(PRINT, pair 1 at 0.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2200 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2200 endif
o2201 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2201 endif

(--- pair 2 of 50: 3.6 and 183.6 degrees ---)
#<_nx>=[COS[3.6000]]
#<_ny>=[SIN[3.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[183.6000]]
#<_ny>=[SIN[183.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2901 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=3.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=183.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2901 endif
(PRINT, pair 2 at 3.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2202 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2202 endif
o2203 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2203 endif

(--- pair 3 of 50: 7.2 and 187.2 degrees ---)
#<_nx>=[COS[7.2000]]
#<_ny>=[SIN[7.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[187.2000]]
#<_ny>=[SIN[187.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2902 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=7.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=187.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2902 endif
(PRINT, pair 3 at 7.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2204 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2204 endif
o2205 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2205 endif

(--- pair 4 of 50: 10.8 and 190.8 degrees ---)
#<_nx>=[COS[10.8000]]
#<_ny>=[SIN[10.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[190.8000]]
#<_ny>=[SIN[190.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2903 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=10.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=190.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2903 endif
(PRINT, pair 4 at 10.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2206 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2206 endif
o2207 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2207 endif

(--- pair 5 of 50: 14.4 and 194.4 degrees ---)
#<_nx>=[COS[14.4000]]
#<_ny>=[SIN[14.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[194.4000]]
#<_ny>=[SIN[194.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2904 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=14.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=194.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2904 endif
(PRINT, pair 5 at 14.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2208 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2208 endif
o2209 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2209 endif

(--- pair 6 of 50: 18.0 and 198.0 degrees ---)
#<_nx>=[COS[18.0000]]
#<_ny>=[SIN[18.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[198.0000]]
#<_ny>=[SIN[198.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2905 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=18.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=198.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2905 endif
(PRINT, pair 6 at 18.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2210 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2210 endif
o2211 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2211 endif

(--- pair 7 of 50: 21.6 and 201.6 degrees ---)
#<_nx>=[COS[21.6000]]
#<_ny>=[SIN[21.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[201.6000]]
#<_ny>=[SIN[201.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2906 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=21.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=201.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2906 endif
(PRINT, pair 7 at 21.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2212 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2212 endif
o2213 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2213 endif

(--- pair 8 of 50: 25.2 and 205.2 degrees ---)
#<_nx>=[COS[25.2000]]
#<_ny>=[SIN[25.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[205.2000]]
#<_ny>=[SIN[205.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2907 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=25.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=205.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2907 endif
(PRINT, pair 8 at 25.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2214 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2214 endif
o2215 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2215 endif

(--- pair 9 of 50: 28.8 and 208.8 degrees ---)
#<_nx>=[COS[28.8000]]
#<_ny>=[SIN[28.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[208.8000]]
#<_ny>=[SIN[208.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2908 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=28.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=208.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2908 endif
(PRINT, pair 9 at 28.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2216 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2216 endif
o2217 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2217 endif

(--- pair 10 of 50: 32.4 and 212.4 degrees ---)
#<_nx>=[COS[32.4000]]
#<_ny>=[SIN[32.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[212.4000]]
#<_ny>=[SIN[212.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2909 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=32.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=212.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2909 endif
(PRINT, pair 10 at 32.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2218 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2218 endif
o2219 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2219 endif

(--- pair 11 of 50: 36.0 and 216.0 degrees ---)
(PRINT, yaw cal: pair 11 of 50 )
#<_nx>=[COS[36.0000]]
#<_ny>=[SIN[36.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[216.0000]]
#<_ny>=[SIN[216.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2910 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=36.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=216.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2910 endif
(PRINT, pair 11 at 36.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2220 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2220 endif
o2221 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2221 endif

(--- pair 12 of 50: 39.6 and 219.6 degrees ---)
#<_nx>=[COS[39.6000]]
#<_ny>=[SIN[39.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[219.6000]]
#<_ny>=[SIN[219.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2911 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=39.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=219.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2911 endif
(PRINT, pair 12 at 39.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2222 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2222 endif
o2223 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2223 endif

(--- pair 13 of 50: 43.2 and 223.2 degrees ---)
#<_nx>=[COS[43.2000]]
#<_ny>=[SIN[43.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[223.2000]]
#<_ny>=[SIN[223.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2912 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=43.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=223.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2912 endif
(PRINT, pair 13 at 43.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2224 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2224 endif
o2225 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2225 endif

(--- pair 14 of 50: 46.8 and 226.8 degrees ---)
#<_nx>=[COS[46.8000]]
#<_ny>=[SIN[46.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[226.8000]]
#<_ny>=[SIN[226.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2913 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=46.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=226.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2913 endif
(PRINT, pair 14 at 46.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2226 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2226 endif
o2227 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2227 endif

(--- pair 15 of 50: 50.4 and 230.4 degrees ---)
#<_nx>=[COS[50.4000]]
#<_ny>=[SIN[50.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[230.4000]]
#<_ny>=[SIN[230.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2914 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=50.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=230.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2914 endif
(PRINT, pair 15 at 50.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2228 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2228 endif
o2229 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2229 endif

(--- pair 16 of 50: 54.0 and 234.0 degrees ---)
#<_nx>=[COS[54.0000]]
#<_ny>=[SIN[54.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[234.0000]]
#<_ny>=[SIN[234.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2915 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=54.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=234.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2915 endif
(PRINT, pair 16 at 54.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2230 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2230 endif
o2231 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2231 endif

(--- pair 17 of 50: 57.6 and 237.6 degrees ---)
#<_nx>=[COS[57.6000]]
#<_ny>=[SIN[57.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[237.6000]]
#<_ny>=[SIN[237.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2916 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=57.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=237.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2916 endif
(PRINT, pair 17 at 57.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2232 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2232 endif
o2233 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2233 endif

(--- pair 18 of 50: 61.2 and 241.2 degrees ---)
#<_nx>=[COS[61.2000]]
#<_ny>=[SIN[61.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[241.2000]]
#<_ny>=[SIN[241.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2917 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=61.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=241.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2917 endif
(PRINT, pair 18 at 61.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2234 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2234 endif
o2235 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2235 endif

(--- pair 19 of 50: 64.8 and 244.8 degrees ---)
#<_nx>=[COS[64.8000]]
#<_ny>=[SIN[64.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[244.8000]]
#<_ny>=[SIN[244.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2918 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=64.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=244.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2918 endif
(PRINT, pair 19 at 64.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2236 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2236 endif
o2237 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2237 endif

(--- pair 20 of 50: 68.4 and 248.4 degrees ---)
#<_nx>=[COS[68.4000]]
#<_ny>=[SIN[68.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[248.4000]]
#<_ny>=[SIN[248.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2919 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=68.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=248.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2919 endif
(PRINT, pair 20 at 68.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2238 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2238 endif
o2239 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2239 endif

(--- pair 21 of 50: 72.0 and 252.0 degrees ---)
(PRINT, yaw cal: pair 21 of 50 )
#<_nx>=[COS[72.0000]]
#<_ny>=[SIN[72.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[252.0000]]
#<_ny>=[SIN[252.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2920 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=72.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=252.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2920 endif
(PRINT, pair 21 at 72.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2240 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2240 endif
o2241 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2241 endif

(--- pair 22 of 50: 75.6 and 255.6 degrees ---)
#<_nx>=[COS[75.6000]]
#<_ny>=[SIN[75.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[255.6000]]
#<_ny>=[SIN[255.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2921 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=75.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=255.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2921 endif
(PRINT, pair 22 at 75.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2242 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2242 endif
o2243 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2243 endif

(--- pair 23 of 50: 79.2 and 259.2 degrees ---)
#<_nx>=[COS[79.2000]]
#<_ny>=[SIN[79.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[259.2000]]
#<_ny>=[SIN[259.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2922 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=79.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=259.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2922 endif
(PRINT, pair 23 at 79.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2244 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2244 endif
o2245 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2245 endif

(--- pair 24 of 50: 82.8 and 262.8 degrees ---)
#<_nx>=[COS[82.8000]]
#<_ny>=[SIN[82.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[262.8000]]
#<_ny>=[SIN[262.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2923 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=82.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=262.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2923 endif
(PRINT, pair 24 at 82.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2246 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2246 endif
o2247 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2247 endif

(--- pair 25 of 50: 86.4 and 266.4 degrees ---)
#<_nx>=[COS[86.4000]]
#<_ny>=[SIN[86.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[266.4000]]
#<_ny>=[SIN[266.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2924 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=86.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=266.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2924 endif
(PRINT, pair 25 at 86.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2248 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2248 endif
o2249 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2249 endif

(--- pair 26 of 50: 90.0 and 270.0 degrees ---)
#<_nx>=[COS[90.0000]]
#<_ny>=[SIN[90.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[270.0000]]
#<_ny>=[SIN[270.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2925 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=90.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=270.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2925 endif
(PRINT, pair 26 at 90.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2250 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2250 endif
o2251 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2251 endif

(--- pair 27 of 50: 93.6 and 273.6 degrees ---)
#<_nx>=[COS[93.6000]]
#<_ny>=[SIN[93.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[273.6000]]
#<_ny>=[SIN[273.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2926 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=93.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=273.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2926 endif
(PRINT, pair 27 at 93.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2252 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2252 endif
o2253 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2253 endif

(--- pair 28 of 50: 97.2 and 277.2 degrees ---)
#<_nx>=[COS[97.2000]]
#<_ny>=[SIN[97.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[277.2000]]
#<_ny>=[SIN[277.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2927 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=97.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=277.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2927 endif
(PRINT, pair 28 at 97.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2254 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2254 endif
o2255 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2255 endif

(--- pair 29 of 50: 100.8 and 280.8 degrees ---)
#<_nx>=[COS[100.8000]]
#<_ny>=[SIN[100.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[280.8000]]
#<_ny>=[SIN[280.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2928 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=100.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=280.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2928 endif
(PRINT, pair 29 at 100.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2256 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2256 endif
o2257 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2257 endif

(--- pair 30 of 50: 104.4 and 284.4 degrees ---)
#<_nx>=[COS[104.4000]]
#<_ny>=[SIN[104.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[284.4000]]
#<_ny>=[SIN[284.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2929 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=104.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=284.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2929 endif
(PRINT, pair 30 at 104.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2258 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2258 endif
o2259 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2259 endif

(--- pair 31 of 50: 108.0 and 288.0 degrees ---)
(PRINT, yaw cal: pair 31 of 50 )
#<_nx>=[COS[108.0000]]
#<_ny>=[SIN[108.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[288.0000]]
#<_ny>=[SIN[288.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2930 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=108.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=288.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2930 endif
(PRINT, pair 31 at 108.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2260 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2260 endif
o2261 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2261 endif

(--- pair 32 of 50: 111.6 and 291.6 degrees ---)
#<_nx>=[COS[111.6000]]
#<_ny>=[SIN[111.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[291.6000]]
#<_ny>=[SIN[291.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2931 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=111.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=291.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2931 endif
(PRINT, pair 32 at 111.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2262 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2262 endif
o2263 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2263 endif

(--- pair 33 of 50: 115.2 and 295.2 degrees ---)
#<_nx>=[COS[115.2000]]
#<_ny>=[SIN[115.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[295.2000]]
#<_ny>=[SIN[295.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2932 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=115.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=295.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2932 endif
(PRINT, pair 33 at 115.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2264 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2264 endif
o2265 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2265 endif

(--- pair 34 of 50: 118.8 and 298.8 degrees ---)
#<_nx>=[COS[118.8000]]
#<_ny>=[SIN[118.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[298.8000]]
#<_ny>=[SIN[298.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2933 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=118.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=298.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2933 endif
(PRINT, pair 34 at 118.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2266 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2266 endif
o2267 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2267 endif

(--- pair 35 of 50: 122.4 and 302.4 degrees ---)
#<_nx>=[COS[122.4000]]
#<_ny>=[SIN[122.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[302.4000]]
#<_ny>=[SIN[302.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2934 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=122.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=302.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2934 endif
(PRINT, pair 35 at 122.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2268 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2268 endif
o2269 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2269 endif

(--- pair 36 of 50: 126.0 and 306.0 degrees ---)
#<_nx>=[COS[126.0000]]
#<_ny>=[SIN[126.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[306.0000]]
#<_ny>=[SIN[306.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2935 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=126.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=306.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2935 endif
(PRINT, pair 36 at 126.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2270 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2270 endif
o2271 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2271 endif

(--- pair 37 of 50: 129.6 and 309.6 degrees ---)
#<_nx>=[COS[129.6000]]
#<_ny>=[SIN[129.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[309.6000]]
#<_ny>=[SIN[309.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2936 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=129.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=309.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2936 endif
(PRINT, pair 37 at 129.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2272 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2272 endif
o2273 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2273 endif

(--- pair 38 of 50: 133.2 and 313.2 degrees ---)
#<_nx>=[COS[133.2000]]
#<_ny>=[SIN[133.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[313.2000]]
#<_ny>=[SIN[313.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2937 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=133.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=313.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2937 endif
(PRINT, pair 38 at 133.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2274 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2274 endif
o2275 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2275 endif

(--- pair 39 of 50: 136.8 and 316.8 degrees ---)
#<_nx>=[COS[136.8000]]
#<_ny>=[SIN[136.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[316.8000]]
#<_ny>=[SIN[316.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2938 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=136.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=316.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2938 endif
(PRINT, pair 39 at 136.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2276 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2276 endif
o2277 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2277 endif

(--- pair 40 of 50: 140.4 and 320.4 degrees ---)
#<_nx>=[COS[140.4000]]
#<_ny>=[SIN[140.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[320.4000]]
#<_ny>=[SIN[320.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2939 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=140.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=320.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2939 endif
(PRINT, pair 40 at 140.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2278 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2278 endif
o2279 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2279 endif

(--- pair 41 of 50: 144.0 and 324.0 degrees ---)
(PRINT, yaw cal: pair 41 of 50 )
#<_nx>=[COS[144.0000]]
#<_ny>=[SIN[144.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[324.0000]]
#<_ny>=[SIN[324.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2940 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=144.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=324.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2940 endif
(PRINT, pair 41 at 144.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2280 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2280 endif
o2281 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2281 endif

(--- pair 42 of 50: 147.6 and 327.6 degrees ---)
#<_nx>=[COS[147.6000]]
#<_ny>=[SIN[147.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[327.6000]]
#<_ny>=[SIN[327.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2941 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=147.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=327.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2941 endif
(PRINT, pair 42 at 147.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2282 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2282 endif
o2283 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2283 endif

(--- pair 43 of 50: 151.2 and 331.2 degrees ---)
#<_nx>=[COS[151.2000]]
#<_ny>=[SIN[151.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[331.2000]]
#<_ny>=[SIN[331.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2942 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=151.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=331.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2942 endif
(PRINT, pair 43 at 151.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2284 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2284 endif
o2285 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2285 endif

(--- pair 44 of 50: 154.8 and 334.8 degrees ---)
#<_nx>=[COS[154.8000]]
#<_ny>=[SIN[154.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[334.8000]]
#<_ny>=[SIN[334.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2943 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=154.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=334.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2943 endif
(PRINT, pair 44 at 154.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2286 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2286 endif
o2287 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2287 endif

(--- pair 45 of 50: 158.4 and 338.4 degrees ---)
#<_nx>=[COS[158.4000]]
#<_ny>=[SIN[158.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[338.4000]]
#<_ny>=[SIN[338.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2944 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=158.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=338.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2944 endif
(PRINT, pair 45 at 158.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2288 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2288 endif
o2289 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2289 endif

(--- pair 46 of 50: 162.0 and 342.0 degrees ---)
#<_nx>=[COS[162.0000]]
#<_ny>=[SIN[162.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[342.0000]]
#<_ny>=[SIN[342.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2945 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=162.0
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=342.0
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2945 endif
(PRINT, pair 46 at 162.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2290 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2290 endif
o2291 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2291 endif

(--- pair 47 of 50: 165.6 and 345.6 degrees ---)
#<_nx>=[COS[165.6000]]
#<_ny>=[SIN[165.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[345.6000]]
#<_ny>=[SIN[345.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2946 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=165.6
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=345.6
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2946 endif
(PRINT, pair 47 at 165.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2292 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2292 endif
o2293 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2293 endif

(--- pair 48 of 50: 169.2 and 349.2 degrees ---)
#<_nx>=[COS[169.2000]]
#<_ny>=[SIN[169.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[349.2000]]
#<_ny>=[SIN[349.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2947 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=169.2
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=349.2
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2947 endif
(PRINT, pair 48 at 169.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2294 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2294 endif
o2295 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2295 endif

(--- pair 49 of 50: 172.8 and 352.8 degrees ---)
#<_nx>=[COS[172.8000]]
#<_ny>=[SIN[172.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[352.8000]]
#<_ny>=[SIN[352.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2948 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=172.8
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=352.8
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2948 endif
(PRINT, pair 49 at 172.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2296 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2296 endif
o2297 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2297 endif

(--- pair 50 of 50: 176.4 and 356.4 degrees ---)
#<_nx>=[COS[176.4000]]
#<_ny>=[SIN[176.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[356.4000]]
#<_ny>=[SIN[356.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2949 if [#<_cal_log> GT 0]
(One row per TOUCH, not per pair, so the actual points can be)
(plotted. Coordinates are shifted into the work frame by taking off)
(the G54 offset, which puts the ring around zero and shows the tip)
(eccentricity as a bodily offset of the whole shape.)
#<_probe_log_kind>=12
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
#<_probe_log_x>=176.4
#<_probe_log_y>=[#<_pax> - #5221]
#<_probe_log_z>=[#<_pay> - #5222]
$Probe/Log
#<_probe_log_x>=356.4
#<_probe_log_y>=[#<_pbx> - #5221]
#<_probe_log_z>=[#<_pby> - #5222]
$Probe/Log
o2949 endif
(PRINT, pair 50 at 176.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2298 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2298 endif
o2299 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2299 endif

G90
G0 Z#<_cal_safe_z>

(================= RESULT =================)
#<_yawavg>=[#<_yawsum> / 50]
#<_cx>=[#<_mxsum> / 50]
#<_cy>=[#<_mysum> / 50]
#<_lobe>=[#<_yawmax> - #<_yawmin>]

(The averaged midpoint is [C - e] in machine coordinates. C is the G54)
(origin, so subtracting the G54 offset leaves -e in work coordinates.)
#<_ecc_x>=[0 - [#<_cx> - #5221]]
#<_ecc_y>=[0 - [#<_cy> - #5222]]
#<_ecc>=[SQRT[[#<_ecc_x> * #<_ecc_x>] + [#<_ecc_y> * #<_ecc_y>]]]

(PRINT, ================================ )
(PRINT, PROBE YAW CALIBRATION - 50 pairs )
(PRINT, ================================ )
(PRINT, )
(PRINT,     _probe_yaw = %.4f#<_yawavg> )
(PRINT, )
(PRINT, ================================ )
(PRINT, min %.4f#<_yawmin>  max %.4f#<_yawmax>  lobing %.4f#<_lobe> )
(PRINT, eccentricity X %.4f#<_ecc_x>  Y %.4f#<_ecc_y>  total %.4f#<_ecc> )
o2300 if [#<_ecc> GT 0.500]
(PRINT, WARNING: far too large for probe eccentricity. )
(PRINT, The G54 origin is probably not on the pin centre. Set it with a )
(PRINT, circular boss probe first, then repeat this calibration. )
o2300 endif
o2999 if [#<_cal_log> GT 0]
(One summary row, so the answer sits in the file next to the pairs it came)
(from rather than only on the console.)
#<_probe_log_kind>=13
#<_probe_log_nomsize>=#<_yawmin>
#<_probe_log_size>=#<_yawmax>
#<_probe_dev_size>=#<_yawavg>
#<_probe_dev_pos>=#<_ecc>
#<_probe_runout>=#<_lobe>
$Probe/Log
o2999 endif

(MSG: Calibration complete - put the _probe_yaw value in your startup macro)

(Clear SD Card probe log if it exists, so the new run is clean.)
$Probe/LogClear
G90
G0 Z#<_cal_safe_z>
(MSG: Yaw calibration - 100 touches - do NOT turn the spindle)

(--- pair 1 of 50: 0.0 and 180.0 degrees ---)
(PRINT, yaw cal: pair 1 of 50 )
#<_nx>=[COS[0.0000]]
#<_ny>=[SIN[0.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[180.0000]]
#<_ny>=[SIN[180.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2900 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=0.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2900 endif
(PRINT, pair 1 at 0.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2200 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2200 endif
o2201 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2201 endif

(--- pair 2 of 50: 3.6 and 183.6 degrees ---)
#<_nx>=[COS[3.6000]]
#<_ny>=[SIN[3.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[183.6000]]
#<_ny>=[SIN[183.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2901 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=3.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2901 endif
(PRINT, pair 2 at 3.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2202 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2202 endif
o2203 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2203 endif

(--- pair 3 of 50: 7.2 and 187.2 degrees ---)
#<_nx>=[COS[7.2000]]
#<_ny>=[SIN[7.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[187.2000]]
#<_ny>=[SIN[187.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2902 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=7.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2902 endif
(PRINT, pair 3 at 7.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2204 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2204 endif
o2205 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2205 endif

(--- pair 4 of 50: 10.8 and 190.8 degrees ---)
#<_nx>=[COS[10.8000]]
#<_ny>=[SIN[10.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[190.8000]]
#<_ny>=[SIN[190.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2903 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=10.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2903 endif
(PRINT, pair 4 at 10.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2206 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2206 endif
o2207 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2207 endif

(--- pair 5 of 50: 14.4 and 194.4 degrees ---)
#<_nx>=[COS[14.4000]]
#<_ny>=[SIN[14.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[194.4000]]
#<_ny>=[SIN[194.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2904 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=14.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2904 endif
(PRINT, pair 5 at 14.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2208 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2208 endif
o2209 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2209 endif

(--- pair 6 of 50: 18.0 and 198.0 degrees ---)
#<_nx>=[COS[18.0000]]
#<_ny>=[SIN[18.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[198.0000]]
#<_ny>=[SIN[198.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2905 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=18.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2905 endif
(PRINT, pair 6 at 18.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2210 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2210 endif
o2211 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2211 endif

(--- pair 7 of 50: 21.6 and 201.6 degrees ---)
#<_nx>=[COS[21.6000]]
#<_ny>=[SIN[21.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[201.6000]]
#<_ny>=[SIN[201.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2906 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=21.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2906 endif
(PRINT, pair 7 at 21.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2212 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2212 endif
o2213 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2213 endif

(--- pair 8 of 50: 25.2 and 205.2 degrees ---)
#<_nx>=[COS[25.2000]]
#<_ny>=[SIN[25.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[205.2000]]
#<_ny>=[SIN[205.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2907 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=25.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2907 endif
(PRINT, pair 8 at 25.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2214 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2214 endif
o2215 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2215 endif

(--- pair 9 of 50: 28.8 and 208.8 degrees ---)
#<_nx>=[COS[28.8000]]
#<_ny>=[SIN[28.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[208.8000]]
#<_ny>=[SIN[208.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2908 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=28.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2908 endif
(PRINT, pair 9 at 28.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2216 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2216 endif
o2217 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2217 endif

(--- pair 10 of 50: 32.4 and 212.4 degrees ---)
#<_nx>=[COS[32.4000]]
#<_ny>=[SIN[32.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[212.4000]]
#<_ny>=[SIN[212.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2909 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=32.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2909 endif
(PRINT, pair 10 at 32.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2218 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2218 endif
o2219 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2219 endif

(--- pair 11 of 50: 36.0 and 216.0 degrees ---)
(PRINT, yaw cal: pair 11 of 50 )
#<_nx>=[COS[36.0000]]
#<_ny>=[SIN[36.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[216.0000]]
#<_ny>=[SIN[216.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2910 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=36.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2910 endif
(PRINT, pair 11 at 36.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2220 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2220 endif
o2221 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2221 endif

(--- pair 12 of 50: 39.6 and 219.6 degrees ---)
#<_nx>=[COS[39.6000]]
#<_ny>=[SIN[39.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[219.6000]]
#<_ny>=[SIN[219.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2911 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=39.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2911 endif
(PRINT, pair 12 at 39.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2222 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2222 endif
o2223 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2223 endif

(--- pair 13 of 50: 43.2 and 223.2 degrees ---)
#<_nx>=[COS[43.2000]]
#<_ny>=[SIN[43.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[223.2000]]
#<_ny>=[SIN[223.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2912 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=43.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2912 endif
(PRINT, pair 13 at 43.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2224 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2224 endif
o2225 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2225 endif

(--- pair 14 of 50: 46.8 and 226.8 degrees ---)
#<_nx>=[COS[46.8000]]
#<_ny>=[SIN[46.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[226.8000]]
#<_ny>=[SIN[226.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2913 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=46.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2913 endif
(PRINT, pair 14 at 46.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2226 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2226 endif
o2227 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2227 endif

(--- pair 15 of 50: 50.4 and 230.4 degrees ---)
#<_nx>=[COS[50.4000]]
#<_ny>=[SIN[50.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[230.4000]]
#<_ny>=[SIN[230.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2914 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=50.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2914 endif
(PRINT, pair 15 at 50.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2228 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2228 endif
o2229 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2229 endif

(--- pair 16 of 50: 54.0 and 234.0 degrees ---)
#<_nx>=[COS[54.0000]]
#<_ny>=[SIN[54.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[234.0000]]
#<_ny>=[SIN[234.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2915 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=54.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2915 endif
(PRINT, pair 16 at 54.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2230 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2230 endif
o2231 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2231 endif

(--- pair 17 of 50: 57.6 and 237.6 degrees ---)
#<_nx>=[COS[57.6000]]
#<_ny>=[SIN[57.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[237.6000]]
#<_ny>=[SIN[237.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2916 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=57.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2916 endif
(PRINT, pair 17 at 57.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2232 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2232 endif
o2233 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2233 endif

(--- pair 18 of 50: 61.2 and 241.2 degrees ---)
#<_nx>=[COS[61.2000]]
#<_ny>=[SIN[61.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[241.2000]]
#<_ny>=[SIN[241.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2917 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=61.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2917 endif
(PRINT, pair 18 at 61.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2234 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2234 endif
o2235 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2235 endif

(--- pair 19 of 50: 64.8 and 244.8 degrees ---)
#<_nx>=[COS[64.8000]]
#<_ny>=[SIN[64.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[244.8000]]
#<_ny>=[SIN[244.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2918 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=64.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2918 endif
(PRINT, pair 19 at 64.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2236 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2236 endif
o2237 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2237 endif

(--- pair 20 of 50: 68.4 and 248.4 degrees ---)
#<_nx>=[COS[68.4000]]
#<_ny>=[SIN[68.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[248.4000]]
#<_ny>=[SIN[248.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2919 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=68.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2919 endif
(PRINT, pair 20 at 68.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2238 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2238 endif
o2239 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2239 endif

(--- pair 21 of 50: 72.0 and 252.0 degrees ---)
(PRINT, yaw cal: pair 21 of 50 )
#<_nx>=[COS[72.0000]]
#<_ny>=[SIN[72.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[252.0000]]
#<_ny>=[SIN[252.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2920 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=72.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2920 endif
(PRINT, pair 21 at 72.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2240 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2240 endif
o2241 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2241 endif

(--- pair 22 of 50: 75.6 and 255.6 degrees ---)
#<_nx>=[COS[75.6000]]
#<_ny>=[SIN[75.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[255.6000]]
#<_ny>=[SIN[255.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2921 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=75.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2921 endif
(PRINT, pair 22 at 75.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2242 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2242 endif
o2243 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2243 endif

(--- pair 23 of 50: 79.2 and 259.2 degrees ---)
#<_nx>=[COS[79.2000]]
#<_ny>=[SIN[79.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[259.2000]]
#<_ny>=[SIN[259.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2922 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=79.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2922 endif
(PRINT, pair 23 at 79.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2244 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2244 endif
o2245 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2245 endif

(--- pair 24 of 50: 82.8 and 262.8 degrees ---)
#<_nx>=[COS[82.8000]]
#<_ny>=[SIN[82.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[262.8000]]
#<_ny>=[SIN[262.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2923 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=82.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2923 endif
(PRINT, pair 24 at 82.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2246 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2246 endif
o2247 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2247 endif

(--- pair 25 of 50: 86.4 and 266.4 degrees ---)
#<_nx>=[COS[86.4000]]
#<_ny>=[SIN[86.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[266.4000]]
#<_ny>=[SIN[266.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2924 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=86.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2924 endif
(PRINT, pair 25 at 86.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2248 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2248 endif
o2249 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2249 endif

(--- pair 26 of 50: 90.0 and 270.0 degrees ---)
#<_nx>=[COS[90.0000]]
#<_ny>=[SIN[90.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[270.0000]]
#<_ny>=[SIN[270.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2925 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=90.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2925 endif
(PRINT, pair 26 at 90.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2250 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2250 endif
o2251 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2251 endif

(--- pair 27 of 50: 93.6 and 273.6 degrees ---)
#<_nx>=[COS[93.6000]]
#<_ny>=[SIN[93.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[273.6000]]
#<_ny>=[SIN[273.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2926 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=93.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2926 endif
(PRINT, pair 27 at 93.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2252 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2252 endif
o2253 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2253 endif

(--- pair 28 of 50: 97.2 and 277.2 degrees ---)
#<_nx>=[COS[97.2000]]
#<_ny>=[SIN[97.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[277.2000]]
#<_ny>=[SIN[277.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2927 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=97.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2927 endif
(PRINT, pair 28 at 97.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2254 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2254 endif
o2255 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2255 endif

(--- pair 29 of 50: 100.8 and 280.8 degrees ---)
#<_nx>=[COS[100.8000]]
#<_ny>=[SIN[100.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[280.8000]]
#<_ny>=[SIN[280.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2928 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=100.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2928 endif
(PRINT, pair 29 at 100.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2256 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2256 endif
o2257 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2257 endif

(--- pair 30 of 50: 104.4 and 284.4 degrees ---)
#<_nx>=[COS[104.4000]]
#<_ny>=[SIN[104.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[284.4000]]
#<_ny>=[SIN[284.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2929 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=104.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2929 endif
(PRINT, pair 30 at 104.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2258 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2258 endif
o2259 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2259 endif

(--- pair 31 of 50: 108.0 and 288.0 degrees ---)
(PRINT, yaw cal: pair 31 of 50 )
#<_nx>=[COS[108.0000]]
#<_ny>=[SIN[108.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[288.0000]]
#<_ny>=[SIN[288.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2930 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=108.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2930 endif
(PRINT, pair 31 at 108.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2260 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2260 endif
o2261 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2261 endif

(--- pair 32 of 50: 111.6 and 291.6 degrees ---)
#<_nx>=[COS[111.6000]]
#<_ny>=[SIN[111.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[291.6000]]
#<_ny>=[SIN[291.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2931 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=111.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2931 endif
(PRINT, pair 32 at 111.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2262 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2262 endif
o2263 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2263 endif

(--- pair 33 of 50: 115.2 and 295.2 degrees ---)
#<_nx>=[COS[115.2000]]
#<_ny>=[SIN[115.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[295.2000]]
#<_ny>=[SIN[295.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2932 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=115.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2932 endif
(PRINT, pair 33 at 115.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2264 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2264 endif
o2265 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2265 endif

(--- pair 34 of 50: 118.8 and 298.8 degrees ---)
#<_nx>=[COS[118.8000]]
#<_ny>=[SIN[118.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[298.8000]]
#<_ny>=[SIN[298.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2933 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=118.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2933 endif
(PRINT, pair 34 at 118.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2266 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2266 endif
o2267 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2267 endif

(--- pair 35 of 50: 122.4 and 302.4 degrees ---)
#<_nx>=[COS[122.4000]]
#<_ny>=[SIN[122.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[302.4000]]
#<_ny>=[SIN[302.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2934 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=122.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2934 endif
(PRINT, pair 35 at 122.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2268 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2268 endif
o2269 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2269 endif

(--- pair 36 of 50: 126.0 and 306.0 degrees ---)
#<_nx>=[COS[126.0000]]
#<_ny>=[SIN[126.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[306.0000]]
#<_ny>=[SIN[306.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2935 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=126.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2935 endif
(PRINT, pair 36 at 126.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2270 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2270 endif
o2271 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2271 endif

(--- pair 37 of 50: 129.6 and 309.6 degrees ---)
#<_nx>=[COS[129.6000]]
#<_ny>=[SIN[129.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[309.6000]]
#<_ny>=[SIN[309.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2936 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=129.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2936 endif
(PRINT, pair 37 at 129.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2272 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2272 endif
o2273 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2273 endif

(--- pair 38 of 50: 133.2 and 313.2 degrees ---)
#<_nx>=[COS[133.2000]]
#<_ny>=[SIN[133.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[313.2000]]
#<_ny>=[SIN[313.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2937 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=133.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2937 endif
(PRINT, pair 38 at 133.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2274 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2274 endif
o2275 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2275 endif

(--- pair 39 of 50: 136.8 and 316.8 degrees ---)
#<_nx>=[COS[136.8000]]
#<_ny>=[SIN[136.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[316.8000]]
#<_ny>=[SIN[316.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2938 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=136.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2938 endif
(PRINT, pair 39 at 136.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2276 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2276 endif
o2277 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2277 endif

(--- pair 40 of 50: 140.4 and 320.4 degrees ---)
#<_nx>=[COS[140.4000]]
#<_ny>=[SIN[140.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[320.4000]]
#<_ny>=[SIN[320.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2939 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=140.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2939 endif
(PRINT, pair 40 at 140.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2278 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2278 endif
o2279 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2279 endif

(--- pair 41 of 50: 144.0 and 324.0 degrees ---)
(PRINT, yaw cal: pair 41 of 50 )
#<_nx>=[COS[144.0000]]
#<_ny>=[SIN[144.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[324.0000]]
#<_ny>=[SIN[324.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2940 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=144.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2940 endif
(PRINT, pair 41 at 144.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2280 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2280 endif
o2281 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2281 endif

(--- pair 42 of 50: 147.6 and 327.6 degrees ---)
#<_nx>=[COS[147.6000]]
#<_ny>=[SIN[147.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[327.6000]]
#<_ny>=[SIN[327.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2941 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=147.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2941 endif
(PRINT, pair 42 at 147.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2282 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2282 endif
o2283 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2283 endif

(--- pair 43 of 50: 151.2 and 331.2 degrees ---)
#<_nx>=[COS[151.2000]]
#<_ny>=[SIN[151.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[331.2000]]
#<_ny>=[SIN[331.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2942 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=151.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2942 endif
(PRINT, pair 43 at 151.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2284 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2284 endif
o2285 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2285 endif

(--- pair 44 of 50: 154.8 and 334.8 degrees ---)
#<_nx>=[COS[154.8000]]
#<_ny>=[SIN[154.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[334.8000]]
#<_ny>=[SIN[334.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2943 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=154.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2943 endif
(PRINT, pair 44 at 154.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2286 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2286 endif
o2287 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2287 endif

(--- pair 45 of 50: 158.4 and 338.4 degrees ---)
#<_nx>=[COS[158.4000]]
#<_ny>=[SIN[158.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[338.4000]]
#<_ny>=[SIN[338.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2944 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=158.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2944 endif
(PRINT, pair 45 at 158.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2288 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2288 endif
o2289 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2289 endif

(--- pair 46 of 50: 162.0 and 342.0 degrees ---)
#<_nx>=[COS[162.0000]]
#<_ny>=[SIN[162.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[342.0000]]
#<_ny>=[SIN[342.0000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2945 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=162.0
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2945 endif
(PRINT, pair 46 at 162.0 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2290 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2290 endif
o2291 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2291 endif

(--- pair 47 of 50: 165.6 and 345.6 degrees ---)
#<_nx>=[COS[165.6000]]
#<_ny>=[SIN[165.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[345.6000]]
#<_ny>=[SIN[345.6000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2946 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=165.6
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2946 endif
(PRINT, pair 47 at 165.6 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2292 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2292 endif
o2293 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2293 endif

(--- pair 48 of 50: 169.2 and 349.2 degrees ---)
#<_nx>=[COS[169.2000]]
#<_ny>=[SIN[169.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[349.2000]]
#<_ny>=[SIN[349.2000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2947 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=169.2
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2947 endif
(PRINT, pair 48 at 169.2 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2294 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2294 endif
o2295 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2295 endif

(--- pair 49 of 50: 172.8 and 352.8 degrees ---)
#<_nx>=[COS[172.8000]]
#<_ny>=[SIN[172.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[352.8000]]
#<_ny>=[SIN[352.8000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2948 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=172.8
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2948 endif
(PRINT, pair 49 at 172.8 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2296 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2296 endif
o2297 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2297 endif

(--- pair 50 of 50: 176.4 and 356.4 degrees ---)
#<_nx>=[COS[176.4000]]
#<_ny>=[SIN[176.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pax>=#5061
#<_pay>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_nx>=[COS[356.4000]]
#<_ny>=[SIN[356.4000]]
#<_sx>=[#<_nx> * #<_cal_stand>]
#<_sy>=[#<_ny> * #<_cal_stand>]
#<_rx>=[#<_nx> * #<_cal_reach>]
#<_ry>=[#<_ny> * #<_cal_reach>]
#<_bx>=[#<_nx> * #<_cal_back>]
#<_by>=[#<_ny> * #<_cal_back>]
#<_tx>=[#<_nx> * #<_cal_slowtrav>]
#<_ty>=[#<_ny> * #<_cal_slowtrav>]
G90
G0 Z#<_cal_safe_z>
G0 X#<_sx> Y#<_sy>
G38.3 Z#<_cal_z> F#<_cal_link>
G91
G38.2 X[0 - #<_rx>] Y[0 - #<_ry>] F#<_cal_fast>
G0 X#<_bx> Y#<_by>
G38.2 X[0 - #<_tx>] Y[0 - #<_ty>] F#<_cal_slow>
G90
#<_pbx>=#5061
#<_pby>=#5062
G91
G0 X#<_bx> Y#<_by>
G90
#<_ddx>=[#<_pax> - #<_pbx>]
#<_ddy>=[#<_pay> - #<_pby>]
#<_sep>=[SQRT[[#<_ddx> * #<_ddx>] + [#<_ddy> * #<_ddy>]]]
#<_yawk>=[#<_cal_sum_r> - [#<_sep> / 2]]
o2949 if [#<_cal_log> GT 0]
#<_probe_log_kind>=12
#<_probe_log_x>=176.4
#<_probe_log_nomsize>=[#<_cal_sum_r> * 2]
#<_probe_log_size>=#<_sep>
#<_probe_dev_size>=#<_yawk>
#<_probe_dev_pos>=0.000
#<_probe_runout>=0.000
$Probe/Log
o2949 endif
(PRINT, pair 50 at 176.4 deg  sep %.4f#<_sep>  yaw %.4f#<_yawk> )
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o2298 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o2298 endif
o2299 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o2299 endif

G90
G0 Z#<_cal_safe_z>

(================= RESULT =================)
#<_yawavg>=[#<_yawsum> / 50]
#<_cx>=[#<_mxsum> / 50]
#<_cy>=[#<_mysum> / 50]
#<_lobe>=[#<_yawmax> - #<_yawmin>]

(The averaged midpoint is [C - e] in machine coordinates. C is the G54)
(origin, so subtracting the G54 offset leaves -e in work coordinates.)
#<_ecc_x>=[0 - [#<_cx> - #5221]]
#<_ecc_y>=[0 - [#<_cy> - #5222]]
#<_ecc>=[SQRT[[#<_ecc_x> * #<_ecc_x>] + [#<_ecc_y> * #<_ecc_y>]]]

(PRINT, ================================ )
(PRINT, PROBE YAW CALIBRATION - 50 pairs )
(PRINT, ================================ )
(PRINT, )
(PRINT,     _probe_yaw = %.4f#<_yawavg> )
(PRINT, )
(PRINT, ================================ )
(PRINT, min %.4f#<_yawmin>  max %.4f#<_yawmax>  lobing %.4f#<_lobe> )
(PRINT, eccentricity X %.4f#<_ecc_x>  Y %.4f#<_ecc_y>  total %.4f#<_ecc> )
o2300 if [#<_ecc> GT 0.500]
(PRINT, WARNING: far too large for probe eccentricity. )
(PRINT, The G54 origin is probably not on the pin centre. Set it with a )
(PRINT, circular boss probe first, then repeat this calibration. )
o2300 endif
o2999 if [#<_cal_log> GT 0]
(One summary row, so the answer sits in the file next to the pairs it came)
(from rather than only on the console.)
#<_probe_log_kind>=13
#<_probe_log_nomsize>=#<_yawmin>
#<_probe_log_size>=#<_yawmax>
#<_probe_dev_size>=#<_yawavg>
#<_probe_dev_pos>=#<_ecc>
#<_probe_runout>=#<_lobe>
$Probe/Log
o2999 endif

(MSG: Calibration complete - put the _probe_yaw value in your startup macro)
