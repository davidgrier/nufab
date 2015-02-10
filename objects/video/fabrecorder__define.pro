;+
; NAME:
;    fabRecorder
;
; PURPOSE:
;    This object saves data files to a specified directory
;    using IDL_IDLBridges to obtain low-latency operation.
;    Its intended use is to save frame-accurate sequences of
;    images for digital video applications.
;
; SUBCLASSES:
;    IDL_Object
;
; PROPERTIES:
;    DIRECTORY: String containing directory for saving images
;        Default: './' current directory
;        [IGS]
;
;    FORMAT: Name of current file format
;        Default: 'gdf'
;        [IGS]
;
;    FORMATS: String array of supported formats
;        [ G ]
;
;    NTHREADS: Number of threads for saving images
;        Default: 1
;        Each thread is responsible for saving one image.
;        Increasing the number of threads improves performance
;        by increasing the number of file-save operations that
;        can occur concurrently at the expense of increasing
;        memory requirements.  This reduces the chance of
;        dropped frames.  Performance ultimately depends on the
;        speed of the hardware, however, and adding too many
;        threads can overwhelm hardware and reduce performance.
;        [IGS]
;               
;    TIMEZONE: Offset in hours from GMT, used for timestamps
;        Default: -4
;        [IGS]
;
; METHODS:
;    fabRecorder::GetProperty
;
;    fabRecorder::SetProperty
;
;    fabRecorder::Write()
;    SYNTAX:
;        res = fabRecorder::Write(image, [time])
;        
;    INPUT:
;        image: data to be written to the data directory in the
;            selected format with the current timestamp for a file
;            name.
;    OPTIONAL INPUT:
;        time: systime at which image was recorded.
;            Default: systime(1)
;
;    OUTPUT:
;        res: file name on success, empty string on failure
;
; NOTES:
;    Implement preprocessing: flipx, flipy, grayscale
;
; MODIFICATION HISTORY:
; 10/13/2011: Written by David G. Grier, New York University
; 05/04/2012 DGG Make sure that parameters have the correct type.
; 05/15/2012 DGG Write method returns empty string on failure.
; 09/16/2013 DGG Write accepts optional TIME argument.
; 12/20/2013 DGG major overhaul for new fab implementation.
; 02/10/2015 DGG update declaration of BRIDGES.
;
; Copyright (c) 2011-2015, David G. Grier
;-

;;;;;
;
; fabRecorder::Write
;
; Save one image to a file
; Return the file name as a string, or an empty string on failure.
;
function fabRecorder::Write, a, time

COMPILE_OPT IDL2, HIDDEN

t = (n_params() eq 1) ? time : systime(1)
t += self.timezone * 3600D
timestamp = string(t - floor(t/86400D) * 86400D, format = '(F012.6)')
fn = self.directory + timestamp + '.' + self.format

foreach bridge, self.bridges do begin
   if bridge.status() eq 0 then begin
      bridge.setvar, 'A', a
      bridge.setvar, 'FN', fn
      bridge.execute, self.cmd, /NOWAIT
      return, fn
   endif
endforeach

return, ''

end

;;;;;
;
; fabRecorder::MakeCommand
;
; Create the command line for the IDL_IDLBridge
;
pro fabRecorder::MakeCommand

COMPILE_OPT IDL2, HIDDEN

case self.format of
   'png'  : self.cmd = 'write_png,  FN, A'
   'bmp'  : self.cmd = 'write_bmp,  FN, A'
   'gif'  : self.cmd = 'write_gif,  FN, A'
   'jpeg' : self.cmd = 'write_jpeg, FN, A, QUALITY=100' ; order
   'ppm'  : self.cmd = 'write_ppm,  FN, A'
   'srf'  : self.cmd = 'write_srf,  FN, A' ; order
   'tiff' : self.cmd = 'write_tiff, FN, A' ; compression, orientation
   'gdf'  : self.cmd = 'write_gdf,  A, FN'
   else   : self.cmd = 'write_png,  FN, A'
