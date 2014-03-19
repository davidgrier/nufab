function nucal_setup, event, error = error

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

if s.haskey('error') then $
   return, 0B

;;; Calibrate in the focal plane
s['cgh'].zc = 0

;;; Set camera to minimum sensitivity
if ~s.haskey('camera') then begin
   error = 'no camera'
   return, 0B
endif

;;; FIXME: Specialized to PointGrey cameras
;;; Should generalize
camera = s['camera']
camera.gain = 0
camera.auto_exposure = 0

;;; Turn off imaging laser
if s.haskey('imagelaser') then $
   s['imagelaser'].shutter = 0

;;; Set trapping laser to minimum power
if ~s.haskey('traplaser') then begin
   error = 'no laser'
   return, 0B
endif

laser = s['traplaser']

;;; Cannot calibrate if laser is off
if ~laser.emission then begin
   error = 'laser is not turned on'
   return, 0B
endif

;;; Set power to minimum
laser.power = 0

;;; Wait for confirmation?
;;; FIXME: Wait for laser to confirm minimum power

;;; Make sure shutter is open
if ~laser.shutter then $
   laser.shutter = 1

;;; Autofocus?
;;; FIXME: Implement

return, 1B
end
