;+
; NAME:
;    fabvideo
;
; PURPOSE:
;    Video screen for nufab system
;
; INHERITS:
;    IDLgrImage
;    IDL_Object
;
; PROPERTIES
;    camera     [RG ]: fabcamera object that provides images
;    width      [ G ]: width of camera image
;    height     [ G ]: height of camera image
;    screen     [RG ]: IDLgrWindow on which the image is drawn
;    framerate  [IGS]: number of frames per second
;    timestamp  [ G ]: time stamp of present video frame
;    playing    [ GS]: If set, video screen updates at framerate
;    hvmmode    [ GS]: If set, video is normalized by background image
;    background [ G ]: Background image for hvmmode
;    recording  [ GS]: 0: paused, not recording
;                      1: record video from camera
;                      2: record video from screen
;                      3: record video from window
;    nthreads   [I  ]: number of threads for video recorder
;
; METHODS
;    GetProperty
;    SetProperty
;
;    SaveImage: Save one snapshot
;    SelectDirectory: Choose directory for recording images
;
; MODIFICATION HISTORY:
; 01/27/2014 Written by David G. Grier, New York University
; 03/04/2014 DGG Implement EXTRA keywords in Init.
; 04/06/2014 DGG Implemented running median hvmmode with numedian().
;    Implemented recording modes.
;
; Copyright (c) 2014 David G. Grier
;-

;;;;;
;
; fabVideo::handleTimerEvent
;
pro fabVideo::handleTimerEvent, id, userdata

COMPILE_OPT IDL2, HIDDEN

self.timer = timer.set(self.time, self)
self.timestamp = systime(1)
data = self.camera.read()

self.IDLgrImage::setproperty, data = (self.hvmmode ne 0) ? $
                                     byte(128.*float(data)/self.median.get() < 255) : $
                                     data
self.screen.draw

if (self.hvmmode eq 1) or ((self.hvmmode eq 2) and ~(self.median.initialized)) then $
   self.median.add, data

case self.recording of
   1: void = self.recorder.write(data, self.timestamp)
   2: begin
      self.IDLgrImage::getproperty, data = data
      void = self.recorder.write(data, self.timestamp)
   end
   3: begin
      self.screen.getproperty, image_data = data
      void = self.recorder.write(data, self.timestamp)
   end
   else:
endcase

end

;;;;;
;
; fabVideo::SaveImage
;
pro fabVideo::SaveImage, filename

COMPILE_OPT IDL2, HIDDEN

if ~isa(filename, 'string') then $
   filename = dialog_pickfile(title = 'nuFAB Save Snapshot', $
                              filter = '*.png', /fix_filter, $
                              directory=self.recorder.directory, $
                              file = 'nufab_snapshot', $
                              default_extension = 'png', $
                              /write, /overwrite_prompt, $
                              resource_name = 'nuFAB')
if strlen(filename) gt 0 then begin
   self.IDLgrImage::GetProperty, data = snapshot
   write_png, filename, snapshot
endif

end

;;;;;
;
; fabVideo::SelectDirectory
;
pro fabVideo::SelectDirectory

COMPILE_OPT IDL2, HIDDEN

directory = dialog_pickfile(title = 'nuFAB Choose Recording Directory', $
                            /directory, /must_exist, /write, $
                            filter = '[^.]*', /fix_filter, $
                            path = self.recorder.directory, $
                            resource_name = 'nuFAB')
if strlen(directory) gt 0 then $
   self.recorder.directory = directory

end

;;;;;
;
; fabVideo::SetProperty
;
pro fabVideo::SetProperty, greyscale = greyscale, $
                           playing =  playing, $
                           hvmmode = hvmmode, $
                           screen = screen, $
                           framerate = framerate, $
                           recording = recording, $
                           _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.camera.setproperty, greyscale = greyscale, _extra = re
self.recorder.setproperty, _extra = re
self.IDLgrImage::SetProperty, _extra = re

if isa(screen, 'IDLgrWindow') then $
   self.screen = screen

if isa(playing) then begin
   self.playing = keyword_set(playing)
   ok = timer.cancel(self.timer)
   if self.playing and isa(self.screen) then $
      self.timer = timer.set(self.time, self)
