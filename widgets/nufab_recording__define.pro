;+
; NAME:
;    nufab_recording
;
; PURPOSE:
;    Control panel for recording video data.
;
; MODIFICATION HISTORY:
; 09/13/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;;;;;
;
; nufab_recording::SaveImage
;
pro nufab_recording::SaveImage, image

  COMPILE_OPT IDL2, HIDDEN

  path = file_search(self.directory, /expand_tilde, /expand_environment, /test_directory)
  
  filename = dialog_pickfile(title = 'Save Snapshot', $
                             filter = '*.png', /fix_filter, $
                             path = path, $
                             file = 'nufab_snapshot', $
                             default_extension = 'png', $
                             /write, /overwrite_prompt, $
                             resource_name = 'nufab')
  if strlen(filename) gt 0 then $
     write_png, filename, image
end


;;;;;
;
; nufab_recording_event
;
pro nufab_recording::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, event.top, get_uvalue = state
  widget_control, event.id,  get_uvalue = uval

  video = state['video']
  
  case uval of
     'NAME': begin
        filename = self.filename
        self.filename = event.value
        if ~self.hasvalidfilename() then begin
           if ~self.hasvalidfilename(/read) then $
              self.filename = filename
        endif
        widget_control, event.id, set_value = self.filename
     end
     
     'TARGET': ; nothing to do
     
     'RECORD': begin
        case event.value of
           'RECORD': begin
              case self.state of
                 'NORMAL': begin                    ; ... not recording, so start
                    if (filename = self.hasvalidfilename()) then begin
                       self.recorder = h5video(filename, /overwrite, $
                                               metadata = self.metadata(state))
                       if isa(self.recorder, 'h5video') then begin
                          video.registercallback, 'recorder', self
                          self.frn = 0
                          self.state = 'RECORDING'
                       endif
                    endif
                 end
                 'PAUSED': self.state = 'RECORDING' ; ... paused, so unpause
                 else:                              ; ... already recording, carry on
              endcase
           end
           
           'PAUSE': begin
              case self.state of
                 'RECORDING': self.state = 'PAUSED'
                 'PAUSED': self.state = 'RECORDING'
                 'REPLAYING': video.playing = ~video.playing
                 else:          ; nothing to do
              endcase
           end
           
           'STOP': begin        ; stop recording, close file
              video.playing = 0
              if (self.state eq 'REPLAYING') then $
                 video.camera = state['camera']
              if (self.state ne 'NORMAL') then begin
                 video.unregistercallback, 'recorder'
                 self.recorder.close
              endif
              self.state = 'NORMAL'
              video.playing = 1
           end
           
           'SNAPSHOT': self.saveimage, video.screendata
              
           else:
        endcase
     end

     'REPLAY': begin
        case event.value of
           'REWIND': begin
              if (self.state eq 'REPLAYING') then begin
                 self.recorder.index = 0
                 video.playing = 0
                 self.callback, video
              endif
           end
           
           'PAUSE': begin
              case self.state of
                 'RECORDING': self.state = 'PAUSED'
                 'PAUSED': self.state = 'RECORDING'
                 'REPLAYING': video.playing = ~video.playing
                 else:          ; nothing to do
              endcase
           end

           'PLAY': begin
              if ~(self.state eq 'REPLAYING') then begin   ; start replaying
                 if (self.state eq 'RECORDING') then begin ; stop recording
                    video.unregistercallback, 'recorder'
                    self.state = 'NORMAL'
                    self.recorder.close
                 endif
                 ;; open replay file
                 filename = self.hasvalidfilename(/read)
                 if isa(filename, 'string') then begin
                    video.playing = 0
                    self.recorder = h5video(filename) ; open for reading
                    if isa(self.recorder, 'h5video') then begin
                       video.camera = self.recorder
                       video.registercallback, 'recorder', self
                       self.state = 'REPLAYING'
                    endif
                 endif
              endif else $
                 self.recorder.stepsize = 1
              video.playing = 1
           end
           
           'FAST': begin
              if (self.state eq 'REPLAYING') then begin
                 self.recorder.stepsize *= 2
                 video.playing = 1
              endif
           end

           'STOP': begin
              video.playing = 0
              if (self.state eq 'REPLAYING') then $
                 video.camera = state['camera']
              if (self.state ne 'NORMAL') then begin
                 video.unregistercallback, 'recorder'
                 self.recorder.close
              endif
              self.state = 'NORMAL'
              video.playing = 1
           end
           
           else:
        endcase
     end
     
     'HVMMODE': begin
        case event.value of
           0: video.unregisterfilter
           1: video.registerfilter, nufab_filter_median(/running, order = 4)
           2: video.registerfilter, nufab_filter_median(order = 4)
        endcase
     end
     
     else: print, 'got', uval
  endcase
  
