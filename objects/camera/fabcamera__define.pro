;+
; NAME
;    fabcamera()
;
; PURPOSE
;    Object interface for digital cameras
;
; INHERITS
;    fab_object
;
; PROPERTIES
;    DATA
;        [ G ] byte-valued array of image data
;    DIMENSIONS
;        [IG ] [w,h,[3]] dimensions of images
;    MPP
;        [IGS] Magnification [micrometers/pixel]
;
; METHODS
;    READ()
;        Reads image and returns resulting DATA
;
;    READ
;        Read image into DATA
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 03/04/2014 DGG Implemented ORDER property.
; 04/06/2014 DGG Enum values for ORDER and HFLIP.
; 02/18/2015 DGG Added EXPOSURE_TIME and GAIN properties
; 03/16/2015 DGG remove references to properties that are not provided
;    by this base class.
; 03/30/2015 DGG clean up fab_object.
; 06/08/2015 DGG Subclasses are responsible for HFLIP and ORDER
;
; Copyright (c) 2013-2015 David G. Grier
;-

;;;;;
;
; fabcamera::read()
;
function fabcamera::read

  COMPILE_OPT IDL2, HIDDEN

  self.read
  return, *self.data
end

;;;;;
;
; fabcamera::read
;
pro fabcamera::read

  COMPILE_OPT IDL2, HIDDEN

  dimensions = size(*self.data, /dimensions)
  *self.data = byte(255*randomu(seed, dimensions))
end

;;;;;
;
; fabcamera::SetProperty
;
pro fabcamera::SetProperty, mpp = mpp, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::SetProperty, _extra = re

  if isa(mpp, /scalar, /number) then $
     self.mpp = mpp
end

;;;;;
;
; fabcamera::GetProperty
;
pro fabcamera::GetProperty, data = data, $
                            dimensions = dimensions, $
                            mpp = mpp, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::GetProperty, _extra = re

  if arg_present(data) then $
     data = *self.data

  if arg_present(dimensions) then begin
     dimensions = size(*self.data, /dimensions)
     if n_elements(dimensions) eq 3 then $
        dimensions = dimensions[where(dimensions ne 3)]
  endif

  if arg_present(mpp) then $
     mpp = self.mpp

  if arg_present(order) then $
     order = self.order
end
                            
;;;;;
;
; fabcamera::Cleanup
;
pro fabcamera::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  self.fab_object::Cleanup
  ptr_free, self.data
end

;;;;;
;
; fabcamera::Init()
;
; Should be overriden by specific camera implementation
;
function fabcamera::Init, dimensions = dimensions, $
                          mpp = mpp, $
                          _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fab_object::Init(_extra = re) then $
     return, 0B

  if isa(dimensions, /number, /array) then begin
     if ~total(n_elements(dimensions) eq [2, 3]) then $
        return, 0B
  endif else $
     dimensions = [640L, 480]

  if isa(mpp, /scalar, /number) then $
     self.mpp = float(mpp)
  
  self.data = ptr_new(make_array(dimensions, /byte), /no_copy)

  self.name = 'fabcamera '
  self.description = 'Generic Camera '
  self.setpropertyattribute, 'name', sensitive = 0
  self.setpropertyattribute, 'description', sensitive = 0
  self.registerproperty, 'mpp', /float, hide = 1
  
  return, 1B
end

;;;;;
;
; fabcamera__define
;
pro fabcamera__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {fabcamera, $
            inherits fab_object, $
            data: ptr_new(), $
            mpp: 0. $
           }
end
