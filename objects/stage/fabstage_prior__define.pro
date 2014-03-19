;+
; NAME:
;    fabstage_prior
;
; PURPOSE:
;    Object for interacting with a Prior Proscan Microscope Stage
;
; INHERITS:
;    fabstage
;
; PROPERTIES:
;    DEVICE       [IG ]
;        Name of the device character file to which the Proscan is attached
;
;    SPEED        [IGS]
;        Maximum speed as a percentage from 1 to 100
;
;    ACCELERATION [IGS]
;        Maximum acceleration as a percentage from 1 to 100
;
;    SCURVE       [IGS]
;        S-curve as a percentage from 1 to 100
;
; METHODS:
;    Command, cmd, expect=expect, text=text
;        Send specificed command to the Proscan
;
;        CMD: Command to send to Proscan
;        EXPECT: Some commands result in a expected return value upon
;            success.  Set this to the expected return value.
;        TEXT: (Flag) Some commends yield multiple lines of text.
;            Set this flag to return the full text.
;
;    Clear
;        Clear command queue, reset error conditions and stop all
;        operations.
;
; NOTES:
;    1. The user must have read and write permissions for the
;    serial port.  The most security-conscious option is to
;    add the user to the appropriate group (i.e. dialout for
;    the Proscan III), rather than trying to extend the permissions
;    of the device file.
;
;    2. The default device file for a Prior Proscan III is
;    /dev/ttyACM0.
;    This can be discovered by plugging the controller into the 
;    USB bus and taking note of which device file is created,
;    for example with the Unix command
;    tail dmesg
;
; MODIFICATION HISTORY:
; 12/01/2011 Written by David G. Grier, New York University
; 12/06/2011 DGG Cleaned up IDLitComponent code.
; 12/09/2011 DGG added STEP command.
; 02/02/2012 DGG Set communications parameters.
; 05/03/2012 DGG update parameter checking for Init and SetProperty.
; 07/08/2013 DGG updates for Prior Proscan III.  Small code cleanups.
;    Additions to documentation.  Check for timeout on read.
;    Increase timeout to 1 second (!).
; 01/01/2014 DGG Overhauled for new fab implementation.
; 02/05/2014 DGG Implemented Velocity() method
; 03/02/2014 DGG Removed Step method
;
; Copyright (c) 2011-2014, David G. Grier
;-

;;;;
;
; fabstage_Prior::Speed
;
; Get and set maximum speed as percentage
;
function fabstage_Prior::Speed, value

COMPILE_OPT IDL2, HIDDEN

if isa(value, /number, /scalar) then begin
   str = 'SMS,'+strtrim((value > 1) < 100, 2)
   if ~self.command(str, expect = '0') then $
      self.error = obj_class(self) + '::Speed: ' + self.error
endif

return, fix(self.command('SMS'))
end

;;;;
;
; fabstage_Prior::Acceleration
;
; Get and set maximum acceleration as percentage
;
function fabstage_Prior::Acceleration, value

COMPILE_OPT IDL2, HIDDEN

if isa(value, /number, /scalar) then begin
   str = 'SAS,'+strtrim((value > 1) < 100,  2)
   if ~self.command(str, expect = '0') then $
      self.error = obj_class(self) + '::Acceleration: ' + self.error
endif

return, fix(self.command('SAS'))
end
;;;;
;
; fabstage_Prior::SCurve
;
; Get and set S-curve value as percentage
;
function fabstage_Prior::SCurve, value

COMPILE_OPT IDL2, HIDDEN

if isa(value, /number, /scalar) then begin
   str = 'SCS,'+strtrim((value > 1) < 100,  2)
   if ~self.command(str, expect = '0') then $
      self.error = obj_class(self) + '::SCurve: ' + self.error
endif

return, fix(self.command('SCS'))
end

;;;;
;
; fabstage_Prior::Velocity
;
pro fabstage_Prior::Velocity, v

COMPILE_OPT IDL2, HIDDEN

if total(v) eq 0 then begin
   void = self.command('VS,0,0')
   void = self.command('VZ,0', expect = 'R')
