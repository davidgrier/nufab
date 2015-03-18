;+
; NAME:
;    fabcamera_PointGrey
;
; PURPOSE:
;    Object for acquiring and displaying images from a
;    PointGrey camera using the flycapture2 API.
;
; INHERITS:
;    fabcamera
;
; PROPERTIES:
;    PROPERTIES: array of strings labeling the camera's controllable properties
;
; METHODS:
;    PropertyInfo(property): Returns anonymous structure
;        describing the chanacteristics of the named PROPERTY.
;
;    Property(name [, value]): Returns value of named property.
;        If VALUE is set, then value is written to the camera's
;        specified property.
;
; MODIFICATION HISTORY:
; 09/24/2013 Written by David G. Grier, New York University
; 01/01/2014 DGG Overhauled for new fab implementation.
; 01/27/2014 DGG First implementation of properties.
; 01/28/2014 DGG Clamp values, rather than raising an error
;    when values are out of range
; 03/04/2014 DGG Implement ORDER property
; 02/10/2015 DGG Updated PROPERTIES definition.
; 02/18/2015 DGG Added EXPOSURE_TIME property as synonym for SHUTTER.
; 03/16/2015 DGG Updated for DLM interface
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; fabcamera_PointGrey::RegisterProperties
;
pro fabcamera_PointGrey::RegisterProperties

  COMPILE_OPT IDL2, HIDDEN

  self.name = 'fabcamera_pointgrey '
  self.description = 'PointGrey Camera '
  
  foreach property, self.properties.keys() do begin
     info = self.propertyinfo(property)
     if ~info.present || ~info.manualSupported then $
        continue
     if info.absValSupported then begin
        self.registerproperty, property, /float, $
           valid_range = [info.absmin, info.absmax]
     endif else begin
        self.registerproperty, property, /integer, $
           valid_range = [info.min, info.max]
     endelse
  endforeach

  self.registerproperty, 'grayscale', /boolean, sensitive = 0
  
  self.setpropertyattribute, 'trigger_mode', sensitive = 0
  self.setpropertyattribute, 'trigger_delay', sensitive = 0
  self.setpropertyattribute, 'brightness', sensitive = 0
  self.setpropertyattribute, 'auto_exposure', sensitive = 0
  self.setpropertyattribute, 'frame_rate', sensitive = 0
end

;;;;;
;
; fabcamera_PointGrey::Read
;
; Transfers a picture to the image
;
pro fabcamera_PointGrey::Read

  COMPILE_OPT IDL2, HIDDEN

  self.data = ptr_new(self.dgghwpointgrey::read(), /no_copy)
  if self.order then $
     *self.data = reverse(temporary(*self.data), 3 - self.grayscale, /overwrite)
end

;;;;;
;
; fabcamera_PointGrey::SetProperty
;
; Set the camera properties
;
pro fabcamera_PointGrey::SetProperty, exposure_time = exposure_time, $
                                      _ref_extra = ex

  COMPILE_OPT IDL2, HIDDEN

  self.dgghwpointgrey::SetProperty, _extra = ex
  self.fabcamera::SetProperty, _extra = ex

  if isa(exposure_time, /number, /scalar) then $
     self.dgghwpointgrey::SetProperty, shutter = exposure_time
end

;;;;;
;
; fabcamera_PointGrey::GetProperty
;
pro fabcamera_PointGrey::GetProperty, data = data, $
                                      exposure_time = exposure_time, $
                                      _ref_extra = ex
  
  COMPILE_OPT IDL2, HIDDEN

  self.dgghwpointgrey::GetProperty, _extra = ex
  self.fabcamera::GetProperty, _extra = ex

  if arg_present(data) then $
     data = *self.data

  if arg_present(exposure_time) then $
     self.dgghwpointgrey::GetProperty, shutter = exposure_time
end

;;;;;
;
; fabcamera_PointGrey::Cleanup
;
; Close video stream
;
pro fabcamera_PointGrey::Cleanup

  COMPILE_OPT IDL2, HIDDEN
  
  self.dgghwpointgrey::Cleanup
  self.fabcamera::Cleanup
end

;;;;;
;
; fabcamera_PointGrey::Init
;
; Initialize the fabcamera_PointGrey object:
; Open the video stream
; Load an image into the IDLgrImage object
;
function fabcamera_PointGrey::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fabcamera::Init(_extra = re) then $
     return, 0B

  if ~self.dgghwpointgrey::Init(_extra = re) then $
     return, 0B

  self.data = ptr_new(self.dgghwpointgrey::read(), /no_copy)

  self.registerproperties

  return, 1B
end

;;;;;
;
; fabcamera_PointGrey__define
;
; Define the fabcamera_PointGrey object
;
pro fabcamera_PointGrey__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {fabcamera_PointGrey,    $
            inherits fabcamera,     $
            inherits dgghwpointgrey $
           }
end
