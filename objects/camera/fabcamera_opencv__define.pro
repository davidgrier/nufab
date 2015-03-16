;+
; NAME
;    fabcamera_opencv()
;
; PURPOSE
;    Object interface for OpenCV video input.
;
; INHERITS
;    fabcamera
;    DGGhwVideo
;
; PROPERTIES
;    [IGS] GRAYSCALE: boolean flag to provide grayscale images
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property.
; 04/06/2014 DGG Implemented HFLIP property.
; 03/16/2015 DGG Update for DLM interface
;
; Copyright (c) 2013-2014 David G. Grier
;-
;;;;;
;
; fabcamera_opencv::read
;
pro fabcamera_opencv::Read

  COMPILE_OPT IDL2, HIDDEN

  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)
  if self.hflip then $
     *self.data = reverse(*self.data, 2 - self.grayscale, /overwrite)
  if self.order then $
     *self.data = reverse(*self.data, 3 - self.grayscale, /overwrite)
end

;;;;;
;
; fabcamera_opencv::SetProperty
;
pro fabcamera_opencv::SetProperty, _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwvideo::SetProperty, _extra = ex
  self.fabcamera::SetProperty, _extra = ex
end

;;;;;
;
; fabcamera_opencv::GetProperty
;
pro fabcamera_opencv::GetProperty, _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwvideo::GetProperty, _extra = ex
  self.fabcamera::GetProperty, _extra = ex
end
                                   
;;;;;
;
; fabcamera_opencv::Init()
;
function fabcamera_opencv::Init, dimensions = _dimensions, $
                                 _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.dgghwvideo::init(dimensions = _dimensions, _extra = re) then $
     return, 0B

  self.dgghwvideo::GetProperty, dimensions = dimensions

  if ~self.fabcamera::init(dimensions = dimensions, _extra = re) then $
     return, 0B

  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)

  self.name = 'fabcamera_opencv '
  self.description = 'OpenCV Camera '
  self.registerproperty, 'grayscale', /boolean
  
  return, 1B
end

;;;;;
;
; fabcamera_opencv::Cleanup
;
pro fabcamera_opencv::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.fabcamera::Cleanup
  self.dgghwvideo::Cleanup
end

;;;;;
;
; fabcamera_opencv__define
;
pro fabcamera_opencv__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {fabcamera_opencv, $
            inherits dgghwvideo, $
            inherits fabcamera $
           }
end
