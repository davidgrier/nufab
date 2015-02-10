;+
; NAME:
;    fabCGH
;
; PURPOSE:
;    Object class that computes a computer generated hologram (CGH) from
;    a trapping pattern and transmits it to a spatial light modulator
;    (SLM) for projection.
;
; CATEGORY:
;    Computational holography, objects
;
; PROPERTIES:
;    SLM    [IGS] Object of type fabSLM for which holograms will be
;        computed.  No computation is performed unless this is defined.
;
;    TRAPS  [IGS] list of fabTrap objects defining traps
;
;    DATA   [ G ] byte-valued hologram, computed from data in TRAPS according
;        to SLM specifications.
;
;    RC     [ GS]  [rx, ry, rz] coordinates of the center of the projected
;         coordinate system.
;         Default: [0, 0, 0]
;
;    MAT    [ GS] Affine transformation matrix that maps requested trap
;         coordinates onto the projected coordinate system.
;         Default: 3 x 3 identity matrix.
;
;    KC     [ GS] [xi, eta] coordinates of optical axis on SLM.
;         Default: Center of SLM.
;
;    BACKGROUND [IGS] background field to be added to hologram.
;         If background is an integer type, assume that it is a scaled
;         phase, cast into the range 0..2Pi and then cast to a field.
;         If it is a floating point type, assume that it is a phase
;         and cast to a field.
;         If it is complex, then assume it is a field, and do not cast.
;         Default: None.
;
; METHODS:
;    fabCGH::GetProperty
;
;    fabCGH::SetProperty
;
;    fabCGH::Compute
;        Use traps to compute hologram according to SLM
;        specifications, then transfer the hologram to the SLM.
;
;    fabCGH::Refine
;        Perform one iteration of hologram refinement, and
;        then transfer the hologram to the SLM.
;
;    fabCGH::Allocate
;        Allocate computational resources based on SLM
;        specifications.  Should only be called by fabCGH::Init
;
;    fabCGH::Deallocate
;        Free previously allocated computational resources.
;        Should only be called by fabCGH::Cleanup
;
; INHERITS:
;    IDLitComponent: registered properties appear on propertysheet
;        widgets.
;
;    IDL_Object: implicit get and set properties.
;
; MODIFICATION HISTORY:
; 01/20/2011 Written by David G. Grier, New York University
; 02/01/2011 DGG moved RC and MAT into CGH from SLM
; 02/05/2011 DGG added hook for DGGhotCGH::Refine
; 03/25/2011 DGG work with TRAPS rather than TRAPDATA
; 04/11/2011 DGG inherit IDLitComponent so that CGH can have
;    registered properties that can be set with a propertysheet
; 12/06/2011 DGG KC is a property of the CGH rather than the SLM.
;    Added PRECOMPUTE method to account for changed values of KC.
;    Added ETA and XI keywords for interactive updates of KC.
;    Inherits IDL_Object for implicit get/set properties.
; 12/10/2011 DGG Have pointers referring to x, y, rsq and theta
;    coordinates in the SLM plane that are precomputed by
;    PRECOMPUTE.  Goal is to permit traps to declare functions
;    for computing their fields that make use of these coordinates.
; 02/04/2012 DGG simplify ptr_free calls in CleanUp method.
; 05/04/2012 DGG Check that parameters are numbers in Init and
;    SetProperty.
; 06/12/2012 DGG Renamed phi to data.
; 06/20/2012 DGG Don't clobber traps during SetProperty.
; 09/11/2013 DGG Introduced BACKGROUND keyword.
; 09/15/2013 DGG Support for callbacks during CGH calculation.
; 10/03/2013 DGG Support for different BACKGROUND types.
; 10/26/2013 DGG Project background by default.
; 02/10/2015 DGG Updated TRAPS definition.
;
; Copyright (c) 2011-2013 David G. Grier
;-

;;;;;
;
; fabCGH::InstallBackground
;
pro fabCGH::InstallBackground, background

COMPILE_OPT IDL2, HIDDEN

if ~isa(self.slm, 'fabSLM') then return

