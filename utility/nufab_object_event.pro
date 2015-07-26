;+
; NAME:
;    nufab_object_event
;
; PURPOSE:
;    Dispatches events from widget applications to objects
;    for event handling.
;
;    The base widget in any object-widget class must
;    1. declare this routine to be its EVENT_PRO,
;    2. have its UVALUE set to self,
;    3. expose a procedure method called handleEvent that will accept
;       the widget event and process it.
;
; MODIFICATION HISTORY:
; 2/14/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
pro nufab_object_event, event

  COMPILE_OPT IDL2, HIDDEN
  
  widget_control, event.handler, get_uvalue = owidget
  owidget.handleEvent, event
end
