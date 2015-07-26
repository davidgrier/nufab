;+
; NAME:
;    nufab
;
; PURPOSE:
;    GUI for the holographic fabrication and characterization system
;
; CATEGORY:
;    Hardware control, holographic optical trapping, digital video microscopy
;
; CALLING SEQUENCE:
;    nufab
;
; KEYWORDS:
;    state: state of the system in the form of a hash.
;
; COMMON BLOCKS:
;    Widget hierarchy is managed by XMANAGER, which uses common blocks.
;
; SIDE EFFECTS:
;    Opens a GUI on the current display.  Controls attached hardware.
;
; MODIFICATION HISTORY:
; 12/20/2013 Written by David G. Grier, New York University
; 04/08/2014 DGG Return state as keyword.
;
; Copyright (c) 2013-2014 David G. Grier
;-

;;;;;
;
; nufab_event
;
pro nufab_event, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = s

  case tag_names(event, /structure_name) of
     'WIDGET_BUTTON': begin
        widget_control, event.id, get_uvalue = uval
        case uval of
           'QUIT': begin
              s['video'].record = 0
              s['video'].play = 0
              widget_control, event.top, /destroy
           end
           else:                ; unrecognized button
        endcase
     end

     'WIDGET_TAB':              ; nothing to do

     else: help, event          ; unrecognized event
  endcase
end

;;;;;
;
; nufab_cleanup
;
pro nufab_cleanup, tlb

  COMPILE_OPT IDL2, HIDDEN

  widget_control, tlb, get_uvalue = state, /no_copy

  foreach key, state.keys() do $
     if total(obj_valid(state[key])) ne 0 then $
        obj_destroy, state[key]
end

;;;;;
;
; nufab
;
pro nufab, state = state

  COMPILE_OPT IDL2

  if xregistered('nufab') then begin
     message, 'not starting: Another nufab is running already', /inf
     return
  endif

  ;;; Hardware
  state = nuconf()
  if state.haskey('error') then begin
     message, state['error'], /inf
     return
  endif
  dimensions = state['camera'].dimensions

  ;;; Widget layout
  wtop = widget_base(/row, title = 'nuFAB', mbar = bar, tlb_frame_attr = 5)

  ;; menu bar
  nufab_menu, bar

  ;; 1. video screen
  wscreen = widget_draw(wtop, $
                        graphics_level = 2,                      $ ; object graphics
                        xsize = dimensions[0],                   $ ; sized to camera
                        ysize = dimensions[1],                   $
                        /button_events, /wheel_events,           $ ; control traps
                        keyboard_events = state.haskey('stage'), $ ; control stage
                        event_func = 'nufab_screen_event')

  ;; 2. control panels
  wcontrol = widget_base(wtop, /column)
  wtabs = widget_tab(wcontrol)
  wcamera = nufab_settings(wtabs, state['camera'], 'Camera')
  wcgh = nufab_settings(wtabs, state['cgh'], 'CGH')

  ;; 3. global information
  ;;    wavelength, mpp (laser status?)
  winfo = nufab_info(wcontrol, state)
  
  ;; 4. logo!
  
  ;;; Realize widget hierarchy
  widget_control, wtop, /realize
  widget_control, wscreen, get_value = screen

  ;;; Graphics hierarchy
  imagemodel = IDLgrModel()
  imagemodel.add, state['video']
  imageview = IDLgrView(viewplane_rect = [0, 0, dimensions])
  imageview.add, imagemodel

  overlay = IDLgrView(viewplane_rect = [0, 0, dimensions], /transparent)
  overlay.add, state['trappingpattern']

  scene = IDLgrScene()
  scene.add, imageview
  scene.add, overlay

  ;;; Embed graphics hierarchy in widget layout
  screen.setproperty, graphics_tree = scene

  ;;; Current state of the system
  state['screen'] = screen
  state['overlay'] = overlay
  state['seed'] = systime(1)
  widget_control, wtop, set_uvalue = state

  ;;; Start event loop
  xmanager, 'nufab', wtop, /no_block, cleanup = 'nufab_cleanup'

  ;;; Start video
  state['video'].screen = screen
  state['video'].play = 1
end
