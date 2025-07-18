G4P1
o100 if [EXISTS[#<_probeetsoffset>]]
    o101 if [#<_probeetsoffset> NE 0]
        #<_ets_tool_first_z>=#<_probeetsoffset>
        #<_my_tlo_z>=[#5063 - #<_ets_tool_first_z>]
        G43.1Z#<_my_tlo_z>
        #<_probeetsoffset>=0
    o101 endif
o100 else
    #<_ets_tool_first_z>=[#5063]
    #<_my_tlo_z >=0
    #<_probeetsoffset>=0
o100 endif 