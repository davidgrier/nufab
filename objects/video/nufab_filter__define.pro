;+
; NAME:
;    nufab_filter
;
; PURPOSE:
;    Base class for video filters
;
; PROPERTIES:
; [IGS] source: object reference to video source
; [ G ] data: video data from filter
;
; MODIFICATION HISTORY:
; 09/13/2015 Written by David G. Grier, New York University
;
; COPYRIGHT:
; Copyright (c) 2015 David G. Grier
;-
;;;;;
;
; nufab_filter::GetProperty
;
pro nufab_filter::GetProperty, data = data

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(data) then $
     data = source.data
end

;;;;;
;
; nufab_filter::SetProperty
;
pro nufab_filter::SetProperty, source = source

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(source) then $
     self.source = source
end

;;;;;
;
; nufab_filter::Init()
;
function nufab_filter::Init, source = source

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(source) then $
     self.source = source

  return, 1B
end

;;;;;
;
; nufab_filter__define
;
; Base object class for nufab video filters
;
pro nufab_filter__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_filter, $
            inherits IDL_Object, $
            source: obj_new() $
           }
end
