(ProbeCheckTolerance.nc)
(Shared tolerance checker, run at the end of every probing macro via)
(    $SD/Run=/Probing/ProbeCheckTolerance.nc)
(Implements Fusion's "out of tolerance" and "out of position" actions.)
()
(Expects, all guaranteed defined by ProbeInit.nc:)
(  #<_probe_tol_size>     size tolerance, 0 disables the check)
(  #<_probe_tol_pos>      position tolerance, 0 disables the check)
(  #<_probe_dev_size>     measured size minus nominal size)
(  #<_probe_dev_pos>      distance from expected to found position)
(  #<_probe_action_size>  0 = warn only, 1 = alarm and stop)
(  #<_probe_action_pos>   0 = warn only, 1 = alarm and stop)
()
(HOW THE STOP WORKS -- and why it is not an M30:)
(  M30 calls Job::channel-end on the INNERMOST job. This macro is nested)
(  inside a probing macro, which is nested inside the program, so an M30)
(  here would end only this file and let the program carry on -- useless)
(  as a safety stop. The real stop is the ALARM: it drives a late reset)
(  into State::Alarm, after which every further gcode line is rejected.)
()
(  $Alarm/Send is ASYNCHRONOUS -- it queues an event and returns at once.)
(  The G4 dwell after it forces a buffer synchronise, which lets the event)
(  be processed, so the alarm has actually taken hold before any further)
(  line can run. Without it there is a window where the program continues.)
()
(Messages use PRINT rather than MSG because PRINT interpolates parameter)
(values, so the operator sees HOW FAR out it was, not just that it failed.)

(--- SIZE: is the feature the size it should be? ---)
o340 if [#<_probe_tol_size> GT 0]
    o341 if [ABS[#<_probe_dev_size>] GT #<_probe_tol_size>]
        (PRINT, PROBE OUT OF TOLERANCE - size error %.4f#<_probe_dev_size> mm exceeds limit %.4f#<_probe_tol_size> mm)
        o342 if [#<_probe_action_size> GT 0]
            $Alarm/Send=3
            G4 P0.1
        o342 endif
    o341 endif
o340 endif

(--- POSITION: is the feature where it should be? ---)
o350 if [#<_probe_tol_pos> GT 0]
    o351 if [#<_probe_dev_pos> GT #<_probe_tol_pos>]
        (PRINT, PROBE OUT OF POSITION - found %.4f#<_probe_dev_pos> mm from nominal, limit %.4f#<_probe_tol_pos> mm)
        o352 if [#<_probe_action_pos> GT 0]
            $Alarm/Send=3
            G4 P0.1
        o352 endif
    o351 endif
o350 endif
