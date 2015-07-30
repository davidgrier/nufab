;+
; NAME:
;    nufab_settings
;
; PURPOSE:
;    Control panel for adjusting instrument settings.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
; 07/30/2015 DGG register self as listener to component object.
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; nufab_settings::handleEvent
;
pro nufab_settings::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  if (event.type eq 0) then begin
     value = widget_info(event.id, COMPONENT = event.component, $
                         PROPERTY_VALUE = event.identifier)
     event.component -> SetPropertyByIdentifier, event.identifier, value
  endif
end

;;;;;
;
; nufab_setings::Refresh
;
pro nufab_settings::Refresh

  COMPILE_OPT IDL2, HIDDEN

  if self.wid gt 0 then $
     widget_control, self.wid, /refresh_property
end

;;;;;
;
; nufab_settings::Create
;
pro nufab_settings::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  wid = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                    TITLE = self.title, $
                    RESOURCE_NAME = 'NufabProperty')
  self.wid = widget_propertysheet(wid, value = self.object, /frame)
  self.widget_id = wid
end

;;;;;
;
; nufab_settings::Init()
;
; Create the widget layout and set up the callback
; for adjusting instrument settings.
;
function nufab_settings::Init, wtop, object, title

  COMPILE_OPT IDL2, HIDDEN

  self.object = object
  self.object.listener = self
  self.title = title
  return, self.nufab_widget::Init(wtop)
end

;;;;;
;
; nufab_settings__define
;
pro nufab_settings__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_settings, $
            inherits nufab_widget, $
            wid: 0L, $
            title: '', $
            object: obj_new() $
           }
end
