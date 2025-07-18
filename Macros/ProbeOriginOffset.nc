#<ets_x>= -14.500
#<ets_y>= -7.500
#<ets_z>= -260.000
#<probelength>=100
#<Offset>=-1.6
M0
G53 G0 Z-1
G53 G0 X[#<ets_x>] y[#<ets_y>]
G53 G38.7 Z[#<ets_z>+#<probelength>] F3500
$SD/Run=Probing/ProbeZ.nc
#<_probeetsoffset>=[#<_Result>+#<Offset>]
G53 G0 Z0