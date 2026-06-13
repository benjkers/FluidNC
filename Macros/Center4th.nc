#<ClearanceHeight>=10
#<XOffset>=#5321
D#<XOffset>

G21 ;metric
M5   ;Stop spindle
G59 ; 4th axis work coordinates

#<P1X>=#<_x> (Setting Current X postiong from G53)
G38.7 z[-2*#<ClearanceHeight>] f200
G91 G1 Z2 f200
$SD/Run=Probing/ProbeZ.nc
#<P1Z>=#<_Result>
G38.7 z[#<ClearanceHeight>] F1000
G38.7 x[-1*#<P1X>*2] f1000
#<P2X>=#<_x>(Setting Current X postiong from G53)

G38.7 z[-2*#<ClearanceHeight>] f200
G91 G1 Z2 f200
$SD/Run=Probing/ProbeZ.nc
#<P2Z>=#<_Result>
G38.7 z[#<ClearanceHeight>] f1000
#<Height>=[#<P2Z>-#<P1Z>]
#<Distance>=[#<P1X>-#<P2X>]
#<AngleDeg>=[ATAN[#<Height>]/[#<Distance>]]
D#<AngleDeg>
D#<Distance>
D#<Height>
G38.7 B[#<AngleDeg>] f4000
G38.7 X[#<Distance>] f1000
G10 L20 P[#<Coordinate>-53] B0
G38.7 Z-100 F200
G1 z[#<ClearanceHeight>] f1000
G38.7 X15 f1000
G38.7 z[-1*#<ClearanceHeight>-[#<_Thickness>/2]] f1000
G59
#<HeightZ>=#<_z>

G59
$SD/Run=Probing/ProbeXNeg.nc
#<side1>=#<_Result>
G38.7 x1 f1000
G90 G53 G1 z0 f1000
G91 G59 G38.7 X[-2*[#<side1>-#<XOffset>]-10] f1000
G38.7  B180 f3000
G59
G38.7 z[#<HeightZ>-#<_z>] f1000


$SD/Run=Probing/ProbeXPos.nc
#<side2>=#<_Result>
G38.7 x-10 f200
G90 G53 G1 z0 f1000
G59 G38.7 B-180 f3000
#<Xcenter>=[[#<side1>-#<side2>]/2+#<side2>]
G90 G53 G1 x[#<Xcenter>] f3000
G10 L20 P[#<Coordinate>-53]  X0




