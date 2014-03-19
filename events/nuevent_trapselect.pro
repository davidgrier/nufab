;+
; NAME:
;    nuevent_trapselect
;
; PURPOSE:
;    Select a trap for manipulation
;
;    Left button selects a trap for translation
;    Middle button selects a trap for rotation
;    Right button selects a trap for grouping
;
; MODIFICATION HISTORY:
; 01/30/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_trapselect, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s

;;; Look for movable trap near user's click
group = nuevent_foundtrap(s, [event.x, event.y], /movable)

;;; If no trap is selected, we might be creating a
;;; region of interest
if ~isa(group) then begin
   nuevent_createroi, event
   return
endif

case event.press of
   ;; [left button] TRANSLATE
   1: begin                           
      nuevent_clearselection, s
      group.state = 2           ; state 2: translating
      s['action'] = 2
      widget_control, event.id, /draw_motion_events
      s['selected'] = group
   end
   ;; [middle button] ROTATE
   2: begin                            
      nuevent_clearselection, s
      if group.count() ge 2 then begin
         group.state = 3        ; state 3: rotating
         s['action'] = 3
         group.setcenter        ; ... about its new center
         widget_control, event.id, /draw_motion_events
         s['selected'] = group
      endif
   end
   ;; [right button] GROUP
   4: begin                              
      if s.haskey('selected') then begin ; Add to existing group
         s['selected'].add, group
      endif else begin          ; ... or create new selection
         group.state = 4        ; state 4: grouping
         s['action'] = 4
         s['selected'] = group
      endelse
   end
endcase

end
