;+
; NAME:
;    fabSLM
;
; PURPOSE:
;    Object class for transmitting computed holograms to a
;    spatial light modulator.
;
; CATEGORY:
;    Computational holography, hardware control, object graphics
;
; PROPERTIES:
;    DATA: Byte-valued hologram
;        [ GS]
;
;    DIMENSIONS: dimensions of the SLM
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
; fabSLM::SetProperty
;
; Set SLM properties
;
pro fabSLM::SetProperty, data = data

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabSLM::GetProperty
;
; Get SLM properties
;
pro fabSLM::GetProperty, dimensions = dimensions, $
                         data = data
                        
COMPILE_OPT IDL2, HIDDEN
    
if arg_present(dimensions) then $
   dimensions = self.dimensions

if arg_present(data) then $
   data = bytarr(self.dimensions)

end

;;;;;
;
; fabSLM::Init()
;
function fabSLM::Init, dimensions = dimensions

COMPILE_OPT IDL2, HIDDEN

self.dimensions = (isa(dimensions, /number, /array)) ? $
                  dimensions : long([512, 512])

return, 1B
end

;;;;;
;
; fabSLM::Cleanup
;
pro fabSLM::Cleanup

COMPILE_OPT IDL2, HIDDEN

; nothing to do

end

;;;;;
;
; fabSLM__define
;
pro fabSLM__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabSLM, $
          inherits IDL_Object, $
          dimensions:  [0L, 0] $
         }
end
