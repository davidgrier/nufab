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
; 03/30/2015 DGG fire video timer during motion events to prevent
;    event pile-up.
; 02/04/2017 DGG only update video if video is playing.
;
; Copyright (c) 2014-2017 David G. Grier
;-
pro nuevent_motion, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = s
  xy = [event.x, event.y]

  if float(!version.release) eq 8.5 then $
     if s['video'].playing then s['video'].update

  case s['action'] of
     2: s['selected'].moveto, xy ; translating
     3: s['selected'].rotateto, xy ; rotating
     4: if s.haskey('roi') then $  ; creating ROI (grouping)
        s['roi'].r1 = xy
     else:
  endcase

  s['wtraps'].refresh
end
