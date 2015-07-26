;+
; NAME:
;    nufab_object_cleanup
;
; PURPOSE:
;    Utility routine for nufab_widget objects
;
; MODIFICATION HISTORY:
; 03/01/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
pro nufab_object_cleanup, widget_id

  COMPILE_OPT IDL2, HIDDEN

  widget_control, widget_id, get_uvalue = owidget
  owidget.cleanup, widget_id
end
