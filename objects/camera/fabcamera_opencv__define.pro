;+
; NAME
;    fabcamera_opencv()
;
; PURPOSE
;    Object interface for OpenCV video input.
;
; INHERITS
;    fabcamera
;
; PROPERTIES
;    DLM    [ G ]
;        file specification of object library.
;
;    NUMBER [IG ]
;        index of OpenCV camera.
;        Default: 0
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property
;
; Copyright (c) 2013-2014 David G. Grier
;-

;;;;;
;
; fabcamera_opencv::read
;
pro fabcamera_opencv::Read, geometry = geometry

COMPILE_OPT IDL2, HIDDEN

if n_elements(geometry) eq 2 then begin
   w = long(geometry[0])
   h = long(geometry[1])
endif else begin
   w = self.width
   h = self.height
endelse

err = call_external(self.dlm, 'video_readvideoframe', /cdecl, $
                    self.stream, $
                    *self.data, w, h, $
                    self.greyscale, self.debug)

if self.order then $
   *self.data = reverse(temporary(*self.data), 2)

end

;;;;;
;
; fabcamera_opencv::GetProperty
;
pro fabcamera_opencv::GetProperty, dlm = dlm, $
                                   number = number, $
                                   stream = stream, $
                                   _ref_extra = ex

COMPILE_OPT IDL2, HIDDEN

self.fabcamera::GetProperty, _extra = ex

if arg_present(dlm) then $
   dlm = self.dlm

if arg_present(number) then $
   number = self.number

if arg_present(stream) then $
   stream = self.stream

end
                                   
;;;;;
;
; fabcamera_opencv::Init()
;
function fabcamera_opencv::Init, dimensions = dimensions, $
                                 number = number, $
                                 _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

catch, error
if (error ne 0L) then begin
   catch, /cancel
   return, 0B
endif

;;; look for shared object library in IDL search path
dlm = 'idlvideo.so'
self.dlm = file_search(fab_path(), dlm, /test_executable)
if ~self.dlm then begin
   message, 'could not find '+dlm, /inf
   return, 0B
endif

if ~self.fabcamera::init(_extra = re) then $
   return, 0B

self.number = (isa(number, /scalar, /number)) ? long(number) > 0 : -1L

stream = 0L
if isa(dimensions, /number) and n_elements(dimensions) eq 2 then begin
   width = long(dimensions[0])
   height = long(dimensions[1])
endif else begin
   width = 0L
   height = 0L
endelse
nchannels = 0L

err = call_external(self.dlm, 'video_queryvideocamera', /cdecl, $
                    self.number, $
                    stream, width, height, nchannels, $
                    self.debug)
if err ne 0 then begin
   message, 'could not acquire an image', /inf, noprint = ~self.debug
   return, 0B
endif
self.stream = stream
self.width = width
self.height = height
self.nchannels = nchannels

self.data = (self.nchannels) and ~self.greyscale ? $
            ptr_new(bytarr(self.width, self.height, self.nchannels, /nozero), /no_copy) : $
            ptr_new(bytarr(self.width, self.height, /nozero), /no_copy)

self.name = 'fabcamera_opencv '
self.description = 'OpenCV Camera '
   
return, 1B
end

;;;;;
;
; fabcamera_opencv::Cleanup
;
pro fabcamera_opencv::Cleanup

COMPILE_OPT IDL2, HIDDEN

err = call_external(self.dlm, 'video_closevideosource', /cdecl, $
                    self.stream, self.debug)
if err then $
   message, 'error closing camera', /inf, noprint = ~self.debug

self.fabcamera::Cleanup

end

;;;;;
;
; fabcamera_opencv__define
;
pro fabcamera_opencv__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabcamera_opencv, $
          inherits fabcamera, $
          dlm: '', $
          number: 0L, $         ; camera number
          stream: 0L, $         ; video stream
          width: 0L, $
          height: 0L, $
          nchannels: 0L $
          }
end
