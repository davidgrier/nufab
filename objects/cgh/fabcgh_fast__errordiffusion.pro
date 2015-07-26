;;;;;
;
; fabCGH_fast::errordiffusion
;
; Computes phase-only hologram corresponding to the
; pre-computed complex-valued hologram using
; serpentine Floyd-Steinberg error diffusion.
;
; References:
; 1. P. W. Tsang and T.-C. Poon,
; Novel method for converting digital Fresenel hologram to phase-only
; hologram based on bidirectional error diffusion,
; Optics Express 21, 23680-23686 (2013).
;
; 2. P. W. M. Tsang, A. S. M. Jiao and T.-C. Poon,
; Fast conversion of digital Fresnel hologram to phase-only
; hologram based on localized error diffusion and redistribution,
; Optics Express 22, 5060-5066 (2014).
;
; Notes:
; Also could incorporate diffusion of quantization error.
;
; MODIFICATION HISTORY:
; 07/18/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
pro fabCGH_fast::errordiffusion

  COMPILE_OPT IDL2, HIDDEN

  psi = *self.field             ; complex field in hologram plane
  psi /= mean(abs(psi))         ; normalized for error diffusion

  dim = self.slm.dimensions
  t0 = systime(1)
  for j = 0, dim[1]-3, 2 do begin
     if self.interrupt then return
     j1 = j+1
     j2 = j+2
     for i = 1, dim[0]-2 do begin ; diffuse right
        h = psi[i, j]             ; ideal complex hologram at this pixel
        hp = h/abs(h)             ; normalized hologram
        psi[i, j] = hp            ; project normalized hologram
        err = (h - hp)/16.        ; error at this pixel
        psi[i+1, j ] += 7.*err    ; diffuse error to neighbors
        psi[i-1, j1] += 3.*err
        psi[i  , j1] += 5.*err
        psi[i+1, j1] += err
     endfor
     if self.interrupt then return
     for i = dim[0]-2, 1, -1 do begin ; diffuse left
        h = psi[i, j1]                ; ideal complex hologram at this pixel
        hp = h/abs(h)                 ; normalized hologram
        psi[i, j1] = hp               ; project normalized hologram
        err = (h - hp)/16.            ; error at this pixel
        psi[i-1, j1] += 7.*err        ; diffuse error to neighbors
        psi[i+1, j2] += 3.*err
        psi[i  , j2] += 5.*err
        psi[i-1, j2] += err
     endfor
     if ((t1 = systime(1)) - t0) ge 0.1 then begin
        t0 = t1
        self.handlecallbacks
     endif
  endfor

  self.quantize, psi
end
