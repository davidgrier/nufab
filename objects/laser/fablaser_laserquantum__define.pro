;+
; NAME:
;    fablaser_LaserQuantum
;
; PURPOSE:
;    Object class for controlling a LaserQuantum laser
;
; CATEGORY:
;    Equipment control
;
; USAGE:
;    a = fablaser_LaserQuantum(device)
;
; PROPERTIES:
;    DEVICE:         [IG ] Name of the communication port's device file
;    KEYSWITCH:      [ G ] Keyswitch status: 1 on, 0 off
;    EMISSION:       [ GS] Emission status:  1 on, 0 off
;    SHUTTER:        [ GS] Shutter stats: 1 open, 0 closed
;    POWER:          [ G ] Emission power [W]
;    TEMPERATURE:    [ G ] Laser head temperature [degrees C]
;    PSUTEMPERATURE: [ G ] Power supply temperature [degrees C]
;    VERSION:        [ G ] Firmware version
;
; METHODS:
;    fablaser_LaserQuantum::GetProperty
;    fablaser_LaserQuantum::SetProperty
;
; SUBCLASSES:
;    fablaser
;
; EXAMPLE:
; IDL> a = fablaser_LaserQuantum("/dev/ttyUSB0")
; IDL> a.emission = 1
; IDL> a.power = 0.2
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
; 01/02/2014 DGG Adapted from IPG to LaserQuantum.
; 01/22/2014 DGG Minimize power and close shutter on cleanup.
; 01/30/2014 DGG Better regular expressions for command responses.
;
; Copyright (c) 2011-2014 David G. Grier
;-

;;;;;
;
; fablaser_LaserQuantum::Temperature()
;
; Temperature of laser head
;
function fablaser_LaserQuantum::Temperature

COMPILE_OPT IDL2, HIDDEN

return, float(strmid(self.command('HTEMP?'), 1, 6))
end

;;;;;
;
; fablaser_LaserQuantum::PSUTemperature()
;
; Temperature of power supply
;
function fablaser_LaserQuantum::PSUTemperature

COMPILE_OPT IDL2, HIDDEN

return, float(strmid(self.command('PSUTEMP?'), 1, 6))
end

;;;;;
;
; fablaser_LaserQuantum::Power()
;
; Laser emission power
;
function fablaser_LaserQuantum::Power, value

COMPILE_OPT IDL2, HIDDEN

if isa(value, /number, /scalar) then begin
   if (value ge 0) and (value lt self.maxpower) then begin
      cmd = 'POWER=' + string(value, format = '(F05.3)')
      void = self.command(cmd)
   endif
endif

return, float(strmid(self.command('POWER?'), 1, 5))
end

;;;;;
;
; fablaser_LaserQuantum::Shutter()
;
; Laser shutter status
;
function fablaser_LaserQuantum::Shutter, state

COMPILE_OPT IDL2, HIDDEN

if isa(state, /number, /scalar) then begin
   cmd = 'SHUTTER ' + ((state) ? 'OPEN' : 'CLOSED')
   void = self.command(cmd)
endif
return, strmatch(self.command('SHUTTER?'), '*OPEN*')
end

;;;;;
;
; fablaser_LaserQuantum::Emission()
;
; Laser emission status
;
function fablaser_LaserQuantum::Emission, state

COMPILE_OPT IDL2, HIDDEN

if isa(state, /number, /scalar) then begin
   cmd = 'LASER=' + ((state) ? 'ON' : 'OFF')
   void = self.command(cmd)
endif
return, strmatch(self.command('STATUS?'), '*ENABLED*')
end

;;;;;
;
; fablaser_LaserQuantum::Keyswitch()
;
function fablaser_LaserQuantum::Keyswitch

COMPILE_OPT IDL2, HIDDEN

return, strmatch(self.command('INTERLOCK?'), '*ENABLED*')
end

;;;;;
;
; fablaser_LaserQuantum::Version()
;
function fablaser_LaserQuantum::Version

COMPILE_OPT IDL2, HIDDEN

str = self.command('SOFTVER?')
return, (stregex(str, '(.*) 0000123', /extract, /subexpr))[1]
end

