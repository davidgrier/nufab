;+
; NAME:
;    fabTrap
;
; PURPOSE:
;    This object abstracts a holographic optical trap as the
;    combination of a graphical representation and data describing
;    the 3D position and physical properties of the trap.  This is
;    the base class from which all practical implementations of
;    holographic optical traps can be abstracted.
;
; CATEGORY:
;    Holographic optical trapping, object graphics
;
; SUPERCLASSES:
;    IDLgrPolyline
;    IDL_Object
;
; PROPERTIES:
;    RC: Three-dimensional position [pixels]
;        [IGS]
;
;    ALPHA: Complex amplitude: amplitude * exp(i phase)
;        [ G ]
;
;    AMPLITUDE: Relative amplitude.  Default: 1
;        [IGS]
;
;    PHASE: Phase [radians].  Default: Random value in [0, 2pi].
;        [IGS]
;
;    DATA: Trap characteristics: [xc, yc, zc, alpha, phase]
;        [ G ]
;
;    STRUCTURE: Structuring field
;        [IGS]
;
; METHODS:
;    fabTrap::GetProperty
;
;    fabTrap::SetProperty
;
;    fabTrap::MoveBy, dr, /override
;        Displace trap in two or three dimensions
;        DR: displacement vector [pixels]
;        OVERRIDE: If set, project the trap.  Default behavior
;            is to displace the graphic, but to leave projection
;            to the parent fabTrapGroup.
;
; NOTES: 
;    Add palette for color table.
;    Return data as a structure describing particular trap type.
;    This would allow for mixtures of optical vortexes, optical
;    tweezers, and other types of traps.
;
; MODIFICATION HISTORY:
; 12/30/2010: Written by David G. Grier, New York University
; 03/22/2011 DGG register properties for inclusion in property sheets
;    Added properties XC, YC, ZC, including get/set methods.
; 02/03/2012 DGG added AMPLITUDE and PHI properties as 
;    a mechanism to implement structured optical traps.
; 02/04/2012 DGG added ELL property for optical vortexes.
; 05/16/2012 DGG subclass IDL_Object for implicit Get/SetProperty methods.
; 05/17/2012 DGG updated parameter checks in SetProperty and streamlined
;    decisions regarding when to call Project method.  Notify parent
;    DGGgrTrapGroup if destroyed programmatically.  Added
;    _overloadForeach method to permit looping over arrays of traps,
;    including one-element arrays.
; 06/12/2012 DGG Don't clobber self.rc[2] when setting rc[0:1].
;    Revised MoveBy method for compatibility with
;    fabTrapGroup::MoveBy.  Added OVERRIDE flag to MoveBy method.
; 12/22/2013 DGG Overhauled for new fab implementation.
; 04/05/2014 DGG Revised alpha, phase and structure definitions.
; 03/30/2015 DGG Clean up IDLgrPolyline.
;
; Copyright (c) 2010-2015 David G. Grier
;-

;;;;
;
; fabTrap::DrawGraphic
;
; Update graphical representation of trap
;
pro fabTrap::DrawGraphic

COMPILE_OPT IDL2, HIDDEN

graphic = *self.graphic
graphic[0, *] += self.rc[0]
graphic[1, *] += self.rc[1]

self.IDLgrPolyline::SetProperty, data = graphic

end

;;;;
;
; fabTrap::Project
;
pro fabTrap::Project

if isa(self.parent, 'fabtrapgroup') then $
   self.parent.project
end

;;;;
;
; fabTrap::MoveBy
;
; Move the trap by a specified displacement
;
pro fabTrap::MoveBy, dr, $
                     override = override

COMPILE_OPT IDL2, HIDDEN

case n_elements(dr) of
   3: self.rc += dr
   2: self.rc[0:1] += dr
else:
endcase

;if keyword_set(override) then $
;   self.project

self.drawgraphic

end

;;;;
;
; fabTrap::Select
;
; Return the parent trap group, and notify parent of change in state
;
function fabTrap::Select, state = state ; 2: select, or 3: grouping

COMPILE_OPT IDL2, HIDDEN

if ~isa(self.parent, 'fabtrapgroup') then $
   return, !NULL

self.parent.setproperty, state = state, rc = self.rc

return, ptr_new(self.parent)
end

;;;;
;
; fabTrap::_overloadForeach
;
; Attempting to loop over just one trap should yield the trap, not an
; error
;
function fabTrap::_overloadForeach, value, key

COMPILE_OPT IDL2

if n_elements(key) gt 0 then return, 0

value = self
key = 0

return, 1
end

