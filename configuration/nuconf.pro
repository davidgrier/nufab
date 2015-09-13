;+
; NAME:
;    nuconf()
;
; PURPOSE:
;    Parse configuration files to assemble nufab system
;
; PROCEDURE:
;    Parses the default.xml configuration file, and then looks
;    for system-specific XML configuration files in ~/.nufab/
;
; OUTPUT:
;    Hash describing system components that were successfully
;    configured, together with error messages, if any.
;
; MODIFICATION HISTORY:
; 12/25/2013 Written by David G. Grier, New York University
; 09/13/2015 DGG incorporate nuconf_recording.
;
; Copyright (c) 2013-2015 David G. Grier
;-
function nuconf

  COMPILE_OPT IDL2, HIDDEN

  ;;; Parse configuration files
  if ~(parser = fab_configurationparser()) then $
     return = hash('error', 'could not initialize configuration parser')

  default_configuration = 'nuconf_default.xml'
  fn = file_search(fab_path(), default_configuration, count = count)
  if ~(count gt 0) then $
     return, hash('error', $
                  'could not open default configuration file: ' + $
                  default_configuration)
  parser.parsefile, fn[0]

  filenames = file_search('~/.nufab/*.xml', /test_read, count = count)
  if count gt 0 then $
     foreach filename, filenames do $
        parser.parsefile, filename

  configuration = parser.configuration
  obj_destroy, parser

  ;;; Apply configuration information to nufab subsystems
  components = list('error')
  components.add, nuconf_camera(configuration)
  components.add, nuconf_slm(configuration)
  components.add, nuconf_traplaser(configuration)
  components.add, nuconf_imagelaser(configuration)
  components.add, nuconf_stage(configuration)
  components.add, nuconf_video(configuration)
  components.add, nuconf_recording(configuration)
  components.add, nuconf_cgh(configuration)
  components.add, nuconf_trappingpattern(configuration)

  ;;; Incorporate configuration information into nufab state
  state = hash()
  foreach component, components do $
     if configuration.haskey(component) then $
        state[component] = configuration[component]

  return, state
end
