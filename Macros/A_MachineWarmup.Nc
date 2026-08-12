#<loops>=10
#<spindle>=18000
#<feedx>=[#</axes/x/max_rate_mm_per_min>]  
#<feedy>=[#</axes/x/max_rate_mm_per_min>]
#<feedz>=[#</axes/z/max_rate_mm_per_min>]
#<feedb>=[#</axes/b/max_rate_mm_per_min>]
#<Xmax>=[#</axes/x/max_travel_mm>*-1]
#<Ymax>=-365
#<Zmax>=-135
#<i>=1

G91
G53 G0 Z0
G53 G1 X[#<Xmax>] Y-365 f500

o100 repeat[#<loops>]
m3 s[#<spindle>/#<loops>*#<i>]
G53 G1 X0 f[#<feedx>/#<loops>*#<i>]
G53 G1 Y0 f[#<feedy>/#<loops>*#<i>]
G53 G1 Z[#<Zmax>] f[#<feedz>/#<loops>*#<i>]
G53 G1 Z0 f[#<feedz>/#<loops>*#<i>]
G53 G1 B90 f[#<feedb>/#<loops>*#<i>]
G53 G1 B0 f[#<feedb>/#<loops>*#<i>]
G53 G1 X[#<Xmax>] f[#<feedx>/#<loops>*#<i>]
G53 G1 Y[#<Ymax>] f[#<feedy>/#<loops>*#<i>]
#<i>=[#<i>+1]
o100 endrepeat
m30;