endif else begin
   vx = strtrim(v[0], 2)
   vy = strtrim(v[1], 2)
   void = self.command('VS,' + vx + ',' + vy + ',u')
   if n_elements(v) eq 3 then $
      void = self.command('VZ,' + strtrim(v[2], 2) + ',u', expect = 'R')
endelse

end

;;;;
;
; fabstage_Prior::MoveTo
;
; Set position
;
pro fabstage_Prior::MoveTo, r, relative = relative

COMPILE_OPT IDL2, HIDDEN

str = keyword_set(relative) ? 'GR' : 'G'

case n_elements(r) of
   1: begin 
      pos = keyword_set(relative) ? [0L, 0, 0] : self.position
      pos[2] = long(r)
   end
   2: pos = long(r)
   3: pos = long(r)
   else: begin
      self.error = obj_class(self) + '::MoveTo: coordinates must have 1, 2 or 3 elements'
      return
   endelse
endcase
str += ',' + strjoin(strtrim(pos, 2), ',')

if ~self.command(str, expect = 'R') then $
   self.error = obj_class(self) + '::MoveTo: ' + self.error

end

;;;;;
;
; fabstage_Prior::SetOrigin
;
; Set current position to be origin of coordinate system
;
pro fabstage_Prior::SetOrigin

COMPILE_OPT IDL2, HIDDEN

void = self.command('Z', expect = '0')

end

;;;;;
;
; fabstage_Prior::SetPosition
;
; Set the coordinate of the current position
;
pro fabstage_Prior::SetPosition, r

COMPILE_OPT IDL2, HIDDEN

if n_elements(r) ne 3 then begin
   self.error = obj_class(self) + '::SetPosition: requires three elements'
   return
endif

str = 'P,' + strjoin(strtrim(long(r), 2), ',')
if ~self.command(str, expect = '0') then $
   self.error = obj_class(self) + '::SetPosition: ' + self.error

end

;;;;;
;
; fabstage_Prior::Position()
;
; Get position
;
function fabstage_Prior::Position

COMPILE_OPT IDL2, HIDDEN

s = self.command('P')
regex = '(-?[0-9]+),(-?[0-9]+),(-?[0-9]+)'
if stregex(s, regex) then $
   r = [0L, 0, 0] $
else $
   r = (long(stregex(s, regex, /subexpr, /extract)))[1:3]

return, r

end

;;;;;
;
; fabstage_Prior::EmergencyStop
;
; Perform an emergency stop
;
pro fabstage_Prior::EmergencyStop

COMPILE_OPT IDL2, HIDDEN

if ~self.command('K', expect = 'R') then begin
    self.error = obj_class(self) + ': Emergency stop failed!'
    message, self.error, /inf
endif

end

;;;;;
;
; fabstage_Prior::Clear
;
; Clear the command queue, reset error conditions, and
; stop all operations
;
pro fabstage_Prior::Clear

COMPILE_OPT IDL2, HIDDEN

if ~self.command('I', expect = 'R') then $
    self.error = obj_class(self) + ': Clear operation failed!'

end

;;;;;
;
; fabstage_Prior::Command()
;
; Send command to Proscan controller
;
function fabstage_Prior::Command, cmd, $
                                  expect = expect, $
                                  text = text

COMPILE_OPT IDL2, HIDDEN

self.error = ''
self.port.clear
self.port.write, cmd
for n = 0, 9 do begin
   str = self.port.read(err = err)
   if strlen(str) gt 0 or (err ne 0) then $
      break
endfor

if err ne 0 then begin
   self.error = 'read timed out'
   return, ''
endif

err = long((stregex(str, 'E,([0-9]+)', /subexpr, /extract))[1])
if err then begin
   self.error = str
   return, ''
endif

if isa(expect, 'string') then begin
   if ~strcmp(str, expect) then begin
      self.error = 'expected ' + expect +'; received ' + str
      return, ''
   endif
endif

res = str
if keyword_set(text) then begin
   while ~strcmp(str, 'end', 3, /fold_case)  do begin
      res = [[res], [str]]
      str = self.port.read()
   endwhile
