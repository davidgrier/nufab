;+
; NAME:
;    fabSerial
;
; PURPOSE:
;    Object for interacting with serial (RS-232) ports
;
; PROPERTIES:
;    device: name of the port's device character file
;        [RGS] Example: '/dev/ttyUSB0'
;
;    timeout: timeout for reads (seconds)
;        [IGS]
;
;    settings: command-line arguments for stty as an array of strings
;        [IGS] Example: For 9600 baud, 8N1,
;              ['9600', '-cstopb', '-parity']
;
;    lun: logical unit number of the port's IDL device
;        [ G ]
;
;    debug: if set, print all input and output activity to stdout
;        [IGS]
;    
; METHODS:
;    fabSerial::GetProperty
;    fabSerial::SetProperty
;
;    fabSerial::Write, str
;        Write string str to the serial device, terminated with the
;        eol character.
;
;    fabSerial::Read([error = error])
;        Read characters from the serial device until the eol
;        character is encountered, or an error occurs.  Return
;        the result as a string.
;        KEYWORD FLAG:
;            ERROR: Set on output if an error (timeout) occurred
;            during reading
;
;    fabSerial::Clear
;        Reads and discards all available strings in the read buffer.
;
; NOTES:
;    Can the eol character be rolled into an stty setting?
;
; MODIFICATION HISTORY:
; 06/23/2011 Written by David G. Grier, New York University
; 12/03/2011 DGG port settings returned with stty -g so that the
;    settings can be set with a subsequent call to setproperty.
;    Added DEBUG keyword.
; 02/02/2012 DGG stty incorrectly reports an error:
;    unable to perform all requested operations
;    for all regular users.  Commented out error check.  Sigh.
; 05/03/2012 DGG updated parameter checking in Init and SetPropert
; 07/08/2013 DGG added ERR keyword to Read().
; 12/28/2013 DGG revamped for nufab.
; 03/03/2014 DGG implemented Clear.
;
; Copyright (c) 2011-2013 David G. Grier
;-

;;;;;
;
; fabSerial::Clear()
;
; Read strings from the serial device until none are left
;
pro fabSerial::Clear

COMPILE_OPT IDL2, HIDDEN

timeout = self.timeout
self.timeout = 0
repeat begin
   void = self.read(error = error)
endrep until error eq 1
self.timeout = timeout

end

;;;;;
;
; fabSerial::Read()
;
; Read a string from the serial device
;
function fabSerial::Read, error = error

COMPILE_OPT IDL2, HIDDEN

str = ''
c = 'a'
error = 0
repeat begin
   if ~file_poll_input(self.lun, timeout = self.timeout) then begin
      error = 1
      break
   endif
   readu, self.lun, c, transfer_count = nbytes 
   if nbytes ne 1 then break
   if self.debug then print, c, byte(c)
   if c ne self.eol then $
      str += string(c)
endrep until c eq self.eol

return, str
end

;;;;;
;
; fabSerial::Write
;
; Write a string to the serial device
;
pro fabSerial::Write, str

COMPILE_OPT IDL2, HIDDEN

if self.debug then print, str
writeu, self.lun, str + self.eol
flush, self.lun

end

;;;;;
;
; fabSerial::SetProperty
;
; Set properties of the fabSerial object
;
pro fabSerial::SetProperty, device = device, $
                            lun = lun, $
                            settings = settings, $
                            eol = eol, $
                            timeout = timeout, $
                            debug = debug

COMPILE_OPT IDL2, HIDDEN

if isa(device) then $
   message, 'cannot change device file name', /inf

if isa(lun) then $
   message, 'cannot change logical unit number', /inf

if isa(settings, 'string') then begin
   cmd = ['stty', '-F', self.device, settings]
   spawn, cmd, /noshell, res, /stderr, exit_status = err
endif

if n_elements(eol) eq 1 then $
   self.eol = eol

if isa(timeout, /number) then $
   self.timeout = double(timeout)

if n_elements(debug) eq 1 then $
   self.debug = keyword_set(debug)

end

;;;;;
;
; fabSerial::GetProperty
;
; Get properties of the fabSerial object
;
pro fabSerial::GetProperty, device = device, $
                            lun = lun, $
                            eol = eol, $
                            timeout = timeout, $
                            settings = settings, $
                            debug = debug

if arg_present(device) then $
   device = self.device

if arg_present(lun) then $
   lun = self.lun

if arg_present(eol) then $
   eol = self.eol

if arg_present(timeout) then $
   timeout = self.timeout

if arg_present(settings) then begin
   cmd = ['stty', '-g', '-F', self.device]
   spawn, cmd, /noshell, res, /stderr, exit_status = err
   settings = res
endif

if arg_present(debug) then $
   debug = self.debug

end

;;;;;
;
; fabSerial::Cleanup
;
; Free resources used by the fabSerial object
;
pro fabSerial::Cleanup

COMPILE_OPT IDL2, HIDDEN

close, self.lun
free_lun, self.lun
end

;;;;;
;
; fabSerial::Init
;
; Initialize the fabSerial object
;
function fabSerial::Init, device, $
                          settings = settings, $
                          eol = eol, $
                          timeout = timeout

COMPILE_OPT IDL2, HIDDEN

if n_params() ne 1 then begin
   message, 'Specify the RS232 device file', /inf
   return, 0B
endif

if ~file_test(device, /read, /write, /character_special) then begin
   message, device + ' is not an accessible serial port', /inf
   return, 0B
endif

if isa(settings, 'string') then begin
   cmd = ['stty', '-F', device, settings]
   spawn, cmd, /noshell, res, /stderr, exit_status = err
endif

openw, lun, device, /get_lun, /rawio, error = err
if (err ne 0) then begin
   message, !ERROR_STATE.MSG, /inf
   return, 0B
endif

s = fstat(lun)
if ~s.open || ~s.isatty || ~s.read || ~s.write then begin
   message, 'cannot access ' + device, /inf
   close, lun
   free_lun, lun
   return, 0B
endif

if n_elements(eol) eq 1 then $
   self.eol = eol

self.timeout = isa(timeout, /number) ? double(timeout) : 0.1D

self.device = device
self.lun = lun

return, 1B
end

;;;;;
;
; fabSerial_define
;
; Object definition for a serial port
;
pro fabSerial__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabSerial, $
          inherits IDL_Object, $
          device: '',          $ ; name of character device
          lun: 0,              $ ; logical unit number
          eol: '',             $ ; end of line character
          timeout: 0.D,        $ ; maximum time to wait for read (sec)
          debug: 0             $ ; flag to turn on communications debugging
         }
end
