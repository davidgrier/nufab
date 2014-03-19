;+
; NAME:
;    nucal_save
;
; PURPOSE:
;    Save calibration constants as XML file suitable
;    for configuration at startup
;
; MODIFICATION HISTORY:
; 01/24/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-

pro nucal_save, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = state

if ~state.haskey('cgh') then $
   return

dirs = file_search('~/.nufab', /test_directory, count = count)
filename = dialog_pickfile(title = 'nuFAB Save Calibration', $
                           file = 'calibration_'+dgtimestamp(/date), $
                           path = (count lt 1) ? './' : dirs[0], $
                           default_extension = 'xml', $
                           filter = '*.xml', /fix_filter, $
                           /write, /overwrite_prompt, $
                           resource_name = 'nuFAB')

if ~strlen(filename) then $
   return

cgh = state['cgh']
rc = '[' + string(cgh.rc, format = '(3(F0,:,","))') + ']'
kc = '[' + string(cgh.kc, format = '(2(F0,:,","))') + ']'
roi = '[' + string(cgh.roi, format = '(4(F0,:,","))') + ']'

cal  = ' <cgh rc="' + rc + '"' + fab_nl()
cal += '      kc="' + kc + '"' + fab_nl()
cal += '      q="' + strtrim(cgh.q, 2) + '"' + fab_nl()
cal += '      aspect_ratio="' + strtrim(cgh.aspect_ratio, 2) + '"' + fab_nl()
cal += '      aspect_z="' + strtrim(cgh.aspect_z, 2) + '"' + fab_nl()
cal += '      angle="' + strtrim(cgh.angle, 2) + '"' + fab_nl()
cal += '      roi="' + roi + '">' + fab_nl()
cal += ' </cgh>'

openw, file, filename, /get_lun
printf, file, '<calibration>'
printf, file, cal
printf, file, '</calibration>'
free_lun, file

end
