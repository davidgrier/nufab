;+
; NAME:
;    nucal_stage_tocleaning
;
; PURPOSE:
;    Move stage to cleaning bay
;
; MODIFICATION HISTORY:
; 02/12/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nucal_stage_tocleaning, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

s['traplaser'].shutter = 0
s['imagelaser'].shutter = 0

stage = s['stage']
stage.z = 10000L                ; back off 1 mm (0.1 um resolution)
stage.x = long(27000.)          ; shift by 1 inch (1 um resolution)
end
