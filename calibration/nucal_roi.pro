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
; 06/08/2015 DGG Use camera delay.
;
; Copyright (c) 2014-2015 David G. Grier
;-
pro nucal_roi, event

  COMPILE_OPT IDL2, HIDDEN

  if isa(event, 'hash') then $
     s = event $
  else $
     widget_control, event.top, get_uvalue = s
  
;if ~nucal_setup(s) then $
;   return

  if s.haskey('error') then $
     return

  ; region of interest near central spot
  rc = s['cgh'].rc
  dn = 0.05*min(s['camera'].dimensions)
  m0 = long(rc[0] - dn)
  m1 = long(rc[0] + dn)
  n0 = long(rc[1] - dn)
  n1 = long(rc[1] + dn)

  slm = s['slm']
  dim = slm.dimension
 ; threshold = 80
  threshold = 2.
  delay = 0.01
  scale = 30

  s['trappingpattern'].clear

  nufabsay, 'X 0', scale = scale
  phi = s['cgh'].data
  wait, delay
  a = float((nufab_snap(s))[m0:m1, n0:n1]) > 1.
  x = 0
  repeat begin
     phi[x++, *] = 0
     slm.data = phi
     wait, delay
     b = (nufab_snap(s))[m0:m1, n0:n1] / a
     delta = max(b)
     print, x, delta
  endrep until (delta gt threshold) || (x ge dim[0]/2)
  x0 = x

  s['trappingpattern'].clear
  nufabsay, 'X 1', scale = scale
  phi = s['cgh'].data
  wait, delay
  a = float((nufab_snap(s))[m0:m1, n0:n1]) > 1
  x = dim[0]-1
  repeat begin
     phi[x--, *] = 0
     slm.data = phi
     wait, delay
     b = (nufab_snap(s))[m0:m1, n0:n1] / a
     delta = max(b)
     print, x, delta
  endrep until (delta gt threshold) || (x le dim[0]/2)
  x1 = x

  s['trappingpattern'].clear
  nufabsay, 'Y 0', scale = scale
  phi = s['cgh'].data
  wait, delay
  a = float((nufab_snap(s))[m0:m1, n0:n1]) > 1
  y = 0
  repeat begin
     phi[*, y++] = 0
     slm.data = phi
     wait, delay
     b = (nufab_snap(s))[m0:m1, n0:n1] / a
     delta = max(b)
     print, y, delta
  endrep until (delta gt threshold) || (y ge dim[1]/2)
  y0 = y

  s['trappingpattern'].clear
  nufabsay, 'Y 1', scale = scale
  phi = s['cgh'].data
  wait, delay
  a = float((nufab_snap(s))[m0:m1, n0:n1]) > 1
  y = dim[1]-1
  repeat begin
     phi[*, y--] = 0
     slm.data = phi
     wait, delay
     b = (nufab_snap(s))[m0:m1, n0:n1] / a
     delta = max(b)
     print, y, delta
  endrep until (delta gt threshold) || (y le dim[1]/2)
  y1 = y

  s['trappingpattern'].clear
  
  s['cgh'].roi = [x0, y0, x1, y1]
end
