;+
; NAME:
;    nuevent_motion
;
; PURPOSE:
;    Handle mouse motion events generated by the nuFab GUI.
;
; CALLING SEQUENCE:
;    nuevent_motion, event
;
; INPUTS:
;    event: event structure generated by nuFab
;
; OPERATION:
;    Dragging with the left mouse button translates a group of traps.
;
;    Dragging with the middle mouse button rotates a group of traps.
;
;    Dragging with the right mouse button extends the region of
;    interest for grouping traps.
;
; MODIFICATION HISTORY:
; 01/29/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_motion, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s
xy = [event.x, event.y]

case s['action'] of
   2: s['selected'].moveto, xy
   3: s['selected'].rotateto, xy
   4: if s.haskey('roi') then $
      s['roi'].r1 = xy
   else:
endcase
end
