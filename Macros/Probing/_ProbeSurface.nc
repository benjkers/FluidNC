(_ProbeSurface.nc)
(Generic single-surface touch with RUNOUT COMPENSATION. Every feature)
(macro calls this once per surface via)
(    $SD/Run=/Probing/_ProbeSurface.nc)
()
(WHY: the stylus tip is never perfectly concentric with the spindle axis.)
(That eccentricity does NOT cancel in centre finding -- unlike the tip)
(RADIUS, which appears as +r on one wall and -r on the opposite one, the)
(eccentricity has the SAME sign on both touches and so survives the)
(average, shifting every result by the runout along that axis.)
()
(Touching the same surface twice with the spindle rotated 180 degrees)
(between them flips the eccentricity, so averaging the two cancels it)
(exactly. The rotation need not be precise: being 20 degrees out still)
(leaves under 3 microns, because the residual is second order.)
()
(CALLER SETS, before calling:)
(  #<_ps_ux> #<_ps_uy> #<_ps_uz>  unit vector pointing INTO the surface)
(  #<_ps_rotate>                  1 = do the two pass runout compensation)
(                                 0 = single pass, e.g. Z where a radial)
(                                 offset does not affect the reading)
(  The probe must already be at the approach standoff for this surface.)
()
(RETURNS:)
(  #<_ps_x> #<_ps_y> #<_ps_z>     averaged trigger point, MACHINE coords)
(  The probe is left back at the position it started from.)

$SD/Run=/Probing/ProbeInit.nc

o500 if [EXISTS[#<_ps_ux>]]
o500 else
#<_ps_ux>=0
o500 endif
o501 if [EXISTS[#<_ps_uy>]]
o501 else
#<_ps_uy>=0
o501 endif
o502 if [EXISTS[#<_ps_uz>]]
o502 else
#<_ps_uz>=0
o502 endif
o503 if [EXISTS[#<_ps_rotate>]]
o503 else
#<_ps_rotate>=1
o503 endif

(--- remember where we started so we can hand the probe back ---)
#<_ps_sx>=#<_abs_x>
#<_ps_sy>=#<_abs_y>
#<_ps_sz>=#<_abs_z>

#<_ps_reach>=[#<_probe_clearance> + #<_probe_overtravel>]

(--- fast find, back off, first accurate touch ---)
G91
G38.2 X[#<_ps_ux> * #<_ps_reach>] Y[#<_ps_uy> * #<_ps_reach>] Z[#<_ps_uz> * #<_ps_reach>] F#<_probe_feed_fast>
G0 X[0 - [#<_ps_ux> * #<_probe_backoff>]] Y[0 - [#<_ps_uy> * #<_probe_backoff>]] Z[0 - [#<_ps_uz> * #<_probe_backoff>]]
G38.2 X[#<_ps_ux> * [#<_probe_backoff> * 2]] Y[#<_ps_uy> * [#<_probe_backoff> * 2]] Z[#<_ps_uz> * [#<_probe_backoff> * 2]] F#<_probe_feed_slow>
G90
#<_ps_p1x>=#5061
#<_ps_p1y>=#5062
#<_ps_p1z>=#5063

o510 if [#<_ps_rotate> GT 0]
    (--- retract clear, let the operator turn the spindle half a turn ---)
    G91
    G0 X[0 - [#<_ps_ux> * #<_probe_clearance>]] Y[0 - [#<_ps_uy> * #<_probe_clearance>]] Z[0 - [#<_ps_uz> * #<_probe_clearance>]]
    G90
    M0
    (MSG: Rotate the spindle 180 degrees by hand, then resume - roughly is fine)

    (--- second accurate touch, eccentricity now reversed ---)
    G91
    G38.2 X[#<_ps_ux> * #<_ps_reach>] Y[#<_ps_uy> * #<_ps_reach>] Z[#<_ps_uz> * #<_ps_reach>] F#<_probe_feed_slow>
    G90
    #<_ps_p2x>=#5061
    #<_ps_p2y>=#5062
    #<_ps_p2z>=#5063

    #<_ps_x>=[[#<_ps_p1x> + #<_ps_p2x>] / 2]
    #<_ps_y>=[[#<_ps_p1y> + #<_ps_p2y>] / 2]
    #<_ps_z>=[[#<_ps_p1z> + #<_ps_p2z>] / 2]

    (--- how much runout we just cancelled, worth watching ---)
    #<_probe_runout>=[SQRT[[[#<_ps_p2x> - #<_ps_p1x>] * [#<_ps_p2x> - #<_ps_p1x>]] + [[#<_ps_p2y> - #<_ps_p1y>] * [#<_ps_p2y> - #<_ps_p1y>]]] / 2]
o510 else
    #<_ps_x>=#<_ps_p1x>
    #<_ps_y>=#<_ps_p1y>
    #<_ps_z>=#<_ps_p1z>
    #<_probe_runout>=0
o510 endif

(--- hand the probe back where the caller left it ---)
G53 G38.3 X#<_ps_sx> Y#<_ps_sy> Z#<_ps_sz> F#<_probe_feed_link>
