;+
; NAME:
;    nuevent_keyboard
;
; PURPOSE:
;    Process keyboard events, specifically keys associated with stage
;    motion.
;
; MODIFICATION HISTORY:
; 01/20/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
;;;;;
;
; nuevent_keyboard()
;
function nuevent_keyboard, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s

case event.key of
   5: velocity = -s['stage'].right           ; left arrow
   6: velocity = s['stage'].right            ; right arrow
   7: if (event.modifiers and 8) ne 0 then $ ; up arrow
      velocity = [0., 0., s['stage'].up] $
   else $
      velocity = s['stage'].forward
   8: if (event.modifiers and 8) ne 0 then $ ; up arrow
      velocity = [0., 0., -s['stage'].up] $
   else $
      velocity = -s['stage'].forward

   else: begin
      help, event
      return, event             ; pass back other keyboard events
   end
endcase

if isa(velocity, /array) then begin
   if event.press then begin
      if ~s.haskey('stage_moving') then begin
         if (event.modifiers and 1) ne 0 then $
            velocity *= s['stage'].fast
         if (event.modifiers and 2) ne 0 then $
            velocity *= s['stage'].slow
         s['stage_moving'] = 1
         s['stage'].velocity = velocity
         ; NOTE: add timed refresh to propertysheet
      endif
   endif else if event.release then begin
      s['stage'].velocity = [0., 0.]
      if s.haskey('stage_moving') then $
         s.remove, 'stage_moving'
      ; NOTE: cancel timed refresh to propertysheet
   endif
endif

return, 0                       ; do not return processed keyboard events

end
