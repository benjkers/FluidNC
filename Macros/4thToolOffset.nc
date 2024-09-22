#<ToolStetterX>=-20
#<ToolStetterY>=0
#<ToolStetterZ>=-140
#<ProbeDistance>=-120
#<BitSetterOffset>=-70.67

G21 
M5 M9
G90	
G49

G53 G0 z0
G53 G0 X[#<ToolStetterX>] Y[#<ToolStetterY>]
G4 P0
G53 G0 Z[#<ToolStetterZ>]

G59 G38.7 Z[#<ProbeDistance>] F200
M62 p1 
G91 G1 Z5 F200 
$SD/Run=Probing/ProbeZ.nc
M63 p1 
#<ToolZero>=#<_Result>
G4 P0
#<Height>=[#<ToolZero>-#<BitSetterOffset>]
D#<Height>
G90 G53 G0 Z[#<Height>]
G10 L20 P[#<Coordinate>-53] Z0
G90 G53 G0 Z0
M30