;+
; NAME:
;    fabCGH_fast
;
; PURPOSE:
;    Object class that computes a computer generated hologram (CGH) from
;    a trapping pattern and transmits it to a spatial light modulator
;    (SLM) for projection.
;
; INHERITS:
;    fabcgh
;
; PROPERTIES:
; [IGS] SLM: Object of type DGGhotSLM for which holograms will be
;        computed.  No computation is performed unless this is defined.
;
; [IGS] TRAPS: list of fabTrap objects describing the traps
;
; [ G ] DATA: byte-value hologram, computed from TRAPS according
;        to SLM specifications.
;
; [ GS] RC: [rx, ry, rz] coordinates of the center of the projected
;        coordinate system.
;        Default: [0, 0, 0]
;
; [ GS] MAT: Affine transformation matrix that maps requested trap
;        coordinates onto the projected coordinate system.
;        Default: 3 x 3 identity matrix.
;
; METHODS:
;    fabCGH_fast::GetProperty
;
;    fabCGH_fast::SetProperty
;
;    fabCGH_fast::Compute
;        Use traps to compute hologram according to SLM
;        specifications, then transfer the hologram to the SLM.
;
; MODIFICATION HISTORY:
; 01/20/2011 Written by David G. Grier, New York University
; 03/25/2011 DGG Work with TRAPS rather than TRAPDATA.
; 09/02/2012 DGG Fixed bug in trap superposition pointed out by
;    David Ruffner and Ellery Russel.
; 09/11/2013 DGG Added support for BACKGROUND keyword
; 09/15/2013 DGG Support for callback functions during long
;    calculations.
; 10/03/2013 DGG and DBR Project background even if there are no
;    traps.
; 10/26/2013 DGG Can rely on background being present.
; 04/05/2014 DGG traps now provide complex amplitudes
;
; Copyright (c) 2011-2015 David G. Grier, David B. Ruffner and Ellery Russel
;-
;;;;;
;
; fabCGH_fast::Compute
;
  ; Compute hologram for the SLM device using fastphase algorithm
  ;
  pro fabCGH_fast::Compute

  COMPILE_OPT IDL2, HIDDEN

  ;; field in the plane of the projecting device
  *self.psi = *self.background
  foreach trap, self.traps do begin
     pr = self.mat # (trap.rc - self.rc)
     ex = exp(*self.ikx * pr[0] + *self.ikxsq * pr[2])
     ey = exp(*self.iky * pr[1] + *self.ikysq * pr[2])
     *self.psi += trap.alpha * (ex # ey) * self.window(pr)
  endforeach

  ;; phase of the field in the plane of the projecting device  
  *self.data = byte(round((127.5/!pi) * (atan(*self.psi, /phase) + !pi)))
end

;;;;;
;
; fabCGH_fast::Precompute
;
pro fabCGH_fast::Precompute

  COMPILE_OPT IDL2, HIDDEN
  
  ci = complex(0., 1.)
  kx = self.q * (findgen((self.slm.dimensions)[0]) - self.kc[0])
  ky = -self.q * self.aspect_ratio * (findgen((self.slm.dimensions)[1]) + self.kc[1])
  *self.ikxsq = ci*kx^2
  *self.ikysq = ci*ky^2
  *self.ikx = ci*kx
  *self.iky = ci*ky
end

;;;;;
;
; fabCGH_fast::Deallocate
;
; Free allocated resources
;
pro fabCGH_fast::Deallocate

  COMPILE_OPT IDL2, HIDDEN

  self->fabCGH::Deallocate

  ptr_free, self.psi, $
            self.ikx, self.iky, $
            self.ikxsq, self.ikysq
end

;;;;;
;
; fabCGH_fast::Allocate()
;
; Allocate memory and define coordinates
;
function fabCGH_fast::Allocate

  COMPILE_OPT IDL2, HIDDEN

  ;; interrogate SLM and allocate hologram
  if ~self.fabCGH::Allocate() then $
     return, 0B

  ;; allocate resources for CGH algorithm
  ; field in SLM plane
  dimensions = self.slm.dimensions
  self.psi = ptr_new(complexarr(dimensions), /no_copy)
  ; coordinates in SLM plane scaled as wavevectors
  self.ikx = ptr_new(complexarr(dimensions[0]), /no_copy)
  self.iky = ptr_new(complexarr(dimensions[1]), /no_copy)
  self.ikxsq = ptr_new(complexarr(dimensions[0]), /no_copy)
  self.ikysq = ptr_new(complexarr(dimensions[1]), /no_copy)

  return, 1B
end

;;;;;
;
; fabCGH_fast::GetProperty
;
; Get properties for CGH object
;
; inherited from fabCGH

;;;;;
;
; fabCGH_fast::SetProperty
;
; Set properties for CGH object
;
; inherited from fabCGH

;;;;;
;
; fabCGH_fast::Init
;
function fabCGH_fast::Init, background = background, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fabCGH::Init(_extra = re) then $
     return, 0B

  if isa(background, /number, /array) then begin
     if ~isa(self.slm, 'fabSLM') then begin
        message, 'must specify SLM before assigning a background', /info
        return, 0B
     endif
     if ~array_equal(size(background, /dimensions), slm.dimensions) then begin
        message, 'background must have the same dimensions as SLM', /info
        return, 0B
     endif
     self.background = ptr_new(background)
  endif

  self.name = 'fabCGH_fast '
  self.description = 'CPU CGH Pipeline '
  return, 1B
end

;;;;;
;
; fabCGH_fast::Cleanup
;
; inherited from fabCGH

;;;;;
;
; fabCGH_fast__define
;
; Define an object that computes holograms from specifications
;
pro fabCGH_fast__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {fabCGH_fast, $
            inherits fabCGH,     $
            psi:      ptr_new(), $ ; computed field
            ikx:      ptr_new(), $
            iky:      ptr_new(), $
            ikxsq:    ptr_new(), $
            ikysq:    ptr_new()  $
         }
end
