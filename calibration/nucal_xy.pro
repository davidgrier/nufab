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
;
; Copyright (c) 2011-2014 David G. Grier
;-
;;;;;
;
; NUCAL_XY_FIND
;
; Find the position of the brightest point on the screen
; that is not the central spot
;
function nucal_xy_find, s

COMPILE_OPT IDL2, HIDDEN

wait, 0.1
a = nufab_snap(s) ; acquire image
a = median(a, 7)
q = fastfeature(a, 64, pickn = 2, count = count)
;b = bpass(a, 2, 21)
;q = feature(b, 21, pickn = pickn, count = count, /quiet)

if count lt 1 then begin
   s['error'] = 'no features'
   return, [0, 0]
endif

rc = s['cgh'].rc
delta = sqrt((q[0, *] - rc[0])^2 + (q[1, *] - rc[1])^2)
w = where(delta gt 20, count)

if count lt 1 then begin
   s['error'] = 'only central spot'
   return, [0, 0]
endif else if count eq 1 then begin
   return, q[0:1, w]
endif else begin
   m = max(q[2, *], ndx)
   return, q[0:1,ndx]
endelse

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

cgh = s['cgh']
;;; Save present calibrations in case this process fails
oq = cgh.q
oaspect_ratio = cgh.aspect_ratio
oangle = cgh.angle

;;; Place a trap at calibration points, and compare
;;; measured positions with specified positions
s['trappingpattern'].clear
rc = cgh.rc
trap = fabtrapgroup(fabtweezer(rc = rc), rs = rc, state = 0)
s['trappingpattern'].add, trap

;;; coordinates of calibration points
npts = 5
dim = s['camera'].dimensions
x = (findgen(npts) + 1.)/(npts + 1) * dim[0]
y = (findgen(npts) + 1.)/(npts + 1) * dim[1]

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
aspect_ratio = sqrt(f3[1]^2 + f4[1]^2)/q
angle = 90./!pi * (atan(f2[1], f1[1]) - atan(f3[1], f4[1]))

cgh.q /= q
cgh.aspect_ratio /= aspect_ratio
cgh.angle -= angle

trap.state = 1

; FIXME: Test for correctness
; place a trap, and make sure that the trap goes where intended
; if not, restore previous calibrations and throw an error
; cgh.q = oq
; cgh.aspect_ratio = oaspect_ratio
; cgh.angle = oangle
; s['error'] = 'NUCAL_XY: Could not find trap after calibration procedure'
; return

if s.haskey('propertysheet') then $
   widget_control, s['propertysheet'], /refresh_property

end
