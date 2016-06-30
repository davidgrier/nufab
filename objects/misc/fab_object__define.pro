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
;    HasProperty(property)
;        Determine whether or not the fab_object has a named property.
;        INPUT:
;            property: string or string array of property names
;        OUTPUT:
;            * 1 if the object has the named property and 0 otherwise.
;            * array of 1's and 0's if the input is an array of names.
;
;    HasMethod(method)
;        Determine whether or not the fab_object has a named method.
;        INPUT:
;            method: string containing property name
;        OUTPUT:
;            1 if the object has the named property and 0 otherwise.
;
;    fab_object::GetProperty
;    fab_object::SetProperty
;
; PROPERTIES:
; [ G ] ALL: ordered hash of all properties and their values
;
; [ G ] ADJUSTABLE: ordered hash of all adjustable properties, and
;       their current values
;
; [I S] LISTENER: Reference to an object that performs a task
;       any time the object's properties are updated with
;       SetProperty.  Listener object must have REFRESH method.
;
; MODIFICATION HISTORY:
; 12/15/2013 Written by David G. Grier, New York University
; 03/29/2014 DGG Added documentation.
; 02/15/2015 DGG Added HasProperty method.
; 03/30/2015 DGG Clean up IDLitComponent.
; 07/30/2015 DGG Implemented LISTENER capability.
; 06/30/2016 DGG Implemented HasMethod method.
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
; fab_object::HasMethod()
;
function fab_object::HasMethod, method

  COMPILE_OPT IDL2

  return, isa(method, 'string') ? obj_hasmethod(self, method) : 0B
end

;;;;;
;
; fab_object::SetProperty
;
pro fab_object::SetProperty, listener = listener, $
                             _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if obj_valid(listener) then begin
     if obj_hasmethod(listener, 'refresh') then $
        self.listener = listener $
     else begin
        message, 'Object class' + obj_class(listener) + ' does not have REFRESH method.', /inf
        message, 'Not adding as listener.', /inf
     endelse
  endif

  self.IDLitComponent::SetProperty, _extra = re

  if obj_valid(self.listener) then $
     self.listener.refresh
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
       if s && ~h then begin
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
; fab_object::Cleanup
;
pro fab_object::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.IDLitComponent::Cleanup
end

;;;;;
;
; fab_object::Init()
;
function fab_object::Init, listener = listener, $
                           _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.IDLitComponent::Init(_extra = re) then $
     return, 0B

  if obj_valid(listener) then $
     self.listener = listener

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
            inherits IDL_Object, $
            listener: obj_new() $
           }
end
