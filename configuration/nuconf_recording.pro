;+
; NAME
;    nuconf_recording()
;
; Options:
; DIRECTORY:   string containing name of the recording directory
; FILENAME:    filename for recording video data
; COMPRESSION: Integer compression level (0 -- 9)
;
; MODIFICATION HISTORY
; 09/13/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
function nuconf_recording, configuration

  COMPILE_OPT IDL2, HIDDEN

  compression = 0

  directory = configuration.haskey('recording_directory') ? $
              configuration['recording_directory'] : $
              './'

  filename = configuration.haskey('recording_filename') ? $
             configuration['recording_filename'] : $
             'nufab.h5'

  if configuration.haskey('recording_compression') then $
     compression = long(configuration['recording_compression'])

  recording = {directory: directory, $
               filename: filename, $
               compression: compression $
              }
  
  configuration['recording'] = recording
  return, 'recording'
end
