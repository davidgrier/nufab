;+
; NAME:
;    nucal_xy
;
; PURPOSE:
;    Calibrate in-plane coordinate system for FAB
;
; NOTES:
; Should be possible to run this repeatedly to improve
; calibration.  In fact, second run makes things worse.
;
; MODIFICATION HISTORY:
; 02/01/2011 Written by David G. Grier, New York University
; 10/04/2011 DGG Force fab_snap to return a grayscale image.
; 11/20/2011 DGG Exclude central spot from search for projected trap.
; 12/28/2013 DGG Overhauled for new fab implementation
; 01/14/2014 DGG Scale SLM pixels rather than trap positions.
; 04/08/2014 DGG Assume setup is handled already.
; 04/21/2014 DGG Seek traps in normalized image
;
; Copyright (c) 2011-2014 David G. Grier
;-
;;;;;
;
; NUCAL_XY_FIND
;
; Find the position of the brightest point on the 
; normalized image
;
function nucal_xy_find, s

COMPILE_OPT IDL2, HIDDEN

a = float(nufab_snap(s, delay = 0.2)) ; acquire image
a /= s['xy_bg']

; candidate features are (at least 5 times) brighter 
; than the background
q = fastfeature(a, 5, pickn = 1, count = count)

if count lt 1 then begin
   s['error'] = 'NUCAL_XY_FIND: found no features'
   return, [0, 0]
endif

return, q[0:1]
end

;;;;;;
;
; NUCAL_XY
;
; Calibrate the NUFAB coordinate system so that placement of traps
; is consistent with screen coordinates.
;
pro nucal_xy, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

;if ~nucal_setup(s) then $
;   return

if s.haskey('error') then $
   return

cgh = s['cgh']
;;; Save present calibrations in case this process fails
oq = cgh.q
oaspect_ratio = cgh.aspect_ratio
oangle = cgh.angle

;;; Clear the screen
s['trappingpattern'].clear

;;; acquire background image
s['xy_bg'] = float(nufab_snap(s, delay = 0.2)) > 1

;;; Place a trap at calibration points, and compare
;;; measured positions with specified positions
rc = cgh.rc
trap = fabtrapgroup(fabtweezer(rc = rc), rs = rc, state = 0)
s['trappingpattern'].add, trap

;;; coordinates of calibration points
npts = 5
dim = s['camera'].dimensions
x = rc[0] + [-2:2] * dim[0]/(2.*npts)
y = rc[1] + [-2:2] * dim[1]/(2.*npts)

;;; calibrate along x:
p = findgen(2, npts)
for n = 0, npts-1 do begin
   trap.moveto, [x[n], y[0], 0.], /override
   p[*, n] = nucal_xy_find(s)
endfor
f1 = poly_fit(x, p[0, *], 1)
f2 = poly_fit(x, p[1, *], 1)

;;; calibrate along y:
p *= 0.
for n = 0, npts-1 do begin
   trap.moveto, [x[0], y[n], 0.], /override
   p[*, n] = nucal_xy_find(s)
endfor
f3 = poly_fit(y, p[0, *], 1)
f4 = poly_fit(y, p[1, *], 1)

if s.haskey('error') then begin
   message, s['error'], /inf
   s.remove, 'error'
   return
endif

;;; adjust geometry
q = sqrt(f1[1]^2 + f2[1]^2)
cgh.q /= q
cgh.aspect_ratio /= sqrt(f3[1]^2 + f4[1]^2)/q
cgh.angle -= 90./!pi * (atan(f2[1], f1[1]) - atan(f3[1], f4[1]))

;;; test for correctness
;rc = [100, 100, 0]
;trap.moveto, rc, /override
;r = nucal_xy_find(s)
;if sqrt(total((r - rc)^2)) gt 0.01*min(dim) then begin
;   s['error'] = 'NUCAL_XY: Calibration out of tolerance'
;   cgh.q = oq
;   cgh.aspect_ratio = oaspect_ratio
;   cgh.angle = oangle
;endif

trap.state = 1.
s.remove, 'xy_bg'

if s.haskey('propertysheet') then $
   widget_control, s['propertysheet'], /refresh_property

end
