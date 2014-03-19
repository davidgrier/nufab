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
;    DATA       [ G ]
;        byte-valued array of image data
;
;    DIMENSIONS [IG ]
;        [w,h,[3]] dimensions of images
; 
;    ORDER      [IGS]
;        flag: if set, flip image vertically
;
;    HFLIP      [IGS]
;        flag: if set, flip image horizontally
;
;    GREYSCALE  [IG ]
;        flag: If set deliver greyscale images
;
;    MPP: Magnification [micrometers/pixel]
;        [IGS]
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
;
; Copyright (c) 2013-2014 David G. Grier
;-

;;;;;
;
; fabcamera::read()
;
function fabcamera::read

COMPILE_OPT IDL2, HIDDEN

self.read
data = *self.data
return, data
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
pro fabcamera::SetProperty, dimensions = dimensions, $
                            greyscale = greyscale, $
                            order = order, $
                            hflip = hflip, $
                            mpp = mpp, $
                            debug = debug, $
                            _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fab_object::SetProperty, _extra = re

if isa(dimensions, /number, /array) then $
   message, 'DIMENSIONS can only be set at initialization', /inf

if isa(greyscale, /scalar, /number) then $
   message, 'GREYSCALE can only be set at initialization', /inf

if isa(order, /scalar, /number) then $
   self.order = (order ne 0)

if isa(hflip, /scalar, /number) then $
   self.hflip = (hflip ne 0)

if isa(mpp, /scalar, /number) then $
   self.mpp = mpp

if isa(debug, /scalar, /number) then $
   self.debug = debug

end

;;;;;
;
; fabcamera::GetProperty
;
pro fabcamera::GetProperty, data = data, $
                            dimensions = dimensions, $
                            greyscale = greyscale, $
                            order = order, $
                            hflip = hflip, $
                            mpp = mpp, $
                            debug = debug, $
                            _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fab_object::GetProperty, _extra = re

if arg_present(data) then $
   data = *self.data

if arg_present(dimensions) then $
   dimensions = size(*self.data, /dimensions)

if arg_present(mpp) then $
   mpp = self.mpp

if arg_present(greyscale) then $
   greyscale = self.greyscale

if arg_present(order) then $
   order = self.order

if arg_present(hflip) then $
   hflip = self.hflip

if arg_present(debug) then $
   debug = self.debug

end
                            
;;;;;
;
; fabcamera::Cleanup
;
pro fabcamera::Cleanup

COMPILE_OPT IDL2, HIDDEN

ptr_free, self.data

end

;;;;;
;
; fabcamera::Init()
;
; Should be overriden by specific camera implementation
;
function fabcamera::Init, dimensions = dimensions, $
                          greyscale = greyscale, $
                          order = order, $
                          hflip = hflip, $
                          mpp = mpp, $
                          debug = debug, $
                          _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~self.fab_object::Init(_extra = re) then $
   return, 0B

self.debug = keyword_set(debug)

if isa(dimensions, /number, /array) then begin
   if ~total(n_elements(dimensions) eq [2, 3]) then $
      return, 0B
endif else $
   dimensions = [640L, 480]

if isa(mpp, /scalar, /number) then $
   self.mpp = float(mpp)

if isa(order, /scalar, /number) then $
   self.order = (order ne 0)

if isa(hflip, /scalar, /number) then $
   self.hflip = (hflip ne 0)

self.data = ptr_new(make_array(dimensions, /byte), /no_copy)

self.greyscale = n_elements(dimensions) eq 2

self.name = 'fabcamera '
self.description = 'Generic Camera '
self.setpropertyattribute, 'name', sensitive = 0
self.setpropertyattribute, 'description', sensitive = 0
self.registerproperty, 'order', /boolean
self.registerproperty, 'hflip', /boolean
self.registerproperty, 'greyscale', /boolean, sensitive = 0
self.registerproperty, 'mpp', /float, sensitive = 0
self.setpropertyattribute, 'mpp', hide = (self.mpp eq 0)

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
          greyscale: 0L, $
          order: 0L, $
          hflip: 0L, $
          mpp: 0., $
          debug: 0L $
         }
end
