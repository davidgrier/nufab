;+
; NAME:
;    nuevent_trapadd
;
; PURPOSE:
;    Add an optical trap
;
;    Creates an optical trap at the selected position,
;    and adds it to the selected group if the right mouse
;    button caused the event.
;
; MODIFICATION HISTORY:
; 01/30/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_trapadd, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s

;;; Create a new trap where the user clicked
trap = fabtweezer(rc = [event.x, event.y], phase = nufab_phase(s))
group = fabtrapgroup(trap, state = 1)
s['trappingpattern'].add, group
nufab_annoy

;;; Right button adds the new trap to the currently selected group
if event.press eq 4 then begin
   if s.haskey('selected') then begin ; Add to existing group
      s['selected'].add, group
   endif else begin                   ; ... or create new active group
      group.state = 4
      s['selected'] = group
      s['action'] = 4
   endelse
endif else $ ; ... otherwise there is no selection
   nuevent_clearselection, s

fab_properties, s, /reload

end
