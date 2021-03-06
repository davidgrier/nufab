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
; [IGS] GRAYSCALE: boolean flag to provide grayscale images
; [IGS] ORDER: boolean flag to flip images vertically
; [IGS] HFLIP: boolean flag to flip images horizontally
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property.
; 04/06/2014 DGG Implemented HFLIP property.
; 03/16/2015 DGG Update for DLM interface
; 09/15/2015 DGG documentation.
;
; Copyright (c) 2013-2015 David G. Grier
;-
;;;;;
;
; fabcamera_opencv::read
;
pro fabcamera_opencv::Read

  COMPILE_OPT IDL2, HIDDEN

  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)
  if self.hflip then $
     *self.data = reverse(temporary(*self.data), 2 - self.grayscale, /overwrite)
  if self.order then $
     *self.data = reverse(temporary(*self.data), 3 - self.grayscale, /overwrite)
end

;;;;;
;
; fabcamera_opencv::SetProperty
;
pro fabcamera_opencv::SetProperty, order = order, $
                                   hflip = hflip, $
                                   _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  if isa(order, /number, /scalar) then $
     self.order = keyword_set(order)
  if isa(hflip, /number, /scalar) then $
     self.hflip = keyword_set(hflip)
  self.dgghwvideo::SetProperty, _extra = ex
  self.fabcamera::SetProperty, _extra = ex
end

;;;;;
;
; fabcamera_opencv::GetProperty
;
pro fabcamera_opencv::GetProperty, order = order, $
                                   hflip = hflip, $
                                   _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(order) then $
     order = self.order
  if arg_present(hflip) then $
     hflip = self.hflip
  self.dgghwvideo::GetProperty, _extra = ex
  self.fabcamera::GetProperty, _extra = ex
end
                                   
;;;;;
;
; fabcamera_opencv::Init()
;
function fabcamera_opencv::Init, dimensions = _dimensions, $
                                 order = order, $
                                 hflip = hflip, $
                                 _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.dgghwvideo::init(dimensions = _dimensions, _extra = re) then $
     return, 0B

  self.dgghwvideo::GetProperty, dimensions = dimensions

  if ~self.fabcamera::init(dimensions = dimensions, _extra = re) then $
     return, 0B

  if isa(order, /number, /scalar) then $
     self.order = keyword_set(order)

  if isa(hflip, /number, /scalar) then $
     self.hflip = keyword_set(hflip)
  
  self.data = ptr_new(self.dgghwvideo::read(), /no_copy)

  self.name = 'fabcamera_opencv '
  self.description = 'OpenCV Camera '
  self.registerproperty, 'grayscale', /boolean
  self.registerproperty, 'order', enum = ['Normal', 'Flipped']
  self.registerproperty, 'hflip', enum = ['Normal', 'Flipped']
  
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
  
  struct = {fabcamera_opencv,    $
            inherits fabcamera,  $
            inherits dgghwvideo, $
            order: 0L,           $
            hflip: 0L            $
           }
end