endif

if isa(hvmmode, /number, /scalar) then $
   self.hvmmode = (long(hvmmode) > 0) < 2
      
if isa(framerate, /scalar, /number) then $
   self.time = 1./double(abs(framerate))

if isa(recording, /scalar, /number) then $
   self.recording = recording
   
end

;;;;;
;
; fabVideo::GetProperty
;
pro fabVideo::GetProperty, greyscale = greyscale, $
                           camera = camera, $
                           screen = screen, $
                           framerate = framerate, $
                           timestamp = timestamp, $
                           playing = playing, $
                           hvmmode = hvmmode, $
                           background = background, $
                           recording = recording, $
                           width = width, $
                           height = height, $
                           _ref_extra = re
  
COMPILE_OPT IDL2, HIDDEN

self.camera.getproperty, _extra = re
self.recorder.getproperty, _extra = re
self.IDLgrImage::GetProperty, _extra = re

if arg_present(greyscale) then $
   greyscale = self.camera.greyscale

if arg_present(camera) then $
   camera = self.camera

if arg_present(screen) then $
   screen = self.screen

if arg_present(framerate) then $
   framerate = 1./self.time

if arg_present(timestamp) then $
   timestamp = self.timestamp

if arg_present(playing) then $
   playing = self.playing

if arg_present(hvmmode) then $
   hvmmode = self.hvmmode

if arg_present(background) then $
   background = self.median.get()

if arg_present(recording) then $
   recording = self.recording

if arg_present(width) then $
   width = (self.camera.dimensions)[0]

if arg_present(height) then $
   height = (self.camera.dimensions)[1]

end

;;;;;
;
; fabVideo::Cleanup
;
pro fabVideo::Cleanup

COMPILE_OPT IDL2, HIDDEN

obj_destroy, self.camera
obj_destroy, self.recorder

end

;;;;;
;
; fabVideo::Init()
;
function fabVideo::Init, camera = camera, $
                         screen = screen, $
                         framerate = framerate, $
                         nthreads = nthreads, $
                         directory = directory, $
                         _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if isa(camera, 'fabcamera') then $
   self.camera = camera $
else $
   return, 0B

imagedata = self.camera.read()

if isa(screen, 'IDLgrWindow') then $
   self.screen = screen

if ~self.IDLgrImage::Init(imagedata, _extra = re) then $
   return, 0B

self.median = numedian(3, data = imagedata)

self.time = (isa(framerate, /scalar, /number)) ? 1./double(abs(framerate)) : 1./29.97D

self.recorder = fabrecorder(nthreads = nthreads, directory = directory)
if ~isa(self.recorder, 'fabRecorder') then $
   return, 0B

self.name = 'fabvideo '
self.description = 'Video Image '
self.registerproperty, 'name', /string, /hide
self.registerproperty, 'description', /string
self.registerproperty, 'playing', /boolean
self.registerproperty, 'framerate', /float
self.registerproperty, 'order', enum = ['Normal', 'Flipped']
self.registerproperty, 'hvmmode', enum = ['Off', 'Running', 'Sample-Hold']
self.registerproperty, 'recording', $
   enum = ['Paused', 'From Camera', 'From Screen', 'From Window']
self.registerproperty, 'directory', /string
self.registerproperty, 'nthreads', /integer, valid_range = [1, 20, 1]
self.registerproperty, 'greyscale', /boolean, sensitive = 0
self.registerproperty, 'width', /integer, sensitive = 0
self.registerproperty, 'height', /integer, sensitive = 0

return, 1B
end

;;;;;
;
; fabVideo__define
;
pro fabVideo__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabVideo, $
          inherits IDLgrImage, $
          inherits IDL_Object, $
          camera: obj_new(), $
          screen: obj_new(), $
          recorder: obj_new(), $
          playing: 0L, $
          hvmmode: 0L, $
          median: obj_new(), $
          bgcounter: 0L, $
          recording: 0L, $
          time: 0.D, $
          timer: 0L, $
          timestamp: 0D $
         }
end
