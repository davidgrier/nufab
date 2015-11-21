; docformat = 'rst'

;+
; Retrieves the calibrated coordinates of SLM pixels from a running
; instances of nufab.
;
; :Requires:
;    getnufab
;
; :Returns:
;    Returns an anonymous structure whose elements are coordinate
;    arrays with the shape `float(nx,ny)`, where nx and ny are the
;    dimensions of the SLM.
;    kx: x-coordinate of each pixel
;    ky: y-coordinate of each pixel
;    kr: radial coordinate of each pixel, relative to the optical axis
;    theta: polar angle around optical axis
;
; :Example:
;    IDL> g = getnufab_geometry()
;
; :Author:
;    David G. Grier, New York University
;
; :Copyright:
;    Copyright (c) 2015 David G. Grier
;-
function getnufab_geometry

  COMPILE_OPT IDL2, HIDDEN

  s = getnufab()
  if s.count() eq 0 then $
     return, {kx:0., ky:0., kr:0., theta:0.}

  cgh = s['cgh']
  return, cgh.geometry()
end

