(Universal Vector Touch Engine)
(Requires: #<VecX>, #<VecY>, #<VecZ>, #<ProbeFeed>, #<ProbeRadius>)

(Calculate total vector length)
#<VecLen> = SQRT[[#<VecX>*#<VecX>] + [#<VecY>*#<VecY>] + [#<VecZ>*#<VecZ>]]

o100 if [#<VecLen> EQ 0]
    (MSG: Vector length is zero, aborting)
    M0
o100 endif

(Calculate Unit Vectors for perfect radius comp)
#<Ux> = [#<VecX> / #<VecLen>]
#<Uy> = [#<VecY> / #<VecLen>]
#<Uz> = [#<VecZ> / #<VecLen>]

(Fast Protected Touch)
G91 G38.7 X[#<VecX>] Y[#<VecY>] Z[#<VecZ>] F#<ProbeFeed>

(Back off 2mm along the reverse vector)
G1 X[-2 * #<Ux>] Y[-2 * #<Uy>] Z[-2 * #<Uz>] F#<ProbeFeed>

(Slow Precision Touch)
G38.7 X[3 * #<Ux>] Y[3 * #<Uy>] Z[3 * #<Uz>] F40

(Calculate Absolute Surface Coordinates with Radius Comp)
#<_SurfaceX> = [#5061 + [#<ProbeRadius> * #<Ux>]]
#<_SurfaceY> = [#5062 + [#<ProbeRadius> * #<Uy>]]
#<_SurfaceZ> = [#5063 + [#<ProbeRadius> * #<Uz>]]

(Back off 2mm to clear the part)
G1 X[-2 * #<Ux>] Y[-2 * #<Uy>] Z[-2 * #<Uz>] F#<ProbeFeed>
G90