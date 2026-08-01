(Sync ETS Offset for ATC)
(Runs automatically after workpiece Z is probed)

#<probelength> = 80
#<Offset> = -1.6

(Retract to safe Z)
G90 G53 G0 Z-1

(Move to ETS X/Y coordinates using firmware variables)
G53 G0 X[#<_etsx>] Y[#<_etsy>]

(Rapid down to just above the ETS)
G53 G38.3 Z[#<_etsz> + #<probelength>] F3500

(Probe the ETS - Fast then Slow)
G91 G38.2 Z-20 F#<ProbeFeed>
G1 Z2 F#<ProbeFeed>
G38.2 Z-5 F40
G4 P0.25

(Calculate and store the ATC offset for C++)
#<_probeetsoffset> = [#5063 + #<Offset>]

(Retract back to safe height)
G90 G53 G0 Z-1