if array_equal(size(background, /dimensions), self.slm.dimensions) then begin
   switch typename(background) of
      'BYTE':
      'INT':
      'LONG':
      'ULONG':
      'LONG64':
      'ULONG64': begin
         *self.background = exp((2.*!pi/max(background)) * complex(0., background))
         break
      end
      'FLOAT':
      'DOUBLE': begin
         *self.background = exp(complex(0., background))
         break
      end
      'COMPLEX':
      'DCOMPLEX': begin
         *self.background = complex(background)
         break
      end
      else: *self.background = complexarr(self.slm.dimensions)
   endswitch
endif
end

;;;;;
;
; fabCGH::Refine
;
; Perform one iteration of hologram refinement
;
pro fabCGH::Refine

COMPILE_OPT IDL2, HIDDEN

; Base class does not know how to do refinement.
; Derived classes must do the work.
end

;;;;;
;
; fabCGH::Reset
;
pro fabCGH::Reset

COMPILE_OPT IDL2, HIDDEN

slm = self.slm
self.kc = slm.dimensions/2.
self.roi = [0, 0, slm.dimensions-1]
self.q = 2./min(slm.dimensions)
self.aspect_ratio = 1.
self.mat = identity(3)
self.precompute
self.project

end

;;;;;
;
; fabCGH::Project
;
pro fabCGH::Project

COMPILE_OPT IDL2, HIDDEN

self.compute
self.slm.data = *self.data
end

;;;;;
;
; fabCGH::Compute
;
; Compute hologram for the SLM device
; Does nothing without an algorithm!
;
pro fabCGH::Compute

COMPILE_OPT IDL2, HIDDEN

self.refining = 0B

*self.data = *self.background

end

;;;;;
;
; fabCGH::Precompute
;
; Compute static variables when kc changes
; Base class does not know how to represent coordinates.
;
pro fabCGH::Precompute

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabCGH::Deallocate
;
; Free allocated resources
;
pro fabCGH::Deallocate

COMPILE_OPT IDL2, HIDDEN

ptr_free, self.background

end

;;;;;
;
; fabCGH::Allocate
;
; Allocate memory and define coordinates
;
pro fabCGH::Allocate

COMPILE_OPT IDL2, HIDDEN

if ~isa(self.slm, 'fabSLM') then $
   return

slm = self.slm
self.kc = float(self.slm.dimensions)/2.
self.setpropertyattribute, 'xi',  VALID_RANGE = [0., (slm.dimensions)[1], 0.1]
self.setpropertyattribute, 'eta', VALID_RANGE = [0., (slm.dimensions)[0], 0.1]

;; data
data = bytarr(slm.dimensions)
self.data = ptr_new(data, /no_copy)

;; background
background = complexarr(slm.dimensions)
self.background = ptr_new(background, /no_copy)

end

;;;;;
;
; fabCGH::GetProperty
;
; Get properties for CGH object
;
pro fabCGH::GetProperty, slm          = slm,          $
                         traps        = traps,        $
                         data         = data,         $
                         background   = bg,           $
                         rc           = rc,           $
                         xc           = xc,           $
                         yc           = yc,           $
                         zc           = zc,           $
                         w            = w,            $
                         h            = h,            $
                         q            = q,            $
                         aspect_ratio = aspect_ratio, $
                         aspect_z     = aspect_z,     $
                         angle        = angle,        $
                         kc           = kc,           $
                         xi           = xi,           $
                         eta          = eta,          $
                         roi          = roi,          $
                         x            = x,            $
                         y            = y,            $
                         rsq          = rsq,          $
                         theta        = theta,        $
                         _ref_extra   = re

COMPILE_OPT IDL2, HIDDEN

self.IDLitComponent::GetProperty, _extra = re

if arg_present(slm) then $
   slm = self.slm

if arg_present(traps) then $
   traps = self.traps

if arg_present(data) then $
   data = *self.slm.data

if arg_present(background) then $
   background = *self.background

if arg_present(rc) then $
   rc = self.rc

if arg_present(xc) then $
   xc = self.rc[0]

if arg_present(yc) then $
   yc = self.rc[1]

if arg_present(zc) then $
   zc = self.rc[2]

if arg_present(w) then $
   w = (self.slm.dimensions)[0]

