;+
; NAME:
;    fabslm_fake
;
; PURPOSE:
;    Object class for transmitting computed holograms to a
;    simulated spatial light modulator on the primary X display
;
; CATEGORY:
;    Computational holography, hardware control, object graphics
;
; PROPERTIES:
;    DATA: Byte-valued hologram
;        [ GS]
;
;    DEVICE_NAME: Name of the X Window display.
;        [IG ]
;
;    DIMENSIONS: dimensions of the SLM.
;        [IG ]
;
; METHODS:
;    SetProperty
;    GetProperty
;
; MODIFICATION HISTORY:
; 01/26/2011 Written by David G. Grier, New York University
; 02/02/2011 DGG removed RC and MAT calibration constants into
;    the definition of the fabCGH class.  Added COMPILE_OPT.
; 11/04/2011 DGG updated object creation syntax.
; 12/09/2011 DGG inherit IDL_Object.  Remove KC.  Documentation fixes.
; 05/04/2012 DGG check that DIM is a number in Init
; 12/20/2013 DGG overhauled for new fab version
;
; Copyright (c) 2011-2013, David G. Grier
;-

;;;;;
;
; fabslm_fake::Init()
;
function fabslm_fake::Init, _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

return, self.fabslm_monitor::init(_extra = re, /primary)
end

;;;;;
;
; fabslm_fake__define
;
pro fabslm_fake__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabslm_fake, $
          inherits fabslm_monitor $
         }
end
