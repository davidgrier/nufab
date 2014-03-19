;+
; NAME:
;    nuevent_trapremove
;
; PURPOSE:
;    Removes the selected trap
;
;    Left and middle buttons delete a trap.
;    Right button removes a trap from its group without
;    destroying it.
;
; MODIFICATION HISTORY:
; 01/30/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_trapremove, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s

xy = [event.x, event.y]

if event.press ne 4 then begin  ; Delete a trap
   nuevent_clearselection, s
   group = nuevent_foundtrap(s, xy)  ; ... any trap is fair game
   if isa(group) then begin          ; ... found one
      obj_destroy, group             ; ... destroy it
      s['trappingpattern'].project   ; ... update CGH and representation
      fab_properties, s, /reload
   endif
endif else begin                ; Remove a trap from a group
   group = nuevent_foundtrap(s, xy, trap = trap, /movable)
   if isa(group) then begin                  ; found a group
      if group.count() ge 2 then begin       ; ... if it has enough traps
         group.state = 4                     ; ... then we're grouping traps
         s['action'] = 4 
         s['selected'] = group
         group.remove, trap     ; ... put this one in its own group
         s['trappingpattern'].add, fabtrapgroup(trap, state = 1)
      endif
   endif
endelse

end
