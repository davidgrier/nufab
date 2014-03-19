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
;
; Copyright (c) 2013-2014 David G. Grier
;-

;;;;;
;
; fabcamera_PointGrey::RegisterProperties
;
pro fabcamera_PointGrey::RegisterProperties

COMPILE_OPT IDL2, HIDDEN

properties = ['brightness',    $
              'auto_exposure', $
              'sharpness',     $
              'white_balance', $
              'hue',           $
              'saturation',    $
              'gamma',         $
              'iris',          $
              'focus',         $
              'zoom',          $
              'pan',           $
              'tilt',          $
              'shutter',       $
              'gain',          $
              'trigger_mode',  $
              'trigger_delay', $
              'frame_rate',    $
              'temperature']

indexes = indgen(n_elements(properties))
self.properties = orderedhash(properties, indexes)

info = self.propertyinfo('gain')
gain = self.property('gain')

self.name = 'fabcamera_pointgrey '
self.description = 'PointGrey Camera '

foreach property, properties do begin
   info = self.propertyinfo(property)
   if ~info.present or ~info.manualSupported then $
      continue
   self.registerproperty, property, /integer, valid_range = [info.min, info.max, 1]
endforeach

self.setpropertyattribute, 'trigger_mode', sensitive = 0
self.setpropertyattribute, 'trigger_delay', sensitive = 0
self.setpropertyattribute, 'frame_rate', sensitive = 0
end

;;;;;
;
; fabcamera_PointGrey::PropertyInfo()
;
; Get information about specified property
;
function fabcamera_PointGrey::PropertyInfo, property, $
                                            error = error

COMPILE_OPT IDL2, HIDDEN

if (error = ~self.properties.haskey(property)) then $
   return, error

present = 0L
autoSupported = 0L
manualSupported = 0L
onOffSupported = 0L
absValSupported = 0L
readOutSupported = 0L
min = 0UL
max = 0UL
absMin = 0.
absMax = 0.
error = call_external(self.dlm, 'property_info', $
                      self.properties[property], $
                      present, autoSupported, manualSupported, $
                      onOffSupported, absValSupported, readOutSupported, $
                      min, max, $
                      absMin, absMax)

return, {present: present, $
         autoSupported: autoSupported, $
         manualSupported: manualSupported, $
         onOffSupported: onOffSupported, $
         absValSupported: absValSupported, $
         readOutSupported: readOutSupported, $
         min: min, $
         max: max, $
         absMin: absMin, $
         absMax: absMax}
end

;;;;;
;
; fabcamera_PointGrey::Property(property, [value])
;
; Reads and writes value of specified property
;
function fabcamera_PointGrey::Property, property, value, $
                                        detailed = detailed, $
                                        fvalue = fvalue, $
                                        on = on, $
                                        off = off, $
                                        auto = auto, $
                                        manual = manual, $
                                        error = error

COMPILE_OPT IDL2, HIDDEN

info = self.propertyinfo(property, error = error)
if error ne 0 then $
   return, -error

if (error = (~info.present or ~info.manualSupported)) then $
   return, -error

present = 0L
absControl = 0L
onePush = 0L
onOff = 0L
autoManualMode = 0L
valueA = 0UL
valueB = 0UL
absValue = 0.

if n_elements(on) eq 1 then $
   onOff = ~keyword_set(on)

if n_elements(off) eq 1 then $
   onOff = keyword_set(off)

if n_elements(auto) eq 1 then $
   autoManualMode = ~keyword_set(auto)

if n_elements(manual) eq 1 then $
   autoManualMode = keyword_set(manual)

if n_params() eq 2 then begin
   if keyword_set(fvalue) then begin
      absvalue = float(value) > info.absmin < info.absmax
      abscontrol = 1L
   endif else begin
      valueA = ulong(value) > info.min < info.max
   endelse
   if info.onOffSupported then $
      onOff = 1L
   autoManualMode = 0L 
   
   error = call_external(self.dlm, 'write_property', $
                         self.properties[property], $
                         absControl, onePush, onOff, autoManualMode, $
                         valueA, valueB, absValue)
   if error ne 0 then $
      return, -error
endif

