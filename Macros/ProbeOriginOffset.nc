#<probelength>=80
#<Offset>=-1.6
M0
G53 G0 Z-1
G53 G0 X[#<_etsx>] y[#<_etsy>]
G53 G38.3 Z[#<_etsz>+#<probelength>] F3500
$SD/Run=Probing/ProbeZ.nc
#<_probeetsoffset>=[#<_Result>+#<Offset>]
G53 G0 Z0