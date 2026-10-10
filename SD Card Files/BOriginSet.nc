(BOriginSet.nc)
(Sets this fixture's work origin into the CURRENTLY SELECTED work offset,)
(after checking it still agrees with the rotary pivot in config.yaml.)

(=================== DO NOT CALL THIS FROM StartUp.nc ===================)
(  It writes to a work offset now, so calling it at boot would put the)
(  origin back every power-up -- the very thing that made it worth)
(  splitting out of the startup macro in the first place. Call it from)
(  the program that needs it, as a single Manual NC pass-through line:)
()
(      $SD/Run=BOriginSet.nc)
()
(  The post selects the setup's offset at the top of the program, before)
(  any pass-through runs, so P0 below resolves to G54, G59 or whatever)
(  that setup uses. Nothing here needs changing when the setup moves to a)
(  different offset.)

(=================== WHY X AND Z ARE CHECKED ===================)
(  The rotary runs along Y, so every point on the axis shares the same X)
(  and Z and any Y is equally on it. Checking Y would mean nothing.)
()
(  With the origin ON the axis, rotating B leaves it where it is in)
(  machine space. Off the axis, B swings it around -- TCPCartesian still)
(  places the tool correctly either way, so this is not a correctness)
(  check. It catches the fixture having moved, or the pivot having been)
(  re-probed without this file being updated to match.)

(=================== INPUTS ===================)
#<_BOrignX>=-236.856 (Set X of Work Origin)
#<_BOrignY>=-4.406 (Set Y of Work Origin)
#<_BOrignZ>=-219.301 (Set Z of Work Origin)

(How far X or Z may differ from the configured pivot before stopping, mm.)
#<_BOrignTol>=0.010

(1 = alarm and abort without writing the offset, 0 = report the mismatch)
(and write it anyway.)
#<_BOrignStop>=1

(=================== CHECK ===================)
(The config tree reads as #</path/to/item>, and EXISTS works on it, so a)
(machine running other kinematics skips the check instead of failing to)
(parse.)
o100 if [EXISTS[#</kinematics/TCPCartesian/pivot_x_mm>]]

#<_bo_px>=#</kinematics/TCPCartesian/pivot_x_mm>
#<_bo_pz>=#</kinematics/TCPCartesian/pivot_z_mm>
#<_bo_dx>=[#<_BOrignX> - #<_bo_px>]
#<_bo_dz>=[#<_BOrignZ> - #<_bo_pz>]

o110 if [[ABS[#<_bo_dx>] GT #<_BOrignTol>] OR [ABS[#<_bo_dz>] GT #<_BOrignTol>]]
(PRINT, ======================================== )
(PRINT, WORK ORIGIN IS OFF THE ROTARY PIVOT )
(PRINT,   origin  X %.4f#<_BOrignX>  Z %.4f#<_BOrignZ> )
(PRINT,   pivot   X %.4f#<_bo_px>  Z %.4f#<_bo_pz> )
(PRINT,   out by  X %.4f#<_bo_dx>  Z %.4f#<_bo_dz>  mm )
(PRINT,   tolerance %.3f#<_BOrignTol> mm )
(PRINT, Re-probe the pivot, or update BOriginSet.nc to match it. )
(PRINT, ======================================== )
o120 if [#<_BOrignStop> GT 0]
(An alarm unwinds the WHOLE job stack: the protocol loop calls Job::abort)
(on seeing the alarm state, which pops every nested job including the)
(program that called this one. M30 would do the opposite -- it ends only)
(this file, hands control back to the caller to carry on with a bad)
(origin, and resets the coordinate system to G54 on the way out.)
$Alarm/Send=3
o120 endif
o110 endif

o100 endif

(=================== APPLY ===================)
(P0 is the active offset. The parser resolves it from)
(gc_block.modal.coord_select, so this follows whatever the program)
(selected rather than naming one here.)
()
(L2, not L20: these are machine coordinates for where the origin IS, not)
(a position the machine is standing at.)
G10 L2 P0 X#<_BOrignX> Y#<_BOrignY> Z#<_BOrignZ>

(#5220 reports the active offset as its P number -- CoordIndex::G54 is 0,)
(so 1 is G54 through 6 for G59.)
#<_bo_wcs>=#5220
(PRINT, work origin set in P%.0f#<_bo_wcs>: X %.4f#<_BOrignX> Y %.4f#<_BOrignY> Z %.4f#<_BOrignZ> )
G4p0.1
