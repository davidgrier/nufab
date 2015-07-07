;+
; NAME:
;    fabCGH_cuda
;
; PURPOSE:
;    Object class that computes a computer generated hologram (CGH) from
;    a trapping pattern and transmits it to a spatial light modulator
;    (SLM) for projection.  Uses the CUDA implementation of the
;    fastphase algorithm.
;
; INHERITS:
;    fabCGH
;
; SPECIAL REQUIREMENTS:
; Uses the CUDA implementation of the fastphase algorithm implemented
; by the cudacgh package, which is available at
;
;     https://github.com/davidgrier/cudacgh
;
; PROPERTIES:
; [IGS] SLM: Object of type DGGhotSLM for which holograms will be
;         computed.  No computation is performed unless this is defined.
;
; [IGS] TRAPS: list of fabTrap objects describing the traps
;
; [ G ] DATA: byte-value hologram, computed from TRAPS according
;         to SLM specifications.
;
; [ GS] RC: [rx, ry, rz] coordinates of the center of the projected
;         coordinate system.
;         Default: [0, 0, 0]
;
; [ GS] MAT: Affine transformation matrix that maps requested trap
;         coordinates onto the projected coordinate system.
;         Default: 3 x 3 identity matrix.
;
; METHODS:
;    fabCGH_cuda::GetProperty
;
;    fabCGH_cuda::SetProperty
;
;    fabCGH_cuda::Compute
;        Use traps to compute hologram according to SLM
;        specifications, then transfer the hologram to the SLM.
;
; MODIFICATION HISTORY:
; 03/22/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-
;;;;;
;
; fabCGH_cuda::Compute
;
; Compute hologram for the SLM device using cudaphase algorithm
;
pro fabCGH_cuda::Compute

  COMPILE_OPT IDL2, HIDDEN

  catch, error
  if error ne 0 then begin
     *self.data *= 0b
     catch, /cancel
     return
  endif

  if ptr_valid(self.background) then $
     cudacgh_initialize, self.cgh, *self.background $
  else $
     cudacgh_initialize, self.cgh

  foreach trap, self.traps do begin
     pr = self.rotatescale(trap.rc)
     p = [pr, trap.amplitude * self.window(pr), trap.phase]
     cudacgh_addtrap, self.cgh, self.cal, p
  endforeach

  ;; phase of the field in the plane of the projecting device
  *self.data = cudacgh_getphase(self.cgh)
end

;;;;;
;
; fabCGH_cuda::Deallocate
;
; Free allocated resources
;
pro fabCGH_cuda::Deallocate

  COMPILE_OPT IDL2, HIDDEN

  catch, error
  if error ne 0L then begin
     catch, /cancel
     return
  endif

  self.fabCGH::Deallocate
  cudacgh_free, self.cgh
end

;;;;;
;
; fabCGH_cuda::Allocate()
;
; Allocate memory and define coordinates
;
function fabCGH_cuda::Allocate

  COMPILE_OPT IDL2, HIDDEN

  catch, error
  if error ne 0L then begin
     catch, /cancel
     return, 0B
  endif

  if ~self.fabCGH::Allocate() then $
     return, 0B
  
  ;; allocate CUDA resources for CGH algorithm
  dimensions = self.slm.dimensions
  self.cgh = cudacgh_allocate(dimensions[0], dimensions[1])

  return, 1B
end

;;;;;
;
; fabCGH_cuda::GetProperty
;
; inherited from fabCGH
;

;;;;;
;
; fabCGH_cuda::SetProperty
;
pro fabCGH_cuda::SetProperty, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fabCGH::SetProperty, _extra = re
  self.cal = [self.kc, self.q, self.aspect_ratio]
end

;;;;;
;
; fabCGH_cuda::Init
;
function fabCGH_cuda::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fabCGH::Init(_extra = re) then $
     return, 0B

  self.cal = [self.kc, self.q, self.aspect_ratio]

  self.name = 'fabCGH_cuda '
  self.description = 'CUDA CGH Pipeline '
  return, 1B
end

;;;;;
;
; fabCGH_cuda::Cleanup
;
; inherited from fabCGH

;;;;;
;
; fabCGH_cuda__define
;
; Define an object that computes holograms from specifications
;
pro fabCGH_cuda__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {fabCGH_cuda, $
            inherits fabCGH, $
            cgh: bytarr(56), $
            cal: fltarr(4)   $
           }
end
