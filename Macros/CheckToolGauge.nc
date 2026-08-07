(CheckToolGauge.nc)
(Safety check run after every tool load -- including when the tool change)
(is SKIPPED because the tool is already in the spindle -- e.g. resuming a)
(program after the STOP button was pressed.)
(
(Two independent checks:)
(  1. Fusion-vs-machine gauge: #<_fusion_tool_gauge> (what the post thinks))
(     vs #<_current_tool_gauge> (what the machine has stored/measured).)
(     Catches wrong / mismeasured tools.)
(  2. Active TLO vs stored gauge: the applied tool length offset Z (#5403))
(     vs #<_current_tool_gauge>. Catches a CLEARED or WRONG offset -- e.g.)
(     the STOP button runs gc_init() which zeroes #5401-#5403, so on resume)
(     the offset may be 0 while the tool is really in the spindle.)
(
(If either disagrees by more than the tolerance, alarm and stop the job)
(rather than cutting with a wrong tool or a wrong Z offset.)

#2=0.5   (gauge-match tolerance, mm -- Fusion vs machine)
#3=0.5   (TLO-match tolerance, mm -- applied offset vs stored gauge)

(--- Check 1: Fusion expected vs machine recorded gauge length ---)
o130 if [EXISTS[#<_fusion_tool_gauge>] EQ 0]
    (MSG: CheckToolGauge -- post did not provide _fusion_tool_gauge, skipping gauge check)
o130 else
    o131 if [EXISTS[#<_current_tool_gauge>] EQ 0]
        (MSG: CheckToolGauge -- machine has no recorded gauge length, skipping gauge check)
    o131 else
        #<_gauge_diff>=[ABS[#<_fusion_tool_gauge> - #<_current_tool_gauge>]]
        o132 if [#<_gauge_diff> GT #2]
            (MSG: TOOL LENGTH MISMATCH -- Fusion and machine gauge lengths disagree)
            $Alarm/Send=3
            M30
        o132 endif
    o131 endif
o130 endif

(--- Check 2: applied TLO Z (#5403) vs machine recorded gauge length ---)
(This catches a TLO that was cleared by a reset/STOP, or otherwise wrong.)
(Only meaningful if the machine actually has a recorded gauge to compare to.)
o133 if [EXISTS[#<_current_tool_gauge>] EQ 0]
    (MSG: CheckToolGauge -- no recorded gauge length, skipping TLO check)
o133 else
    #<_tlo_diff>=[ABS[#5403 - #<_current_tool_gauge>]]
    o134 if [#<_tlo_diff> GT #3]
        (MSG: TOOL OFFSET ERROR -- active TLO does not match tool gauge; was it reset?)
        $Alarm/Send=3
        M30
    o134 endif
o133 endif
