;+
; NAME:
;    nufab_snap
;
; PURPOSE:
;    Take a picture with the nufab video system.
;
; CATEGORY:
;    Hardware control
;
; CALLING SEQUENCE:
;    a = nufab_snap([s])
;
; OPTIONAL INPUTS:
;    s: state hash for the running nufab system.
;        Obtained with getnufab(), if not provided.
;
; KEYWORD PARAMETERS:
;    delay: time to wait before acquiring image [second]
;
;    max: return an image of the maximum value at each pixel in a
;        specified number of frames.
;
;    min: return minimum intensity in a specified number of frames.
;
;    mean: return the average of a specified number of images
;
; OUTPUTS:
;    a: byte-valued array containing one image.
;
; RESTRICTIONS:
;    Does nothing if nufab is not running.
;
; MODIFICATION HISTORY:
; 12/30/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

function nufab_snap, s, $
                     delay = delay, $
                     max = max, $
                     min = min, $
                     mean = mean

COMPILE_OPT IDL2, HIDDEN

if n_params() eq 0 then $
   s = getnufab()

if ~isa(s, 'hash') then $
   return, 0

if ~s.haskey('camera') then $
   return, 0

a = s['camera'].read()

if isa(delay, /number, /scalar) then begin
   nframes = long(delay*s['video'].frame_rate)
   for i = 1, nframes do $
      a = s['camera'].read()
endif

if isa(max, /number, /scalar) then begin
   for i = 2, max do $
      a >= s['camera'].read()
endif

if isa(mean, /number, /scalar) then begin
   for i = 2, mean do $
      a += float(s['camera'].read())
   a = byte(a/mean)
endif

return, a
end
