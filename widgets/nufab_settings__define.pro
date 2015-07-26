;+
; NAME:
;    nufab_settings
;
; PURPOSE:
;    Control panel for adjusting instrument settings.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
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
; nufab_settings::Create
;
pro nufab_settings::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  wid = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                    TITLE = self.title, $
                    RESOURCE_NAME = 'NufabProperty')
  void = widget_propertysheet(wid, value = self.object, /frame)
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
            title: '', $
            object: obj_new() $
           }
end
