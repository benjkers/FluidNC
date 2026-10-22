(_Approach.nc  --  lives in /Motion/ on the SD card)
(NOT a probing macro: the milling path uses it too. /Probing/ is for the)
(cycles and their helpers, so positioning macros live in /Motion/ instead.)
(Make a positioning move FLAT then PLUMB instead of diagonal, at ANY B angle.)
()
(The post cannot do this split on its own. It writes in the WORK frame with)
(TCP on, and the height that matters -- machine Z -- depends on the pivot and)
(the work offset, which the post does not know. getCurrentPosition is no help)
(either: it tracks the TOOLPATH, so after a G53 retract it still reports where)
(the last cut ended. The controller knows where it is, so the split is here.)

(=================== HOW ===================)
(The tool axis in the work frame is a unit vector v, supplied by the post from)
(Fusion's workPlane.forward. Two facts make the rest arithmetic:)
()
(  1. Moving along v changes machine Z and NOTHING else, at every B. The)
(     spindle does not tilt, so the tool axis is always machine +Z, and)
(     forward takes the TLO off before rotating and puts it back after, so)
(     the tool length is a pure translation, identical at every angle.)
()
(  2. For any displacement d, the machine Z it produces is d . v -- the same)
(     identity the post's own initial-positioning comment leans on.)
()
(So L = [current - target] . v is the machine Z headroom above the target, and)
(  target + L*v  is the point directly above the target AT THE CURRENT HEIGHT.)
(Traverse there and the path is flat; drop to the target and it is plumb.)
()
(Everything here is in WORK coordinates. Both points carry the same tool)
(length offset, so it cancels out of the difference and is never needed)
(explicitly. Reaching for machine coordinates is what would drag the TLO in,)
(with a sign that has to match the part - tlo inside forward. Avoids all of it.)

(=================== WHY THE CLAMP IS AT ZERO ===================)
(L is clamped up to 0 and NOT to some minimum lift. The only thing the clamp)
(has to prevent is a NEGATIVE L, where the tool sits below the target along)
(the tool axis: traversing at that height would cross below the target's own)
(clearance height and then climb into it. Coming up to exactly the target's)
(height is sufficient, and any margin on top is unjustified margin.)
()
(It also makes the macro safe to call on EVERY positioning move, because a)
(move that is already a single clean axis move stays a single move:)
()
(  straight up to the target     L negative, no lateral  -> one move, the lift)
(  sideways at equal height      L zero                  -> one move, flat)
(  straight down to the target   no lateral              -> one move, plunge)
(  across and down               a real diagonal         -> flat, then plumb)
()
(A minimum lift breaks all of that. At 5 mm, a bare 2 mm sideways nudge comes)
(out as lift 5, across 2, down 5 -- three moves and a bounced stylus for no)
(reason -- and a straight-up probe lift becomes up 13 then back down 5.)

(=================== INPUTS ===================)
(  _ap_x _ap_y _ap_z        target, WORK coordinates)
(  _ap_vx _ap_vy _ap_vz     tool axis, UNIT vector, WORK frame)
(  _ap_protected            optional; non-zero routes every leg through)
(                           _SafeMove.nc, for a probe in the spindle)

o2720 if [EXISTS[#<_ap_protected>] EQ 0]
#<_ap_protected>=0.000
o2720 endif

(=================== DRAIN BEFORE READING ===================)
(get_system_param reads the position WITHOUT protocol_buffer_synchronize, so)
(#<_x> is the position at PARSE time -- where the machine was when this line)
(was read, not where the queued motion will leave it. mc_dwell synchronises)
(first, so any G4 is the drain. Without this the headroom is computed from a)
(stale position and the traverse is not flat.)
G4 P0.01

(=================== HEADROOM AND LATERAL TRAVEL ===================)
#<_ap_dx>=[#<_x> - #<_ap_x>]
#<_ap_dy>=[#<_y> - #<_ap_y>]
#<_ap_dz>=[#<_z> - #<_ap_z>]
#<_ap_l>=[[#<_ap_dx> * #<_ap_vx>] + [#<_ap_dy> * #<_ap_vy>] + [#<_ap_dz> * #<_ap_vz>]]

(=================== WHY THE THRESHOLD IS 0.010 AND NOT 0.0001 ===================)
(Every leg below is skipped when its length is under 0.010 mm. That number)
(has to clear STEP QUANTISATION, and the first version used 0.0001, which)
(does not -- it let a zero-length G38.3 through and error 33 stopped a job.)
()
(The two sides of the comparison come from different places. #<_x> is the)
(read-back: get_mpos through motors_to_cartesian, so it carries the stepped)
(position, up to half a step from what was commanded. gc_state.position --)
(what isequal_position_vector memcmps a G38 target against, bitwise -- holds)
(the COMMANDED value. So with the machine parked exactly on the target, d)
(reads as half a step rather than zero, the leg fires, and the target it)
(computes collapses back onto the commanded coordinates in float and is)
(rejected as a zero-length probe.)
()
(0.010 mm is above any sane step size and far below anything that matters: a)
(skipped leg leaves the tool 0.010 mm short, inside _SafeMove.nc's own)
(0.050 mm arrival tolerance and well under probe repeatability.)

(Lateral travel is what is left of d once its tool-axis component is taken)
(out: |d|^2 - L^2, which is zero for a pure up or down move. Float error can)
(put that fractionally below zero, so it is clamped before the root.)
#<_ap_d2>=[[#<_ap_dx> * #<_ap_dx>] + [#<_ap_dy> * #<_ap_dy>] + [#<_ap_dz> * #<_ap_dz>]]
#<_ap_s2>=[#<_ap_d2> - [#<_ap_l> * #<_ap_l>]]
#<_ap_s2>=[[#<_ap_s2> + ABS[#<_ap_s2>]] / 2.000]
#<_ap_lat>=[SQRT[#<_ap_s2>]]

(=================== WHY THERE IS NO SIGN GUARD ===================)
(An earlier version alarmed when L was far enough negative, on the theory)
(that an inverted v would show up that way. It was removed after stopping two)
(real jobs and catching nothing, and the reasoning is worth keeping:)
()
(  - A legitimate deep start and an inverted v BOTH show up as a negative L.)
(    Magnitude cannot separate them, so any bound is a guess. The first one)
(    was 50 mm and a routine 58 mm lift out of a probe cleared it.)
()
(  - With no lateral travel the sign cannot hurt anything: a pure lift and a)
(    pure plunge land on the target either way, only the route differs, and)
(    both routes are the same single axis move.)
()
(  - The only fault it could catch is a SYSTEMATIC inversion -- workPlane)
(    .forward pointing into the part. That is a Fusion-wide convention, so it)
(    would break every indexed operation at once and be obvious on the first)
(    job, not something that slips through quietly.)
()
(  - It could not see the fault that IS real: the post builds v from the)
(    COMMANDED B, while the firmware rotates by commanded B minus)
(    rotaryOffset -- the B that ProbeBLevel.nc writes into the work offset.)
(    The post never sees it, so after levelling v is off by that angle and)
(    the plunge walks sin[offset] * L sideways: 0.5 mm at 0.1 deg over a)
(    300 mm drop. v stays a valid unit vector and L stays sane, so no bound)
(    on L would ever have noticed.)
()
(The sound fix is for v to be computed HERE, from the commanded B and the)
(rotary offset, both of which the controller knows and the post does not.)
(That removes the whole class of error instead of bounding it.)

(=================== THE CLAMP ===================)
(_ap_up is how far the tool has to rise before traversing: max of 0 and -L,)
(written without a branch as [X + ABS[X]] / 2. Zero whenever L is already)
(positive, which is the normal retracted case.)
#<_ap_up>=[0.000 - #<_ap_l>]
#<_ap_up>=[[#<_ap_up> + ABS[#<_ap_up>]] / 2.000]
#<_ap_leff>=[#<_ap_l> + #<_ap_up>]

(=================== LEG 1 - RISE TO THE TARGET HEIGHT ===================)
(Straight up the tool axis at the current XY, so it is a pure machine Z move)
(and crosses nothing. Skipped entirely when the tool is already at or above)
(the target, which is almost always.)
o2723 if [#<_ap_up> GT 0.010]
#<_am_x>=[#<_x> + [#<_ap_up> * #<_ap_vx>]]
#<_am_y>=[#<_y> + [#<_ap_up> * #<_ap_vy>]]
#<_am_z>=[#<_z> + [#<_ap_up> * #<_ap_vz>]]
$SD/Run=/Motion/_ApMove.nc
o2723 endif

(=================== TRAVERSE BELOW THE CEILING, NOT ON IT ===================)
(The traverse only has to satisfy  target height <= traverse <= current)
(height. Any point in that band is correct. Asking for exactly the current)
(height picks the boundary, with no margin -- and there IS an error to have)
(margin against:)
()
(  #<_x> is the read-back, which reached here as mpos -> motors_to_cartesian)
(  -> motors_to_cartesian, using the ACTUAL stepped B. The move computed)
(  from it goes out through the forward transform at the COMMANDED B in)
(  gc_state. When those two angles differ --)
(  by a B step, by anything -- the round trip is not the identity, and the)
(  error is that angle times the distance from the rotation centre. It lands)
(  straight on the traverse height.)
()
(At the top of travel there is 0.002 mm of headroom above machine Z0, so a B)
(mismatch of 0.005 deg is already enough to be refused. 0.03 deg at 52 mm)
(from the centre put a commanded 0.027 and a soft limit alarm in the log.)
()
(So back off by _ap_margin and traverse just under the ceiling. Clamped at)
(zero, which also covers the case the margin exceeds the headroom: the)
(traverse then sits at the target's own height, which is a height the)
(controller has already accepted, since the target itself is inside travel.)
()
(0.050 mm. The B step on this machine is 0.006 deg, which at 400 mm from the)
(rotary centre is 0.042 mm of round-trip error -- so 0.050 clears it, and it)
(would still clear it at any distance this machine can reach. The traverse)
(therefore runs 0.05 mm under the top of travel instead of on it.)
()
(That 0.05 mm is the price of computing the height at all, and it cannot be)
(driven to zero: the soft limit leaves 0.002 mm above machine Z0, while one B)
(step already costs twenty times that. To traverse at EXACTLY machine Z0 the)
(height must not be computed -- it has to be held by omission, which means)
(G53 G0 X.. Y.. in the machine frame, which means knowing the machine XY of)
(the target. Only the firmware can supply that.)
#<_ap_margin>=0.050
#<_ap_trav>=[#<_ap_leff> - #<_ap_margin>]
#<_ap_trav>=[[#<_ap_trav> + ABS[#<_ap_trav>]] / 2.000]

(=================== LEG 2 - FLAT TRAVERSE ===================)
(To the point directly above the target, at the height we are now at. Skipped)
(when there is no lateral travel, which is what keeps a pure plunge or a pure)
(lift down to one move -- and keeps a zero-length G38.3, error 33, out of)
(_SafeMove.nc. See the threshold note above for why it is 0.010.)
o2724 if [#<_ap_lat> GT 0.010]
#<_am_x>=[#<_ap_x> + [#<_ap_trav> * #<_ap_vx>]]
#<_am_y>=[#<_ap_y> + [#<_ap_trav> * #<_ap_vy>]]
#<_am_z>=[#<_ap_z> + [#<_ap_trav> * #<_ap_vz>]]
$SD/Run=/Motion/_ApMove.nc
o2724 endif

(=================== LEG 3 - PLUMB PLUNGE ===================)
(Down the tool axis onto the target. Skipped when the traverse already landed)
(on it, i.e. the move was flat all along.)
o2725 if [ABS[#<_ap_trav>] GT 0.010]
#<_am_x>=#<_ap_x>
#<_am_y>=#<_ap_y>
#<_am_z>=#<_ap_z>
$SD/Run=/Motion/_ApMove.nc
o2725 endif

(=================== NOTES ===================)
(The traverse height is whatever the machine happens to be at, which after a)
(G53 G0 Z0 retract is the top of travel -- the one height known to be clear of)
(the table, since that is where the changer lives. Nothing is added on top, so)
(there is no lift to overtravel: the traverse is never higher than where the)
(machine already is.)
()
(v must be a UNIT vector. L is a projection, so a non-unit v scales the)
(headroom and the traverse comes out at the wrong height. The post takes it)
(from Fusion's workPlane.forward, which is normalised.)
()
(v is NOMINAL -- it comes from the commanded B angle. If the kinematics is)
(compensating a tilted rotary axis, the real tool axis differs by that tilt)
(and the plunge walks sideways by tilt * L: about 0.24 mm in machine Y over a)
(60 mm plunge at B180 with axis_z 0.002. Zero while axis_z is 0.)
()
(_ApMove.nc is in /Motion/ beside this file. _SafeMove.nc stays in /Probing/:)
(the probing macros call it there by that path, so it is left where it is.)
()
(Each leg costs an SD read for _ApMove.nc, and a protected leg costs a second)
(for _SafeMove.nc. Skipped legs cost nothing, so a move that was already a)
(single axis move is one read, same as calling _SafeMove.nc directly was.)
