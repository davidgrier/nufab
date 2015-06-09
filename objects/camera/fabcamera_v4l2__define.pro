;+
; NAME:
;    fabcamera_V4L2
;
; PURPOSE:
;    Object for acquiring and displaying images from a camera
;    using libv4l (Video4Linux2) to handle hardware interfacing.
;
; SUBCLASSES:
;    fabcamera
;
; PROPERTIES:
;    CAMERA: index of the V4L2 camera to open
;    DIMENSIONS: [w,h] dimensions of image (pixels)
;    GREYSCALE: if set, images should be cast to grayscale.
;
; METHODS:
;    fabcamera_V4L2::GetProperty
;
;    fabcamera_V4L2::SetProperty
;
;    fabcamera_V4L2::Read: Take a picture and transfer it to the 
;        underlying IDLgrImage
;
;    fabcamera_V4L2::Read(): Take a picture, transfer it to the 
;        underlying IDLgrImage, and then return the image data 
;        from the Image object.
;
; MODIFICATION HISTORY:
; 01/26/2011 Written by David G. Grier, New York University
; 02/25/2011 DGG Adapted from fabcamera_V4L2 to acquire images
;    directly into the data buffer of the underlying IDLgrImage
;    object.
; 03/15/2011 DGG Adapted from fabcamera_OpenCV
; 03/22/2011 DGG Correctly implemented Snap.
; 03/23/2011 DGG use _ref_extra in Get/SetProperty and Init
; 09/16/2013 DGG record timestamp for each acquired frame.
; 01/01/2014 DGG Overhauled for new fab implementation.
; 05/29/2015 DGG formatting and debugging code.
;
; Copyright (c) 2011-2015 David G. Grier
;-

;;;;;
;
; fabcamera_V4L2::SetProperty
;
; Set the camera properties
;
pro fabcamera_V4L2::SetProperty, order = order, $
                                 dimensions = dimension, $
                                 _extra = re

  COMPILE_OPT IDL2, HIDDEN

  if isa(order, /number, /scalar) then $
     self.idlv4l2::SetProperty, vflip = order

  if isa(dimensions, /number) then $
     self.idlv4l2::SetProperty, dimensions = dimensions

  self.idlv4l2::SetProperty, _extra = re
  self.fabcamera::SetProperty, _extra = re
end

;;;;;
;
; fabcamera_V4L2::GetProperty
;
; Get the properties of the camera or of the
; underlying IDLgrImage object.
;
pro fabcamera_V4L2::GetProperty, order = order, $
                                 dimensions = dimensions, $
                                 _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(order) then $
     self.idlv4l2::GetProperty, vflip = order

  if arg_present(dimensions) then $
     self.idlv4l2::GetProperty, dimensions = dimensions

  self.idlv4l2::GetProperty, _extra = re
  self.fabcamera::GetProperty, _extra = re
end

;;;;;
;
; fabcamera_V4L2::Cleanup
;
; Close video stream
;
pro fabcamera_V4L2::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.idlv4l2::Cleanup
  self.fabcamera::Cleanup
end

;;;;;
;
; fabcamera_V4L2::Init
;
; Initialize the fabcamera_V4L2 object:
; Open the video stream
; Load an image into the IDLgrImage object
;
function fabcamera_V4L2::Init, order = order, $
                               dimensions = dimensions, $
                               _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  ;catch, error
  ;if (error ne 0L) then begin
  ;   catch, /cancel
  ;   return, 0
  ;endif

  if (self.idlv4l2::Init(_extra = re, vflip = order) ne 1) then $
     return, 0B

  if (self.fabcamera::Init(_extra = re) ne 1) then $
     return, 0B

  self.name = 'fabcamera_V4L2 '
  self.description = 'V4L2 Camera '
  self.registerproperty, 'greyscale', /boolean, sensitive = 0
  self.registerproperty, 'hflip', enum = ['Normal', 'Flipped']
  self.registerproperty, 'order', enum = ['Normal', 'Flipped']

  return, 1B
end

;;;;;
;
; fabcamera_V4L2__define
;
; Define the fabcamera_V4L2 object
;
pro fabcamera_V4L2__define

  COMPILE_OPT IDL2

  struct = {fabcamera_V4L2,    $
            inherits idlv4l2,  $
            inherits fabcamera $
           }
end
