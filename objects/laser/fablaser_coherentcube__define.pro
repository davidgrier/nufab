;+
; NAME:
;    fablaser_CoherentCube
;
; PURPOSE:
;    Object class for controlling a Coherent Cube laser
;
; CATEGORY:
;    Equipment control
;
; USAGE:
;    a = fablaser_CoherentCube(device)
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
;    fablaser_CoherentCube::GetProperty
;    fablaser_CoherentCube::SetProperty
;
; SUBCLASSES:
;    fablaser
;
; EXAMPLE:
; IDL> a = fablaser_CoherentCube("/dev/ttyUSB0")
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
; 01/02/2014 DGG Adapted from IPG to CoherentCube.
; 01/22/2014 DGG Minimize power and close shutter on cleanup.
;
; Copyright (c) 2011-2014 David G. Grier
;-

;;;;;
;
; fablaser_CoherentCube::Temperature()
;
; Temperature of laser head
;
function fablaser_CoherentCube::Temperature

COMPILE_OPT IDL2, HIDDEN

return, float(strmid(self.command('?BT'), 3, 2))
end

;;;;;
;
; fablaser_CoherentCube::PSUTemperature()
;
; Temperature of power supply
;
function fablaser_CoherentCube::PSUTemperature

COMPILE_OPT IDL2, HIDDEN

return, float(strmid(self.command('?PST'), 4, 6))
end

;;;;;
;
; fablaser_CoherentCube::Power([value])
;
; Laser emission power
;
function fablaser_CoherentCube::Power, value

COMPILE_OPT IDL2, HIDDEN

if isa(value, /number, /scalar) then begin
   val = value < self.maxpower > self.minpower
   cmd = 'P=' + string(value, format = '(F5.2)')
   void = self.command(cmd)
endif

res = self.command('?P')
return, float(strmid(res, 2, strlen(res)-2))
end

;;;;;
;
; fablaser_CoherentCube::Current()
;
function fablaser_CoherentCube::Current

COMPILE_OPT IDL2, HIDDEN

res = self.command('?C')
return, float(strmid(res, 2, strlen(res)-2))
end

;;;;;
;
; fablaser_CoherentCube::Shutter()
;
; Laser shutter status
;
function fablaser_CoherentCube::Shutter, state

COMPILE_OPT IDL2, HIDDEN

void = self.command('CDRH=0')
cmd = isa(state, /number, /scalar) ? $
      'L=' + ((state) ? '1' : '0') : $
      '?L'
res = self.command(cmd)
void = self.command('CDRH=1')
return, strmatch(res, 'L=1')
end

;;;;;
;
; fablaser_CoherentCube::Emission()
;
; Laser emission status
;
function fablaser_CoherentCube::Emission, state

COMPILE_OPT IDL2, HIDDEN

if ~self.keyswitch() then $
   return, 0B
if isa(state, /number, /scalar) then begin
   cmd = 'T=' + ((state) ? '1' : '0')
   void = self.command(cmd)
endif
return, strmatch(self.command('?T'), 'T=1')
end

;;;;;
;
; fablaser_CoherentCube::Keyswitch()
;
function fablaser_CoherentCube::Keyswitch

COMPILE_OPT IDL2, HIDDEN

res = self.command('?K')
return, strmatch(res[0], 'K=1')
end

;;;;;
;
; fablaser_CoherentCube::Version()
;
function fablaser_CoherentCube::Version

COMPILE_OPT IDL2, HIDDEN

return, self.command('?SV')
end

;;;;;
;
; fablaser_CoherentCube::Command()
;
; Send command to Coherent Cube laser and return response
;
; COMMAND REFERENCE:
; Commands may be prefaced with '?' to query property
; >=0 [1]   : Command prompt                (default off)
; CDRH=1 [0]: five-second delay             (default on)
; ?BT       : Base temperature 0-55 C       (query only)
; ?C        : Diode current [0.1 mA]        (query only)
; CLS       : Clear communication screen    (no ? form)
; ?DST      : Diode set temperature 15-35 C (query only)
; ?DT       : Diode temperature 15-35 C     (query only)
; E=0 [1]   : Echo on/off                   (default off)
; ?F        : Fault number                  (query only)
; ?FF       : Fault binary code             (query only)
; ?FL       : Fault list                    (query only)
; ?HH       : Head hours [second]           (query only)
; ?HID      : Head ID number                (query only)
; L=0 [1]   : Laser off [on]
; ?LT       : Laser type                    (query only)
; OP=1 [2,3]: Operating protocol            (default 1)
; P=0       : Laser power [mW]
; ?PSH      : Laser hours
; ?PST      : Computer temperature
; SP=0      : Laser power set point [mW]
; ?SS       : Thermoelectric cooler status  (query only)
; ?SV       : Software version              (query only)
; ?STA      : Operating status:             (query only)
;             1: Warm up
;             2: Standby
;             3: Laser on
;             4: Error
;             5: Fatal error, system halted
; ?M        : Manual mode (query only)
; ?MINLP    : Minimum laser power [mW]      (query only)
; ?MAXLP    : Maximum laser power [mW]      (query only)
; ?NOMP     : Nominal CW power output [mW]  (query only)
; ?WAVE     : Wavelength [nm]               (query only)
; ?INT      : Interlock status              (query only)
; ?PVPS     : Protocol version              (query only)
; T=1 [0]   : Thermoelectric cooler         (default on)
; CW=1 [0]  : CW mode                       (default on)
; ANA=0 [1] : Analog control mode           (default off)
; EXT=0 [1] : External control mode         (default off)
;
function fablaser_CoherentCube::Command, cmd

