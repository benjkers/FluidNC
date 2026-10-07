(ProbeBLevel.nc)
(Levels a part on the B axis from two probed points and writes the result)
(into that work offset's B component. Nothing moves: work B0 simply)
(becomes "this part is level".)
()
(The two points do NOT have to be on the same face or at the same height.)
(Each one carries its NOMINAL Z -- the height that face is meant to be at)
(in the model -- and the designed step between them is taken out of the)
(measurement, leaving only the part's tilt.)
()
(RUN FROM SD:   $SD/Run=/Probing/ProbeBLevel.nc)

(=================== TWO WAYS TO RUN IT ===================)
(  _bl_mode 0  the macro probes both points itself, from the machine)
(              coordinates taught in the MODE 0 block below. Teach once)
(              per fixture.)
(  _bl_mode 1  something else has already probed them and passed the)
(              results in. The post does this when "B level: use this)
(              point" is ticked on two Probe Geometry surface cycles.)
()
(  Anything the caller has already set is LEFT ALONE -- every shared)
(  input below is defaulted only if it does not already exist, and the)
(  mode 0 teach values are assigned inside the mode 0 block, so they)
(  cannot overwrite what the post passed in.)

(=================== THE MATHS ===================)
(  A face that is flat in the part frame sits at machine height)
(      Z = za + [w + [X - xa] * SIN[t]] / COS[t])
(  where w is its nominal height, t the tilt and xa/za the pivot. Taking)
(  the difference between the two touches kills xa, za and the part)
(  origin -- which matters, because nothing has been zeroed yet -- and)
(  leaves)
(      dZ * COS[t] - dX * SIN[t] = dNominalZ)
(  which solves in closed form as)
(      t = ATAN[dZ]/[dX] - ASIN[dNominalZ / hypot[dX,dZ]])
()
(  With both points on one face dNominalZ is 0 and that collapses to the)
(  slope between the touches. Only the two machine X positions and the)
(  two machine Z readings appear in it, so the path taken to reach them)
(  does not matter.)

(=================== WHY IT NEEDS NO CALIBRATION ===================)
(  The answer is a DIFFERENCE between two touches taken with the same)
(  ball on faces at the same tilt, so every constant drops out: tool)
(  length, ball radius, the ball riding up a tilted plane, Z pre-travel,)
(  X runout. None of them have to be known.)

(=================== WHAT GUARDS IT ===================)
(  Nothing in two points cross-checks the nominal step: feed in the)
(  wrong step and you get a wrong tilt, quietly. _bl_maxtilt is the)
(  only backstop, so set it just above the worst tilt you would believe)
(  from this fixture -- a degree or two -- not to some round number. A)
(  12 mm step entered as 0 over a 100 mm span reads as 7 degrees, which)
(  a limit of 10 would wave through.)

(=================== ORDER MATTERS ===================)
(  Level FIRST, then probe XYZ into the same offset. The B component)
(  says where the part's zero ORIENTATION is and the XYZ component says)
(  where its origin is AT that orientation, so setting B afterwards)
(  would leave XYZ describing the old clocking. With TCP ON a G10)
(  rotates XYZ to match; with TCP off -- as here -- it does not.)

(=================== CHECKING IT ===================)
(  Rotate to work B0 and run it again. It should read 0.000.)

(================= PRELUDE =================)
$SD/Run=/Probing/ProbeInit.nc
G21
G90
M5
M129 (TCP off - this measures the machine frame)

(================= SHARED INPUTS =================)
(Defaulted only when the caller has not already set them.)

(0 = probe here, 1 = results already supplied.)
o10 if [EXISTS[#<_bl_mode>]]
o10 else
#<_bl_mode>=0
o10 endif

(Which offset to write: 1 = G54 ... 6 = G59, 0 = the active one.)
o11 if [EXISTS[#<_bl_wcs>]]
o11 else
#<_bl_wcs>=0
o11 endif

(DRO Z that clears the part. Used for the traverses in mode 0 and for)
(the optional rotate to level.)
o12 if [EXISTS[#<_bl_safez>]]
o12 else
#<_bl_safez>=-5.000
o12 endif

(Minimum X spacing. The angle resolves as probe scatter over this, so)
(spread the points as far apart in X as the part allows.)
o13 if [EXISTS[#<_bl_minspan>]]
o13 else
#<_bl_minspan>=20.000
o13 endif

(Refuse anything bigger than this, in degrees. See WHAT GUARDS IT.)
o14 if [EXISTS[#<_bl_maxtilt>]]
o14 else
#<_bl_maxtilt>=2.000
o14 endif

(How far the measured X spacing may differ from the nominal one before)
(stopping. Only active when the nominal X values are given.)
o15 if [EXISTS[#<_bl_maxresid>]]
o15 else
#<_bl_maxresid>=0.500
o15 endif

(1 = rotate to work B0 at the end, so the part finishes level.)
o16 if [EXISTS[#<_bl_goto0>]]
o16 else
#<_bl_goto0>=0
o16 endif

(================= MODE 1: CHECK WHAT CAME IN =================)
(The two measurements cannot be defaulted, so say which one is missing)
(rather than letting the parser complain about an undefined parameter.)
(The nominals can be: zero on both means one continuous face, and zero)
(nominal X means skip the spacing check.)
o20 if [#<_bl_mode> GT 0]

o21 if [EXISTS[#<_bl_x1>] AND EXISTS[#<_bl_z1>]]
o21 else
(PRINT, STOPPED: mode 1, but point 1 was not passed in. )
(PRINT, Needs _bl_x1 and _bl_z1 set before this macro runs. )
$Alarm/Send=3
M30
o21 endif

o22 if [EXISTS[#<_bl_x2>] AND EXISTS[#<_bl_z2>]]
o22 else
(PRINT, STOPPED: mode 1, but point 2 was not passed in. )
(PRINT, Needs _bl_x2 and _bl_z2 set before this macro runs. )
$Alarm/Send=3
M30
o22 endif

o23 if [EXISTS[#<_bl_nz1>]]
o23 else
#<_bl_nz1>=0
o23 endif
o24 if [EXISTS[#<_bl_nz2>]]
o24 else
#<_bl_nz2>=0
o24 endif
o25 if [EXISTS[#<_bl_nx1>]]
o25 else
#<_bl_nx1>=0
o25 endif
o26 if [EXISTS[#<_bl_nx2>]]
o26 else
#<_bl_nx2>=0
o26 endif
o27 if [EXISTS[#<_bl_y1>]]
o27 else
#<_bl_y1>=0
o27 endif
o28 if [EXISTS[#<_bl_y2>]]
o28 else
#<_bl_y2>=0
o28 endif

o20 endif

(================= LOG TAGS =================)
#<_probe_prog_id>=8040
#<_probe_log_kind>=0
#<_probe_tol_size>=0
#<_probe_tol_pos>=0
#<_probe_dev_size>=0
#<_probe_dev_pos>=0
#<_probe_runout>=0
#<_probe_log_nomsize>=0

(================= MODE 0: TEACH AND PROBE =================)
o100 if [#<_bl_mode> EQ 0]

(--- point 1: machine X and Y of the touch ---)
#<_bl_x1>=-180.000
#<_bl_y1>=-150.000
(DRO Z to drop to before the touch. Reached with a PROTECTED move, so a)
(face higher than taught stops the program instead of crashing.)
#<_bl_zs1>=-80.000
(NOMINAL height of this face in the work offset. Leave both nominals at)
(0 when the two points are on the same face.)
#<_bl_nz1>=0.000
(NOMINAL X of this point in the work offset, for the sanity check only.)
(Leave both at 0 to skip it.)
#<_bl_nx1>=0.000

(--- point 2 ---)
#<_bl_x2>=-280.000
#<_bl_y2>=-150.000
#<_bl_zs2>=-80.000
#<_bl_nz2>=0.000
#<_bl_nx2>=0.000

(How far below the taught start Z the face may be, at either point.)
#<_bl_drop>=6.000
#<_bl_reach>=[#<_bl_drop> + #<_probe_overtravel>]

G53 G0 Z#<_bl_safez>

G53 G0 X#<_bl_x1> Y#<_bl_y1>
G53 G38.3 Z#<_bl_zs1> F#<_probe_feed_link>
G53 G38.2 Z[#<_bl_zs1> - #<_bl_reach>] F#<_probe_feed_fast>
G91
G0 Z#<_probe_backoff>
G38.2 Z[0 - #<_probe_backoff> * 2] F#<_probe_feed_slow>
G90
#<_bl_z1>=#5063
G91
G0 Z#<_probe_backoff>
G90
G53 G0 Z#<_bl_safez>

G53 G0 X#<_bl_x2> Y#<_bl_y2>
G53 G38.3 Z#<_bl_zs2> F#<_probe_feed_link>
G53 G38.2 Z[#<_bl_zs2> - #<_bl_reach>] F#<_probe_feed_fast>
G91
G0 Z#<_probe_backoff>
G38.2 Z[0 - #<_probe_backoff> * 2] F#<_probe_feed_slow>
G90
#<_bl_z2>=#5063
G91
G0 Z#<_probe_backoff>
G90
G53 G0 Z#<_bl_safez>
o100 endif

(================= DELTAS =================)
#<_bl_dx>=[#<_bl_x2> - #<_bl_x1>]
#<_bl_dz>=[#<_bl_z2> - #<_bl_z1>]
#<_bl_dn>=[#<_bl_nz2> - #<_bl_nz1>]
#<_bl_dnx>=[#<_bl_nx2> - #<_bl_nx1>]

(Work left to right, so the answer does not depend on which point came)
(first. The nominal step has to flip with the measurement, or the solver)
(lands on the part-is-upside-down branch instead.)
o200 if [#<_bl_dx> LT 0]
#<_bl_dx>=[0 - #<_bl_dx>]
#<_bl_dz>=[0 - #<_bl_dz>]
#<_bl_dn>=[0 - #<_bl_dn>]
#<_bl_dnx>=[0 - #<_bl_dnx>]
o200 endif

o205 if [#<_bl_dx> LT #<_bl_minspan>]
(PRINT, STOPPED: the points are %.2f#<_bl_dx> mm apart in X, minimum )
(PRINT, is %.2f#<_bl_minspan>. The angle resolves over that span. )
$Alarm/Send=3
M30
o205 endif

(================= ANGLE =================)
#<_bl_r>=SQRT[[#<_bl_dx> * #<_bl_dx>] + [#<_bl_dz> * #<_bl_dz>]]

(ASIN needs its argument inside +-1. A nominal step as big as the whole)
(measured span means the nominals cannot describe these two touches.)
o210 if [ABS[#<_bl_dn>] GT [#<_bl_r> - 0.0005]]
(PRINT, STOPPED: nominal step %.3f#<_bl_dn> mm is as big as the )
(PRINT, measured span %.3f#<_bl_r> mm. Check the nominal heights. )
$Alarm/Send=3
M30
o210 endif

#<_bl_beta>=ATAN[#<_bl_dz>]/[#<_bl_dx>]
#<_bl_corr>=ASIN[#<_bl_dn> / #<_bl_r>]
#<_bl_tilt>=[#<_bl_beta> - #<_bl_corr>]

o215 if [#<_bl_tilt> GT 180]
#<_bl_tilt>=[#<_bl_tilt> - 360]
o215 endif
o220 if [#<_bl_tilt> LT -180]
#<_bl_tilt>=[#<_bl_tilt> + 360]
o220 endif

#<_bl_per100>=[100 * TAN[#<_bl_tilt>]]
#<_bl_newoff>=[#<_abs_b> - #<_bl_tilt>]

o225 if [ABS[#<_bl_tilt>] GT #<_bl_maxtilt>]
(PRINT, STOPPED: part reads %.3f#<_bl_tilt> deg, over the )
(PRINT, %.3f#<_bl_maxtilt> deg limit. Check both points are on the )
(PRINT, faces you meant, the nominal heights are right, and the part )
(PRINT, is seated. )
$Alarm/Send=3
M30
o225 endif

(================= SANITY CHECK =================)
(Both touches were commanded at a work X, and with TCP off that maps)
(straight onto machine X, so the measured spacing must match the)
(nominal one. A mismatch means the results did not come from the points)
(the nominals describe -- a mis-wired pass-through, or a probe that)
(moved in X between the touch and the capture.)
o230 if [ABS[#<_bl_dnx>] GT 1]
#<_bl_resid>=[#<_bl_dx> - ABS[#<_bl_dnx>]]
o235 if [ABS[#<_bl_resid>] GT #<_bl_maxresid>]
(PRINT, STOPPED: measured X spacing %.3f#<_bl_dx> but nominal is )
(PRINT, %.3f#<_bl_dnx>, out by %.3f#<_bl_resid> mm. )
$Alarm/Send=3
M30
o235 endif
o230 endif

(================= APPLY =================)
(G10 L20 sets the offset from where the machine is standing now:)
(    offset = MPos - value. B has not moved since the touches, so)
(    offset = B_machine - tilt, which is the angle the part is level at.)
G10 L20 P#<_bl_wcs> B#<_bl_tilt>

(PRINT, ======================================== )
(PRINT, B LEVEL  touch 1 X %.3f#<_bl_x1> Z %.4f#<_bl_z1> nom Z %.3f#<_bl_nz1> )
(PRINT,          touch 2 X %.3f#<_bl_x2> Z %.4f#<_bl_z2> nom Z %.3f#<_bl_nz2> )
(PRINT, measured slope %.4f#<_bl_beta> deg, nominal step takes off %.4f#<_bl_corr> )
(PRINT, part tilt %.4f#<_bl_tilt> deg  [%.3f#<_bl_per100> mm per 100] )
(PRINT, B offset written %.4f#<_bl_newoff>  to P%.0f#<_bl_wcs> )
(PRINT, work B0 is now this part level. Probe XYZ next. )
(PRINT, ======================================== )

(================= LOG =================)
#<_probe_nom_x>=#<_bl_tilt>
#<_probe_nom_y>=#<_bl_wcs>
#<_probe_nom_z>=1
#<_probe_log_x>=#<_bl_x1>
#<_probe_log_y>=#<_bl_y1>
#<_probe_log_z>=#<_bl_z1>
#<_probe_log_size>=#<_bl_per100>
$Probe/Log
#<_probe_nom_z>=2
#<_probe_log_x>=#<_bl_x2>
#<_probe_log_y>=#<_bl_y2>
#<_probe_log_z>=#<_bl_z2>
$Probe/Log

(================= OPTIONAL: GO LEVEL =================)
o300 if [#<_bl_goto0> GT 0]
G53 G0 Z#<_bl_safez>
G0 B0
(MSG: rotated to work B0 - the part is now level)
o300 endif

(MSG: B level set - probe XYZ into this offset next)

(=================== DRIVING IT FROM THE POST ===================)
(  Tick "B level: use this point" on two Probe Geometry - Surface)
(  cycles. The post then switches TCP off, captures the machine X, Y and)
(  Z of each touch along with that operation's nominal X and Bottom)
(  Height, and calls this macro after the second one. Ticked cycles pair)
(  up in program order, so four ticks means two levelling passes.)
()
(  By hand in Manual NC pass-through, the same thing looks like:)
()
(    before the first probe:   M129)
(    after the first probe:    #<_bl_x1>=#5061)
(                              #<_bl_y1>=#5062)
(                              #<_bl_z1>=#5063)
(                              #<_bl_nx1>=0)
(                              #<_bl_nz1>=0)
(    after the second probe:   #<_bl_x2>=#5061)
(                              #<_bl_y2>=#5062)
(                              #<_bl_z2>=#5063)
(                              #<_bl_nx2>=100)
(                              #<_bl_nz2>=-12.5)
(                              #<_bl_mode>=1)
(                              #<_bl_wcs>=1)
(                              $SD/Run=/Probing/ProbeBLevel.nc)
()
(  _bl_nz1 and _bl_nz2 are the two faces' nominal heights in the work)
(  offset -- both 0 for one continuous face. #5061, #5062 and #5063 are)
(  the machine X, Y and Z of the last touch, hence the M129 first.)
