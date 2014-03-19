pro testfabvideo_event, event

COMPILE_OPT IDL2, HIDDEN

widget_control, event.top, get_uvalue = s
video = s['video']

widget_control, event.id, get_uvalue = uval
case uval of
   'START': video.play = 1
   'PAUSE': video.play = 0
   'RECORD': video.record = 1
   'STOP' : video.record = 0
   'DONE': begin
      video.record = 0
      video.play = 0
      widget_control, event.top, /destroy
   end
endcase

end

pro testfabvideo

COMPILE_OPT IDL2

;;; Hardware
videoimage = fabVideo(dimensions = [640, 480], /greyscale)
screendimensions = videoimage.dimensions

;;; Widget layout
tlb = widget_base(/column, title = 'nufab', tlb_frame_attr = 5)

wscreen = widget_draw(tlb, $
                      xsize = screendimensions[0], $
                      ysize = screendimensions[1], $
                      graphics_level = 2)

buttons = widget_base(tlb, /row, /align_center)
void = widget_button(buttons, value = 'start', uvalue = 'START')
void = widget_button(buttons, value = 'pause', uvalue = 'PAUSE')
void = widget_button(buttons, value = 'record', uvalue = 'RECORD')
void = widget_button(buttons, value = 'stop', uvalue = 'STOP')
void = widget_button(buttons, value = 'done', uvalue = 'DONE')

widget_control, tlb, /realize
widget_control, wscreen, get_value = screen

;;; Graphics hierarchy
imagemodel = IDLgrModel()
imagemodel.add, videoimage
imageview = IDLgrView(viewplane_rect = [0, 0, screendimensions])
imageview.add, imagemodel

;;; Embed graphics hierarchy in widget layout
screen.setproperty, graphics_tree = imageview

;;; Current state of the system
state = hash()
state['video'] = videoimage
widget_control, tlb, set_uvalue = state

;;; Start event loop
xmanager, 'testfabvideo', tlb, /no_block

;;; Start video
videoimage.screen = screen
videoimage.play = 1

end
