(_ToolAxisZ.nc)
(Move to a HEIGHT, along the tool axis, protected.)
()
(Written Z is only the tool axis when nothing is indexed. With TCP on and)
(the part turned, a Z move goes sideways: at B90 written Z is machine X. So)
(every macro that used to say)
()
(    G0 Z#<_probe_retract_z>)
(    G38.3 Z#<_probe_depth_z> F#<_probe_feed_link>)
()
(calls this instead, and keeps working at any index angle.)

(=================== INPUTS ===================)
(  _ta_target               the height to reach)
(  _probe_axis_ux/uy/uz     the tool axis, in the frame being written)
(=================== OUTPUT ===================)
(  _ta_at                   the height actually reached)

(The axis defaults to straight up, so a 3-axis machine, a TCP-disabled one,)
(and an un-indexed section all behave exactly as they did before: the move)
(below collapses to a pure Z move of the same length.)
o2500 if [EXISTS[#<_probe_axis_ux>] EQ 0]
#<_probe_axis_ux>=0
o2500 endif
o2501 if [EXISTS[#<_probe_axis_uy>] EQ 0]
#<_probe_axis_uy>=0
o2501 endif
o2502 if [EXISTS[#<_probe_axis_uz>] EQ 0]
#<_probe_axis_uz>=1
o2502 endif
o2503 if [EXISTS[#<_probe_feed_link>] EQ 0]
#<_probe_feed_link>=1000.000
o2503 endif

(=================== MOVE ===================)
(Height is the projection of the written position on the tool axis. The)
(constant offset between the written frame and the machine frame is not)
(known here and does not need to be: the caller's target comes from the same)
(projection, so it cancels.)
#<_ta_now>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]
#<_ta_d>=[#<_ta_target> - #<_ta_now>]

(Protected, always. The macros this replaces used a bare G0 for the retract)
(between touches, but the post's own rule is that every move made with a)
(probe in the spindle is a G38.3 -- the descent from a clearance plane can)
(still meet a clamp, and a rapid there snaps the stylus. G38.3 stops on)
(contact and does not alarm when the path is clear, so it costs nothing.)
o2510 if [ABS[#<_ta_d>] GT 0.0001]
#<_ta_dx>=[#<_probe_axis_ux> * #<_ta_d>]
#<_ta_dy>=[#<_probe_axis_uy> * #<_ta_d>]
#<_ta_dz>=[#<_probe_axis_uz> * #<_ta_d>]
G91
G38.3 X#<_ta_dx> Y#<_ta_dy> Z#<_ta_dz> F#<_probe_feed_link>
G90
o2510 endif

(What it actually reached. A G38.3 that met something stops short, so the)
(caller's "did I get to depth" check has to read this back rather than)
(assume the target -- which is also why this is a projection and not just)
(_ta_target echoed.)
#<_ta_at>=[[#<_x> * #<_probe_axis_ux>] + [#<_y> * #<_probe_axis_uy>] + [#<_z> * #<_probe_axis_uz>]]

(=================== DID IT ARRIVE? ===================)
(G38.3 stops on contact without alarming, so a blocked move looks exactly)
(like a completed one unless it is checked. Callers used to be responsible)
(for that and not all of them were -- the post's own descent to the retract)
(height was unchecked. Doing it here covers every caller.)
(See _SafeMove.nc for why the stop is an alarm and not an M30.)
o2520 if [ABS[#<_ta_at> - #<_ta_target>] GT 0.050]
(PRINT, STOPPED - tool axis move touched something )
(PRINT,   wanted height %.3f#<_ta_target>  reached %.3f#<_ta_at>  )
$Alarm/Send=3
G4 P0.1
o2520 endif