end

;;;;;
;
; nufab_recording::hasvalidfilename
;
function nufab_recording::hasvalidfilename, read = read

  COMPILE_OPT IDL2

  filename = self.filename
  directory = self.directory

  write_flag = ~keyword_set(read)

;  if (filename.length eq 0) then $ ; IDL 8.4
  if strlen(filename) eq 0 then $
     return, 0

;  if filename.contains(path_sep()) then begin ; IDL 8.4
  if strmatch(filename, '*'+path_sep()+'*') then begin
     directory = file_dirname(filename)
     filename = file_basename(filename)
  endif

  ;; Check that directory exists, or can be created
  if write_flag then begin
     if ~file_test(directory, /directory) then $
     file_mkdir, directory

     if ~file_test(directory, /directory, /write) then begin
        res = dialog_message('Cannot write to '+directory)
        return, 0
     endif
  endif else begin
     if ~file_test(directory, /directory, /read) then begin
        res = dialog_message('Cannot read from '+directory)
        return, 0
     endif
  endelse

  directory = file_search(directory, /expand_tilde, /expand_environment, /mark_directory)
  
;  if ~filename.endswith('.h5', /fold_case) then $ ; IDL 8.4
  if ~strmatch(filename, '*.h5', /fold_case) then $
     filename += '.h5'
  
  fullname = directory + filename

  ;; Check that file can be written, or read, as needed
  if write_flag then begin
     if file_test(fullname) then begin
        res = dialog_message([fullname + ' already exists.', 'Overwrite?'], $
                             /question, /default_no, /center)
        if (res eq 'No') then $
           return, 0
        if ~file_test(fullname, /write) then begin
           res = dialog_message('Cannot overwrite '+fullname, /center)
           return, 0
        endif
     endif
  endif else begin
     if ~file_test(fullname) then begin
        res = dialog_message('Cannot read '+fullname, /center)
        return, 0
     endif
  endelse

  self.directory = directory
  self.filename = filename

  return, fullname
end

;;;;;
;
; nufab_recording::metadata()
;
function nufab_recording::metadata, state

  COMPILE_OPT IDL2, HIDDEN

  info = get_login_info()

  camera = state['camera']
  exposure_time = (camera.hasproperty('exposure_time')) ? $
                  camera.exposure_time : $
                  'unknown'

  gain = (camera.hasproperty('gain')) ? $
         camera.gain : $
         'unknown'
  
  metadata = {creator:       'nufab', $
              machine_name:  info.machine_name, $
              user_name:     info.user_name, $
              camera:        camera.name, $
              exposure_time: exposure_time, $
              gain:          gain, $
              lambda:        state['imagelaser'].wavelength, $
              mpp:           camera.mpp}
  
  return, metadata
end

