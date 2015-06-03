;+
; NAME:
;    nucal_restore
;
; PURPOSE:
;    Restore previously saved calibration state
;
; MODIFICATION HISTORY:
; 01/25/2014 Written by David G. Grier, New York University
; 06/29/2015 DGG corrected routine name.
;
; Copyright (c) 2014-2015 David G. Grier
;-

pro nucal_restore, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = s

;;; Make sure there's something to calibrate
  if ~s.haskey('cgh') then $
     return

  cgh = s['cgh']

;;; Select calibration file to restore
  dirs = file_search('~/.nufab', /test_directory, count = count)
  filename = dialog_pickfile(title = 'nuFAB Restore Calibration', $
                             file = 'calibration*', $
                             path = (count lt 1) ? './' : dirs[0], $
                             default_extension = 'xml', /fix_filter, $
                             /read, resource_name = 'nuFAB')

  if ~strlen(filename) then $
     return

;;; Parse calibration file
  if ~(parser = fab_configurationparser()) then $
     return

  parser.parsefile, filename
  configuration = parser.configuration
  obj_destroy, parser

;;; Apply configuration
  if configuration.haskey('cgh_rc') then $
     if execute('a = '+configuration['cgh_rc'], 1, 1) then $
        cgh.rc = a

  if configuration.haskey('cgh_kc') then $
     if execute('a = '+configuration['cgh_kc'], 1, 1) then $
        cgh.kc = a

  if configuration.haskey('cgh_q') then $
     cgh.q = float(configuration['cgh_q'])

  if configuration.haskey('cgh_aspect_ratio') then $
     cgh.aspect_ratio = float(configuration['cgh_aspect_ratio'])

  if configuration.haskey('cgh_aspect_z') then $
     cgh.aspect_z = float(configuration['cgh_aspect_z'])

  if configuration.haskey('cgh_angle') then $
     cgh.angle = float(configuration['cgh_angle'])

  if configuration.haskey('cgh_roi') then $
     if execute('a = '+configuration['cgh_roi'], 1, 1) then $
        cgh.roi = a

  if s.haskey('propertysheet') then $
     widget_control, s['propertysheet'], /refresh_property
end