COMPILE_OPT IDL2, HIDDEN

self.port.write, cmd
res = self.port.read()
while strlen((s = self.port.read())) gt 1 do $
   res = [res, s]
if n_elements(res) gt 1 then begin
   w = where(strlen(res) gt 0, count)
   if count lt 1 then $
      return, ''
   res = res[w]
endif
return, res
end

;;;;;
;
; fablaser_CoherentCube::SetProperty
;
; Set properties of the CoherentCube laser object
;
pro fablaser_CoherentCube::SetProperty, emission = emission, $
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
; fablaser_CoherentCube::GetProperty
;
; Get properties of the CoherentCube laser object
;
pro fablaser_CoherentCube::GetProperty, device = device, $
                                        keyswitch = keyswitch, $
                                        emission = emission, $
                                        shutter = shutter, $
                                        power = power, $
                                        current = current, $
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

if arg_present(current) then $
   current = self.current()

if arg_present(temperature) then $
   temperature = self.temperature()

if arg_present(psutemperature) then $
   psutemperature = self.psutemperature()

if arg_present(version) then $
   version = self.version()

end

;;;;;
;
; fablaser_CoherentCube::Cleanup
;
; Free resources used by the CoherentCube laser object
;
pro fablaser_CoherentCube::Cleanup

COMPILE_OPT IDL2, HIDDEN

message, 'shutting down', /inf
void = self.power(0.)
void = self.shutter(0.)
obj_destroy, self.port
end

;;;;;
;
; fablaser_CoherentCube::Init
;
; Initialize the CoherentCube laser object
;
function fablaser_CoherentCube::Init, device = device, $
                                      wavelength = wavelength, $
                                      _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~isa(device, 'string') then begin
   message, 'Specify the RS232 device file for the CoherentCube laser', /inf
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
; settings for CoherentCube laser determined with minicom
; and recorded with stty -g
port.settings = ['1:0:8be:0:3:1c:7f:15:4:5:1:0:11:13' + $
                 ':1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0']
port.eol = string(13b)

self.port = port

; check that this really is a CoherentCube laser
res = (self.command('?WAVE'))[0]
if strlen(res) lt 8 then begin  ; if not ...
   message, device + ' does not appear to be a Coherent Cube laser', /inf
   port.settings = osettings    ; restore port settings
   obj_destroy, self.port
   return, 0B
end
wavelength = float(strmid(res, 5, strlen(res)-5))/1000.
res = (self.command('?MINLP'))[0]
minpower = float(strmid(res, 6, strlen(res)-6))
res = (self.command('?MAXLP'))[0]
maxpower = float(strmid(res, 6, strlen(res)-6))

if ~self.fablaser::Init(wavelength = wavelength, $
                        minpower = minpower, maxpower = maxpower, $
                        _extra = re) then begin
   message, 'could not initialize fablaser', /inf
   port.settings = osettings    ; restore port settings
   obj_destroy, self.port
   return, 0B
endif

self.name = 'fablaser_CoherentCube '
self.description = 'Coherent Cube Laser '
self.registerproperty, 'device', /string, sensitive = 0
self.setpropertyattribute, 'keyswitch', sensitive = 0
self.setpropertyattribute, 'current', sensitive = 0
self.setpropertyattribute, 'temperature', sensitive = 0
self.setpropertyattribute, 'wavelength', sensitive = 0
self.registerproperty, 'psutemperature', /float, sensitive = 0
self.registerproperty, 'version', /string, sensitive = 0
return, 1
end

;;;;;
;
; fablaser_CoherentCube__define
;
; Object definition for an CoherentCube laser
;
pro fablaser_CoherentCube__define

COMPILE_OPT IDL2, HIDDEN

struct = {fablaser_CoherentCube, $
          inherits fablaser,     $
          port: obj_new()        $
         }
end
