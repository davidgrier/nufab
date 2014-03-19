;+
; NAME:
;    fab_path
;
; PURPOSE:
;    Returns the current IDL search path as an array of strings
;
; CATEGORY:
;    Utility
;
; CALLING SEQUENCE:
;    path = fab_path()
;
; OUTPUTS:
;    path: string array
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

function fab_path

COMPILE_OPT IDL2, HIDDEN

path = strsplit(!PATH, path_sep(/search_path), /extract)

return, path
end
