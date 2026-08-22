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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1002 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1002 endif
o1003 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1003 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1006 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1006 endif
o1007 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1007 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1010 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1010 endif
o1011 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1011 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1014 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1014 endif
o1015 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1015 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1018 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1018 endif
o1019 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1019 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1022 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1022 endif
o1023 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1023 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1026 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1026 endif
o1027 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1027 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1030 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1030 endif
o1031 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1031 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1034 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1034 endif
o1035 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1035 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1038 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1038 endif
o1039 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1039 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1042 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1042 endif
o1043 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1043 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1046 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1046 endif
o1047 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1047 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1050 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1050 endif
o1051 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1051 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1054 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1054 endif
o1055 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1055 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1058 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1058 endif
o1059 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1059 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1062 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1062 endif
o1063 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1063 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1066 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1066 endif
o1067 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1067 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1070 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1070 endif
o1071 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1071 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1074 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1074 endif
o1075 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1075 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1078 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1078 endif
o1079 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1079 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1082 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1082 endif
o1083 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1083 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1086 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1086 endif
o1087 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1087 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1090 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1090 endif
o1091 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1091 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1094 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1094 endif
o1095 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1095 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1098 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1098 endif
o1099 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1099 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1102 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1102 endif
o1103 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1103 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1106 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1106 endif
o1107 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1107 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1110 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1110 endif
o1111 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1111 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1114 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1114 endif
o1115 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1115 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1118 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1118 endif
o1119 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1119 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1122 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1122 endif
o1123 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1123 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1126 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1126 endif
o1127 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1127 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1130 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1130 endif
o1131 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1131 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1134 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1134 endif
o1135 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1135 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1138 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1138 endif
o1139 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1139 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1142 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1142 endif
o1143 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1143 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1146 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1146 endif
o1147 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1147 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1150 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1150 endif
o1151 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1151 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1154 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1154 endif
o1155 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1155 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1158 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1158 endif
o1159 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1159 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1162 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1162 endif
o1163 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1163 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1166 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1166 endif
o1167 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1167 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1170 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1170 endif
o1171 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1171 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1174 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1174 endif
o1175 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1175 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1178 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1178 endif
o1179 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1179 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1182 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1182 endif
o1183 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1183 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1186 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1186 endif
o1187 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1187 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1190 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1190 endif
o1191 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1191 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1194 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1194 endif
o1195 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1195 endif

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
#<_yawsum>=[#<_yawsum> + #<_yawk>]
#<_mxsum>=[#<_mxsum> + [[#<_pax> + #<_pbx>] / 2]]
#<_mysum>=[#<_mysum> + [[#<_pay> + #<_pby>] / 2]]
o1198 if [#<_yawk> LT #<_yawmin>]
#<_yawmin>=#<_yawk>
o1198 endif
o1199 if [#<_yawk> GT #<_yawmax>]
#<_yawmax>=#<_yawk>
o1199 endif

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
o900 if [#<_ecc> GT 0.500]
(PRINT, WARNING: far too large for probe eccentricity. )
(PRINT, The G54 origin is probably not on the pin centre. Set it with a )
(PRINT, circular boss probe first, then repeat this calibration. )
o900 endif
(MSG: Calibration complete - put the _probe_yaw value in your startup macro)
