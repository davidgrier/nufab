;+
; NAME:
;    nuevent_wheel
;
; PURPOSE:
;    Wheel events translate traps along the axial direction
;
; CALLING SEQUENCE:
;    nuevent_wheel, event
;
; INPUTS:
;    event: Event structure generated by nuFab
;
; SIDE EFFECTS:
;    Moves optical traps
;
; MODIFICATION HISTORY:
; 01/29/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_wheel, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = s
  group = nuevent_foundtrap(s, [event.x, event.y], /movable)
  if isa(group) then $
     group.moveby, [0., 0., float(event.clicks)]
  s['wtraps'].refresh
end
