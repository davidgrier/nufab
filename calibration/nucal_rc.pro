;+
; NAME:
;    nucal_RC
;
; PURPOSE:
;    Locate the optical axis in the camera's coordinate system
;
; MODIFICATION HISTORY:
; 01/28/2014 Written by David G. Grier, New York University
; 04/08/2014 DGG Assume setup is handled already.
; 09/17/2014 DGG Report error on failure.
;
; Copyright (c) 2014 David G. Grier
;-
pro nucal_rc, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

;if ~nucal_setup(s) then $
;   return

s['trappingpattern'].clear
a = nufab_snap(s)
a = median(a, 5)
q = fastfeature(a, 100, pickn = 1, count = count)
if count eq 1 then begin
   s['cgh'].rc = q[0:1] 
   if s.haskey('propertysheet') then $
      widget_control, s['propertysheet'], /refresh_property
endif else $
   s['error'] = 'could not locate central spot'

end
