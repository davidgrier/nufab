;+
; NAME:
;    nufab_phase
;
; PURPOSE:
;    Returns random phase value.
;
; CALLING SEQUENCE:
;    phase = nufab_phase(state)
;
; INPUTS:
;    state: state hash of running nufab process
;
; OUTPUTS:
;    phase: value between 0 and 2 pi.
;
; SIDE EFFECTS:
;    Updates the random number sequence in nufab.
;
; MODIFICATION HISTORY:
; 12/21/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

function nufab_phase, s

COMPILE_OPT IDL2, HIDDEN

if ~isa(s, 'hash') then $
   return, 0.

if ~s.haskey('seed') then $
   return, 0.

seed = s['seed']
phase = 2.*!pi*randomu(seed, 1)
s['seed'] = seed

return, phase
end
