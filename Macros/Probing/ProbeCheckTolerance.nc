(ProbeCheckTolerance.nc)
(Shared tolerance checker, run at the end of a probing macro via)
(    $SD/Run=/Probing/ProbeCheckTolerance.nc)
(Implements Fusion's "out of tolerance" and "out of position" actions.)
()
(Expects, all guaranteed defined by ProbeInit.nc:)
(  #<_probe_tol_size>     size tolerance, 0 disables the check)
(  #<_probe_tol_pos>      position tolerance, 0 disables the check)
(  #<_probe_dev_size>     measured size minus nominal size)
(  #<_probe_dev_pos>      distance from expected to found centre)
(  #<_probe_action_size>  0 = warn only, 1 = alarm and stop)
(  #<_probe_action_pos>   0 = warn only, 1 = alarm and stop)

(--- SIZE: is the feature the size it should be? ---)
o340 if [#<_probe_tol_size> GT 0]
    o341 if [ABS[#<_probe_dev_size>] GT #<_probe_tol_size>]
        (MSG: PROBE OUT OF TOLERANCE - measured size outside the size tolerance)
        o342 if [#<_probe_action_size> GT 0]
            $Alarm/Send=3
            M30
        o342 endif
    o341 endif
o340 endif

(--- POSITION: is the feature where it should be? ---)
o350 if [#<_probe_tol_pos> GT 0]
    o351 if [#<_probe_dev_pos> GT #<_probe_tol_pos>]
        (MSG: PROBE OUT OF POSITION - found centre outside the position tolerance)
        o352 if [#<_probe_action_pos> GT 0]
            $Alarm/Send=3
            M30
        o352 endif
    o351 endif
o350 endif
