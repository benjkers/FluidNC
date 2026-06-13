(Probe External features in square pattern)

#<Clearance_Height>=5  (Probe clearance above work)

M5  (Stop Spindle)


(Probe z to establish offset)
$SD/Run=Probing/ProbeZ.nc
G4 p0.5 (wait)
G10 L20 P[#<Coordinate>-53]  X0 Y0 Z0 (Saving X0 Y0 Z0 to selected work offset)
G38.7 z[#<Clearance_Height>]  F1500

o102 if[#<_XDimension> GT 0]
    G38.7 x[#<_XDimension>/2+5] 
    G38.7 z[-1*[#<Clearance_Height>+#<Height>]]  

    (Side 1 Probing)
    $SD/Run=Probing/ProbeXNeg.nc
    G4 p0.5 (wait)
    #<side1>=#<_Result> (Setting side1 results to the X probe result)
    G38.7 x1  F1500
    G38.7 z[#<Clearance_Height>+#<Height>]   F1500
    G38.7 x[-1*[#<_XDimension>+6]] 
    G38.7 z[-1*[#<Clearance_Height>+#<Height>]] 

    (Side 2 Probing)
    $SD/Run=Probing/ProbeXPos.nc
    G4 p0.5 (wait)
    #<side2>=#<_Result> (Setting side2 results to the X probe result)
    #<Xcenter>=[[#<side1>-#<side2>]/2+#<side2>]
    G38.7 x-1 F500
    G38.7  z[#<Clearance_Height>+#<Height>]  F1500

    G90 G53 G1 x[#<Xcenter>] f1500
    G10 L20 P[#<Coordinate>-53]  X0 (Setting X0) 
o102 endif

o102 if[#<_YDimension> GT 0]
    G38.7 y[[#<_YDimension>/2]+5]  F1500
    G91 G38.7 z[-1*[#<Clearance_Height>+#<Height>]]

    (Side 3 Probing)
    $SD/Run=Probing/ProbeYNeg.nc
    G4 p0.5 (wait)
    #<side3>=#<_Result> (Setting side3 results to the Y probe result)
    G38.7 y1 F500
    G38.7 z[#<Clearance_Height>+#<Height>] F1500
    G38.7 Y[-1*[#<_YDimension>+6]] 
    G38.7 z[-1*[#<Clearance_Height>+#<Height>]] 
    G4 0.5 (wait)

    (Side 4 Probing)
    $SD/Run=Probing/ProbeYPos.nc
    G4 p0.5 (wait)
    #<side4>=#<_Result> (Setting side4 results to the Y probe result)
    #<Ycenter>=[[#<side3>-#<side4>]/2+#<side4>]
    G38.7  Y-1  F500
    G38.7 Z [#<Clearance_Height>+#<Height>]  F1500  
    G90 G53 G1 Y[#<Ycenter>] f1500
    G10 L20 P[#<Coordinate>-53]  Y0 (Setting Y0)
o102 endif

G90 G53 G1 Z-5 F1500
g91
m30

