(_SafeMove.nc)
(A protected positioning move that CONFIRMS it arrived.)
()
(G38.3 stops on contact and does NOT alarm -- that is what makes it right for)
(positioning with a probe in the spindle. But it means a blocked move looks)
(exactly like a completed one: the program carries on to the next line with)
(the machine somewhere other than where every following line assumes it is.)
(The next move then starts from the wrong place, and the one after that, and)
(the first thing the operator sees is a broken stylus.)
()
(So every positioning move goes through here: move, then check, then alarm if)
(it did not get there. The alarm is what actually stops the program -- see the)
(note below.)

(=================== INPUTS ===================)
(  _sm_x _sm_y _sm_z        target, in WORK coordinates)
(  _probe_feed_rapid        feed for positioning moves)
(  _sm_tol                  arrival tolerance, mm)

(=================== WHY AN ALARM AND NOT M30 ===================)
(M30 ends the INNERMOST job. This file is nested inside a program, and often)
(inside a probing macro as well, so an M30 here would end only this file and)
(let the caller carry on -- useless as a safety stop.)
()
(The alarm drives a late reset into State::Alarm, after which every further)
(gcode line is rejected. $Alarm/Send is ASYNCHRONOUS, so the G4 after it)
(forces a buffer synchronise and lets the event be processed before anything)
(else can run. Without the dwell there is a window where the program)
(continues.)

o2700 if [EXISTS[#<_probe_feed_rapid>] EQ 0]
#<_probe_feed_rapid>=3000.000
o2700 endif
o2701 if [EXISTS[#<_sm_tol>] EQ 0]
#<_sm_tol>=0.050
o2701 endif

(=================== MOVE ===================)
(Settle before measuring the distance. #<_x>/#<_y>/#<_z> are evaluated)
(through get_mpos with NO buffer sync, so a read taken while an earlier move)
(is still decelerating reports an in-flight position -- which would make a)
(zero-length move look non-zero, or the reverse.)
G4 P0.01

(SKIP THE MOVE IF THERE IS NOTHING TO DO. A G38.x whose target is already)
(the current position is REJECTED: GCode.cpp tests isequal_position_vector)
(against gc_state.position and returns error 33, Gcode invalid target.)
()
(This never mattered while the only caller was the first approach after a)
(tool change, which always began from G53 Z0 and so always had somewhere to)
(go. Now that every rapid in a probing section is routed through here, a)
(rapid to a point the machine already occupies is routine -- Fusion emits)
(them, and the post can no longer suppress them, because the forceXYZ this)
(macro needs resets the modal trackers that used to do the suppressing.)
()
(_ToolAxisZ.nc and _LateralMove.nc have always had this guard; this file is)
(the one that never needed it before.)
#<_sm_dx>=[#<_sm_x> - #<_x>]
#<_sm_dy>=[#<_sm_y> - #<_y>]
#<_sm_dz>=[#<_sm_z> - #<_z>]
o2705 if [[ABS[#<_sm_dx>] GT 0.0001] OR [ABS[#<_sm_dy>] GT 0.0001] OR [ABS[#<_sm_dz>] GT 0.0001]]
G90
G38.3 X#<_sm_x> Y#<_sm_y> Z#<_sm_z> F#<_probe_feed_rapid>
o2705 endif

(=================== DID IT ARRIVE? ===================)
#<_sm_ex>=[#<_x> - #<_sm_x>]
#<_sm_ey>=[#<_y> - #<_sm_y>]
#<_sm_ez>=[#<_z> - #<_sm_z>]
#<_sm_err>=[SQRT[[#<_sm_ex> * #<_sm_ex>] + [#<_sm_ey> * #<_sm_ey>] + [#<_sm_ez> * #<_sm_ez>]]]

(PRINT interpolates the values, so the operator sees HOW FAR out it stopped)
(and where, not merely that something went wrong. Two spaces follow every)
(parameter because the PRINT reader consumes the character after each one.)
o2710 if [#<_sm_err> GT #<_sm_tol>]
(PRINT, STOPPED - positioning move touched something )
(PRINT,   stopped %.3f#<_sm_err>  mm from the target )
(PRINT,   wanted  X %.3f#<_sm_x>  Y %.3f#<_sm_y>  Z %.3f#<_sm_z>  )
(PRINT,   reached X %.3f#<_x>  Y %.3f#<_y>  Z %.3f#<_z>  )
$Alarm/Send=3
G4 P0.1
o2710 endif