endcase

end

;;;;;
;
; fabRecorder::SetProperty
;
; Set properties of the recorder object
;
pro fabRecorder::SetProperty, directory = directory, $
                              format = format, $
                              nthreads = nthreads, $
                              timezone = timezone

COMPILE_OPT IDL2, HIDDEN

if isa(directory, 'string') then begin
   if ~file_test(directory, /directory) then $
      file_mkdir, directory
   if file_test(directory, /directory, /write) then begin
      self.directory = directory
      if ~stregex(directory, '/$', /boolean) then $
         self.directory += '/'
   endif else begin
      message, 'Cannot open '+directory+' for writing', /inf
      message, 'Continuing to write to '+self.directory, /inf
   endelse
endif

if isa(format, 'string') then begin
   self.format = format
   self.makecommand
endif

if isa(nthreads, /scalar, /number) then $
   if ~self.allocate(nthreads) then $
      message, 'Failed to reallocate all requested threads', /inf

if isa(timezone, /scalar, /number) then $
   self.timezone = double(timezone)

end

;;;;;
;
; fabRecorder::GetProperty
;
; Get properties of the recorder object
;
pro fabRecorder::GetProperty, directory = directory, $
                              format = format, $
                              formats = formats, $
                              nthreads = nthreads, $
                              timezone = timezone

COMPILE_OPT IDL2, HIDDEN

if arg_present(directory) then $
   directory = self.directory

if arg_present(format) then $
   format = self.format

if arg_present(formats) then $
   formats = self.formats

if arg_present(nthreads) then $
   nthreads = self.bridges.count()

if arg_present(timezone) then $
   timezone = self.timezone

end

;;;;;
;
; fabRecorder::Allocate
;
; Allocate IDL_IDLBridges
;
function fabRecorder::Allocate, nthreads

COMPILE_OPT IDL2, HIDDEN

self.bridges.remove, /all

if nthreads lt 1 then $
   return, 0B

for i = 0, nthreads-1 do begin
   bridge = IDL_IDLBridge()
   if ~isa(bridge) then $
      break
   self.bridges.add, bridge
endfor

return, self.bridges.count() gt 0
end

;;;;;
;
; fabRecorder::Cleanup
;
pro fabRecorder::Cleanup

COMPILE_OPT IDL2, HIDDEN

self.bridges.remove, /all

end

;;;;;
;
; fabRecorder::Init
;
; Initialize the recorder object
;
function fabRecorder::Init, directory = directory, $
                            nthreads = nthreads, $
                            format = format, $
                            timezone = timezone

COMPILE_OPT IDL2, HIDDEN

if ~isa(directory, 'String') then $
   directory = './'                   ; default to current working directory
if ~stregex(directory, '/$', /boolean) then $
   directory += '/'
if ~file_test(directory, /directory, /write) then begin
   message, 'Cannot write to '+directory, /inf
   return, 0B
endif
self.directory = directory

self.timezone = (isa(timezone, /scalar, /number)) ? double(timezone) : -4D

self.formats = ['png', 'bmp', 'gif', 'jpeg', 'ppm', 'srf', 'tiff', 'gdf']

self.format = (isa(format, 'string')) ? format : 'png'
self.makecommand

self.bridges = list()
nthreads = (isa(nthreads, /scalar, /number)) ? long(nthreads) : 1L
return, self.allocate(nthreads)
end



;;;;;
;
; fabRecorder__define
;
; Define the object structure for a fabRecorder
;
pro fabRecorder__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabRecorder,            $
          inherits   IDL_Object,  $
          bridges:   obj_new(),   $ ; bridge objects
          directory: '',          $ ; directory for recording images
          formats:   strarr(8),   $ ; recognized formats
          format:    '',          $ ; file format
          timezone:  0D,          $ ; current offset from GMT
          cmd:       ''           $ ; IDL_IDLBridge, execute=cmd
         }
end