error = call_external(self.dlm, 'read_property', $
                      self.properties[property], $
                      present, absControl, onePush, onOff, autoManualMode, $
                      valueA, valueB, absValue)
if error ne 0 then $
   return, -error

return, keyword_set(detailed) ? $
        {present: present, $
         abscontrol: abscontrol, $
         onepush: onepush, $
         onoff: onoff, $
         automanualmode: automanualmode, $
         valuea: valuea, $
         valueb: valueb, $
         absvalue: absvalue} : $
        keyword_set(fvalue) ? absvalue : valueA

end

;;;;;
;
; fabcamera_PointGrey::ReadRegister()
;
; Reads value from specified register
;
function fabcamera_PointGrey::ReadRegister, address, $
                                            error = error

COMPILE_OPT IDL2, HIDDEN

if ~isa(address, 'ulong') then $
   return, 0

;address = '1A60'XUL
value = ulong(0)
error = call_external(self.dlm, 'read_register', address, value)
return, value

end

;;;;;
;
; fabcamera_PointGrey::WriteRegister()
;
; Reads value from specified register
;
pro fabcamera_PointGrey::WriteRegister, address, value

COMPILE_OPT IDL2, HIDDEN

if (error = ~isa(address, 'ulong')) then $
   return

if (error = ~isa(value, 'ulong')) then $
   return

error = call_external(self.dlm, 'write_register', address, value)

end

;;;;;
;
; fabcamera_PointGrey::Read
;
; Transfers a picture to the image
;
pro fabcamera_PointGrey::Read

COMPILE_OPT IDL2, HIDDEN

error = call_external(self.dlm, 'read_pgr', *self.data)
if self.order then $
   *self.data = reverse(temporary(*self.data), 2)

end

;;;;;
;
; fabcamera_PointGrey::SetProperty
;
; Set the camera properties
;
pro fabcamera_PointGrey::SetProperty, brightness    = brightness,    $
                                      auto_exposure = auto_exposure, $
                                      sharpness     = sharpness,     $
                                      white_balance = white_balance, $
                                      hue           = hue,           $
                                      saturation    = saturation,    $
                                      gamma         = gamma,         $
                                      iris          = iris,          $
                                      focus         = focus,         $
                                      zoom          = zoom,          $
                                      pan           = pan,           $
                                      tilt          = tilt,          $
                                      shutter       = shutter,       $
                                      gain          = gain,          $
                                      trigger_mode  = trigger_mode,  $
                                      trigger_delay = trigger_delay, $
                                      frame_rate    = frame_rate,    $
                                      temperature   = temperature,   $
                                      hflip         = hflip,         $
                                      _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fabcamera::SetProperty, _extra = re

if isa(brightness, /number, /scalar) then $
   void = self.property('brightness', brightness)

if isa(auto_exposure, /number, /scalar) then $
   void = self.property('auto_exposure', auto_exposure)

if isa(sharpness, /number, /scalar) then $
   void = self.property('sharpness', sharpness)

if isa(white_balance, /number, /scalar) then $
   void = self.property('white_balance', white_balance)

if isa(hue, /number, /scalar) then $
   void = self.property('hue', hue)

if isa(saturation, /number, /scalar) then $
   void = self.property('saturation', saturation)

if isa(gamma, /number, /scalar) then $
   void = self.property('gamma', gamma)

if isa(iris, /number, /scalar) then $
   void = self.property('iris', iris)

if isa(focus, /number, /scalar) then $
   void = self.property('focus', focus)

if isa(zoom, /number, /scalar) then $
   void = self.property('zoom', zoom)

if isa(pan, /number, /scalar) then $
   void = self.property('pan', pan)

if isa(tilt, /number, /scalar) then $
   void = self.property('tilt', tilt)

if isa(shutter, /number, /scalar) then $
   void = self.property('shutter', shutter)

if isa(gain, /number, /scalar) then $
   void = self.property('gain', gain)

if isa(trigger_mode, /number, /scalar) then $
   void = self.property('trigger_mode', trigger_mode)

if isa(trigger_delay, /number, /scalar) then $
   void = self.property('trigger_delay', trigger_delay)

if isa(frame_rate, /number, /scalar) then $
   void = self.property('frame_rate', frame_rate)

