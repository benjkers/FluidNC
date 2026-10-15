(_LateralMove.nc)
(Move to a position in the LATERAL plane, protected, holding the tool-axis)
(height where it is.)
()
(The companion to _ToolAxisZ.nc. Between them they cover every traverse a)
(probing macro makes: lift along the tool axis, cross over laterally, descend)
(along the tool axis.)
()
(This replaces the G53 traverses the macros used to make. Two things were)
(wrong with those once TCP is on:)
()
(  1. G53 is a different FRAME. The block sets _suspended, so its words are)
(     TRUE MACHINE coordinates with no transform. But the values fed to it)
(     came from #<_abs_*>, and get_mpos runs steps_to_mpos, which ends in)
(     motors_to_cartesian, which applies inverse. Those are UN-ROTATED)
(     part-frame coordinates. Capturing in one frame and replaying in the)
(     other sent a retract 67 mm off line at B90 and into the vise.)
()
(  2. A G53 block with only some axis words inherits the rest from)
(     gc_state.position, which is part-frame -- so the UNNAMED axes jump too,)
(     not just the named one. There is no safe way to write a partial G53)
(     while the transform is live.)
()
(Everything here is in the WORK frame: #<_x>/#<_y>/#<_z> report it, a plain)
(G90/G91 word commands it, and G10 L20 writes it. No pivot, no B, no offsets)
(are needed anywhere in this file.)

(=================== INPUTS ===================)
(  _lm_l1                   target coordinate along lateral 1)
(  _lm_l2                   target coordinate along lateral 2)
(  _probe_lat_ux/uy/uz      lateral 1, in the frame being written)
(=================== OUTPUT ===================)
(  _lm_at1 _lm_at2          the coordinates actually reached)

(Lateral 1 is the written direction that comes out as machine X. Lateral 2 is)
(always written Y: B turns about Y, so that axis is never rotated and needs)
(no basis vector.)
()
(Lateral 1 defaults to written X, so a 3-axis machine, a TCP-disabled job and)
(an un-indexed section all collapse this to a plain X/Y move of exactly the)
(same length as before.)
o2600 if [EXISTS[#<_probe_lat_ux>] EQ 0]
#<_probe_lat_ux>=1
o2600 endif
o2601 if [EXISTS[#<_probe_lat_uy>] EQ 0]
#<_probe_lat_uy>=0
o2601 endif
o2602 if [EXISTS[#<_probe_lat_uz>] EQ 0]
#<_probe_lat_uz>=0
o2602 endif
o2603 if [EXISTS[#<_probe_feed_link>] EQ 0]
#<_probe_feed_link>=1000.000
o2603 endif

(=================== MOVE ===================)
(Where we are, in the same two coordinates. The constant offset between this)
(frame and the machine frame is not known here and does not need to be: the)
(caller's targets come from the same projection, so it cancels.)
#<_lm_n1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_lm_n2>=#<_y>
#<_lm_d1>=[#<_lm_l1> - #<_lm_n1>]
#<_lm_d2>=[#<_lm_l2> - #<_lm_n2>]

(=================== ONE AXIS AT A TIME ===================)
(Lateral 1 first, then lateral 2, as two separate blocks.)
()
(This is the order Fusion simulates, and matching it is the whole point: on a)
(boss or bore it probes the two X faces, moves to the measured X CENTRE, then)
(probes the two Y faces. Moving lateral 1 first is that move to the centre.)
()
(These two directions are exactly machine X and machine Y: lateral 1 is by)
(definition the written direction that comes out as machine X, and lateral 2)
(is written Y, which B never rotates. So one block moves only machine X and)
(the next only machine Y, whatever the index angle.)
()
(It used to be a single combined block, which the controller interpolates as)
(a straight line -- the machine cut the corner diagonally where Fusion showed)
(two axis moves, and a simulation is only worth having if the machine follows)
(the path that was verified.)
()
(Lateral 1 moves along its own vector, so its block carries written X, Y and)
(Z components; lateral 2 is pure written Y and needs none of that.)
#<_lm_dx>=[#<_probe_lat_ux> * #<_lm_d1>]
#<_lm_dy>=[#<_probe_lat_uy> * #<_lm_d1>]
#<_lm_dz>=[#<_probe_lat_uz> * #<_lm_d1>]

(Protected, always. There is a probe in the spindle and a traverse at depth)
(can still meet a clamp; G38.3 stops on contact and does not alarm when the)
(path is clear, so it costs nothing when all is well.)
o2610 if [[ABS[#<_lm_dx>] GT 0.0001] OR [ABS[#<_lm_dy>] GT 0.0001] OR [ABS[#<_lm_dz>] GT 0.0001]]
G91
G38.3 X#<_lm_dx> Y#<_lm_dy> Z#<_lm_dz> F#<_probe_feed_link>
G90
o2610 endif

(Did lateral 1 arrive? Splitting the move means a blocked first leg no longer)
(stops the second one, and carrying on along Y while pressed against whatever)
(stopped the X leg would drag the stylus along it. So check here rather than)
(leaving it to the caller, which only looks once both legs are done.)
#<_lm_mid1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
o2611 if [ABS[#<_lm_mid1> - #<_lm_l1>] LT 0.050]
o2612 if [ABS[#<_lm_d2>] GT 0.0001]
G91
G38.3 Y#<_lm_d2> F#<_probe_feed_link>
G90
o2612 endif
o2611 endif

(What was actually reached. A G38.3 that met something stopped short, so the)
(caller's obstruction check has to read these back rather than assume the)
(targets.)
#<_lm_at1>=[[#<_x> * #<_probe_lat_ux>] + [#<_y> * #<_probe_lat_uy>] + [#<_z> * #<_probe_lat_uz>]]
#<_lm_at2>=#<_y>
