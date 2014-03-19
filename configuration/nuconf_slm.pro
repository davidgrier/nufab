;+
; NAME
;    nuconf_slm()
;
; Options:
; OBJECT:     name of SLM object
; DIMENSIONS: [w,h] dimensions of SLM
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-
function nuconf_slm, configuration

COMPILE_OPT IDL2, HIDDEN

slm_object = (configuration.haskey('slm_object')) ? $
             configuration['slm_object'] : 'fabslm'

if configuration.haskey('slm_device_name') then $
   device_name = configuration['slm_device_name']

if configuration.haskey('slm_dimensions') then $
   if execute('a = '+configuration['camera_dimensions'], 1, 1) then $
      dimensions = a

slm = obj_new(slm_object, device_name = device_name, dimensions = dimensions)

if ~isa(slm, 'fabslm') then $
   configuration['error'] = 'could not initialize SLM'

configuration['slm'] = slm
return, 'slm'
end
