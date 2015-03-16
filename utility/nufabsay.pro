;+
; NAME:
;    nufabsay
;
; PURPOSE:
;    Project traps to spell out words
;
; CATEGORY:
;    Utility, hardware control
;
; CALLING SEQUENCE:
;    nufabsay, text
;
; INPUTS:
;    text: string containing charaters to display
;
; KEYWORD PARAMETERS:
;    scale: number of screen pixels between adjacent traps
;        Default: text fills 80 percent of screen.
;
;    fuzz: random offset of pixels from grid.
;        Default: 10 percent of scale
;
; SIDE EFFECTS:
;    Projects optical tweezers on current nufab session.
;
; RESTRICTIONS:
;    Does nothing unless nufab is running
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
; 03/02/2015 DGG simplified bail-out condition.
;    Added didactic comments.
;
; Copyright (c) 2013 David G. Grier
;-

pro nufabsay, str, scale = scale, fuzz = fuzz

COMPILE_OPT IDL2

;; Get access to a running nuFab instance
s = getnufab()
if ~s.count() then return

;; Create a pattern of points corresponding
;; to "pixels" in rasterized text
if n_elements(fuzz) ne 1 then $
   fuzz = 0.1
p = textcoords(str, width, height, /center, fuzz = fuzz)

if n_elements(p) lt 2 then $
   return                       ; nothing to say!

;; Scale the pixel positions to fit into
;; nuFab's field of view
if n_elements(scale) ne 1 then begin
   dim = s['camera'].dimensions ; scale is set by camera
   scale = 0.8 * max(dim)/width
endif
p *= scale

;; Center the pixels over the center of
;; nuFab's trapping pattern
rc = s['cgh'].rc                ; CGH determines the center
p[0, *] += rc[0]
p[1, *] += rc[1]

;; Add these "pixels" to the trapping pattern
;; as a group of optical tweezers.
group = fabTrapGroup(state = 1) ; create the group of traps
npts = n_elements(p[0,*])
for n = 0, npts-1 do $                ; add each pixel to group
   group.add, fabTweezer(rc = p[*,n]) ; ... each at its own position
s['trappingpattern'].add, group       ; add the group to the pattern
s['trappingpattern'].project          ; project the pattern
   
;;; If we wanted to, we could move the group around with
;;; commands of the form
;;; IDL> group.moveto, rnew ; which moves group's center to rnew
;;; IDL> group.moveby, dr   ; which moves its center by dr
;;; where rnew and dr are 2- or 3-dimensional vectors with
;;; distances measured in screen pixels.
end
