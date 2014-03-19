;+
; NAME:
;    fablaser_IPG
;
; PURPOSE:
;    Object class for controlling an IPG fiber laser
;
; SUBCLASSES
;    fablaser
;
; PROPERTIES:
;    device: Name of the serial port's device file
;        [IG ]
;
;    firmware: Version of the laser's firmware
;        [ G ]
;
;    status: Instrument status: structure of type IPGLaserStatus
;        [ G ]
;
;    keyswitch: Keyswitch status: 1 on, 0 off
;        [ G ]
;
;    emission: Emission status:  1 on, 0 off
;        [ GS]
;
;    current: Diode current as percentage of maximum current
;        [ GS]
;
;    power: Emission power [W]
;        [ G ]
;
;    temperature: Diode temperature [degrees C]
;        [ G ]
;
; METHODS:
;    fablaser_IPG::GetProperty
;    fablaser_IPG::SetProperty
;
; EXAMPLE:
; IDL> a = fablaser_IPG("/dev/ttyUSB0")
; IDL> help, a.status
; IDL> a.emission = 1
; IDL> a.current = 10
;
; MODIFICATION HISTORY:
; 03/15/2011 Written by David G. Grier, New York University
; 04/26/2011 DGG derived from IPGLASER class.
; 06/23/2011 DGG inherits DGGhwSerialDevice
; 11/28/2011 DGG DGGhwSerial used as an object, rather than
;    being inherited.
; 12/03/2011 DGG determined robust communications settings.
; 12/06/2011 DGG Cleaned up IDLitComponent code.
; 12/28/2013 DGG Overhauled for nufab implementation.
;
; Copyright (c) 2011-2014 David G. Grier
;-
;;;;;
;
; fablaser_IPG::Keyswitch
;
; Get keyswitch setting
;
function fablaser_IPG::Keyswitch

COMPILE_OPT IDL2, HIDDEN

st = self.status()
return, st.keyswitch

end


;;;;;
;
; fablaser_IPG::Emission
;
; Set and return emission status
;
function fablaser_IPG::Emission, status

COMPILE_OPT IDL2, HIDDEN

if n_params() eq 1 then begin
   if ~self.keyswitch() then $
      message, 'Keyswitch is off', /inf
   void = self.command((status) ? 'EMON' : 'EMOFF')
endif

st = self.status()
return, st.emission

end

;;;;;
;
; fablaser_IPG::Power()
;
; Get laser power
;
function fablaser_IPG::Power

COMPILE_OPT IDL2, HIDDEN

res = self.command('ROP')
if strcmp(res, 'off', 3, /fold_case) then $
   return, 0. $
else if strcmp(res, 'low', 3, /fold_case) then $
   return, 0.1
return, float(res)
end

;;;;;
;
; fablaser_IPG::Current()
;
; Get and set the diode current
;
function fablaser_IPG::Current, value

COMPILE_OPT IDL2, HIDDEN

if n_params() eq 0 then $
   return, float(self.command('RCS'))

value = (value > float(self.command('RNC'))) < 100.
cmd = 'SDC ' + strtrim(string(value, format = '(F5.1)'), 2)
return, float(self.command(cmd))
end

;;;;;
;
; fablaser_IPG::Temperature()
;
; Get laser temperature
;
function fablaser_IPG::Temperature

COMPILE_OPT IDL2, HIDDEN

return, float(self.command('RCT'))
end

;;;;;
;
; fablaser_IPG::Status()
;
; Get laser status
;
function fablaser_IPG::Status

COMPILE_OPT IDL2, HIDDEN

res = fix(self.command('STA'))

status = {IPGlaserStatus,                            $
          emission:           ((res AND 2^2) ne 0),  $
          backreflection:     ((res AND 2^3) ne 0),  $
          analogcontrol:      ((res AND 2^4) ne 0),  $
          moduledisconnect:   ((res AND 2^6) ne 0),  $
          modulefailure:      ((res AND 2^7) ne 0),  $
          aimingbeam:         ((res AND 2^8) ne 0),  $
          powersupply:        ((res AND 2^11) EQ 0), $
          modulationenabled:  ((res AND 2^12) ne 0), $
          laserenable:        ((res AND 2^14) ne 0), $
          safeemission:       ((res AND 2^15) ne 0), $
          unexpectedemission: ((res AND 2^17) ne 0), $
          keyswitch:          ((res AND 2^21) EQ 0), $
          aimingbeamhardware: ((res AND 2^22) ne 0), $
          modulesconnected:   ((res AND 2^29) EQ 0), $
          collimator:         ((res AND 2^30) ne 0)  $
         }

