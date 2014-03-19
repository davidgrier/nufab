;+
; NAME:
;    fabstage_fake
;
; PURPOSE:
;    Implements a placeholder stage for systems that do not have
;    an actual stage attached.
;
; INHERITS:
;    fabstage
;
; MODIFICATION HISTORY:
; 03/04/2014 Written by David G. Grier, New York Univeristy
;
; Copyright (c) 2014 David G. Grier
;-
;;;;;
;
; fabstage_fake::Init()
;
function fabstage_fake::Init, _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~self.fabstage::Init(_extra = re) then $
   return, 0B

self.name = 'fabstage_fake '
self.description = 'Placeholder Stage '

return, 1B
end

;;;;;
;
; fabstage_fake__define
;
pro fabstage_fake__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabstage_fake, $
          inherits fabstage $
         }
end