if arg_present(h) then $
   h = (self.slm.dimensions)[1]

if arg_present(q) then $
   q = self.q

if arg_present(aspect_ratio) then $
   aspect_ratio = self.aspect_ratio

if arg_present(aspect_z) then $
   aspect_z = self.mat[2, 2]

if arg_present(angle) then $
   angle = 180./!pi * atan(self.mat[1], self.mat[0])

if arg_present(kc) then $
   kc = self.kc

if arg_present(xi) then $
   xi = self.kc[0]

if arg_present(eta) then $
   eta = self.kc[1]

if arg_present(roi) then $
   roi = self.roi

if arg_present(x) then $
   x = self.x

if arg_present(y) then $
   y = self.y

if arg_present(rsq) then $
   rsq = self.rsq

if arg_present(theta) then $
   theta = self.theta

if arg_present(name) then $
   name = self.name

end

;;;;;
;
; fabCGH::SetProperty
;
; Set properties for CGH object
;
pro fabCGH::SetProperty, slm          = slm,          $
                         traps        = traps,        $
                         background   = bg,           $
                         rc           = rc,           $
                         xc           = xc,           $
                         yc           = yc,           $
                         zc           = zc,           $
                         q            = q,            $
                         aspect_ratio = aspect_ratio, $
                         aspect_z     = aspect_z,     $
                         angle        = angle,        $
                         kc           = kc,           $
                         xi           = xi,           $
                         eta          = eta,          $
                         roi          = roi,          $
                         _ref_extra   = re

COMPILE_OPT IDL2, HIDDEN

self.IDLitComponent::SetProperty, _extra = re

doprecompute = 0
if isa(slm, 'fabSLM') then begin
   self.slm = slm
   dimensions = slm.dimensions
   self.kc = dimensions/2.
   self.roi = [0, 0, dimensions-1]
   self.q = 2./min(slm.dimensions)
   self.setpropertyattribute, 'xi', valid_range = [0, dimensions[0]-1, 0.5]
   self.setpropertyattribute, 'eta', valid_range = [0, dimensions[1]-1, 0.5]
   self.allocate
   doprecompute = 1
endif

if isa(traps, 'list') then $
   if traps.count() eq 0 then $
      self.traps.remove, /all $
   else if isa(traps[0], 'fabtrap') then $
      self.traps = traps 

if isa(bg, /number, /array) then $
   self.installbackground, bg

if isa(rc, /number) then begin
   case n_elements(rc) of
      2: self.rc[0:1] = rc
      3: self.rc = rc
      else:
   endcase
endif

if isa(xc, /scalar, /number) then $
   self.rc[0] = float(xc)

if isa(yc, /scalar, /number) then $
   self.rc[1] = float(yc)

if isa(zc, /scalar, /number) then $
   self.rc[2] = float(zc)

if isa(q, /number, /scalar) then begin
   self.q = float(q)
   doprecompute = 1
endif

if isa(aspect_ratio, /number, /scalar) then begin
   self.aspect_ratio = float(aspect_ratio)
   doprecompute = 1
endif

if isa(aspect_z, /number, /scalar) then $
   self.mat[2, 2] = float(aspect_z)

if isa(angle, /number, /scalar) then begin
   theta = angle * !pi/180.
   self.mat[0:1, 0:1] = [[cos(theta), sin(theta)], [-sin(theta), cos(theta)]]
endif

if (isa(kc, /number) and n_elements(kc) eq 2) then begin
   self.kc = float(kc)
   doprecompute = 1
endif

if isa(xi, /scalar, /number) then begin
   self.kc[0] = float(xi)
   doprecompute = 1
endif

if isa(eta, /scalar, /number) then begin
   self.kc[1] = float(eta)
   doprecompute = 1
endif

if isa(roi, /number) and n_elements(roi) eq 4 then begin
   self.roi = long(roi)
   doprecompute = 1
endif

if doprecompute then self.precompute
self.project
   
end

;;;;;
;
; fabCGH::Init
;
function fabCGH::Init, slm          = slm,   $
                       traps        = traps, $
                       background   = bg, $
                       rc           = rc,    $
                       q            = q,            $
                       aspect_ratio = aspect_ratio, $
                       aspect_z     = aspect_z,     $
                       angle        = angle,        $
                       kc           = kc,    $
                       roi          = roi,   $
                       _ref_extra   = re

