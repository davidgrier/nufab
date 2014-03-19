;+
; NAME:
;    fab_properties
;
; PURPOSE:
;    Create a propertysheet tailored for FAB objects
;
; NOTES:
; .Xdefaults:
; Idl*nuFAB*XmLabel*background: lightyellow
;
; MODIFICATION HISTORY:
; 04/11/2011 Written by David G. Grier, New York University
; 10/13/2011 DGG Fixed crash when last trap is deleted.
; 11/04/2011 DGG Minor fix to refresh method.
; 12/10/2011 DGG Added support for shutter properties.
;    Added COMPILE_OPT.
; 12/26/2013 DGG Overhauled for new fab implementation.
;
; Copyright (c) 2011-2013 David G. Grier
;-

;;;;;
;
; FAB_PROPERTIES_RELOAD
;
; Reload properties for an object that may have changed
;
pro fab_properties_reload, s

COMPILE_OPT IDL2, HIDDEN

if ~s.haskey('propertysheet') then return

widget_control, s['propertysheet'], get_value = obj
if ~isa(obj) or isa(obj, 'fabtrap') then begin
   traps = s['trappingpattern'].traps
   widget_control, s['propertysheet'], set_value = traps
endif

end

;;;;;
;
; FAB_PROPERTIES_REFRESH
;
; Refresh properties that may have changed for an existing object.
; Only motion events appear to require a refresh, and these
; only affect traps and the stage.
;
; NOTE: no perceived effect if one object is being displayed but
; another calls for a refresh event.
;
pro fab_properties_refresh, s

COMPILE_OPT IDL2, HIDDEN

if s.haskey('propertysheet') then begin
   widget_control, s['propertysheet'], get_value = obj
   if isa(obj, 'fabtrap') or isa(obj, 'fabstage') then $
      widget_control, s['propertysheet'], /refresh_property
endif

end

;;;;;
;
; FAB_PROPERTIES_UPDATE
;
; Update object properties in response to user input
;
pro fab_properties_update, event

COMPILE_OPT IDL2, HIDDEN

if (event.type eq 0) then begin
   value = widget_info(event.ID, COMPONENT = event.component, $
                       PROPERTY_VALUE = event.identifier)
   event.component->SetPropertyByIdentifier, event.identifier, value
endif
 
end
 
;;;;;
;
; FAB_PROPERTIES_EVENT
;
; Handle resize events and quit button
;
pro fab_properties_event, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.id, get_uvalue = uvalue
case uvalue of
   'REFRESH': begin
      widget_control, event.top, get_uvalue = s
      widget_control, s['propertysheet'], /refresh_property
   end

   'DONE': widget_control, event.top, /destroy
;   else: begin
;      widget_control, event.top, get_uvalue = s
;      widget_control, s['propertysheet'], SCR_XSIZE = event.x, SCR_YSIZE = event.y
;   end
endcase

end

;;;;;
;
; FAB_PROPERTIES_CLEANUP
;
pro fab_properties_cleanup, wid

COMPILE_OPT IDL2, HIDDEN

widget_control, wid, get_uvalue = s
s.remove, 'propertysheet'
end

;;;;;
;
; FAB_PROPERTIES
;
; The main routine
;
pro fab_properties, nufab_event, refresh = refresh, reload = reload

COMPILE_OPT IDL2, HIDDEN

if keyword_set(refresh) then begin
   fab_properties_refresh, nufab_event
   return
endif

if keyword_set(reload) then begin
   fab_properties_reload, nufab_event
   return
endif

widget_control, nufab_event.top, get_uvalue = s
widget_control, nufab_event.id,  get_uvalue = uval

case uval of
   'TRAPS' : obj = s['trappingpattern'].traps.toarray()

   'CGH' : obj = s['cgh']

   'VIDEO': obj = s['video']

   'CAMERA' : obj = s['camera']

   'RECORDER' : obj = s['recorder']

   'STAGE' : obj = s['stage']

   'ILLUMINATION': obj = s['illumination']

   'TRAPLASER': obj = s['traplaser']

   'IMAGELASER': obj = s['imagelaser']

   'SHUTTER': obj = s['shutter']

   else: return
endcase

;;; Property sheet already realized -- display new object
if s.haskey('propertysheet') then begin
   widget_control, s['propertysheet'], set_value = obj
   return
endif

;;; Otherwise create a new property sheet
base = widget_base(title = 'nuFAB Properties', $
                   /column, resource_name = 'nuFAB', /tlb_size_event)

nentries = n_elements(obj)

prop = widget_propertysheet(base, value = obj, $
                            event_pro = 'fab_properties_update', $
                            /frame)

void = widget_button(base, value = 'Refresh', uvalue = 'REFRESH')
done = widget_button(base, value = 'DONE', uvalue = 'DONE')

s['propertysheet'] = prop
widget_control, base, set_uvalue = s, /no_copy
 
; Activate the widgets.
widget_control, base, /realize
 
xmanager, 'fab_properties', base, /no_block, $
          group_leader = nufab_event.top, $
          cleanup = 'fab_properties_cleanup'
end
