(--- 4th Axis Master Calibration - Depth Limited ---)
#<WCS> = 6                  (G59 = WCS 6)
#<Clearance> = 10           (Safe Z retract)
#<SearchDist> = 30          (Max probe travel)
#<StylusLength> = 50        (Enter your actual stylus length)
#<ProbeRadius> =2.5         (Enter your probe Radius)

(1. LEVEL B-AXIS)
#<StartX> = #<_x>
#<RotaryCenter> = #5241     (G59 X-offset)

#<VecX>=0 #<VecY>=0 #<VecZ>=-1*#<SearchDist>
$SD/Run=Probing/ProbeVector.nc
#<Z1> = #<_SurfaceZ>

G90 G53 G0 Z0
#<MirroredX> = [#<RotaryCenter> - [#<StartX> - #<RotaryCenter>]]
G0 X[#<MirroredX>]
#<VecX>=0 #<VecY>=0 #<VecZ>=-1*#<SearchDist>
$SD/Run=Probing/ProbeVector.nc
#<Z2> = #<_SurfaceZ>

#<Angle> = [ATAN[[#<Z1> - #<Z2>]] / [ABS[#<StartX> - #<MirroredX>]]]
G90 G53 G0 Z0
G0 B[#<Angle>]
G10 L20 P[#<WCS>] B0

(2. GET TRUE Z TOP)
G59 G0 X0 
G90 G0 Z[#<Z1>]
#<VecX>=0 #<VecY>=0 #<VecZ>=-1*#<SearchDist>
$SD/Run=Probing/ProbeVector.nc
#<Z_Top> = #<_SurfaceZ>

(3. FIND X CENTER)
(Calculate center depth and enforce safety cap)
#<TargetDepth> = [#<Z_Top> - [#<Width>/2]] (Rough estimate, refined later)
#<DistToCenter> = ABS[#<Z_Top> - [#<Z_Top> - #<Width>/2]] 

(Safety Logic: If distance > StylusLength, cap at StylusLength)
#<PlungeZ> = [#<Z_Top> - #<StylusLength>]
IF [[#<Z_Top> - #<G59_Z0>] LT #<StylusLength>]
    #<PlungeZ> = #<G59_Z0>
ENDIF

G90 G53 G0 Z0
G0 X[#<StartX> + 20] 
G0 Z[#<PlungeZ>]
#<VecX>=-1*#<SearchDist> #<VecY>=0 #<VecZ>=0
$SD/Run=Probing/ProbeVector.nc
#<Face1> = #<_SurfaceX>

G90 G53 G0 Z0
G0 B180
G0 X[#<MirroredX> - 20]
G0 Z[#<PlungeZ>]
#<VecX>=1*#<SearchDist> #<VecY>=0 #<VecZ>=0
$SD/Run=Probing/ProbeVector.nc
#<Face2> = #<_SurfaceX>

#<X_Center> = [[#<Face1> + #<Face2>] / 2]
#<Width> = ABS[#<Face1> - #<Face2>]
G10 L2 P[#<WCS>] X[#<X_Center>]

(4. FIND Z CENTER)
G90 G53 G0 Z0
G0 B90 
G0 X[#<X_Center> + [#<Width>/2] + 20]
G0 Z[#<G59_Z0>]
#<VecX>=-1*#<SearchDist> #<VecY>=0 #<VecZ>=0
$SD/Run=Probing/ProbeVector.nc
#<TopFace_B90> = #<_SurfaceX>

#<H> = [#<TopFace_B90> - #<X_Center>]
#<Z_Center> = [#<Z_Top> - #<H>]
G10 L2 P[#<WCS>] Z[#<Z_Center>]

(5. SYNC & RESET)
G90 G53 G0 Z0
G0 B0
$SD/Run=Probing/SyncETS.nc
M30