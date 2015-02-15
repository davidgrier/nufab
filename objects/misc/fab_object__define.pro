;+
; NAME:
;    fab_object
;
; PURPOSE:
;    Base class for components of the nuFAB system.
;
; INHERITS:
;    IDL_Object
;    IDLitComponent
;
; METHODS:
;    fab_object::HasProperty(property)
;        Determine whether or not the fab_object has a named property.
;        INPUT:
;            property: string or string array of property names
;        OUTPUT:
;            * 1 if the object has the named property and 0 otherwise.
;            * array of 1's and 0's if the input is an array of names.
;             
;    fab_object::GetProperty

;    See documentation oof IDLitComponent and WIDGET_PROPERTYSHEET
;    to expose properties for property sheets.
;
; PROPERTIES:
;    ALL [ G ]: ordered hash of all properties and their values
;
;    ADJUSTABLE [ G ]: ordered hash of all adjustable properties, and
;        their current values
;
; MODIFICATION HISTORY:
; 12/15/2013 Written by David G. Grier, New York University
; 03/29/2014 DGG Added documentation.
; 02/15/2015 DGG Added HasProperty method.
;
; Copyright (c) 2013-2015 David G. Grier
;-
;;;;;
;
; fab_object::HasProperty()
;
function fab_object::HasProperty, property

  COMPILE_OPT IDL2, HIDDEN

  if isa(property, 'string') then $
     return, self.queryproperty(property)

  return, 0
end

;;;;;
;
; fab_object::GetProperty
;
pro fab_object::GetProperty, all = all, $
                             adjustable = adjustable, $
                             _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.IDLitComponent::GetProperty, _extra = re

if arg_present(all) then begin
   all = orderedhash()
   properties = self.queryproperty()
   foreach property, properties do begin
      self.getpropertyattribute, property, hide = h
      if ~h then begin
         if self.getpropertybyidentifier(property, value) then $
            all[property] = value $
         else $
            all[property] = 'not set'
      endif
   endforeach
endif

if arg_present(adjustable) then begin
   adjustable = orderedhash()
   properties = self.queryproperty()
   foreach property, properties do begin
      self.getpropertyattribute, property, sensitive = s, hide = h
      if s and ~h then begin
         if self.getpropertybyidentifier(property, value) then $
            adjustable[property] = value $
         else $
            adjustable[property] = 'not set'
      endif
   endforeach
endif

end

;;;;;
;
; fab_object::Init()
;
function fab_object::Init, _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~self.IDLitComponent::Init(_extra = re) then $
   return, 0B

self.name = 'fab_object '
self.description = 'Object '

return, 1B
end

;;;;;
;
; fab_object__define
;
pro fab_object__define

COMPILE_OPT IDL2, HIDDEN

struct = {fab_object, $
          inherits IDLitComponent, $
          inherits IDL_Object $
         }

end
