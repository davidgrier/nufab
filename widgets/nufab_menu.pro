;+
; NAME:
;    nufab_menu
;
; PURPOSE:
;    Create the pull-down menus for nufab
;
; CALLING SEQUENCE:
;    nufab_menu, parent
;
; INPUTS:
;    parent: widget reference to a menu bar
;
; MODIFICATION HISTORY:
; 12/22/2013 Written by David G. Grier, New York University
; 09/14/2015 DGG Reorganization for tab-based layout.
;
; Copyright (c) 2013-2015 David G. Grier
;-

pro nufab_menu, bar

COMPILE_OPT IDL2, HIDDEN

;;;
;;; FILE
;;;
file_menu = widget_button(bar, value = 'File', /menu)
void = widget_button(file_menu, value = 'Save Configuration...', $
                     event_pro = 'nuconf_save')
;;; Quit should be handled by the parent
void = widget_button(file_menu, value = 'Quit', uvalue = 'QUIT')

;;;
;;; PROPERTIES
;;;
prop_menu = widget_button(bar, value = 'Properties', /menu, $
                           event_pro = 'fab_menu_event')
void = widget_button(prop_menu, value = 'Video...', $
                     event_pro = 'fab_properties', uvalue = 'VIDEO')
void = widget_button(prop_menu, value = 'Imaging Laser...', $
                     event_pro = 'fab_properties', uvalue = 'IMAGELASER')
void = widget_button(prop_menu, value = 'Trapping Laser...', $
                     event_pro = 'fab_properties', uvalue = 'TRAPLASER')

;;;
;;; TRAPS
;;;
traps_menu = widget_button(bar, value = 'Traps', /menu, $
                          event_pro = 'fab_menu_event')
void = widget_button(traps_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'TRAPS')
void = widget_button(traps_menu, value = 'Clear', uvalue = 'CLEAR')

;;;
;;; STAGE
;;;
stage_menu = widget_button(bar, value = 'Stage', /menu)
void = widget_button(stage_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'STAGE')
void = widget_button(stage_menu, value = 'Set Origin', $
                     event_pro = 'nucal_stagesetorigin')
void = widget_button(stage_menu, value = 'Calibration Bay', $
                     event_pro = 'nucal_stage_tocalibration')
void = widget_button(stage_menu, value = 'Cleaning Bay', $
                     event_pro = 'nucal_stage_tocleaning')
void = widget_button(stage_menu, value = 'Sample Bay 1', $
                     event_pro = 'nucal_stage_tosample1')
void = widget_button(stage_menu, value = 'Sample Bay 2', $
                     event_pro = 'nucal_stage_tosample2')

;;;
;;; CALIBRATION
;;;
calibration_menu = widget_button(bar, value = 'Calibration', /menu)
void = widget_button(calibration_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'CGH')
void = widget_button(calibration_menu, value = 'Save...', $
                     event_pro = 'nucal_save')
void = widget_button(calibration_menu, value = 'Restore...', $
                     event_pro = 'nucal_restore')
void = widget_button(calibration_menu, value = 'Reset', $
                     event_pro = 'nucal_reset')
void = widget_button(calibration_menu, value = 'Calibrate Geometry...', $
                     event_pro = 'nucal_geometry')
void = widget_button(calibration_menu, value = 'Calibrate Aberrations...', $
                     event_pro = 'nucal_shackhartmann')

;;;
;;; ANALYSIS
;;;
analysis_menu = widget_button(bar, value = 'Analysis', /menu)
void = widget_button(analysis_menu, value = 'Something Nice', $
                     uvalue = 'NICE')

;;;
;;; HELP
;;;
help_menu = widget_button(bar, value = 'Help', /menu, event_pro = 'fab_help')
void = widget_button(help_menu, value = 'About...', uvalue = 'ABOUT')
void = widget_button(help_menu, value = 'Calibration...', uvalue = 'CALIBRATE')
void = widget_button(help_menu, value = 'Trapping...', uvalue = 'TRAPPING')
void = widget_button(help_menu, value = 'Stage Motion...', uvalue = 'STAGE')
void = widget_button(help_menu, value = 'Recording...',  uvalue = 'RECORD')

end
