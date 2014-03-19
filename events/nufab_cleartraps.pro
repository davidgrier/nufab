;+
; NAME:
;    nufab_cleartraps
;
; PURPOSE:
;    Remove all traps from trapping pattern.
;
; CATEGORY:
;    Hardware control
;
; CALLING SEQUENCE:
;    nufab_cleartraps, state
;
; INPUTS:
;    state: nufab state hash.
;
; SIDE EFFECTS:
;    Clears all traps in running nufab session
;
; EXAMPLE:
; IDL> s = getnufab()
; IDL> nufab_cleartraps, s
;
; MODIFICATION HISTORY:
; 12/20/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

;;;;;
;
; nufab_cleartraps
;
pro nufab_cleartraps, s

COMPILE_OPT IDL2, HIDDEN

if ~isa(s, 'hash') then $
   return

if s.haskey('trappingpattern') then $
   s['trappingpattern'].remove, /all
end
