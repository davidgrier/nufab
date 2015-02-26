;+
; NAME:
;    nufab_wait
;
; PURPOSE:
;    Wait for fixed time during programmatic interaction with nuFAB,
;    while continuing to update video.
;
; CATEGORY:
;    nuFAB
;
; CALLING SEQUENCE:
;    nufab_wait, delay
;
; INPUTS:
;    delay: delay time [seconds]
;
; SIDE EFFECTS:
;    Does not allow for user interaction during waiting period.
;
; MODIFICATION HISTORY:
; 09/12/2013 Written by David G. Grier, New York University
; 09/16/2013 DGG Uses fab_video_update for better integration.
; 02/26/2015 DGG Updated for nufab.
;
; Copyright (c) 2013-2015 David G. Grier
;-

pro nufab_wait, delay

COMPILE_OPT IDL2

t0 = systime(1)
t1 = t0 + delay

s = getnufab()
if ~isa(s, 'hash') then begin
   wait, delay
   return
endif

v = s['video']
dt = v.frametime - 0.001        ; interval between frames
if delay lt dt then begin
   wait, delay
   return
endif

ddt = 2.*dt                     ; guaranteed long interval
v.playing = 0                   ; stop automatic video updating
repeat begin
   tmr = timer.set(ddt, v)      ; set long-interval timer
   wait, dt                     ; wait real frame interval 
   void = timer.fire(tmr)       ; fire the timer to update video
endrep until (t1 - systime(1)) le dt
v.playing = 1                   ; restart video
wait, (t1 - systime(1)) > 0

end
