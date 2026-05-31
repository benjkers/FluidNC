(Probe Hole / Pocket / Internal)
M5
#<WCS> = [#<WorkOffset> - 53]

o100 if [#<_XDimension> GT 0]
    (Side 1: Right Wall, Probing +X)
    G91 G0 X[#<_XDimension>/2 - #<Approach>]
    #<VecX>=1 * [#<Approach> + #<Overtravel>]  #<VecY>=0  #<VecZ>=0
    $SD/Run=Probing/ProbeVector.nc
    #<Side1X> = #<_SurfaceX>
    
    (Side 2: Left Wall, Probing -X)
    G91 G0 X[-1 * #<_XDimension> + 2*#<Approach>]
    #<VecX>=-1 * [#<Approach> + #<Overtravel>]  #<VecY>=0  #<VecZ>=0
    $SD/Run=Probing/ProbeVector.nc
    #<Side2X> = #<_SurfaceX>
    
    (Calculate and Set X Center)
    #<Xcenter> = [[#<Side1X> + #<Side2X>] / 2]
    G90 G53 G1 X[#<Xcenter>] F1500
    G10 L20 P#<WCS> X0
o100 endif

o101 if [#<_YDimension> GT 0]
    (Side 3: Back Wall, Probing +Y)
    G91 G0 Y[#<_YDimension>/2 - #<Approach>]
    #<VecX>=0  #<VecY>=1 * [#<Approach> + #<Overtravel>]  #<VecZ>=0
    $SD/Run=Probing/ProbeVector.nc
    #<Side1Y> = #<_SurfaceY>
    
    (Side 4: Front Wall, Probing -Y)
    G91 G0 Y[-1 * #<_YDimension> + 2*#<Approach>]
    #<VecX>=0  #<VecY>=-1 * [#<Approach> + #<Overtravel>]  #<VecZ>=0
    $SD/Run=Probing/ProbeVector.nc
    #<Side2Y> = #<_SurfaceY>
    
    (Calculate and Set Y Center)
    #<Ycenter> = [[#<Side1Y> + #<Side2Y>] / 2]
    G90 G53 G1 Y[#<Ycenter>] F1500
    G10 L20 P#<WCS> Y0
o101 endif

G90 G53 G1 Z-5 F1500
M30