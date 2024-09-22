(Probe Internal features in square pattern)


M5  (Stop Spindle)

o102 if[#<_XDimension> GT 0]
    (Side 1 Probing)
    G38.7 x[-1*#<_XDimension>/2+5] f200
    G1 x2 f200 
    $SD/Run=Probing/ProbeXNeg.nc
    G4 p0.5 (wait)
    #<side1>=#<_Result> (Setting side1 results to the X probe result)

    (Side 2 Probing)
    G38.7 x[#<_XDimension>+5] f200
    G1 x-2 f200
    $SD/Run=Probing/ProbeXPos.nc
    G4 p0.5 (wait)
    #<side2>=#<_Result> (Setting side2 results to the X probe result)
    #<Xcenter>=[[#<side1>-#<side2>]/2+#<side2>]
    G90 G53 G1 x[#<Xcenter>] f1500
    G10 L20 P[#<Coordinate>-53]  X0 (Setting X0)
    G91
o102 endif

o102 if[#<_YDimension> GT 0]
    (Side 3 Probing)
    G38.7 Y[-1*#<_YDimension>+5]F200
    G1 y2 f200
    $SD/Run=Probing/ProbeYNeg.nc
    G4 p0.5 (wait)
    #<side3>=#<_Result> (Setting side3 results to the Y probe result)


    (Side 4 Probing)
    G38.7 Y[#<_YDimension>+5]F200
    G1 y-2 f200
    $SD/Run=Probing/ProbeYPos.nc
    G4 p0.5 (wait)
    #<side4>=#<_Result> (Setting side4 results to the Y probe result)
    #<Ycenter>=[[#<side3>-#<side4>]/2+#<side4>]
    G90 G53 G1 Y[#<Ycenter>] f1500
    G10 L20 P[#<Coordinate>-53]  Y0 (Setting Y0)
    G91
o102 endif

G90 G53 G1 Z-5 F1500
g91
m30

