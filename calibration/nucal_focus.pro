function nucal_focus_spotsize, s

COMPILE_OPT IDL2, HIDDEN

a = nufab_snap(s)
ndx = where(median(a, 7) gt 32, count)
if count lt 1 then $
   return, 1000.

mass = a[ndx]
totalmass = total(mass)
xy = array_indices(a, ndx)
mx = total(xy[0]*mass)/totalmass
my = total(xy[1]*mass)/totalmass
xy[0, *] -= mx
xy[1, *] -= my

rg = sqrt(mean(total(xy^2, 1)))

return, rg
end

pro nucal_focus, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

s['trappingpattern'].clear

stage = s['stage']
z0 = stage.z
zmin = z0
rmin = 1000.
for z = z0-20, z0+20, 2 do begin
   stage.z = z
   wait, 0.25
   if (rg = nucal_focus_spotsize(s)) lt rmin then begin
      rmin = rg
      zmin = stage.z
   endif
endfor
stage.z = zmin

end
