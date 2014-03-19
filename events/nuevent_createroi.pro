;+
; NAME:
;    nuevent_createroi
;
; PURPOSE:
;    Create a region of interest for selecting and grouping traps
;
;    Triggered by Control-Right Clicking on a blank part of the screen
;
; MODIFICATION HISTORY:
; 01/30/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_createroi, event

COMPILE_OPT IDL2, HIDDEN

if event.press ne 4 then $
   return

widget_control, event.top, get_uvalue = s

roi = nufab_roi(r0 = [event.x, event.y]) ; Create ROI
s['overlay'].add, roi                    ; ... show it in GUI
s['roi'] = roi                           ; ... use it to select traps
s['action'] = 4                          ; state 4: grouping
widget_control, event.id, /draw_motion_events

end