;;;;
;
; fabTrap::SetProperty
;
pro fabTrap::SetProperty, rc         = rc,        $ ; position
                          xc         = xc,        $
                          yc         = yc,        $
                          zc         = zc,        $
                          amplitude  = amplitude, $ ; relative amplitude
                          phase      = phase,     $ ; relative phase
                          structure  = structure, $ ; structure
                          _ref_extra = re

COMPILE_OPT IDL2, HIDDEN
  
self.IDLgrPolyline::SetProperty, _extra = re

;doproject = 0
if isa(rc, /number, /array) then begin
   case n_elements(rc) of
      3: self.rc = rc
      2: self.rc[0:1] = rc
   else:
   endcase
;   doproject = 1
endif

if isa(xc, /number, /scalar) then begin
   self.rc[0] = xc
;   doproject = 1
endif

if isa(yc, /number, /scalar) then begin
   self.rc[1] = yc
;   doproject = 1
endif

if isa(zc, /number, /scalar) then begin
   self.rc[2] = zc
;   doproject = 1
endif

if isa(amplitude, /number, /scalar) then begin
   self.amplitude = amplitude
   self.alpha = self.amplitude * exp(complex(0., self.phase))
;   doproject = 1
endif

if isa(phase, /number, /scalar) then begin
   self.phase = phase
   self.alpha = self.amplitude * exp(complex(0., self.phase))
;   doproject = 1
endif

if isa(structure, 'pointer') then $
   self.structure = structure

;if doproject then self.project
self.drawgraphic

end

;;;;
;
; fabTrap::GetProperty
;
pro fabTrap::GetProperty, rc         = rc,        $
                          xc         = xc,        $
                          yc         = yc,        $
                          zc         = zc,        $
                          alpha      = alpha,     $
                          amplitude  = amplitude, $
                          phase      = phase,     $
                          structure  = structure, $
                          phi        = phi,       $
                          data       = data,      $
                          _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self->IDLgrPolyline::GetProperty, _extra = re

rc = self.rc
xc = rc[0]
yc = rc[1]
zc = rc[2]

if arg_present(alpha) then $
   alpha = self.alpha

if arg_present(amplitude) then $
   amplitude = self.amplitude

if arg_present(phase) then $
   phase = self.phase

if arg_present(structure) then $
   structure = self.structure

if arg_present(data) then $
   data = [self.rc, self.amplitude, self.phase]

end

;;;;;
;
; fabTrap::Init
;
function fabTrap::Init, rc         = rc,        $
                        amplitude  = amplitude, $
                        phase      = phase,     $
                        structure  = structure, $
                        _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if (self.IDLgrPolyline::Init(_extra = re) ne 1) then $
   return, 0B

if ~isa(self.graphic) then $
   self.graphic = ptr_new(fltarr(3))

case n_elements(rc) of
   3: self.rc = rc
   2: self.rc = [rc, 0.]
else:
endcase

self.amplitude = isa(amplitude, /number, /scalar) ? float(amplitude) : 1.

self.phase = isa(phase, /number, /scalar) ? float(phase) : $
             2. * !pi * randomu(seed)

self.alpha = self.amplitude * exp(complex(0., self.phase))

if isa(structure, 'pointer') then $
   self.structure = structure

self.drawgraphic

self.name = 'fabTrap '
self.description = 'Optical Trap '
self.registerproperty, 'name', /string, /hide
self.registerproperty, 'description', /string
self.registerproperty, 'xc', /float, description = 'Trap position: x'
self.registerproperty, 'yc', /float, description = 'Trap position: y'
self.registerproperty, 'zc', /float, description = 'Trap position: z'
self.registerproperty, 'amplitude', /float, description = 'Relative amplitude', $
   valid_range = [0., 100., 0.01]
self.registerproperty, 'phase', /float, description = 'Relative phase', $
   valid_range = [0., 2.*!pi, 0.01]

return, 1B
end

;;;;
;
; fabTrap::Cleanup
;
pro fabTrap::Cleanup

COMPILE_OPT IDL2, HIDDEN

self.IDLgrPolyline::Cleanup

if isa(self.parent, 'fabtrapgroup') then $
   self.parent.remove, self

ptr_free, self.structure
end

;;;;
;
; fabTrap__define
;
; Define the object structure for a fabTrap
;
pro fabTrap__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabTrap, $
          inherits IDLgrPolyline, $
          inherits IDL_Object,    $
          graphic:   ptr_new(),   $ ; coordinates of graphical representation
          rc:        fltarr(3),   $ ; 3D position [pixels]
          alpha:     complex(0),  $ ; complex amplitude
          amplitude: 0.,          $ ; relative amplitude
          phase:     0.,          $ ; relative phase
          structure: ptr_new()    $ ; structuring field
         }
end
