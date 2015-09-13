;+
; NAME:
;    nufab_Filter_Median
;
; PURPOSE:
;    Median filter for the nufab video system
;
; SUPERCLASSES:
;    nufab_Filter
;
; PROPERTIES:
; [I S] source: Object reference to source of images
; [ G ] data: Median filtered image from source.
; [IGS] order: Order of the filter
;        Default: 3
; [IGS] running: Flag: If set, performing running median
;
; METHODS:
;    GetProperty
;    SetProperty
;
; NOTES:
;    Should handle color images: median on each channel
;
; MODIFICATION HISTORY:
; 03/15/2015 Written by David G. Grier, New York University
;
; Copyright (c) David G. Grier
;-
;;;;;
;
; nufab_filter_median::GetProperty
;
pro nufab_filter_median::GetProperty, data = data, $
                                       order = order, $
                                       running = running

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(data) then begin
     data = self.source.data
     if obj_valid(self.median) then begin
        if self.running || ~self.median.initialized then $
           self.median.add, data
        data = byte(128.*float(data)/self.median.get())
     endif
  endif

  if arg_present(order) then $
     order = self.order

  if arg_present(running) then $
     running = self.running
end

;;;;;
;
; nufab_filter_median::SetProperty
;
pro nufab_filter_median::SetProperty, source = source, $
                                       order = order, $
                                       running = running
  COMPILE_OPT IDL2, HIDDEN

  !except = self.except

  if obj_valid(source) then begin
     self.source = source
     data = self.source.data
     if obj_valid(self.median) then $
        obj_destroy, self.median
     self.median = numedian(order = self.order, data = data)
  endif

  if isa(order, /number, /scalar) then begin
     self.order = long(order) > 3
     self.median.order = self.order
  endif

  if isa(running, /number, /scalar) then $
     self.running = keyword_set(running)
end

;;;;;
;
; nufab_filter_median::Init()
;
function nufab_filter_median::Init, source = source, $
                                     order = order, $
                                     running = running

  COMPILE_OPT IDL2, HIDDEN

  if ~self.nufab_filter::Init(source = source) then $
     return, 0B
  
  self.order = isa(order, /number, /scalar) ? long(order) > 3L : 3L

  if isa(self.source) then begin
     self.median = numedian(order = self.order, data = self.source.data)
     if ~isa(self.median) then $
        return, 0B
  endif

  self.running = keyword_set(running)

  self.except = !except
  !except = 0

  return, 1B
end

;;;;;
;
; nufab_filter_median__define
;
; Running median filter image normalization for nufab
;
pro nufab_filter_median__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_filter_median, $
            inherits nufab_filter, $
            median: obj_new(), $
            order: 0L, $
            running: 0L, $
            except: 0L $
           }
end
