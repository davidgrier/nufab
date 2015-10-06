;+
; NAME:
;    nufab_trapsettings
;
; PURPOSE:
;    Control panel for adjusting properties of traps.
;
; MODIFICATION HISTORY:
; 02/13/2015 Written by David G. Grier, New York University
; 07/30/2015 DGG register self as listener to component object.
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; nufab_trapsettings::handleEvent
;
pro nufab_trapsettings::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  if (event.type eq 0) then begin
     value = widget_info(event.id, COMPONENT = event.component, $
                         PROPERTY_VALUE = event.identifier)
     event.component -> SetPropertyByIdentifier, event.identifier, value
     self.object.project
  endif
end

;;;;;
;
; nufab_trappsettings::Reload
;
pro nufab_trapsettings::Reload

  COMPILE_OPT IDL2, HIDDEN

  traps = self.object.traps
  value = (traps.count() lt 1) ? $
          obj_new() : $
          traps.toarray()
  widget_control, self.wproperty, set_value = value
end
  
;;;;;
;
; nufab_trapsettings::Refresh
;
pro nufab_trapsettings::Refresh

  COMPILE_OPT IDL2, HIDDEN

  if self.wproperty gt 0 then $
     widget_control, self.wproperty, /refresh_property
end

;;;;;
;
; nufab_trapsettings::Create
;
pro nufab_trapsettings::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  geometry = widget_info(wtop, /geometry)
  wid = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                    TITLE = self.title, $
                    RESOURCE_NAME = 'NufabProperty')
  traps = self.object.traps
  if traps.count() lt 1 then traps = obj_new()
  self.wproperty = widget_propertysheet(wid, value = traps, $
                                        scr_xsize = geometry.scr_xsize, $
                                        scr_ysize = geometry.scr_ysize)
  self.widget_id = wid
end

;;;;;
;
; nufab_trapsettings::Init()
;
; Create the widget layout and set up the callback
; for adjusting instrument settings.
;
function nufab_trapsettings::Init, wtop, object, title

  COMPILE_OPT IDL2, HIDDEN

  self.object = object
  self.object.listener = self
  self.title = title
  return, self.nufab_widget::Init(wtop)
end

;;;;;
;
; nufab_trapsettings__define
;
pro nufab_trapsettings__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_trapsettings, $
            inherits nufab_widget, $
            wproperty: 0L, $
            title: '', $
            object: obj_new() $
           }
end
