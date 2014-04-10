pro nucal_stagegotoorigin, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
    s = event $
else $
    widget_control, event.top, get_uvalue = s

stage = s['stage']

if stage.z lt 1000 then $
   stage.z = 1000
stage.x = 0
stage.z = 0

end
