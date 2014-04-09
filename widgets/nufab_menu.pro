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
;
; Copyright (c) 2013-2014 David G. Grier
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
;;; VIDEO
;;;
video_menu = widget_button(bar, value = 'Video', /menu, $
                           event_pro = 'fab_menu_event')
void = widget_button(video_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'VIDEO')
void = widget_button(video_menu, value = 'Camera...', $
                     event_pro = 'fab_properties', uvalue = 'CAMERA')
void = widget_button(video_menu, value = 'Take Snapshot...', uvalue = 'SNAPSHOT')
void = widget_button(video_menu, value = 'Recording Directory...', uvalue = 'RECDIR')
void = widget_button(video_menu, value = 'Record', uvalue = 'RECORD')

;;;
;;; TRAPS
;;;
traps_menu = widget_button(bar, value = 'Traps', /menu, $
                          event_pro = 'fab_menu_event')
void = widget_button(traps_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'TRAPS')
void = widget_button(traps_menu, value = 'Clear', uvalue = 'CLEAR')

;;;
;;; LASERS
;;;
laser_menu = widget_button(bar, value = 'Lasers', /menu)
void = widget_button(laser_menu, value = 'Image Laser...', $
                     event_pro = 'fab_properties', uvalue = 'IMAGELASER')
void = widget_button(laser_menu, value = 'Trap Laser...', $
                     event_pro = 'fab_properties', uvalue = 'TRAPLASER')

;;;
;;; STAGE
;;;
stage_menu = widget_button(bar, value = 'Stage', /menu)
void = widget_button(stage_menu, value = 'Properties...', $
                     event_pro = 'fab_properties', uvalue = 'STAGE')
void = widget_button(stage_menu, value = 'Set Origin', $
                     event_pro = 'nucal_stagesetorigin')
void = widget_button(stage_menu, value = 'Calibration Bay', $
                     event_pro = 'nucal_stagegotoorigin')
void = widget_button(stage_menu, value = 'Cleaning Bay', $
                     event_pro = 'nucal_stagecleaning')
void = widget_button(stage_menu, value = 'Sample Bay 1', $
                     event_pro = 'nucal_stagesample1')
void = widget_button(stage_menu, value = 'Sample Bay 2', $
                     event_pro = 'nucal_stagesample2')

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
                     event_pro = 'uncal_geometry')
;void = widget_button(calibration_menu, value = 'Calibrate RC...', $
;                     event_pro = 'nucal_rc')
;void = widget_button(calibration_menu, value = 'Calibrate XY...', $
;                     event_pro = 'nucal_xy')
;void = widget_button(calibration_menu, value = 'Calibrate KC...', $
;                     event_pro = 'nucal_kc')
;void = widget_button(calibration_menu, value = 'Calibrate ROI...', $
;                     event_pro = 'nucal_roi')
void = widget_button(calibration_menu, value = 'Calibrate Aberrations...', $
                     event_pro = 'nucal_shackhartmann')

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
