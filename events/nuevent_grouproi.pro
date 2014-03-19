;+
; NAME:
;    nuevent_grouproi
;
; PURPOSE:
;    Group traps that are selected within a region of interest
;
; USAGE:
;    nuevent_grouproi, state 
;
; INPUTS:
;    state: state of running nufab instance
;
; SIDE EFFECTS:
;    Eliminates existing groups and reconstitutes them as a combined group.
;
; MODIFICATION HISTORY: 
; 12/20/2013 Written by David G. Grier, New York University
; 01/30/2014 DGG revised for updated event handler
;
; Copyright (c) 2013-2014 David G. Grier
;-
pro nuevent_grouproi, s

COMPILE_OPT IDL2, HIDDEN

if ~s.haskey('roi') then $ ; no ROI: nothing to do
   return

groups = s['trappingpattern'].get(/all, isa = 'fabtrapgroup')
foreach group, groups do begin
   if ~isa(group, 'fabtrapgroup') then begin ; ... not ROI itself
      if ~s.haskey('selected') then $
         s['action'] = 1
      break
   endif
   group.getproperty, data = d
   found = s['roi'].containspoints(d[0:1,*])
   if min(found) gt 0 then begin ; add this group to the active group
      if s.haskey('selected') then begin
         s['selected'].add, group 
      endif else begin          ; this group becomes the active group
         group.setproperty, state = 4
         s['selected'] = group
      endelse
   endif
endforeach

; clean up resources
obj_destroy, s['roi']
s.remove, 'roi'

end
