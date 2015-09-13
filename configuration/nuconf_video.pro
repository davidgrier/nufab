;+
; NAME
;    nuconf_video()
;
; Options:
; CAMERA:     reference to fabcamera object that will provide images
; ORDER:      flag: set to flip image vertically
; FRAMERATE:  number of images per second
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER option
; 09/13/2015 DGG Update for nufab_recording
;
; Copyright (c) 2013-2015 David G. Grier
;-
function nuconf_video, configuration

  COMPILE_OPT IDL2, HIDDEN

  if configuration.haskey('camera') then $
     camera = configuration['camera']

  if configuration.haskey('video_order') then $
     order = long(configuration['video_order'])

  if configuration.haskey('video_frame_rate') then $
     if execute('a = '+configuration['video_frame_rate'], 1, 1) then $
        frame_rate = a

  video = nufab_video(camera = camera, order = order, $
                      frame_rate = frame_rate)

  if ~isa(video, 'nufab_video') then $
     configuration['error'] = 'could not initialize video system'

  configuration['video'] = video
  return, 'video'
end
