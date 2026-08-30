(BreakDetection.nc)
(Re-probes the tool in the spindle on the toolsetter and compares against)
(where it touched when it was measured. A tool that has broken or chipped)
(is SHORTER, so it touches lower and the trigger sits further down.)
()
(Called by the post from a Manual NC "Break control" step in the Fusion)
(timeline, so it can be dropped in after a risky operation.)
()
(WHAT IT COMPARES)
(  The ATC records #<_current_tool_probe_z>, the raw machine Z at which the)
(  tool triggered the setter when its gauge was established. This macro)
(  probes again and takes the difference. Comparing raw probe heights avoids)
(  needing the gauge constant, and cancels any movement of the setter itself)
(  as long as it has not been touched between the two probes.)
()
(      loss = recorded_probe_z - new_probe_z)
()
(  Positive loss means the tool is shorter than when it was measured. A)
(  large NEGATIVE figure is also wrong -- a tool cannot grow -- and usually)
(  means chips under the setter or the wrong tool in the spindle, so it is)
(  reported too rather than passed silently.)
()
(REQUIRES the ATC to have run at least once this session, since it supplies)
(the setter position and the recorded trigger height.)

(================= EDIT THESE =================)
(How much shortening counts as a broken tool.)
#<_bd_tol>=0.500

(A loss more negative than this means something is wrong in the other)
(direction -- swarf on the setter, or a different tool than expected.)
#<_bd_grow>=0.200

(Feeds for the approach and the measuring touch.)
#<_bd_fast>=400.000
#<_bd_slow>=100.000

(================= GUARDS =================)
(Everything below reads parameters the ATC publishes. Reading an undefined)
(parameter is a hard gcode error that aborts the controller, so each one is)
(checked before use rather than assumed.)
o600 if [EXISTS[#<_etsx>] EQ 0]
    (MSG: BreakDetection - no toolsetter position, run a tool change first)
    $Alarm/Send=3
    G4 P0.1
o600 endif
o601 if [EXISTS[#<_current_tool_probe_z>] EQ 0]
    (MSG: BreakDetection - this tool has no recorded probe height, nothing to compare)
    $Alarm/Send=3
    G4 P0.1
o601 endif

(================= MEASURE =================)
(Lift clear, cross to the setter at machine height, then descend. The)
(approach stops above the setter by the ATC's own rapid offset, and the)
(probe travels that offset plus the overtravel allowance.)
#<_bd_reach>=[#<_etszrapidoffset> + #<_etsovertravel>]

G90
G53 G0 Z0
G53 G0 X#<_etsx> Y#<_etsy>
G53 G0 Z[#<_etsz> + #<_etszrapidoffset>]

(Fast find, back off, slow accurate touch -- the same two stage approach the)
(probing macros use, because a single fast touch is not repeatable enough to)
(judge a fraction of a millimetre against.)
G91
G38.2 Z[0 - #<_bd_reach>] F#<_bd_fast>
G0 Z1.000
G38.2 Z-2.000 F#<_bd_slow>
G90
#<_bd_new>=#5063

(Release the stylus before any further move: the controller rejects a probe)
(move that begins already triggered, and the touch above leaves it pressed.)
G91
G0 Z2.000
G90
G53 G0 Z0

(================= COMPARE =================)
#<_bd_loss>=[#<_current_tool_probe_z> - #<_bd_new>]

(PRINT, BREAK CHECK - was %.4f#<_current_tool_probe_z>  now %.4f#<_bd_new> )
(PRINT,   length change %.4f#<_bd_loss>  limit %.4f#<_bd_tol> )

o610 if [#<_bd_loss> GT #<_bd_tol>]
    (PRINT, TOOL BROKEN - shorter by %.4f#<_bd_loss> mm )
    $Alarm/Send=3
    G4 P0.1
o610 endif

o611 if [#<_bd_loss> LT [0 - #<_bd_grow>]]
    (PRINT, BREAK CHECK FAILED - tool measures LONGER by %.4f#<_bd_loss> mm )
    (PRINT,   a tool cannot grow - suspect swarf on the setter or the wrong tool )
    $Alarm/Send=3
    G4 P0.1
o611 endif

(MSG: Break check passed)
