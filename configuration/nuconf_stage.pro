;+
; NAME
;    nuconf_stage()
;
; Options:
; OBJECT:     name of microscope stage object
; SPEED: stage speed {1,100}
; ACCELERATION: stage acceleration {1,100}
; SCURVE: acceleration profile {1,100}
; 
; MODIFICATION HISTORY
; 01/01/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
function nuconf_stage, configuration

COMPILE_OPT IDL2, HIDDEN

stage_object = (configuration.haskey('stage_object')) ? $
               configuration['stage_object'] : 'fabstage_fake'

if configuration.haskey('stage_device') then $
   device = configuration['stage_device']

if configuration.haskey('stage_right') then $
   if execute('a = '+configuration['stage_right'], 1, 1) then $
      right = a $
   else $
      right = [1., 0.]

if configuration.haskey('stage_forward') then $
   if execute('a = '+configuration['stage_forward'], 1, 1) then $
      forward = a $
   else $
      forward = [0., 1.]

if configuration.haskey('stage_up') then $
   up = float(configuration['stage_up'])

stage = obj_new(stage_object, device = device, $
                right = right, forward = forward, up = up)

if isa(stage, 'fabstage_prior') then begin
   if configuration.haskey('stage_speed') then $
      stage.speed = configuration['stage_speed']

   if configuration.haskey('stage_acceleration') then $
      stage.acceleration = configuration['stage_acceleration']

   if configuration.haskey('stage_scurve') then $
      stage.scurve = configuration['stage_scurve']
endif

if ~isa(stage, 'fabstage') then $
   configuration['error'] = 'could not initialize stage'

configuration['stage'] = stage
return, 'stage'
end
