;+
; NAME:
;    nufab_info
;
; PURPOSE:
;    Control panel for displaying information
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; nufab_info::GetProperty
;
;;;;;
;
; nufab_info::SetProperty
;

;;;;;
;
; nufab_info::Create
;
pro nufab_info::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  style = {NOEDIT: 1, FRAME: 1, COLUMN: 1,  XSIZE: 12, YSIZE: 1}
  
  winfo = widget_base(wtop, /ROW, RESOURCE_NAME = 'Nufab')

  void = cw_field(winfo, title = 'lambda [um]   ', _EXTRA = style, $
                  VALUE = string(self.wavelength, format = '(F5.3)'))
  void = cw_field(winfo, title = 'mpp [um/pixel]', _EXTRA = style, $
                  VALUE = string(self.mpp, format = '(F5.3)'))

  self.widget_id = winfo
end

;;;;;
;
; nufab_info::Init()
;
; Create the widget layout and set up the timer
; for occasional updating of properties
;
function nufab_info::Init, wtop, state

  COMPILE_OPT IDL2, HIDDEN

  self.wavelength = state['imagelaser'].wavelength
  self.mpp = state['camera'].mpp
  
  if ~self.Nufab_Widget::Init(wtop) then $
     return, 0B

  return, 1B
end

;;;;;
;
; nufab_info__define
;
pro nufab_info__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {Nufab_Info, $
            inherits Nufab_Widget, $
            wavelength: 0., $
            mpp: 0., $
            temperature: 0. $
           }
end