;;;;;
;
; fablaser_LaserQuantum::Command()
;
; Send command to LaserQuantum laser and return response
;
; COMMAND REFERENCE:
; POWER=#.### Sets maximum power [W]
; POWER?      Reports power (#.###W)
; STATUS?     Reports whether laser is enabled or not
; LASER=OFF   Disables the laser and interlock circuitry
; LASER=ON    Re-enables the laser interlock circuitry.
;             Laser still will not turn on unless keyswitch
;             is set and interlock is closed.
; SHUTTER?    Reports whether shutter is open or closed
; SHUTTER OPEN  Opens laser shutter
; SHUTTER CLOSE Closes laser shutter
; INTERLOCK?    Reports status of interlock
; BACKLIGHT=### LCD backlight percentage (%)
; HTEMP?        Reports temperature of laser base (##.###C)
; PSUTEMP?      Reports temperature of the FPU driver
; SERIAL?       Reports serial number of laser
; CALDATE?      Reports date of calibration of system
; SOFTVER?      Reports version of software
; TIMERS?       Reports laser usage timers
; DATE?         Reports the date saved in firmware
; TIME?         Reports time saved in firmware
;
function fablaser_LaserQuantum::Command, cmd

COMPILE_OPT IDL2, HIDDEN

self.port.write, cmd
return, self.port.read()
end

;;;;;
;
; fablaser_LaserQuantum::SetProperty
;
; Set properties of the LaserQuantum laser object
;
pro fablaser_LaserQuantum::SetProperty, emission = emission, $
                                        shutter = shutter, $
                                        power = power, $
                                        _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fablaser::setproperty, _extra = re

if isa(emission, /scalar, /number) then $
   void = self.emission(emission)

if isa(shutter, /scalar, /number) then $
   void = self.shutter(shutter)

if isa(power, /scalar, /number) then $
   void = self.power(power)

end

;;;;;
;
; fablaser_LaserQuantum::GetProperty
;
; Get properties of the LaserQuantum laser object
;
pro fablaser_LaserQuantum::GetProperty, device = device, $
                                        keyswitch = keyswitch, $
                                        emission = emission, $
                                        shutter = shutter, $
                                        power = power, $
                                        temperature = temperature, $
                                        psutemperature = psutemperature, $
                                        version = version, $
                                        _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.fablaser::getproperty, _extra = re

if arg_present(device) then $
   device = self.port.device

if arg_present(keyswitch) then $
   keyswitch = self.keyswitch()

if arg_present(emission) then $
   emission = self.emission()

if arg_present(shutter) then $
   shutter = self.shutter()

if arg_present(power) then $
   power = self.power()

if arg_present(temperature) then $
   temperature = self.temperature()

if arg_present(psutemperature) then $
   psutemperature = self.psutemperature()

if arg_present(version) then $
   version = self.version()

end

;;;;;
;
; fablaser_LaserQuantum::Cleanup
;
; Free resources used by the LaserQuantum laser object
;
pro fablaser_LaserQuantum::Cleanup

COMPILE_OPT IDL2, HIDDEN

message, 'shutting down', /inf
void = self.power(0.)
void = self.shutter(0.)
obj_destroy, self.port
end

;;;;;
;
; fablaser_LaserQuantum::Init
;
; Initialize the LaserQuantum laser object
;
function fablaser_LaserQuantum::Init, device = device, $
                                      _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~self.fablaser::Init(wavelength = 0.532, $
                        minpower = 0, maxpower = 2.5, $
                        _extra = re) then $
   return, 0B

if ~isa(device, 'string') then begin
   message, 'Specify the RS232 device file for the LaserQuantum laser', /inf
   return, 0B
endif

; open serial port
port = fabserial(device)
if ~isa(port, 'fabserial') then $
   return, 0B

; save present settings so that they can be restored
osettings = port.settings

; RS232 Settings: 19,200 baud, no paraity, 1 stop bit,
; no handshaking.  Each command is terminated with <cr>,
; and any relevant response is terminated with <cr>.
; settings for LaserQuantum laser determined with minicom
; and recorded with stty -g
port.settings = ['1:0:8be:0:3:1c:7f:15:4:5:1:0:11:13' + $
                 ':1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0']
port.eol = string(13b)

self.port = port

; check that this really is a LaserQuantum laser

res = self.command('STATUS?')
if strlen(res) le 1 then begin  ; if not ...
   message, device + ' does not appear to be a LaserQuantum laser', /inf
   port.settings = osettings    ; restore port settings
   obj_destroy, self.port
   return, 0B
end

self.name = 'fablaser_LaserQuantum '
self.description = 'LaserQuantum Laser '
self.registerproperty, 'device', /string, sensitive = 0
self.setpropertyattribute, 'keyswitch', sensitive = 0
self.setpropertyattribute, 'current', /hide
self.setpropertyattribute, 'temperature', sensitive = 0
self.setpropertyattribute, 'wavelength', sensitive = 0
self.registerproperty, 'psutemperature', /float, sensitive = 0
self.registerproperty, 'version', /string, sensitive = 0
return, 1
end

;;;;;
;
; fablaser_LaserQuantum__define
;
; Object definition for an LaserQuantum laser
;
pro fablaser_LaserQuantum__define

COMPILE_OPT IDL2, HIDDEN

struct = {fablaser_LaserQuantum, $
          inherits fablaser,     $
          port: obj_new()        $
         }
end
