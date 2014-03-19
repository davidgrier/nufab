;+
; NAME:
;    fab_nl
;
; PURPOSE:
;    Provides newline character
;
; CATEGORY:
;    Utility
;
; CALLING SEQUENCE:
;    nl = fab_nl()
;
; OUTPUTS:
;    nl: string(10b)
;
; MODIFICATION HISTORY
; 12/30/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

function fab_nl

COMPILE_OPT IDL2, HIDDEN

return, string(10b)
end
