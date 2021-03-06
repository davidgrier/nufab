;+
; NAME:
;    numedian
;
; PURPOSE:
;    Computes running median of image data using a reasonably
;    fast and memory efficient hierarchical algorithm
;
; INHERITS:
;    IDL_Object
;
; SYNTAX:
;    a = numedian([order])
;
; OPTIONAL ARGUMENT:
;
; PROPERTIES:
; [I S] data: image data for initializing median calculation.
;        Resets median buffer when set.
;
; [IGS] dimensions: [nx, ny] dimensions of image buffer.
;        Resets median buffer if set.
;
; [IGS] order: number of orders for median buffer hierarchy.
;        Effective buffer size is 3^(order + 1).
;        Setting order restarts initialization.
;
; [ GS] initialized: flag: 1 if median buffer fully initialized.
;        Setting initialized to 0 resets median buffer.
;
; METHODS:
;    numedian::Add, data
;        Adds image data to median buffer.
;
;    numedian::Get()
;        Computes and returns current median
;
; MODIFICATION HISTORY:
; 04/06/2014 Written by David G. Grier, New York University
; 09/14/2015 DGG Formatting and documentation.
;
; Copyright (c) 2014-2015 David G. Grier
;-

;;;;;
;
; numedian::Get()
;
function numedian::Get

  COMPILE_OPT IDL2, HIDDEN

  return, median(*self.buffer, dim = 1)
end

;;;;;
;
; numedian::Add
;
pro numedian::Add, data

  COMPILE_OPT IDL2, HIDDEN

  if n_params() ne 1 then return

  if isa(self.next, 'numedian') then begin
     self.next.add, data
     if self.next.ndx eq 0 then $
        (*self.buffer)[self.ndx++, *, *] = self.next.get()      
  endif else if array_equal(size(data, /dimensions), self.dimensions) then $
     (*self.buffer)[self.ndx++, *, *] = data
  
  if self.ndx eq 3 then begin
     self.initialized = 1
     self.ndx = 0
  endif
end

;;;;;
;
; numedian::SetProperty
;
pro numedian::SetProperty, order = order, $
                           dimensions = dimensions, $
                           data = data, $
                           initialized = initialized

  COMPILE_OPT IDL2, HIDDEN

  if isa(order, /number, /scalar) then begin
     self.order = (long(order) > 0) < 10
     if self.order eq 0 then $
        self.next = obj_new() $
     else begin
        if isa(self.next, 'numedian') then $
           self.next.order = self.order - 1 $
        else $
           self.next = numedian(order = order - 1, dimensions = self.dimensions)
     endelse
     self.initialized = 0
  endif

  if isa(self.next, 'numedian') then $
     self.next.setproperty, dimensions = dimensions, data = data, $
                            initialized = initialized
  
  if isa(dimensions, /number) then begin
     self.dimensions = long(dimensions)
     self.buffer = ptr_new(replicate(1B, [3, self.dimensions]))
     self.ndx = 1L
     self.initialized = 0
  endif

  if isa(data, /number, /array) then begin
     self.dimensions = size(data, /dimensions)
     self.buffer = ptr_new(bytarr([3, self.dimensions]))
     for i = 0, 2 do $
        (*self.buffer)[i, *, *] = data
     self.ndx = 1L
     self.initialized = 0
  endif

  if isa(initialized, /number, /scalar) then $
     self.initialized = keyword_set(initialized)
end

;;;;;
;
; numedian::GetProperty
;
pro numedian::GetProperty, ndx = ndx, $
                           order = order, $
                           dimensions = dimensions, $
                           buffer = buffer, $
                           initialized = initialized

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(ndx) then $
     ndx = self.ndx

  if arg_present(order) then $
     order = self.order

  if arg_present(dimensions) then $
     dimensions = self.dimensions

  if arg_present(buffer) then $
     buffer = self.buffer

  if arg_present(initialized) then $
     initialized = self.initialized
end

;;;;;
;
; numedian::Init()
;
function numedian::Init, order = order, $
                         data = data, $
                         dimensions = dimensions

  COMPILE_OPT IDL2, HIDDEN

  if order gt 0 then begin
     self.order = order
     self.next = numedian(order = self.order-1, data = data, dimensions = dimensions)
  endif

  if isa(dimensions, /number) and (n_elements(dimensions) eq 2) then begin
     self.dimensions = long(dimensions)
     self.buffer = ptr_new(replicate(1B, [3, self.dimensions]))
  endif

  if isa(data, /number, /array) and (size(data, /n_dimensions) eq 2) then begin
     self.dimensions = size(data, /dimensions)
     self.buffer = ptr_new(bytarr([3, self.dimensions]))
     for i = 0, 2 do $
        (*self.buffer)[i, *, *] = data
     self.ndx = 1
  endif

  self.initialized = 0

  return, 1B
end

;;;;;
;
; numedian::Cleanup
;
pro numedian::Cleanup

  COMPILE_OPT IDL2

  if isa(self.next, 'numedian') then $
     obj_destroy, self.next
  ptr_free, self.buffer
end

;;;;;
;
; numedial__define
;
pro numedian__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {numedian, $
            inherits IDL_Object, $
            buffer: ptr_new(), $
            dimensions: [0L, 0], $
            ndx: 0L, $
            initialized: 0L, $
            order: 0L, $
            next: obj_new() $
           }
end
