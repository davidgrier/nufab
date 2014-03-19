;+
; NAME
;    nuconf_video()
;
; Options:
; CAMERA:     reference to fabcamera object that will provide images
; ORDER:      flag: set to flip image vertically
; FRAMERATE:  number of images per second
; NTHREADS:   number of threads for recording video
; DIRECTORY:  directory into which to record video frames
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER option
;
; Copyright (c) 2013-2014 David G. Grier
;-
function nuconf_video, configuration

COMPILE_OPT IDL2, HIDDEN

if configuration.haskey('camera') then $
   camera = configuration['camera']

if configuration.haskey('video_order') then $
   order = long(configuration['video_order'])

if configuration.haskey('video_framerate') then $
   if execute('a = '+configuration['video_framerate'], 1, 1) then $
      framerate = a

if configuration.haskey('video_nthreads') then $
   if execute('a = '+configuration['video_nthreads'], 1, 1) then $
      nthreads = a

if configuration.haskey('video_directory') then $
   if execute('a = '+configuration['video_directory'], 1, 1) then $
      directory = a

video = fabvideo(camera = camera, order = order, $
                 framerate = framerate, $
                 nthreads = nthreads, directory = directory)

if ~isa(video, 'fabvideo') then $
   configuration['error'] = 'could not initialize video system'

configuration['video'] = video
return, 'video'
end
