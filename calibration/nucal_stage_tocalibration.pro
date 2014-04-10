;+
; NAME:
;    nucal_stage_tocalibration
;
; PURPOSE:
;    Move stage to calibration bay
;
; MODIFICATION HISTORY:
; 04/09/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nucal_stage_tocalibration, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
    s = event $
else $
    widget_control, event.top, get_uvalue = s

stage = s['stage']

if stage.z lt 1000 then $
   stage.z = 1000
stage.x = 0
stage.z = 0

end
