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
