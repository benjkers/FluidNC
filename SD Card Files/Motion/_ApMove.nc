(_ApMove.nc  --  lives in /Motion/ on the SD card)
(One positioning move, protected or not. Called only by _Approach.nc.)
()
(This exists to keep _Approach.nc FLAT. Each of its three legs needs the)
(protected/unprotected choice, and combining that with the leg's own distance)
(test would mean either nested o-blocks or an AND -- neither of which any)
(macro on this card currently uses, so neither is proven on this firmware.)
(Nesting one macro file inside another IS proven: _SafeMove.nc is already)
(called that way from the probing macros. So the choice lives here, in two)
(flat conditions, and _Approach.nc just names a point.)

(=================== INPUTS ===================)
(  _am_x _am_y _am_z     target, WORK coordinates)
(  _ap_protected         non-zero routes the move through _SafeMove.nc, which)
(                        makes it a G38.3 that stops on contact and then)
(                        CONFIRMS it arrived. Zero emits a plain G0.)

o2740 if [EXISTS[#<_ap_protected>] EQ 0]
#<_ap_protected>=0.000
o2740 endif

o2741 if [#<_ap_protected> GT 0]
#<_sm_x>=#<_am_x>
#<_sm_y>=#<_am_y>
#<_sm_z>=#<_am_z>
$SD/Run=/Probing/_SafeMove.nc
o2741 endif

o2742 if [#<_ap_protected> EQ 0]
G90
G0 X#<_am_x> Y#<_am_y> Z#<_am_z>
o2742 endif
