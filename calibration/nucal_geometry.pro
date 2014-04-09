;+
; NAME:
;    nucal_geometry
;
; PURPOSE:
;    Perform all of the geometric calibration operations
;
; MODIFICATION HISTORY:
; 04/08/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nucal_geometry, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

if ~nucal_setup(s) then $
   return

nucal_rc, s                     ; coordinates of optical axis on camera
nucal_xy, s                     ; rotation and scaling of camera plane
nucal_kc, s                     ; coordinates of optical axis on SLM
nucal_roi, s                    ; area of SLM in input pupil

end
