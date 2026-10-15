(ProbePinYaw.nc)
(Measures _probe_yaw -- the stylus pre-travel -- from a standing pin, and)
(sets a work origin on that pin's TRUE top-surface centre. Both come out)
(of the same eight touches, and the tip eccentricity falls out with them.)
()
(RUN FROM SD:   $SD/Run=/Probing/ProbePinYaw.nc)

(=================== HOW THIS RELATES TO ProbeYawCal.nc ===================)
(  ProbeYawCal is the better yaw instrument and stays the reference: 50)
(  opposite pairs at 3.6 degree steps, which maps the LOBING -- how the)
(  pre-travel varies with direction -- and that is the thing that decides)
(  whether one yaw number can serve at all. This is the same maths on two)
(  pairs instead of fifty. Use it as the quick check, not the authority.)
()
(  What this adds is the thing ProbeYawCal asks for and cannot do for)
(  itself: the G54 origin on the pin's top centre. ProbeYawCal says to set)
(  that with a circular boss probe, which is right about the radius error)
(  cancelling in a midpoint -- but a boss probe runs at ONE spindle)
(  orientation, so its midpoint lands on [centre - e], not the centre. Its)
(  origin carries the tip eccentricity.)
()
(  That matters for ProbeYawCal's own eccentricity output. It computes e by)
(  comparing its averaged midpoint against the G54 offset, so if G54 came)
(  from a boss probe at the same orientation, both carry the same -e and)
(  it reports ZERO. The eccentricity line only means anything when G54 is)
(  on the true centre. Set the origin here first and that output becomes a)
(  real measurement.)
()
(  Do not run this and expect ProbeYawCal's warning about eccentricity to)
(  stay quiet -- once the origin is true, a real e SHOULD show up there.)

(=================== HOW TO RUN IT ===================)
(  1. Probe in the spindle, touched off as usual.)
(  2. Jog the ball roughly over the pin centre and a few mm above its)
(     top face. Where you park is the starting point. Being off centre)
(     does not bias anything, but the first Z touch has to land on the)
(     flat, so stay within pin radius minus _pn_edge -- 3 mm on an 8 mm)
(     pin. Park worse than that and it stops after one pass and says so.)
(  3. Run this file. It probes the top, then the four flanks, stops for)
(     you to turn the spindle 180 degrees by hand, probes the four)
(     flanks again, and finishes on the top at the centre it found.)
()
(  The pin has to stand proud by more than ball radius plus _pn_depth,)
(  about 4.5 mm for a 5.96 ball, so the ball meets the flank and not the)
(  top edge. Mike the pin and enter what you measure: the ball radius)
(  this reports is only as good as the diameter that went in, while the)
(  runout and the origin do not depend on it at all.)

(=================== WHY TWO PASSES ===================)
(  A stylus tip that is not concentric sits off the spindle axis by a)
(  vector e.)
(  Every flank trigger is displaced by e, so the centre one pass computes)
(  is the pin centre minus e. From a single pass you cannot tell the two)
(  apart -- a perfectly centred pin and a bent stylus read identically.)
()
(  Turning the spindle 180 degrees turns e into -e. The second pass)
(  therefore reads the pin centre PLUS e. Average the two and e cancels,)
(  leaving the true centre. Half their difference IS e. So the origin)
(  needs no runout calibration, and the runout falls out for free.)
()
(  The rotation does not have to be accurate. Being 10 degrees out moves)
(  the centre by under 2 microns on a 0.1 mm runout: the error goes as)
(  1 - COS of the miss, which is 1.5 percent at 10 degrees.)

(=================== WHAT THE SPANS GIVE YOU ===================)
(  The distance between opposite flank triggers is the pin diameter plus)
(  two ball radii however the ball is running out, because e shifts both)
(  triggers the same way. So the span measures the EFFECTIVE ball radius)
(  -- stylus bending and pre-travel included -- which is the number that)
(  matters for single-sided touches.)
()
(  Parking off centre shortens a span, since the touches then run along a)
(  chord rather than a diameter. The midpoint is unaffected, so the true)
(  centre is known before the spans are used and Pythagoras puts each)
(  span back onto the diameter exactly. That is why a sloppy park is)
(  fine.)

(=================== WHAT THE ECCENTRICITY NUMBER REALLY IS ==============)
(  It is the eccentricity of the TRIGGER locus, not of the ball. A probe)
(  whose pre-travel differs with direction -- most of them -- triggers)
(  late on one side and early on the other, which displaces the apparent)
(  centre exactly as a bent stylus does, and reverses with the spindle)
(  exactly as a bent stylus does. The two are indistinguishable from)
(  outside, and this reports their sum.)
()
(  That is the useful number, not a shortcoming: what biases a one-sided)
(  touch is where the probe TRIGGERS, not where the ball is. Add this to)
(  a single-sided reading and it comes out right either way.)
()
(  The centre and the ball radius are clean regardless -- averaging the)
(  two passes kills the pre-travel asymmetry along with the runout, and)
(  the span cancels it a second way by summing both directions.)
()
(  Not measured at all: the axial part. A tilted stylus also sits a)
(  little low, and that reverses with the rotation too, but it lands)
(  entirely in Z where only one reading is taken per orientation. The)
(  top-Z cross-check below surfaces it as a rough-to-final disagreement)
(  if it is ever big enough to matter.)

(=================== INPUTS ===================)
(Pin diameter as measured, mm. Mike it -- do not trust the label.)
#<_pn_dia>=8.000

(Ruby ball diameter, nominal, mm. Only used to position the touches and)
(to judge the measured radius against; it is not used in the result.)
#<_pn_ball>=5.960

(Work offset to write: 1 to 6 for G54 to G59, or 0 for whichever offset)
(the program has selected.)
#<_pn_wcs>=1

(Machine Z to travel between touches at.)
#<_pn_safez>=0

(How far the ball centre sits below the top face for the flank touches.)
#<_pn_depth>=1.500

(Nominal ball standoff from the flank before each touch, mm. Has to be)
(bigger than the park tolerance below, or parking off centre would start)
(a touch already inside the pin.)
#<_pn_clear>=4.000

(How close to the top face's edge the first Z touch may land, mm. This)
(sets the park tolerance: the ball has to come down on the flat, so you)
(have to park within pin radius minus this -- 3 mm on an 8 mm pin.)
#<_pn_edge>=1.000

(How far below the parked Z the top face may be.)
#<_pn_zdrop>=6.000

(Hand rotation prompted between the passes, degrees. Reporting only.)
#<_pn_turn>=180

(=================== LIMITS ===================)
(Credible range for the yaw, mm. It is a pre-travel, so it cannot be)
(meaningfully negative: a result below the floor says the pin diameter)
(entered is too small, or a touch missed. Above the ceiling says the same)
(the other way, or that the stylus is loose.)
#<_pn_minyaw>=-0.020
#<_pn_maxyaw>=0.400

(How far the X and Y yaw may differ before it is worth saying so, mm.)
(This is a warning, not a stop -- a real split is information, not a)
(fault, and ProbeYawCal maps it properly.)
#<_pn_maxyawd>=0.030

(How far the two passes' spans may disagree, mm. They measure the same)
(diameter twice, so this is pure repeatability.)
#<_pn_maxspan>=0.050

(How far the final top-Z touch may differ from the rough one, mm. Catches)
(a domed or chamfered top, or swarf under the first touch.)
#<_pn_maxztop>=0.050

(1 = alarm and abort without writing anything, 0 = report and carry on.)
#<_pn_stop>=1

(=================== SHARED PROBE INPUTS ===================)
(Defaulted only if the caller has not already set them, so running this)
(after ProbeInit leaves its values alone. The fallbacks below are the same)
(numbers ProbeInit uses, which matters most for the slow feed: pre-travel)
(scales with probing speed, so a yaw calibrated at one feed is wrong at)
(another. Measure at the feed production measures at.)
o10 if [EXISTS[#<_probe_feed_fast>] EQ 0]
#<_probe_feed_fast>=300.000
o10 endif
o11 if [EXISTS[#<_probe_feed_slow>] EQ 0]
#<_probe_feed_slow>=50.000
o11 endif
o12 if [EXISTS[#<_probe_feed_link>] EQ 0]
#<_probe_feed_link>=1000.000
o12 endif
o13 if [EXISTS[#<_probe_backoff>] EQ 0]
#<_probe_backoff>=2.000
o13 endif
o14 if [EXISTS[#<_probe_overtravel>] EQ 0]
#<_probe_overtravel>=3.000
o14 endif

(=================== DERIVED =================)
#<_pn_pr>=[#<_pn_dia> / 2]
#<_pn_br>=[#<_pn_ball> / 2]

(Where the ball centre stands when a flank triggers, nominally.)
#<_pn_rho>=[#<_pn_pr> + #<_pn_br>]

(How far off centre you are allowed to park, from the edge margin above.)
#<_pn_maxoff>=[#<_pn_pr> - #<_pn_edge>]

(Offset from the parked position to start each flank touch from.)
#<_pn_app>=[#<_pn_rho> + #<_pn_clear>]

(Incremental reach for the fast flank probe. Both passes run from lines)
(through the PARKED point, so that the 180 degree cancellation is exact,)
(which means a touch may start up to the park error further out than)
(nominal and the reach has to cover it. The cost is that a probe which)
(fails to trigger overdrives by that much before the move ends.)
#<_pn_reach>=[#<_pn_clear> + #<_pn_maxoff> + #<_probe_overtravel>]
#<_pn_fine>=[#<_probe_backoff> * 2]

(Standoff must beat the park tolerance, or the near-side touch starts)
(inside the pin. Caught here, before anything moves.)
o20 if [#<_pn_clear> LE #<_pn_maxoff>]
(PRINT, STOPPED: _pn_clear %.3f#<_pn_clear>  must exceed the park )
(PRINT, tolerance %.3f#<_pn_maxoff>  mm. Raise it, or raise _pn_edge. )
$Alarm/Send=3
o20 endif

(Reach for the first top-Z probe, measured down from the parked Z.)
#<_pn_zreach>=[#<_pn_zdrop> + #<_probe_overtravel>]

(Where you parked. Everything is referred back to this.)
#<_pn_px>=#<_abs_x>
#<_pn_py>=#<_abs_y>
#<_pn_pz>=#<_abs_z>

(The whole method assumes the pin stands square to Z, so B has to be at)
(machine zero. It also settles the TCP question: RPCP contributes nothing)
(at B0, so it makes no difference whether M128 is in force. On a machine)
(with no B axis this reads 0 and waves through.)
#<_pn_maxb>=0.050
o30 if [ABS[#<_abs_b>] GT #<_pn_maxb>]
(PRINT, STOPPED: B is at %.4f#<_abs_b>  deg, not machine zero. )
(PRINT, Rotate to G53 B0 before probing the pin. )
$Alarm/Send=3
o30 endif

(=================== TOP FACE, ROUGH =================)
(This one only has to be good enough to set the flank height and to be)
(cross-checked later; the touch that sets Z comes at the end, on centre.)
G90
G53 G38.2 Z[#<_pn_pz> - #<_pn_zreach>] F#<_probe_feed_fast>
G91
G0 Z#<_probe_backoff>
G38.2 Z[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_tz0>=#5063
G91
G0 Z#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

(Machine Z the flank touches run at. The trigger above put the ball's)
(BOTTOM on the top face, so its centre was one ball radius higher: drop)
(radius plus depth to get the centre that far under the face.)
#<_pn_fz>=[#<_pn_tz0> - #<_pn_br> - #<_pn_depth>]

(A G38.3 descent that stops short leaves the ball above the face, and the)
(flank probe below then runs its full reach and errors out, which aborts)
(the job. A descent that stops low is still on the flank and still valid.)
(So no height check is needed here -- the probe errors cover both.)

(=================== PASS A: FLANKS AS PARKED =================)
G53 G0 X[#<_pn_px> - #<_pn_app>] Y#<_pn_py>
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 X#<_pn_reach> F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X#<_pn_fine> F#<_probe_feed_slow>
G90
#<_pn_axm>=#5061
G91
G0 X[0 - #<_probe_backoff>]
G90
G53 G0 Z#<_pn_safez>

G53 G0 X[#<_pn_px> + #<_pn_app>] Y#<_pn_py>
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 X[0 - #<_pn_reach>] F#<_probe_feed_fast>
G0 X#<_probe_backoff>
G38.2 X[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_axp>=#5061
G91
G0 X#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

G53 G0 X#<_pn_px> Y[#<_pn_py> - #<_pn_app>]
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 Y#<_pn_reach> F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y#<_pn_fine> F#<_probe_feed_slow>
G90
#<_pn_aym>=#5062
G91
G0 Y[0 - #<_probe_backoff>]
G90
G53 G0 Z#<_pn_safez>

G53 G0 X#<_pn_px> Y[#<_pn_py> + #<_pn_app>]
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 Y[0 - #<_pn_reach>] F#<_probe_feed_fast>
G0 Y#<_probe_backoff>
G38.2 Y[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_ayp>=#5062
G91
G0 Y#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

#<_pn_amx>=[[#<_pn_axm> + #<_pn_axp>] / 2]
#<_pn_amy>=[[#<_pn_aym> + #<_pn_ayp>] / 2]
#<_pn_asx>=[#<_pn_axp> - #<_pn_axm>]
#<_pn_asy>=[#<_pn_ayp> - #<_pn_aym>]
(PRINT, pass A  centre X %.4f#<_pn_amx>  Y %.4f#<_pn_amy>  )
(PRINT,         spans  X %.4f#<_pn_asx>  Y %.4f#<_pn_asy>  )

(Check the park HERE, before asking for the rotation: one pass already)
(locates the centre to within the runout, which is nothing against a)
(millimetre limit, so there is no reason to make the operator turn the)
(spindle before telling them the park was no good.)
#<_pn_aox>=[#<_pn_amx> - #<_pn_px>]
#<_pn_aoy>=[#<_pn_amy> - #<_pn_py>]
#<_pn_aoff>=SQRT[[#<_pn_aox> * #<_pn_aox>] + [#<_pn_aoy> * #<_pn_aoy>]]
o50 if [#<_pn_aoff> GT #<_pn_maxoff>]
(PRINT, STOPPED: centre is %.3f#<_pn_aoff>  mm from where you parked, )
(PRINT, limit %.3f#<_pn_maxoff> . Park closer, or probe the right pin. )
$Alarm/Send=3
o50 endif

(=================== TURN THE SPINDLE =================)
(MSG: Turn the spindle 180 deg by hand, then press CYCLE START)
M0

(=================== PASS B: SPINDLE TURNED =================)
G53 G0 X[#<_pn_px> - #<_pn_app>] Y#<_pn_py>
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 X#<_pn_reach> F#<_probe_feed_fast>
G0 X[0 - #<_probe_backoff>]
G38.2 X#<_pn_fine> F#<_probe_feed_slow>
G90
#<_pn_bxm>=#5061
G91
G0 X[0 - #<_probe_backoff>]
G90
G53 G0 Z#<_pn_safez>

G53 G0 X[#<_pn_px> + #<_pn_app>] Y#<_pn_py>
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 X[0 - #<_pn_reach>] F#<_probe_feed_fast>
G0 X#<_probe_backoff>
G38.2 X[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_bxp>=#5061
G91
G0 X#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

G53 G0 X#<_pn_px> Y[#<_pn_py> - #<_pn_app>]
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 Y#<_pn_reach> F#<_probe_feed_fast>
G0 Y[0 - #<_probe_backoff>]
G38.2 Y#<_pn_fine> F#<_probe_feed_slow>
G90
#<_pn_bym>=#5062
G91
G0 Y[0 - #<_probe_backoff>]
G90
G53 G0 Z#<_pn_safez>

G53 G0 X#<_pn_px> Y[#<_pn_py> + #<_pn_app>]
G53 G38.3 Z#<_pn_fz> F#<_probe_feed_link>
G91
G38.2 Y[0 - #<_pn_reach>] F#<_probe_feed_fast>
G0 Y#<_probe_backoff>
G38.2 Y[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_byp>=#5062
G91
G0 Y#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

#<_pn_bmx>=[[#<_pn_bxm> + #<_pn_bxp>] / 2]
#<_pn_bmy>=[[#<_pn_bym> + #<_pn_byp>] / 2]
#<_pn_bsx>=[#<_pn_bxp> - #<_pn_bxm>]
#<_pn_bsy>=[#<_pn_byp> - #<_pn_bym>]
(PRINT, pass B  centre X %.4f#<_pn_bmx>  Y %.4f#<_pn_bmy>  )
(PRINT,         spans  X %.4f#<_pn_bsx>  Y %.4f#<_pn_bsy>  )

(=================== CENTRE AND RUNOUT =================)
(Pass A read the centre as pin minus e, pass B as pin plus e.)
#<_pn_ctrx>=[[#<_pn_amx> + #<_pn_bmx>] / 2]
#<_pn_ctry>=[[#<_pn_amy> + #<_pn_bmy>] / 2]
#<_pn_ex>=[[#<_pn_bmx> - #<_pn_amx>] / 2]
#<_pn_ey>=[[#<_pn_bmy> - #<_pn_amy>] / 2]
#<_pn_e>=SQRT[[#<_pn_ex> * #<_pn_ex>] + [#<_pn_ey> * #<_pn_ey>]]

(Runout as a dial indicator would read it: the ball swings through twice)
(its offset in one turn.)
#<_pn_tir>=[2 * #<_pn_e>]

(Direction the ball leans at the orientation pass A was taken in. ATAN)
(is a two-argument atan2 here and answers in degrees.)
#<_pn_edir>=ATAN[#<_pn_ey>]/[#<_pn_ex>]

(=================== EFFECTIVE BALL RADIUS =================)
(Each pass's X touches ran along a line that misses the pin axis by the)
(ball centre's Y offset, so the span is a chord. Half-span and that miss)
(are the two legs of a right angle whose hypotenuse is the trigger)
(radius, so the chord comes back to the diameter exactly. The ball centre)
(sits at the spindle plus e in pass A and minus e in pass B.)
#<_pn_ady>=[#<_pn_py> + #<_pn_ey> - #<_pn_ctry>]
#<_pn_bdy>=[#<_pn_py> - #<_pn_ey> - #<_pn_ctry>]
#<_pn_adx>=[#<_pn_px> + #<_pn_ex> - #<_pn_ctrx>]
#<_pn_bdx>=[#<_pn_px> - #<_pn_ex> - #<_pn_ctrx>]

(Pythagoras alone is not quite right once the probe has pre-travel: the)
(ball stops short along the PROBE direction, not along the radius, so the)
(half-span that goes in is already shortened in the wrong direction and)
(the result comes out low by about p * d^2 / 2 rho^2 -- a couple of)
(microns at a 1.5 mm park error, which is the same size as the thing being)
(measured. So each one is done twice: Pythagoras for a first pre-travel)
(estimate, then again with the half-span put back to where contact)
(actually happened. The second pass leaves well under a tenth of a micron)
(and needs no third.)
()
(On centre d is zero and all of this collapses to the half-span, which is)
(what ProbeYawCal relies on by always probing through the origin.)

(--- pass A, X touches, chorded by the Y standoff ---)
#<_pn_h>=[#<_pn_asx> / 2]
#<_pn_d>=#<_pn_ady>
#<_pn_r0>=SQRT[[#<_pn_h> * #<_pn_h>] + [#<_pn_d> * #<_pn_d>]]
#<_pn_p0>=[#<_pn_rho> - #<_pn_r0>]
#<_pn_c0>=[#<_pn_h> + #<_pn_p0>]
#<_pn_rax>=[SQRT[[#<_pn_c0> * #<_pn_c0>] + [#<_pn_d> * #<_pn_d>]] - #<_pn_p0>]

(--- pass B, X touches ---)
#<_pn_h>=[#<_pn_bsx> / 2]
#<_pn_d>=#<_pn_bdy>
#<_pn_r0>=SQRT[[#<_pn_h> * #<_pn_h>] + [#<_pn_d> * #<_pn_d>]]
#<_pn_p0>=[#<_pn_rho> - #<_pn_r0>]
#<_pn_c0>=[#<_pn_h> + #<_pn_p0>]
#<_pn_rbx>=[SQRT[[#<_pn_c0> * #<_pn_c0>] + [#<_pn_d> * #<_pn_d>]] - #<_pn_p0>]

(--- pass A, Y touches, chorded by the X standoff ---)
#<_pn_h>=[#<_pn_asy> / 2]
#<_pn_d>=#<_pn_adx>
#<_pn_r0>=SQRT[[#<_pn_h> * #<_pn_h>] + [#<_pn_d> * #<_pn_d>]]
#<_pn_p0>=[#<_pn_rho> - #<_pn_r0>]
#<_pn_c0>=[#<_pn_h> + #<_pn_p0>]
#<_pn_ray>=[SQRT[[#<_pn_c0> * #<_pn_c0>] + [#<_pn_d> * #<_pn_d>]] - #<_pn_p0>]

(--- pass B, Y touches ---)
#<_pn_h>=[#<_pn_bsy> / 2]
#<_pn_d>=#<_pn_bdx>
#<_pn_r0>=SQRT[[#<_pn_h> * #<_pn_h>] + [#<_pn_d> * #<_pn_d>]]
#<_pn_p0>=[#<_pn_rho> - #<_pn_r0>]
#<_pn_c0>=[#<_pn_h> + #<_pn_p0>]
#<_pn_rby>=[SQRT[[#<_pn_c0> * #<_pn_c0>] + [#<_pn_d> * #<_pn_d>]] - #<_pn_p0>]

#<_pn_rmx>=[[#<_pn_rax> + #<_pn_rbx>] / 2]
#<_pn_rmy>=[[#<_pn_ray> + #<_pn_rby>] / 2]
#<_pn_rm>=[[#<_pn_rmx> + #<_pn_rmy>] / 2]
#<_pn_reff>=[#<_pn_rm> - #<_pn_pr>]

(Corrected spans, for the report and the log.)
#<_pn_dx>=[2 * #<_pn_rmx>]
#<_pn_dy>=[2 * #<_pn_rmy>]

(=================== PROBE YAW =================)
(Same definition ProbeYawCal uses: yaw = [pin radius + ruby radius] minus)
(half the trigger separation, which is the pre-travel. Here the trigger)
(radius is already in hand, so it is just the ruby radius less the)
(effective one.)
()
(_pn_ball MUST be the nominal diameter the POST writes into)
(_probe_tool_radius, not a miked one, because ProbeInit consumes the yaw)
(as _probe_eff_radius = _probe_tool_radius - _probe_yaw. Enter a miked)
(ruby here and the yaw comes out short by the difference, and production)
(then overshoots into the material by exactly that much. The PIN is the)
(one that has to be miked: it is the only true length reference in the)
(measurement, and its error goes into the yaw one for one.)
#<_pn_yaw>=[#<_pn_br> - #<_pn_reff>]
#<_pn_yawx>=[#<_pn_br> - [#<_pn_rmx> - #<_pn_pr>]]
#<_pn_yawy>=[#<_pn_br> - [#<_pn_rmy> - #<_pn_pr>]]

(X against Y is a two-direction slice of the lobing ProbeYawCal maps over)
(50 pairs. A big split means no single yaw serves both axes, whatever)
(number goes in.)
#<_pn_yawd>=[#<_pn_yawx> - #<_pn_yawy>]

(What the session was using before this, if anything, so the report can)
(show the change rather than just the new number.)
#<_pn_yawold>=0
#<_pn_hadyaw>=0
#<_pn_yawdelta>=0
o60 if [EXISTS[#<_probe_yaw>]]
#<_pn_yawold>=#<_probe_yaw>
#<_pn_yawdelta>=[#<_pn_yaw> - #<_pn_yawold>]
#<_pn_hadyaw>=1
o60 endif

(=================== GUARDS =================)
#<_pn_offx>=[#<_pn_ctrx> - #<_pn_px>]
#<_pn_offy>=[#<_pn_ctry> - #<_pn_py>]
#<_pn_bad>=0

o110 if [[#<_pn_yaw> LT #<_pn_minyaw>] OR [#<_pn_yaw> GT #<_pn_maxyaw>]]
(PRINT, STOPPED: yaw reads %.4f#<_pn_yaw>  mm, outside the credible )
(PRINT, range %.4f#<_pn_minyaw>  to %.4f#<_pn_maxyaw> . Check the pin )
(PRINT, diameter entered, and that all four flanks were touched. )
#<_pn_bad>=1
o110 endif

o115 if [ABS[#<_pn_yawd>] GT #<_pn_maxyawd>]
(PRINT, NOTE: yaw differs between axes by %.4f#<_pn_yawd>  mm. One )
(PRINT, number cannot serve both -- run ProbeYawCal to map the lobing. )
o115 endif

#<_pn_sdx>=[#<_pn_rax> - #<_pn_rbx>]
#<_pn_sdy>=[#<_pn_ray> - #<_pn_rby>]
o120 if [[ABS[#<_pn_sdx>] GT #<_pn_maxspan>] OR [ABS[#<_pn_sdy>] GT #<_pn_maxspan>]]
(PRINT, STOPPED: the two passes disagree on the diameter by )
(PRINT, X %.4f#<_pn_sdx>  Y %.4f#<_pn_sdy>  mm, limit %.4f#<_pn_maxspan> . )
(PRINT, Either the pin moved, or a touch landed on swarf. )
#<_pn_bad>=1
o120 endif

o130 if [#<_pn_bad> GT 0]
o135 if [#<_pn_stop> GT 0]
(An alarm unwinds the WHOLE job stack: the protocol loop calls Job::abort)
(on seeing the alarm state, which pops every nested job including the)
(program that called this one. M30 would do the opposite -- end only this)
(file, hand control back to carry on with a bad origin, and reset the)
(coordinate system to G54 on the way out.)
$Alarm/Send=3
o135 endif
o130 endif

(=================== TOP FACE, ON CENTRE =================)
(Now that the centre is known, take the reading that actually sets Z)
(there, rather than wherever the operator parked. The rough touch backed)
(off by _probe_backoff, so coming back to that height and probing twice)
(it reproduces the same slow approach and the same pre-travel.)
G53 G0 X#<_pn_ctrx> Y#<_pn_ctry>
G53 G38.3 Z[#<_pn_tz0> + #<_probe_backoff>] F#<_probe_feed_link>
G91
G38.2 Z[0 - #<_pn_fine>] F#<_probe_feed_slow>
G90
#<_pn_tz>=#5063
G91
G0 Z#<_probe_backoff>
G90
G53 G0 Z#<_pn_safez>

#<_pn_zd>=[#<_pn_tz> - #<_pn_tz0>]
o140 if [ABS[#<_pn_zd>] GT #<_pn_maxztop>]
(PRINT, WARNING: top Z on centre differs from the first touch by )
(PRINT, %.4f#<_pn_zd>  mm. A domed or chamfered top, or swarf. )
o140 endif

(=================== APPLY =================)
(G10 L20 sets the offset from where the machine is standing now, so the)
(value wanted is nominal plus [here minus found]. The tool length offset)
(cancels out of that difference, and G53 above never applied it anyway.)
#<_pn_gx>=[#<_abs_x> - #<_pn_ctrx>]
#<_pn_gy>=[#<_abs_y> - #<_pn_ctry>]
#<_pn_gz>=[#<_abs_z> - #<_pn_tz>]
G10 L20 P#<_pn_wcs> X#<_pn_gx> Y#<_pn_gy> Z#<_pn_gz>

(#5220 reports the active offset as its P number -- CoordIndex::G54 is 0,)
(so 1 is G54 through to 6 for G59. With _pn_wcs at 0 the write went to)
(whichever offset was selected, and this is the one it landed in.)
#<_pn_rpt>=#<_pn_wcs>
o150 if [#<_pn_wcs> LE 0]
#<_pn_rpt>=#5220
o150 endif

(Put the measured yaw into use for the rest of this session, and rebuild)
(the effective radius from it the way ProbeInit does, so anything probing)
(after this picks it up without a reload.)
()
(Named parameters live in RAM only -- global_named_params is never written)
(to NVS -- so this survives a soft reset but NOT a power cycle. The line)
(printed below is the one to paste into StartUp.nc to make it stick.)
#<_probe_yaw>=#<_pn_yaw>
o160 if [EXISTS[#<_probe_tool_radius>]]
#<_probe_eff_radius>=[#<_probe_tool_radius> - #<_probe_yaw>]
o160 endif

(=================== REPORT =================)
(PRINT, ======================================== )
(PRINT, PROBE YAW = %.4f#<_pn_yaw>  mm   <-- the X and Y mean )
(PRINT,      X %.4f#<_pn_yawx>   Y %.4f#<_pn_yawy>   split %.4f#<_pn_yawd>  )
o170 if [#<_pn_hadyaw> GT 0]
(PRINT,      was %.4f#<_pn_yawold> , change %.4f#<_pn_yawdelta>  mm )
o170 endif
o175 if [ABS[#<_pn_yawd>] GT #<_pn_maxyawd>]
(PRINT,      THE SPLIT IS THE RESULT HERE, not the mean. A single )
(PRINT,      number is wrong by half of it whichever way you probe. )
(PRINT,      Run ProbeYawCal to map it before trusting one value. )
o175 endif
(To keep this past a power cycle it has to go in StartUp.nc. Do not print)
(the parameter name here: a literal hash-name inside a PRINT is read as a)
(VALUE, and with the default format at that, which is what produced the)
(run of digits the first time round.)
(PRINT, Set _probe_yaw in StartUp.nc to  %.4f#<_pn_yaw>  )
(PRINT, ---------------------------------------- )
(PRINT, PIN  centre X %.4f#<_pn_ctrx>  Y %.4f#<_pn_ctry>  top Z %.4f#<_pn_tz>  )
(PRINT,      parked %.3f#<_pn_offx>  %.3f#<_pn_offy>  mm off that centre )
(PRINT, DIA  measured X %.4f#<_pn_dx>  Y %.4f#<_pn_dy>  entered %.4f#<_pn_dia>  )
(PRINT,      effective ball radius %.4f#<_pn_reff>  nominal %.4f#<_pn_br>  )
(PRINT, ECC  tip offset %.4f#<_pn_e>  mm at %.1f#<_pn_edir>  deg )
(PRINT,      components X %.4f#<_pn_ex>  Y %.4f#<_pn_ey>  )
(PRINT,      TIR %.4f#<_pn_tir>  mm -- what a dial would read in one turn )
(PRINT, ORIGIN written to P%.0f#<_pn_rpt> : pin top centre is now X0 Y0 Z0 )
(PRINT,      this centre has the tip offset REMOVED, so it is the true one )
(PRINT, ======================================== )

(=================== LOG =================)
(One row per pass, as ProbeRunoutX does: nom_x carries the orientation,)
(nomsize the expected diameter and size the measured one. The runout)
(column is filled on the turned row, where the pair is complete.)
#<_probe_nom_x>=0
#<_probe_nom_y>=#<_pn_rpt>
#<_probe_nom_z>=#<_pn_yaw>
#<_probe_log_x>=#<_pn_amx>
#<_probe_log_y>=#<_pn_amy>
#<_probe_log_z>=#<_pn_tz0>
#<_probe_log_nomsize>=#<_pn_dia>
#<_probe_log_size>=#<_pn_dx>
#<_probe_runout>=0
$Probe/Log
#<_probe_nom_x>=#<_pn_turn>
#<_probe_log_x>=#<_pn_bmx>
#<_probe_log_y>=#<_pn_bmy>
#<_probe_log_z>=#<_pn_tz>
#<_probe_log_size>=#<_pn_dy>
#<_probe_runout>=#<_pn_e>
$Probe/Log

(MSG: Pin done - yaw set for this session, origin written, see console)
