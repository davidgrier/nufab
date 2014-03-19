;+
; NAME
;    nuconf_save
;
; PURPOSE
;    Save current configuration as XML file
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013-2014 David G. Grier
;-
;;;;;
;
; fab_camera_configuration
;
function fab_camera_configuration, state

COMPILE_OPT IDL2, HIDDEN

if ~isa((camera = state['camera']), 'fabcamera') then $
   return, ''

dimensions = string(camera.dimensions, format = '("[",I0,",",I0,"]")')
greyscale = strtrim(camera.greyscale, 2)

conf  = '  <camera object="' + strlowcase(obj_class(camera)) + '"' + fab_nl()
conf += '          dimensions="' + dimensions + '"' + fab_nl()
conf += '          greyscale="' + greyscale + '">' + fab_nl()
conf += '  </camera>'

return, conf
end

;;;;;
;
; fab_slm_configuration()
;
function fab_slm_configuration, state

COMPILE_OPT IDL2, HIDDEN

if ~isa((slm = state['slm']), 'fabslm') then $
   return, ''

object_name = strlowcase(obj_class(slm))
dimensions = string(slm.dimensions, format = '("[",I0,",",I0,"]")')

conf  = '  <slm object="' + object_name + '"' + fab_nl()
if (object_name eq 'fabslm_fake') then $
conf += '       dimensions="' + dimensions + '">' + fab_nl() $
else $
conf += '       device_name="' + slm.device_name + '">' + fab_nl()
conf += '  </slm>'

return, conf
end

;;;;;
;
; fab_stage_configuration()
;
function fab_stage_configuration, state

COMPILE_OPT IDL2, HIDDEN

if ~isa((stage = state['stage']), 'fabstage') then $
   return, ''

properties = stage.queryproperty()
conf  = '  <stage object="' + strlowcase(obj_class(stage)) + '"' + fab_nl()
if stage.queryproperty('device') then $
   conf += '         device="' + stage.device + '"' + fab_nl()
for i = 2, n_elements(properties) - 1 do begin
   property = strlowcase(properties[i])
   stage.getpropertyattribute, property, sensitive = s
   if s then begin
      void = stage.getpropertybyidentifier(property, value)
      conf += '         ' + property + '="' + $
              strtrim(value, 2) + '"' + fab_nl()
   endif
endfor
conf += '         >' + fab_nl()
conf += '  </stage>'

return, conf
end

;;;;;;
;
; fab_video_configuration()
;
function fab_video_configuration, state

COMPILE_OPT IDL2, HIDDEN

if ~isa((video = state['video']), 'fabvideo') then $
   return, ''

conf  = '  <video framerate="' + strtrim(video.framerate, 2) + '"' + fab_nl()
conf += '         nthreads="' + strtrim(video.nthreads, 2) + '"' + fab_nl()
conf += '         directory="' + video.directory + '">' + fab_nl()
conf += '  </video>'

return, conf
end

;;;;;
;
; fab_cgh_configuration()
;
function fab_cgh_configuration, state

COMPILE_OPT IDL2, HIDDEN

if ~isa((cgh = state['cgh']), 'fabcgh') then $
   return, ''

rc = '[' + string(cgh.rc, format = '(3(F0,:,","))') + ']'
kc = '[' + string(cgh.kc, format = '(2(F0,:,","))') + ']'
roi = '[' + string(cgh.roi, format = '(4(I0,:,","))') + ']'

conf  = '  <cgh object="' + strlowcase(obj_class(cgh)) + '">' + fab_nl()
;conf += '       rc="' + rc + '"' + fab_nl()
;conf += '       kc="' + kc + '"' + fab_nl()
;conf += '       q="' + strtrim(cgh.q, 2) + '"' + fab_nl()
;conf += '       aspect_ratio="' + strtrim(cgh.aspect_ratio, 2) + '"' + fab_nl()
;conf += '       aspect_z="' + strtrim(cgh.aspect_z, 2) + '"' + fab_nl()
;conf += '       angle="' + strtrim(cgh.angle, 2) + '"' + fab_nl()
;conf += '       roi="' + roi + '">' + fab_nl()
conf += '  </cgh>'

return, conf
end

;;;;;
;
; nuconf_save
;
pro nuconf_save, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = state

filename = dialog_pickfile(title = 'nuFAB Save Configuration', $
                           file = 'nuFAB_'+dgtimestamp(/date), $
                           default_extension = 'xml', $
                           filter = '*.xml', /fix_filter, $
                           /write, /overwrite_prompt, $
                           resource_name = 'nuFAB')
if ~strlen(filename) then $
   return

openw, file, filename, /get_lun
printf, file, '<configuration>'
printf, file, fab_camera_configuration(state)
printf, file, fab_slm_configuration(state)
printf, file, fab_stage_configuration(state)
printf, file, fab_video_configuration(state)
printf, file, fab_cgh_configuration(state)
printf, file, '</configuration>'
free_lun, file

end