COMPILE_OPT IDL2, HIDDEN

if (self.IDLitComponent::Init(_extra = re) ne 1) then $
   return, 0

self.name = 'fabCGH '
self.description = 'CGH Calculation Pipeline '
self.setpropertyattribute, 'name', /hide
self.registerproperty, 'xc', /float
self.registerproperty, 'yc', /float
self.registerproperty, 'zc', /float
self.registerproperty, 'w', /integer, name = 'Width', sensitive = 0
self.registerproperty, 'h', /integer, name = 'Height', sensitive = 0
self.registerproperty, 'q', /float
self.registerproperty, 'aspect_ratio', /float
self.registerproperty, 'aspect_z', /float
self.registerproperty, 'angle', /float
self.registerproperty, 'xi', /float
self.registerproperty, 'eta', /float

if isa(slm, 'fabSLM') then begin
   self.slm = slm
   dimensions = slm.dimensions
   self.kc = dimensions/2.
   self.roi = [0, 0, dimensions-1]
   self.q = 2./min(dimensions)
   self.setpropertyattribute, 'xi', valid_range = [0, dimensions[0]-1, 0.5]
   self.setpropertyattribute, 'eta', valid_range = [0, dimensions[1]-1, 0.5]
   self.allocate
endif

if isa(bg, /number, /array) then $
   self.installbackground, bg

if isa(rc, /number) then begin
   case n_elements(rc) of
      2: self.rc[0:1] = float(rc)
      3: self.rc = float(rc)
      else:
   endcase
endif

if isa(q, /number, /scalar) then $
   self.q = float(q)

self.aspect_ratio = isa(aspect_ratio, /number, /scalar) ? float(aspect_ratio) : 1.

self.mat = identity(3)

if isa(aspect_z, /number, /scalar) then $
   self.mat[2, 2] = float(aspect_z)

if isa(angle, /number, /scalar) then begin
   theta = angle * !pi/180.
   self.mat[0:1, 0:1] = [[cos(theta), sin(theta)], [-sin(theta), cos(theta)]]
endif

if isa(kc, /number) and n_elements(kc) eq 2 then $
   self.kc = float(kc)

if isa(roi, /number) and n_elements(roi) eq 4 then $
   self.roi = long(roi)

if isa(slm, 'fabslm') then $
   self.precompute

if isa(traps, 'list') then begin
   if isa(traps[0], 'fabTrap') then begin
      self.traps = traps
      self.project
   endif
endif else $
   self.traps = list()

return, 1
end

;;;;;
;
; fabCGH::Cleanup
;
pro fabCGH::Cleanup

COMPILE_OPT IDL2, HIDDEN

; Cleaning up SLM should be parent's task
; if isa(self.slm) then obj_destroy, self.slm

self.deallocate

ptr_free, self.x,     $
          self.y,     $
          self.theta, $
          self.rsq, $
          self.data

end

;;;;;
;
; fabCGH__define
;
; Define an object that computes holograms from specifications
;
pro fabCGH__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabCGH, $
          inherits fab_object,        $ 
          slm:          obj_new(),    $ ; target SLM
          data:         ptr_new(),    $ ; byte-valued hologram
          traps:        obj_new(),    $ ; list of trap objects
          rc:           fltarr(3),    $ ; center of trap coordinate system
          mat:          fltarr(3, 3), $ ; transformation matrix
          kc:           fltarr(2),    $ ; center of hologram on SLM
          q:            0.,           $ ; conversion to inverse pixels in SLM plane
          aspect_ratio: 0.,           $ ; qy/qx
          x:            ptr_new(),    $ ; coordinates in SLM plane
          y:            ptr_new(),    $ ;
          rsq:          ptr_new(),    $ ; polar coordinates in SLM plane
          theta:        ptr_new(),    $ ;
          roi:          lonarr(4),    $ ; active region of SLM
          background:   ptr_new(),    $ ; background hologram
          refining:     0B            $ ; set if refining the hologram
         }
end
