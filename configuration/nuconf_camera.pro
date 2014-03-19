;+
; NAME
;    nuconf_camera()
;
; Options:
; OBJECT:     name of camera object
; GREYSCALE:  flag: '1': provide greyscale images
; ORDER:      flag: '1': flips images vertically
; DIMENSIONS: [w,h]: requested dimensions of camera images
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property
;
; Copyright (c) 2013-2014 David G. Grier
;-
function nuconf_camera, configuration

COMPILE_OPT IDL2, HIDDEN

camera_object = (configuration.haskey('camera_object')) ? $
                configuration['camera_object'] : 'fabcamera'

greyscale = (configuration.haskey('camera_greyscale')) ? $
            configuration['camera_greyscale'] eq '1' : 1

if configuration.haskey('camera_order') then $
   order = long(configuration['camera_order'])

if configuration.haskey('camera_hflip') then $
   hflip = long(configuration['camera_hflip'])

mpp = (configuration.haskey('camera_mpp')) ? $
      float(configuration['camera_mpp']) : 0.

if configuration.haskey('camera_dimensions') then $
   if execute('a = '+configuration['camera_dimensions'], 1, 1) then $
      dimensions = a

camera = obj_new(camera_object, greyscale = greyscale, $
                 order = order, hflip = hflip, $
                 dimensions = dimensions, mpp = mpp)

if ~isa(camera, 'fabcamera') then $
   configuration['error'] = 'could not initialize camera'

configuration['camera'] = camera
return, 'camera'
end
