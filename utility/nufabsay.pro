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
;
; Copyright (c) 2013 David G. Grier
;-

pro nufabsay, str, scale = scale, fuzz = fuzz

COMPILE_OPT IDL2

s = getnufab()
if ~s.count() then return

if n_elements(fuzz) ne 1 then $
   fuzz = 0.1

p = textcoords(str, width, height, /center, fuzz = fuzz)
if n_elements(scale) ne 1 then begin
   dim = s['camera'].dimensions
   scale = 0.8 * max(dim)/width
endif
p *= scale
rc = s['cgh'].rc
p[0, *] += rc[0]
p[1, *] += rc[1]

if n_elements(p) ge 2 then begin
   group = fabTrapGroup(state = 1)
   npts = n_elements(p[0,*])
   for n = 0, npts-1 do $
      group.add, fabTweezer(rc = p[*,n])
   s['trappingpattern'].add, group
   s['trappingpattern'].project
endif
   
end
