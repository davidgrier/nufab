;+
; NAME:
;    nuevent_clearselection
;
; PURPOSE:
;    De-select the currently selected group of traps for interactions
;    with the nuFab GUI.
;
; CALLING SEQUENCE:
;    nuevent_clearselection, s
;
; INPUTS:
;    s: state variable for running nuFab system.
;
; MODIFICATION HISTORY:
; 01/29/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
pro nuevent_clearselection, s

COMPILE_OPT IDL2, HIDDEN

if s.haskey('selected') then begin
   if isa(s['selected']) then $
      s['selected'].state = 1
   s.remove, 'selected'
endif
s['action'] = 1

end
