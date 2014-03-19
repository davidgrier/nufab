;+
; NAME:
;    fabmedian__define
;
; PURPOSE:
;    Defines an object for computing the running median of a sequence
;    of images.
;
; PROPERTIES
;    NFRAMES     [IG ]
;        Number of frames in buffer
;
;    INITIALIZED [ G ]
;        Flag: true if buffer is completely filled
;
;    DATA        [ G ]
;        Present estimate for the median
;
; METHODS
;    Init: a = fabmedian(nframes, data)
;
;    fabmedian::Add, data
;        Store data in the buffer
;
;    fabmedian::Get()
;        Get the running median
;
; MODIFICATION HISTORY:
; 05/26/2013 Written by David G. Grier, New York University
; 11/25/2013 DGG Set even keyword for median.  Clean up Init method.
; 03/04/2014 DGG DATA and INITIALIZED properties
;
; Copyright (c) 2013 David G. Grier
;-

;;;;;
;
; fabmedian::get
;
; Compute and return running median
;
function fabmedian::get

COMPILE_OPT IDL2, HIDDEN

if ~self.initialized then begin
   if self.ndx eq 0 then $
      return, (*self.buffer)[*, *, 0]
   return, median((*self.buffer)[*, *, 0:self.ndx], dim = 3, /even)
endif

return, median(*self.buffer, dim = 3, /even)
end

;;;;;
;
; fabmedian::add
;
; Store data into the buffer
;
pro fabmedian::add, data

COMPILE_OPT IDL2, HIDDEN

self.ndx = (self.ndx + 1) mod self.nframes
if self.ndx eq 0 then self.initialized = 1

(*(self.buffer))[*, *, self.ndx] = data

end

;;;;;
;
; fabmedian::GetProperty
;
pro fabmedian::GetProperty, data = data, $
                            nframes = nframes, $
                            initialized = initialized

COMPILE_OPT IDL2, HIDDEN

if arg_present(data) then $
   data = self.get()

if arg_present(nframes) then $
   nframes = self.nframes

if arg_present(initialized) then $
   initialized = self.initialized

end

;;;;;
;
; fabmedian::Init
;
function fabmedian::Init, nframes, data

COMPILE_OPT IDL2, HIDDEN

umsg = 'USAGE: a = fabmedian(nframes, data)'

if n_params() ne 2 then begin
   message, umsg, /inf
   return, 0B
endif

if ~isa(nframes, /number, /scalar) then begin
   message, umsg, /inf
   message, 'NFRAMES should be the number of data sets in the median', /inf
   return, 0B
endif

if nframes le 1 then begin
   message, umsg, /inf
   message, 'NFRAMES must be greater than 1', /inf
   return, 0B
endif

self.nframes = nframes

if ~isa(data, /array, /number) then begin
   message, umsg, /inf
   message, 'DATA should be a two-dimensional numeric array', /inf
   return, 0B
endif else begin
   sz = size(data)
   if sz[0] ne 2 then begin
      message, umsg, /inf
      message, 'DATA must be a two-dimensional array', /inf
      return, 0B
   endif
   self.dimensions = sz[1:2]
   a = rebin(data, sz[1], sz[2], nframes, /sample)
   self.buffer = ptr_new(a, /no_copy)
endelse

return, 1B
end

;;;;;
;
; fabmedian::cleanup
;
; Release resources
;
pro fabmedian::cleanup

COMPILE_OPT IDL2, HIDDEN

ptr_free, self.buffer

end

;;;;;
;
; fabmedian__define
;
; Defines the running median object
;
pro fabmedian__define

COMPILE_OPT IDL2

struct = {fabmedian, $
          inherits fab_object, $
          buffer: ptr_new(), $
          dimensions: [0, 0], $
          nframes: 0, $
          ndx: 0, $
          initialized: 0B}
end
