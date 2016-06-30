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
; [ G ] DATA: byte-valued hologram, computed from TRAPS according
;        to SLM specifications.
;
; [ G ] FIELD: complex-valued field in the hologram plane.
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
; 04/05/2014 DGG traps now provide complex amplitudes.
; 07/21/2015 DGG added FIELD keyword.
; 02/22/2016 DGG fixed BACKGROUND property.
; 06/30/2016 DGG Compute uses specialized method for each trap class.
;
; Copyright (c) 2011-2016 David G. Grier, David B. Ruffner and Ellery Russel
;-

;;;;;
;
; fabCGH_fast::Quantize()
;
; Quantize provided field into phase hologram
;
function fabCGH_fast::Quantize, field

  COMPILE_OPT IDL2, HIDDEN

  return, byte(round((128/!pi) * (atan(field, /phase) + !pi)))
end

;;;;;
;
; fabCGH_fast::Quantize
;
; Quantize computed field into phase hologram
; and update local data
;
pro fabCGH_fast::Quantize, field

  COMPILE_OPT IDL2, HIDDEN

  *self.data = (n_params() eq 1) ? $
               self.quantize(field) : $
               self.quantize(*self.field)
end

;;;;;
;
; fabCGH_fast::Refine
;
pro fabCGH_fast::Refine

  COMPILE_OPT IDL2, HIDDEN

  return                        ; locks up with large-format slm
  if self.traps.count() le 2 then return
  print,'refining'
  self.interrupt = 0
  self.errordiffusion
  if ~self.interrupt then begin
     print,'... projecting'
     self.project
  endif else $
     self.interrupt = 0
  print,'... ... done'
end

;;;;;
;
; fabCGH_fast::Compute
;
; Compute hologram for the SLM device using fastphase algorithm
;
pro fabCGH_fast::Compute

  COMPILE_OPT IDL2, HIDDEN

  ;; stop ongoing hologram refinement
  self.interrupt = 1
  ;; field in the plane of the projecting device
  *self.field = *self.background
  foreach trap, self.traps do $
     *self.field += call_method(obj_class(trap), self, trap)

  ;; phase of the field in the plane of the projecting device
  self.quantize
end

;;;;;
;
; fabCGH_fast::Precompute
;
pro fabCGH_fast::Precompute

  COMPILE_OPT IDL2, HIDDEN
  
  ci = complex(0., 1.)
  kx = self.q * (findgen((self.slm.dimensions)[0]) - self.kc[0])
  ky = self.aspect_ratio * $
       self.q * (findgen((self.slm.dimensions)[1]) - self.kc[1])
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

  ptr_free, self.field, $
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
  self.field = ptr_new(complexarr(dimensions), /no_copy)
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
pro fabCGH_fast::GetProperty, field = field, $
                              _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if arg_present(field) then $
     field = *self.field

  self.fabCGH::GetProperty, _extra = re
end

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
function fabCGH_fast::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if ~self.fabCGH::Init(_extra = re) then $
     return, 0B

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
            field:    ptr_new(), $ ; computed field
            ikx:      ptr_new(), $
            iky:      ptr_new(), $
            ikxsq:    ptr_new(), $
            ikysq:    ptr_new(), $
            interrupt: 0L        $
         }
end