endif

return, res
end

;;;;;
;
; fabstage_Prior::SetProperty
;
; Set properties of the fabstage_Prior object
;
pro fabstage_Prior::SetProperty, speed = speed, $
                                 acceleration = acceleration, $
                                 scurve = scurve, $
                                 _ref_extra = re

self.fabstage::SetProperty, _extra = re

if isa(speed, /number) then $
   void = self.speed(speed)

if isa(acceleration, /number) then $
   void = self.acceleration(acceleration)

if isa(scurve, /number) then $
   void = self.scurve(scurve)

end

;;;;;
;
; fabstage_Prior::GetProperty
;
; Get properties of the fabstage_Prior object
;
pro fabstage_Prior::GetProperty, device = device, $
                                 version = version, $
                                 speed = speed, $
                                 acceleration = acceleration, $
                                 scurve = scurve, $
                                 _ref_extra = re
                             
COMPILE_OPT IDL2,  HIDDEN

self.fabstage::GetProperty, _extra = re

if arg_present(device) then $
   device = self.port.device

if arg_present(version) then $
   version = self.command('VERSION')

if arg_present(speed) then $
   speed = self.speed()

if arg_present(acceleration) then $
   acceleration = self.acceleration()

if arg_present(scurve) then $
   scurve = self.scurve()
end

;;;;;
;
; fabstage_Prior::Cleanup
;
; Free resources used by the fabstage_Prior object
;
pro fabstage_Prior::Cleanup

COMPILE_OPT IDL2, HIDDEN

obj_destroy, self.port

end

;;;;;
;
; fabstage_Prior::Init
;
; Initialize the fabstage_Prior object
;
function fabstage_Prior::Init, device = device, $
                               speed = speed, $
                               acceleration = acceleration, $
                               scurve = scurve, $
                               quiet = quiet, $
                               _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~isa(device, 'string') then begin
   message, 'Specify the RS232 device file for the Proscan Controller', /inf
   return, 0B
endif

if ~self.fabstage::Init(_extra = re) then $
   return, 0B

; open serial port
port = fabSerial(device)
if ~isa(port, 'fabSerial') then $
   return, 0B

; save present settings so that they can be restored
osettings = port.settings

; settings for Proscan II determined with minicom
; and recorded with stty -g
port.settings = ['1:0:8bd:0:3:1c:7f:15:4:5:1:0:11:13' + $
                 ':1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0']
; settings for Proscan III
port.settings = ['1401:0:cbd:0:3:1c:7f:15:4:5:1:0:11:13' + $
                 ':1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0']
port.eol = string(13b)
port.timeout = 1.0 ; long timeout for motion commands

self.port = port
; check that the device is a Prior Proscan Controller
a = self.command('VERSION')
if strlen(a) ne 3 then begin    ; version is a 3-digit string
   if ~keyword_set(quiet) then $
   message, device + ' does not appear to be a Proscan Controller', /inf
   port.settings = osettings
   obj_destroy, self.port
   return, 0B
endif

if isa(speed, /scalar, /number) then $
   void = self.speed(speed)

if isa(acceleration, /scalar, /number) then $
   void = self.acceleration(acceleration)

if isa(scurve, /scalar, /number) then $
   void = self.scurve(scurve)

self.name = 'fabstage_Prior '
self.description = 'Prior Proscan Controller '
self.registerproperty, 'device', /string, sensitive = 0
self.registerproperty, 'version', /string, sensitive = 0
self.registerproperty, 'speed', /integer, valid_range = [1, 100]
self.registerproperty, 'acceleration', /integer, valid_range = [1, 100]
self.registerproperty, 'scurve', /integer, valid_range = [1, 100]
self.setpropertyattribute, 'fast', valid_range = [1., 10., 1.]
self.setpropertyattribute, 'slow', valid_range = [0.1, 1., 0.1]

return, 1
end

;;;;;
;
; fabstage_Prior_define
;
; Object definition for a Prior Proscan stage controller
;
pro fabstage_Prior__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabstage_Prior, $
          inherits fabstage, $
          port: obj_new() $
         }
end
