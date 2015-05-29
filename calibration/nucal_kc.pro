;+
; NAME:
;    nucal_kc
;
; PURPOSE:
;    Determine the position of the optical axis on the face of the SLM
;
; MODIFICATION HISTORY:
; 01/24/2014 Written by David G. Grier, New York University
; 04/08/2014 DGG Assume setup is handled already.
;
; Copyright (c) 2014 David G. Grier
;-

;;;;;
;
; nucal_kc_setgain
;
pro nucal_kc_setgain, s, xy

COMPILE_OPT IDL2, HIDDEN

camera = s['camera']
repeat begin
   ogain = camera.gain
   camera.gain = ogain+1
   a = nufab_snap(s, delay = 0.2)
   rad = 100
   max = max(a[xy[0]-rad:xy[0]+rad, xy[1]-rad:xy[1]+rad])
endrep until max gt 200 || camera.gain eq ogain

end

;;;;;
;
; nucal_kc_findtrap
;
; Locate local maximum in the vicinity of the requested position
;
function nucal_kc_findtrap, s, xy

COMPILE_OPT IDL2, HIDDEN

a = nufab_snap(s, delay = 0.2)
;b = bpass(a, 2, 21)
b = median(a, 7)
rad = 100
b = b[xy[0]-rad:xy[0]+rad, xy[1]-rad:xy[1]+rad]
;q = feature(b, 11, pickn = 1, count = count, /quiet)

q = fastfeature(b, 32, pickn = 1, count = count)

if count lt 1 then begin
   s['error'] = 'NUCAL_KC_FINDTRAP: no trap image in range'
   q = [0, 0]
endif

return, q[0:1]
end

;;;;;
;
; nucal_kc_trapdelta
;
; Measure lateral displacement of trap due to axial translation
;
function nucal_kc_trapdelta, s, trap, rc

COMPILE_OPT IDL2, HIDDEN

trap.rc = rc
trap.zc = -10 & trap.project
rm = nucal_kc_findtrap(s, rc)
trap.zc = 10 & trap.project
rp = nucal_kc_findtrap(s, rc)

return, rp - rm
end

;;;;;
;
; nucal_kc_delta
;
; Measure lateral displacement of trapping pattern due
; to axial translation
;
function nucal_kc_delta, s

COMPILE_OPT IDL2, HIDDEN

s['trappingpattern'].clear
dim = s['camera'].dimensions
rc = [0.25*dim[0], 0.25*dim[1]]
trap = fabtweezer(rc = rc)
group = fabtrapgroup(trap, rs = rc, state = 0)
s['trappingpattern'].add, group

nucal_kc_setgain, s, rc

delta  = nucal_kc_trapdelta(s, trap, rc)
delta += nucal_kc_trapdelta(s, trap, [0.75*dim[0], 0.25*dim[1]])
delta += nucal_kc_trapdelta(s, trap, [0.75*dim[0], 0.75*dim[1]])
delta += nucal_kc_trapdelta(s, trap, [0.25*dim[0], 0.75*dim[1]])

return, delta
end

;;;;;
;
; nucal_kc
;
pro nucal_kc, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

if s.haskey('error') then $
   return

;if ~nucal_setup(s) then $
;   return

ogain = s['camera'].gain

kc = s['cgh'].kc
dk = 50
npts = 5

;;; Scan along x to minimize total displacement along x
kx = findgen(npts) - npts/2 + kc[0]
ky = kc[1]
delta = fltarr(npts)
for n = 0, npts-1 do begin
   s['cgh'].kc = [kx[n], ky]
   delta[n] = (nucal_kc_delta(s))[0]
endfor
f = poly_fit(kx, delta, 1)
kc[0] = -f[0]/f[1]

;;; Scan along y to minimize total displacement along y
kx = kc[0]
ky = findgen(npts) - npts/2 + kc[1]
for n = 0, npts-1 do begin
   s['cgh'].kc = [kx, ky[n]]
   delta[n] = (nucal_kc_delta(s))[1]
endfor
f = poly_fit(ky, delta, 1)
kc[1] = -f[0]/f[1]

if s.haskey('error') then $
   return
   
s['cgh'].kc = kc
s['camera'].gain = ogain
s['trappingpattern'].clear

if s.haskey('propertysheet') then $
   widget_control, s['propertysheet'], /refresh_property

end
