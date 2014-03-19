;;;;;
; 
; fablaser::SetProperty
;
;pro fablaser::SetProperty, _ref_extra = ex

;COMPILE_OPT IDL2, HIDDEN

;self.IDLitComponent::SetProperty, _extra = ex
;if isa(name, 'string') then $
;   self.name = name

;if isa(description, 'string') then $
;   self.description = description
;end

;;;;;
;
; fablaser::GetProperty
;
pro fablaser::GetProperty, wavelength = wavelength, $
                           mincurrent = mincurrent, $
                           maxcurrent = maxcurrent, $
                           minpower = minpower, $
                           maxpower = maxpower, $
                           keyswitch = keyswitch, $
                           emission = emission, $
                           shutter = shutter, $
                           power = power, $
                           current = current, $
                           temperature = temperature, $
                           _ref_extra = ex

COMPILE_OPT IDL2, HIDDEN

self.fab_object::GetProperty, _extra = ex

if arg_present(wavelength) then $
   wavelength = self.wavelength

if arg_present(mincurrent) then $
   mincurrent = self.mincurrent

if arg_present(maxcurrent) then $
   maxcurrent = self.maxcurrent

if arg_present(minpower) then $
   minpower = self.minpower

if arg_present(maxpower) then $
   maxpower = self.maxpower

if arg_present(keyswitch) then $
   keyswitch = self.keyswitch

if arg_present(emission) then $
   emission = self.emission

if arg_present(shutter) then $
   shutter = self.shutter

if arg_present(power) then $
   power = self.power

if arg_present(current) then $
   current = self.current

if arg_present(temperature) then $
   temperature = self.temperature

end

;;;;;
;
; fablaser::Init()
;
function fablaser::Init, wavelength = wavelength, $
                         mincurrent = mincurrent, $
                         maxcurrent = maxcurrent, $
                         minpower = minpower, $
                         maxpower = maxpower, $
                         keyswitch = keyswitch, $
                         emission = emission, $
                         shutter = shutter, $
                         power = power, $
                         temperature = temperature, $
                         _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if isa(wavelength, /number, /scalar) then $
   self.wavelength = float(wavelength) $
else begin
   message, 'must specify wavelength', /inf
   return, 0B
endelse

if ~self.fab_object::Init(_extra = re) then $
   return, 0B

self.minpower = (isa(minpower, /number, /scalar)) ? minpower : 0.
self.maxpower = (isa(maxpower, /number, /scalar)) ? maxpower : self.minpower
self.mincurrent = (isa(mincurrent, /number, /scalar)) ? mincurrent : 0.
self.maxcurrent = (isa(maxcurrent, /number, /scalar)) ? maxcurrent : self.mincurrent

self.keyswitch = (isa(keyswitch, /number, /scalar)) ? keyword_set(keyswitch) : 0
self.emission = (isa(emission, /number, /scalar)) ? keyword_set(emission) : 0
self.shutter = (isa(shutter, /number, /scalar)) ? keyword_set(shutter) : 0
self.power = (isa(power, /number, /scalar)) ? $
             (power > self.minpower) < self.maxpower : self.minpower
self.current = (isa(current, /number, /scalar)) ? $
             (current > self.mincurrent) < self.maxcurrent : self.mincurrent
self.temperature = 0.

self.name = 'fablaser '
self.description = 'Generic Laser '
self.setpropertyattribute, 'name', sensitive = 0
self.setpropertyattribute, 'description', sensitive = 0
self.registerproperty, 'keyswitch', /boolean
self.registerproperty, 'emission', /boolean
self.registerproperty, 'shutter', /boolean
self.registerproperty, 'power', /float, $
   valid_range = [self.minpower, self.maxpower, (self.maxpower - self.minpower)/100. > 0.01]
self.registerproperty, 'current', /float, $
   valid_range = [self.mincurrent, self.maxcurrent, (self.maxcurrent - self.mincurrent)/100. > 0.01]
self.registerproperty, 'temperature', /float
self.registerproperty, 'wavelength', /float
return, 1B
end

;;;;;
;
; fablaser__define
;                    
pro fablaser__define

COMPILE_OPT IDL2, HIDDEN

struct = {fablaser, $
          inherits fab_object, $
          keyswitch: 0, $
          emission: 0, $
          shutter: 0, $
          power: 0., $
          minpower: 0., $
          maxpower: 0., $
          current: 0., $
          mincurrent: 0., $
          maxcurrent: 0., $
          temperature: 0., $
          wavelength: 0. $
         }

end
