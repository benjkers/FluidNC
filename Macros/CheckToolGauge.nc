(CheckToolGauge.nc)
(Safety check run after every tool load -- including when the tool change is)
(SKIPPED because the tool is already in the spindle, such as resuming a)
(program after the STOP button.)
()
(Two independent checks:)
()
(  1. Fusion versus machine gauge. #<_fusion_tool_gauge>, what the post)
(     believes the tool is, against #<_current_tool_gauge>, what the machine)
(     has stored or measured. Catches a wrong or mismeasured tool.)
()
(  2. Applied offset versus stored gauge. The active tool length offset Z,)
(     parameter 5403, against #<_current_tool_gauge>. Catches a CLEARED or)
(     wrong offset: the STOP button runs gc_init, which zeroes 5401 to 5403,)
(     so on resume the offset can be zero while the tool is really loaded.)
()
(Either disagreement alarms and halts rather than cutting with the wrong)
(tool or the wrong Z.)
()
(HOW THE HALT WORKS, and why it is not an M30:)
(  M30 ends the INNERMOST job. This macro is nested inside the program, so)
(  an M30 here would end only this file and let the program carry on --)
(  useless as a safety stop. The alarm is what halts: it drives a late reset)
(  into the alarm state, after which every further line is rejected.)
()
(  Alarm/Send is asynchronous, queueing an event and returning at once, so)
(  the dwell after it forces a buffer synchronise and lets the alarm take)
(  hold before anything else can run.)

#2=0.5   (gauge match tolerance, mm -- Fusion against machine)
#3=0.5   (offset match tolerance, mm -- applied TLO against stored gauge)

(--- Check 1: what Fusion expects against what the machine recorded ---)
o130 if [EXISTS[#<_fusion_tool_gauge>] EQ 0]
    (MSG: CheckToolGauge - post gave no expected gauge, skipping that check)
o130 else
    o131 if [EXISTS[#<_current_tool_gauge>] EQ 0]
        (MSG: CheckToolGauge - machine has no recorded gauge, skipping that check)
    o131 else
        #<_gauge_diff>=[ABS[#<_fusion_tool_gauge> - #<_current_tool_gauge>]]
        o132 if [#<_gauge_diff> GT #2]
            (PRINT, TOOL LENGTH MISMATCH - Fusion %.4f#<_fusion_tool_gauge>  machine %.4f#<_current_tool_gauge> )
            (PRINT, difference %.4f#<_gauge_diff>  limit %.4f#2 )
            $Alarm/Send=3
            G4 P0.1
        o132 endif
    o131 endif
o130 endif

(--- Check 2: the applied offset against the recorded gauge ---)
(Only meaningful when the machine actually has a gauge to compare against.)
o133 if [EXISTS[#<_current_tool_gauge>] EQ 0]
    (MSG: CheckToolGauge - no recorded gauge, skipping the offset check)
o133 else
    #<_tlo_diff>=[ABS[#5403 - #<_current_tool_gauge>]]
    o134 if [#<_tlo_diff> GT #3]
        (PRINT, TOOL OFFSET ERROR - applied TLO %.4f#5403  gauge %.4f#<_current_tool_gauge> )
        (PRINT, difference %.4f#<_tlo_diff>  limit %.4f#3  - was the offset reset? )
        $Alarm/Send=3
        G4 P0.1
    o134 endif
o133 endif