;;;;;
;
; nufab_recording::Callback
;
; Update the control panel based on current recording activity
;
pro nufab_recording::Callback, video

  COMPILE_OPT IDL2, HIDDEN

  if (self.state eq 'RECORDING') then begin
     widget_control, self.wtgt, get_value = target
     if self.frn lt target then begin
        self.recorder.write, video.data ; (self.state eq 'RECORDING') ? video.data : video.screendata
        self.frn++
     endif else begin
        video.unregistercallback, 'recorder'
        self.state = 'NORMAL'
        self.recorder.close
        self.frn = 0
     endelse
     widget_control, self.wfrn, set_value = self.frn     
  endif else if (self.state eq 'REPLAYING') then begin
     widget_control, self.wfrn, set_value = self.recorder.index
  endif
end

;;;;;
;
; nufab_recording::Create
;
pro nufab_recording::Create, wtop

  COMPILE_OPT IDL2, HIDDEN
  
  wrecording = widget_base(wtop, /COLUMN, /GRID_LAYOUT, $
                           TITLE = self.title, $               ; for WIDGET_TAB
                           RESOURCE_NAME = 'nufab')

  void = cw_field(wrecording, /FRAME, /RETURN_EVENTS, $
                  VALUE = self.filename, $
                  title = 'File Name:', UVALUE = 'NAME')
  
  wtgt = cw_field(wrecording, /FRAME, /RETURN_EVENTS, /ULONG, $
                  VALUE = 1000UL, $
                  title = '# Frames: ', UVALUE = 'TARGET')

  bvalues = ['Record', 'Pause', 'Stop', 'Snapshot']
  void = cw_bgroup(wrecording, bvalues, /ROW, $
                   LABEL_LEFT = 'Record', $
                   button_uvalue = strupcase(bvalues), $
                   /FRAME, /NO_RELEASE, UVALUE = 'RECORD')

  bvalues = ['Rewind', 'Pause', 'Play', 'Fast', 'Stop']
  void = cw_bgroup(wrecording, bvalues, /ROW, $
                   LABEL_LEFT = 'Replay', $
                   button_uvalue = strupcase(bvalues), $
                   /FRAME, /NO_RELEASE, UVALUE = 'REPLAY')
  
  ;wframeslider = widget_slider(wrecording, /FRAME, UVALUE = 'FRAMENUMBER', $
  ;                             MINIMUM = 0, MAXIMUM = 100, SENSITIVE = 0)

  wfrn = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                  VALUE = 0UL, $
                  title = 'Frame #:  ')
  
  wftn = cw_field(wrecording, /FRAME, /NOEDIT, /ULONG, $
                  VALUE = 0UL, $
                  title = 'Feature #:')

  bvalues = ['Normal', 'Running', 'Sample/Hold']
  void = cw_bgroup(wrecording, bvalues, $
                   /ROW, /FRAME, $
                   LABEL_LEFT = 'Mode', $
                   /EXCLUSIVE, /NO_RELEASE, $
                   SET_VALUE = 0, UVALUE = 'HVMMODE')

  self.state = 'NORMAL'
  self.wtgt = wtgt
  self.wfrn = wfrn
  self.frn = 0
  self.widget_id = wrecording
end

;;;;;
;
; nufab_recording::Init()
;
; Create the widget layout and set up the callback for the
; video recording object.
;
function nufab_recording::Init, wtop, configuration, title

  COMPILE_OPT IDL2, HIDDEN

  help, configuration
  self.directory = isa(configuration.directory, 'string') ? $
                   configuration.directory : $
                   '~/data'
  self.filename = isa(configuration.filename, 'string') ? $
                  configuration.filename : $
                  'nufab.h5'
  self.title = title
  return, self.nufab_widget::Init(wtop) 
end

;;;;;
;
; nufab_recording__define
;
pro nufab_recording__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_recording, $
            inherits nufab_widget, $
            title: '', $
            state: '', $        ; 'paused', 'recording', 'replaying'
            recorder: obj_new(), $
            directory: '', $
            filename: '', $            
            wtgt: 0L, $
            frn: 0UL, $
            wfrn: 0L $
           }
end

