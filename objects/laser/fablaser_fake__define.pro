;;;;;
;
; fablaser_fake::GetProperty
;
pro fablaser_fake::GetProperty, keyswitch = keyswitch, $
                                emission = emission, $
                                power = power, $
                                current = current, $
                                temperature = temperature, $
                                wavelength = wavelength, $
                                _ref_extra = ex

COMPILE_OPT IDL2, HIDDEN

self.fablaser::GetProperty, _extra = ex

if arg_present(keyswitch) then $
   keyswitch = self.keyswitch

if arg_present(emission) then $
   emission = self.emission

if arg_present(power) then $
   power = self.power

if arg_present(current) then $
   current = self.current

if arg_present(temperature) then $
   temperature = self.temperature

if arg_present(wavelength) then $
   wavelength = self.wavelength

end

;;;;;
;
; fablaser_fake::SetProperty
;
pro fablaser_fake::SetProperty, keyswitch = keyswitch, $
                                emission = emission, $
                                power = power, $
                                current = current, $
                                temperature = temperature, $
                                wavelength = wavelength, $
                                _ref_extra = ex

COMPILE_OPT IDL2, HIDDEN

self.fablaser::SetProperty, _extra = ex

if isa(keyswitch, /scalar, /number) then $
   self.keyswitch = keyword_set(keyswitch)

if isa(emission, /scalar, /number) then $
   self.emission = self.keyswitch and keyword_set(emission)

if isa(power, /scalar, /number) then $
   self.power = float(power)

if isa(current, /scalar, /number) then $
   self.current = float(current)

if isa(temperature, /scalar, /number) then $
   self.temperature = float(temperature)

if isa(wavelength, /scalar, /number) then $
   self.wavelength = float(wavelength)

end

;;;;;
;
; fablaser_fake::Init()
;
function fablaser_fake::Init, description = description, $
                              keyswitch = keyswitch, $
                              emission = emission, $
                              power = power, $
                              current = current, $
                              temperature = temperature, $
                              wavelength = wavelength, $
                              _ref_extra = ex

COMPILE_OPT IDL2, HIDDEN

if ~self.fablaser::init(wavelength = wavelength, _extra = ex) then $
   return, 0B

self.name = 'fablaser_fake '
self.description = isa(description, 'string') ? description : 'Placeholder '
self.keyswitch = isa(keyswitch, /scalar, /number) ? keyword_set(keyswitch) : 1
self.emission = isa(emission, /scalar, /number) ? keyword_set(emission) : 0
self.power = isa(power, /scalar, /number) ? float(power) : 0.
self.current = isa(current, /scalar, /number) ? float(current) : 0.
self.temperature = isa(temperature, /scalar, /number) ? float(temperature) : 24.

self.setpropertyattribute, 'name', /hide
self.setpropertyattribute, 'keyswitch', sensitive = 0
self.setpropertyattribute, 'current', sensitive = 0
return, 1B
end

;;;;;
;
; fablaser_fake__define
;
pro fablaser_fake__define

COMPILE_OPT IDL2, HIDDEN

struct = {fablaser_fake, $
          inherits fablaser}

end
