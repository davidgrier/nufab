;+
; NAME:
;    getnufab
;
; PURPOSE:
;    Returns the base state structure of a running instance of FAB.
;    This provides access to all of the subsystems of FAB, including
;    objects controlling its hardware and defining its traps.
;
; CATEGORY:
;    Holographic optical trapping, video microscopy, instrument control
;
; CALLING SEQUENCE:
;    s = getnufab()
;
; INPUTS:
;    None
;
; OUTPUTS:
;    s: hash() of the running system's state.
;
; COMMON BLOCKS:
;    managed: Reads data from the common block used by XMANAGER to
;       manage the widget hierarchy in FAB.
;
; MODIFICATION HISTORY:
; 10/04/2011 Written by David G. Grier, New York University.
; 12/25/2013 Updated for nufab
; 
; Copyright (c) 2011-2013 David G. Grier
;-
function getnufab

common managed, ids, names, modalList

nmanaged = n_elements(ids)
if (nmanaged lt 1) then begin
   message, 'nufab is not running', /inf
   return, hash()
endif

w = where(names eq 'nufab', ninstances)
if ninstances ne 1 then begin
   message, 'nufab is not running', /inf
   return, hash()
endif

widget_control, ids[w], get_uvalue = s

return, s
end
