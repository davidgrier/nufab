;+
; NAME:
;    fabVortex
;
; PURPOSE:
;    This object abstracts an optical vortex as the
;    combination of a graphical representation and data describing
;    the 3D position and physical properties of the trap.  This
;    inherits the fabTrap class, and specifies a spiral for
;    the graphical representation, whose radius depends on axial
;    position, z.
;
; CATEGORY:
;    Holographic optical trapping, object graphics
;
; INHERITS:
;    fabTrap
;
; PROPERTIES:
;    fabVortex inherits the properties and methods of
;    the fabTrap class
;
;    RC [IGS] three-element vector [xc, yc, zc] specifying the trap's
;        position [pixels].
;
;    AMPLITUDE [IGS] relative amplitude.
;        Default: 1
;
;    PHASE [IGS] relative phase [radians].
;        Default: random number in [0, 2pi].
;
;    ELL [IGS] winding number
;        Defaults: 0
;
; METHODS:
;    All user-accessible methods for fabTweezer are provided
;    by the fabTrap class.
;
; MODIFICATION HISTORY:
; 12/30/2010 Written by David G. Grier, New York University
; 01/27/2011 DGG completed inheritance from fabTrap
; 03/23/2011 DGG use _ref_extra in Init.  Register name,
;    identifier and description
; 02/04/2012 DGG ELL is a property of a fabTrap.  Initialize
;    fabTrap before vortex-specific initializations.  First
;    attempt at a graphical representation.
;
; Copyright (c) 2010-2016, David G. Grier
;-

;;;;;
;
; fabVortex::DrawGraphic
;
; Update graphical representation of an optical vortex
; Replaces the default method for a fabTrap
;
pro fabVortex::DrawGraphic

  COMPILE_OPT IDL2, HIDDEN

  graphic = *self.graphic
  radius = (5. + self.rc[2] * 0.02) > 0.1 < 20
  graphic[0:1, *] *= radius
  if self.ell lt 0 then graphic[0, *] *= -1
  graphic[0, *] += self.rc[0]
  graphic[1, *] += self.rc[1]

  self.IDLgrPolyline::SetProperty, data = graphic
end

;;;;;
;
; fabVortex::GetProperty
;
pro fabVortex::GetProperty, ell = ell, $
                            _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fabTrap::GetProperty, _extra = re

  if arg_present(ell) then $
     ell = self.ell
end

;;;;;
;
; fabVortex::SetProperty
;
pro fabVortex::SetProperty, ell = ell, $
                            _extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.fabTrap::SetProperty, _extra = re

  if n_elements(ell) eq 1 then begin
     self.ell = ell
     self.project
     self.drawgraphic
  endif
end

;;;;;
;
; fabVortex::Init
;
function fabVortex::Init, _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if (self.fabTrap::Init(_extra = re) ne 1) then $
     return, 0

  ; override graphic
  npts = 15
  theta = 2.*!pi/(npts - 1.) * findgen(1, npts)
  x = theta * sin(2*theta) / !pi
  y = theta * cos(2*theta) / !pi
  z = replicate(0.1, 1, npts)
  self.graphic = ptr_new([x, y, z])

  self.name = 'fabVortex'
  self.identifier = 'fabVortex'
  self.description = 'Optical Vortex'
  self.registerproperty, 'ell', /INTEGER, NAME = 'ell', $
     VALID_RANGE = [-100, 100]
  return, 1
end

;;;;;
;
; fabVortex__define
;
; An optical tweeer is an instance of an optical trap
;
pro fabVortex__define

  COMPILE_OPT IDL2

  struct = {fabVortex,        $
            inherits fabTrap  $
           }
end
