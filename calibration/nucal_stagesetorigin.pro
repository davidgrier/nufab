pro nucal_stagesetorigin, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue=s

s['stage'].setorigin
end
