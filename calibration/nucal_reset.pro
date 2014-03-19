;+
; NAME:
;    nucal_reset
;
; PURPOSE:
;    Resets calibration constants of active nufab session
;
; CALLING SEQUENCE:
;    nucal_reset, arg
;
; INPUTS:
;    arg: Current state of the running nufab session,
;        or alternatively an event structure from nufab.
;
; SIDE EFFECTS:
;    Resets effective geometry for CGH calculations
;
; MODIFICATION HISTORY:
; 01/02/2014 Written by David G. Grier, New York University
; 01/25/2014 Reset RC also.
;
; Copyright (c) 2014 David G. Grier
;-

pro nucal_reset, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

s['cgh'].reset
s['cgh'].rc = s['camera'].dimensions/2
s['cgh'].zc = 0

if s.haskey('propertysheet') then $
   widget_control, s['propertysheet'], /refresh_property

end