return, status
end

;;;;;
;
; fablaser_IPG::Command()
;
; Send command to IPG laser and return response
;
function fablaser_IPG::Command, cmd

COMPILE_OPT IDL2, HIDDEN

self.port.write, cmd
str = self.port.read()

; NULL return suggests that device is not responding
; ... perhaps not an IPG laser?
if strlen(str) lt 1 then $
   return, ''

; Check for bad command
if strcmp(str, 'BCMD', /fold_case) then begin
   message, cmd + ': invalid command', /inf
   return, ''
endif

; Check for other error conditions
res = stregex(str, 'ERR: (.*)', /subexpr, /extract)
if strlen(res[0]) ge 1 then begin
   message, 'ERROR: ' + cmd + ': ' + res[1], /inf
   return, ''
endif

; Successful commands return strings in the format
; CMD: Response string
res = stregex(str, cmd+': (.*)', /subexpr, /extract)

; Check for invalid response
if strlen(res[0]) lt 1 then $
   return, ''

; Success
return, res[1]

end

;;;;;
;
; fablaser_IPG::SetProperty
;
; Set properties of the IPG laser object
;
pro fablaser_IPG::SetProperty, emission = emission, $
                               current = current, $
                               _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fablaser::setproperty, _extra = re

if isa(emission, /scalar, /number) then $
   void = self.emission(emission)

if isa(current, /scalar, /number) then $
   void = self.current(current)

end

;;;;;
;
; fablaser_IPG::GetProperty
;
; Get properties of the IPG laser object
;
pro fablaser_IPG::GetProperty, device = device, $
                               firmware = firmware, $
                               status = status, $
                               _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fablaser::getproperty, _extra = re

if arg_present(device) then $
   device = self.port.device

if arg_present(firmware) then $
   firmware = self.command('RFV')

if arg_present(status) then $
   status = self.status()

end

;;;;;
;
; fablaser_IPG::Cleanup
;
; Free resources used by the IPG laser object
;
pro fablaser_IPG::Cleanup

obj_destroy, self.port
end

;;;;;
;
; fablaser_IPG::Init
;
; Initialize the IPG laser object
;
function fablaser_IPG::Init, device = device, $
                             quiet = quiet

COMPILE_OPT IDL2, HIDDEN

if ~self.fablaser::Init(wavelength = 1.07) then $
   return, 0B

if ~isa(device, 'string') then begin
   message, 'Specify the RS232 device file for the IPG laser', /inf
   return, 0B
endif

; open serial port
port = fabserial(device)
if ~isa(port, 'fabserial') then $
   return, 0B

; save present settings so that they can be restored
osettings = port.settings

; settings for IPG laser determined with minicom
; and recorded with stty -g
port.settings = ['0:0:18b1:0:3:1c:7f:15:4:0:1:0:11:13' + $
                 ':1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0']
port.eol = string(13b)

self.port = port

; check that this really is an IPG laser
res = self.command('RFV')
if strlen(res) le 1 then begin  ; if not ...
   if ~keyword_set(quiet) then $
   message, device + ' does not appear to be an IPG laser', /inf
   port.settings = osettings    ; restore port settings
   obj_destroy, self.port
   return, 0B
end

self.name = 'fablaser_IPG '
self.description = 'IPG Fiber Laser '
self.wavelength = 1.07
self.registerproperty, 'device', /string, sensitive = 0
self.registerproperty, 'firmware', /string, sensitive = 0
self.setpropertyattribute, 'current', valid_range = [10., 35., 0.1]
return, 1
end

;;;;;
;
; fablaser_IPG__define
;
; Object definition for an IPG fiber laser
;
pro fablaser_IPG__define

COMPILE_OPT IDL2, HIDDEN

struct = {fablaser_IPG,           $
          inherits fablaser,     $
          port: obj_new()          $
         }
end
