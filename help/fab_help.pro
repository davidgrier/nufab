;+
; NAME:
;    fab_help
;
; PURPOSE:
;    Deploys a help file browser for the nufab system.
;
; CATEGORY:
;    Hardware control
;
; CALLING SEQUENCE:
;    Implemented as an event handler for XMANAGER.
;    fab_help, event
;
; INPUTS:
;    event: event structure created by XMANAGER.
;        event.uvalue should be a string describing the type of
;        help required.
;
; SIDE EFFECTS:
;    Opens a help browser on the current display.
;
; NOTES:
; Relevant settings for .Xdefaults
;
; Idl*nufab*XmText*background: lightyellow
; Idl*nufab*XmText*highlightThickness: 5
;
; MODIFICATION HISTORY:
; 12/25/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013-2014 David G. Grier
;-

;;;;;
;
; fab_help_event
;
; Closes the help browser
;
pro fab_help_event, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, /destroy

end

;;;;;
;
; fab_help
;
pro fab_help, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'string') then $
   topic = event $
else $
   widget_control, event.id, get_uvalue = topic

;;; look for helpfile in IDL search path
filename = 'nufab/help/'+topic+'.txt'
helpfile = file_search(fab_path(), filename, /test_read, /fold_case, count = count)
if count le 0 then $
   return

;;; read file
line = ''
text = []
openr, file, helpfile[0], /get_lun
while ~eof(file) do begin
   readf, file, line
   text = [text, line]
endwhile
free_lun, file

;;; widget hierarchy
tlb = widget_base(title = 'nuFAB Help', /column, $
                  resource_name = 'nuFAB')
void = widget_text(tlb, value = text, $
                   xsize = 80, ysize = n_elements(text))
void = widget_button(tlb, value = 'Done', uvalue = 'DONE')

widget_control, tlb, /realize

xmanager, 'fab_help', tlb, /no_block            

end
