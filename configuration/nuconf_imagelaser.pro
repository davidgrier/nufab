;+
; NAME
;    nuconf_imagelaser()
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
; nuconf_imagelaser()
;
function nuconf_imagelaser, configuration

COMPILE_OPT IDL2, HIDDEN

imagelaser_object = (configuration.haskey('imagelaser_object')) ? $
                   configuration['imagelaser_object'] : 'fablaser_fake'

description = (configuration.haskey('imagelaser_description')) ? $
              configuration['description'] : 'Trapping Laser '

keyswitch = (configuration.haskey('imagelaser_keyswitch')) ? $
            keyword_set(long(configuration['imagelaser_keyswitch'])) : 0

emission = (configuration.haskey('imagelaser_emission')) ? $
           keyword_set(long(configuration['imagelaser_emission'])) : 0

power = (configuration.haskey('imagelaser_power')) ? $
        float(power) : 0.

current = (configuration.haskey('imagelaser_current')) ? $
          float(current) : 0.

if configuration.haskey('imagelaser_temperature') then $
   temperature = float(configuration['imagelaser_temperature'])

if configuration.haskey('imagelaser_wavelength') then $
   wavelength = float(configuration['imagelaser_wavelength'])

if configuration.haskey('imagelaser_device') then $
   device = configuration['imagelaser_device']

imagelaser = obj_new(imagelaser_object, $
                     device = device, $
                     description = description, $
                     emission = emission, $
                     power = power, $
                     current = current, $
                     temperature = temperature, $
                     wavelength = wavelength)

if ~isa(imagelaser, 'fablaser') then $
   configuration['error'] =  'could not initialize trapping laser'

configuration['imagelaser'] = imagelaser
return, 'imagelaser'
end
