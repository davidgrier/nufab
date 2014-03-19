;+
; NAME
;    nuconf_traplaser()
;
; Options:
; OBJECT:      name of trapping laser object
; DESCRIPTION: brief description of laser for property sheet
; KEYSWITCH:   flag: '1' set laser's keyswitch to 'ON'
; EMISSION:    flag: '1' set laser to emit
; POWER:       requested emission power
; CURRENT:     requested laser current
; TEMPERATURE: requested laser temperature
; WAVELENGTH:  wavelength of laser for property sheet
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-
;;;;;
;
; nuconf_traplaser()
;
function nuconf_traplaser, configuration

COMPILE_OPT IDL2, HIDDEN

traplaser_object = (configuration.haskey('traplaser_object')) ? $
                   configuration['traplaser_object'] : 'fablaser_fake'

description = (configuration.haskey('traplaser_description')) ? $
              configuration['description'] : 'Trapping Laser '

keyswitch = (configuration.haskey('traplaser_keyswitch')) ? $
            keyword_set(long(configuration['traplaser_keyswitch'])) : 0

emission = (configuration.haskey('traplaser_emission')) ? $
           keyword_set(long(configuration['traplaser_emission'])) : 0

power = (configuration.haskey('traplaser_power')) ? $
        float(power) : 0.

current = (configuration.haskey('traplaser_current')) ? $
          float(current) : 0.

if configuration.haskey('traplaser_temperature') then $
   temperature = float(configuration['traplaser_temperature'])

if configuration.haskey('traplaser_wavelength') then $
   wavelength = float(configuration['traplaser_wavelength'])

if configuration.haskey('traplaser_device') then $
   device = configuration['traplaser_device']

traplaser = obj_new(traplaser_object, $
                    device = device, $
                    description = description, $
                    emission = emission, $
                    power = power, $
                    current = current, $
                    temperature = temperature, $
                    wavelength = wavelength)

if ~isa(traplaser, 'fablaser') then $
   configuration['error'] =  'could not initialize trapping laser'

configuration['traplaser'] = traplaser
return, 'traplaser'
end