if isa(temperature, /number, /scalar) then $
   void = self.property('temperature', temperature)

if isa(gain, /number, /scalar) then $
   void = self.property('gain', gain)

if isa(hflip, /number, /scalar) then begin
   print, 'setting hflip:', hflip
   val = '80000000'XUL + (hflip ne 0)
   self.writeregister, '1054'XUL, val
endif

end

;;;;;
;
; fabcamera_PointGrey::GetProperty
;
pro fabcamera_PointGrey::GetProperty, properties    = properties,    $
                                      brightness    = brightness,    $
                                      auto_exposure = auto_exposure, $
                                      sharpness     = sharpness,     $
                                      white_balance = white_balance, $
                                      hue           = hue,           $
                                      saturation    = saturation,    $
                                      gamma         = gamma,         $
                                      iris          = iris,          $
                                      focus         = focus,         $
                                      zoom          = zoom,          $
                                      pan           = pan,           $
                                      tilt          = tilt,          $
                                      shutter       = shutter,       $
                                      gain          = gain,          $
                                      trigger_mode  = trigger_mode,  $
                                      trigger_delay = trigger_delay, $
                                      frame_rate    = frame_rate,    $
                                      temperature   = temperature,   $
                                      hflip         = hflip,         $
                                      _ref_extra    = re

COMPILE_OPT IDL2, HIDDEN

self.fabcamera::GetProperty, _extra = re

if arg_present(properties) then $
   properties = self.properties.keys()

if arg_present(brightness) then $
   brightness = self.property('brightness')

if arg_present(auto_exposure) then $
   auto_exposure = self.property('auto_exposure')

if arg_present(sharpness) then $
   sharpness = self.property('sharpness')

if arg_present(white_balance) then $
   white_balance = self.property('white_balance')

if arg_present(hue) then $
   hue = self.property('hue')

if arg_present(saturation) then $
   saturation = self.property('saturation')

if arg_present(gamma) then $
   gamma = self.property('gamma')

if arg_present(iris) then $
   iris = self.property('iris')

if arg_present(focus) then $
   focus = self.property('focus')

if arg_present(zoom) then $
   zoom = self.property('zoom')

if arg_present(pan) then $
   pan = self.property('pan')

if arg_present(tilt) then $
   tilt = self.property('tilt')

if arg_present(shutter) then $
   shutter = self.property('shutter')

if arg_present(gain) then $
   gain = self.property('gain')

if arg_present(trigger_mode) then $
   trigger_mode = self.property('trigger_mode')

if arg_present(trigger_delay) then $
   trigger_delay = self.property('trigger_delay')

if arg_present(frame_rate) then $
   frame_rate = self.property('frame_rate')

if arg_present(temperature) then $
   temperature = self.property('temperature')

if arg_present(hflip) then $
   hflip = (self.readregister('1054'XUL) and 1)

end

;;;;;
;
; fabcamera_PointGrey::Cleanup
;
; Close video stream
;
pro fabcamera_PointGrey::Cleanup

COMPILE_OPT IDL2, HIDDEN

if (error = call_external(self.dlm, 'close_pgr')) then $
   message, 'error closing camera', /inf, noprint = ~self.debug

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
function fabcamera_PointGrey::Init, hflip = hflip, $
                                    _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

;catch, error
;if (error ne 0L) then begin
;   catch, /cancel
;   return, 0B
;endif

;;; look for shared object library in IDL search path
dlm = 'idlpgr.so'
self.dlm = file_search(fab_path(), dlm, /test_executable)
if ~self.dlm then begin
   message, 'Could not find '+dlm, /inf
   return, 0B
endif

if ~self.fabcamera::Init(_extra = re) then $
   return, 0B

nx = 0
ny = 0
error = call_external(self.dlm, 'open_pgr', nx, ny)
if error then $
   return, 0B

a = bytarr(nx, ny)
self.data = ptr_new(a)

self.registerproperties

if isa(hflip, /number, /scalar) then $
   self.writeregister, '1054'XUL, '80000000'XUL + (hflip ne 0)

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

struct = {fabcamera_PointGrey, $
          inherits fabcamera,  $
          dlm: '',             $ 
          properties: hash()   $
         }
end
