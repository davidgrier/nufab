;+
; NAME:
;    nucal_roi
;
; PURPOSE:
;    Measure region of interest corresponding to the
;    illuminated region of the SLM
;
; MODIFICATION HISTORY:
; 01/22/2014 Written by David G. Grier, New York University
; 04/08/2014 DGG Assume setup is handled already.
;
; Copyright (c) 2014 David G. Grier
;-
pro nucal_roi, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

;if ~nucal_setup(s) then $
;   return

; region of interest near central spot
rc = s['cgh'].rc
dim = s['camera'].dimensions
dn = 0.05*min(s['camera'].dimensions)
m0 = long(rc[0] - dn)
m1 = long(rc[0] + dn)
n0 = long(rc[1] - dn)
n1 = long(rc[1] + dn)

slm = s['slm']
dim = slm.dimension
threshold = 80
delay = 0.01
scale = 30

s['trappingpattern'].clear

nufabsay, 'X 0', scale = scale
phi = s['cgh'].data
wait, delay
a = float((nufab_snap(s))[m0:m1, n0:n1])
x = 0
repeat begin
   phi[x++, *] = 0
   slm.data = phi
   wait, delay
   b = float((nufab_snap(s))[m0:m1, n0:n1])
   delta = total((b-a) gt 32)
endrep until delta gt threshold
x0 = x-2

s['trappingpattern'].clear
nufabsay, 'X 1', scale = scale
phi = s['cgh'].data
wait, delay
a = float((nufab_snap(s))[m0:m1, n0:n1])
x = dim[0]-1
repeat begin
   phi[x--, *] = 0
   slm.data = phi
   wait, delay
   b = float((nufab_snap(s))[m0:m1, n0:n1])
   delta = total((b-a) gt 32)
endrep until delta gt threshold
x1 = x+1

s['trappingpattern'].clear
nufabsay, 'Y 0', scale = scale
phi = s['cgh'].data
wait, delay
a = float((nufab_snap(s))[m0:m1, n0:n1])
y = 0
repeat begin
   phi[*, y++] = 0
   slm.data = phi
   wait, delay
   b = float((nufab_snap(s))[m0:m1, n0:n1])
   delta = total((b-a) gt 32)
endrep until delta gt threshold
y0 = y-2

s['trappingpattern'].clear
nufabsay, 'Y 1', scale = scale
phi = s['cgh'].data
wait, delay
a = float((nufab_snap(s))[m0:m1, n0:n1])
y = dim[1]-1
repeat begin
   phi[*, y--] = 0
   slm.data = phi
   wait, delay
   b = float((nufab_snap(s))[m0:m1, n0:n1])
   delta = total((b-a) gt 32)
endrep until delta gt threshold
y1 = y+1

s['trappingpattern'].clear

s['cgh'].roi = [x0, y0, x1, y1]

end
