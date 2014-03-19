;+
; NAME:
;    fabstage
;
; PURPOSE:
;    Base class for controlling microscope stages
;
; INHERITS:
;    fab_object
;
; PROPERTIES:
;    POSITION     [ GS]
;        Three-element array describing present stage position.
;        Setting POSITION causes stage to move.
;
;    DISPLACEMENT [  S]
;        Two- or three-element array describing desired displacement
;        of stage relative to current position.
;        Setting DISPLACEMENT causes stage to move.
;
;    VELOCITY     [  S]
;        Two- or three-element array describing desired motion of stage.
;        Setting VELOCITY causes stage to start moving.
;        Motion must be stopped by setting VELOCITY to a
;        zero-valued vector.
;
;    RIGHT        [IGS]
;        Two-element array defining velocity of translations to right.
;        Default: [1., 0.]
;
;    FORWARD      [IGS]
;        Two-element array defining velocity of forward translations.
;        Default: [0., 1.]
;
;    UP           [IGS]
;        Signed number describing upward translations of focus drive.
;        Default: 1.
;
;    FAST         [IGS]
;        Multiplication factor for fast translations.
;        Default: 2.
;
;    SLOW         [IGS]
;        Multiplication factor for slow translations.
;        Default: 0.5
;
;    ERROR        [ G ]
;        String containing error message from stage
;
; METHODS:
;    GetProperty
;    SetProperty
;
;    Position()
;        Report current position
;
;        OUTPUT: Current position as a three-element vector.
;
;        SIDE EFFECTS:
;            Setting R causes stage to move.
;
;    SetPosition, r
;        Define coordinates of current position
;
;        INPUT: Coordinate of current position as a three-element
;               vector.
;
;    SetOrigin
;        Define current position to be the origin of the coordinate
;        system.
;
;    MoveTo, r, /relative
;        Move stage to specified position.
;
;        INPUT:
;            r: two- or three-element vector of desired position
;               relative to the origin of the coordinate system.
;
;        KEYWORD FLAG:
;            relative: If set, then move by R relative to current
;                      position.
;
;        SIDE EFFECTS:
;            Causes stage to move.
;
;    Velocity, v
;        INPUT:
;            v: two- or three-element vector of desired velocity.
;
;        SIDE EFFECTS:
;            Causes stage to start moving.  Motion will continue
;            until a subsequent call to VELOCITY sets the speed
;            to zero, or until the stage hits a limit stop (or crashes
;            into the microscope objective!)
;
; MODIFICATION HISTORY:
; 03/03/2014 Written by David G. Grier, New York University
;
; Copyright (c) 2014 David G. Grier
;-
;;;;;
;
; fabstage::Velocity
;
; Start stage moving in requested direction
;
pro fabstage::Velocity, v

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabstage::MoveTo
;
pro fabstage::MoveTo, r, relative = relative

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabstage::SetOrigin
;
; This must be implemented by inheriting object
;
function fabstage::SetOrigin

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabstage::SetPosition
;
; This must be implemented by inheriting object
;
pro fabstage::SetPosition

COMPILE_OPT IDL2, HIDDEN

end

;;;;;
;
; fabstage::Position()
;
function fabstage::Position

COMPILE_OPT IDL2, HIDDEN

return, [0L, 0, 0]

end

;;;;;
;
; fabstage::SetProperty
;
pro fabstage::SetProperty, position = position, $
                           x = x, $
                           y = y, $
                           z = z, $
                           displacement = displacement, $
                           dx = dx, $
                           dy = dy, $
                           dz = dz, $
                           velocity = velocity, $
                           vx = vx, $
                           vy = vy, $
                           vz = vz, $
                           right = right, $
                           forward = forward, $
                           up = up, $
                           fast = fast, $
                           slow = slow, $
                           _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if isa(x, /number) || isa(y, /number) || isa(z, /number) then begin
   position = self.position()
   if isa(x, /scalar, /number) then position[0] = x
   if isa(y, /scalar, /number) then position[1] = y
   if isa(z, /scalar, /number) then position[2] = z
endif

if isa(position, /number) then $
   self.moveto, position

if isa(dx, /number) || isa(dy, /number) || isa(dz, /number) then begin
   displacement = fltarr(3)
   if isa(dx, /scalar, /number) then displacement[0] = dx
   if isa(dy, /scalar, /number) then displacement[1] = dy
   if isa(dz, /scalar, /number) then displacement[2] = dz
endif

if isa(displacement, /number) then $
   self.moveto, displacement, /relative

if isa(vx, /number) || isa(vy, /number) || isa(vz, /number) then begin
   velocity = fltarr(3)
   if isa(vx, /scalar, /number) then velocity[0] = vx
   if isa(vy, /scalar, /number) then velocity[1] = vy
   if isa(vz, /scalar, /number) then velocity[2] = vz
endif

if isa(velocity, /number, /array) then $
   self.velocity, velocity

if isa(right, /number, /array) then $
   self.right = float(right[0:1])
if isa(forward, /number, /array) then $
   self.forward = float(forward[0:1])
if isa(up, /number, /scalar) then $
   self.up = float(up)

if isa(fast, /number, /scalar) then $
   self.fast = float(fast)
if isa(slow, /number, /scalar) then $
   self.slow = float(slow)

end

;;;;;
;
; fabstage::GetProperty
;
pro fabstage::GetProperty, position = position, $
                           x = x, $
                           y = y, $
                           z = z, $
                           right = right, $
                           left = left, $
                           forward = forward, $
                           backward = backward, $
                           up = up, $
                           down = down, $
                           fast = fast, $
                           slow = slow, $
                           _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

self.IDLitComponent::GetProperty, _extra = re

if arg_present(position) then $
   position = self.position()

if (arg_present(x) || arg_present(y) || arg_present(z)) then begin
   r = self.position()
   x = r[0]
   y = r[1]
   z = r[2]
endif

if arg_present(left) then $
   left = -self.right

if arg_present(right) then $
   right = self.right

if arg_present(forward) then $
   forward = self.forward

if arg_present(backward) then $
   backward = -self.forward

if arg_present(up) then $
   up = self.up

if arg_present(down) then $
   down = -self.up

if arg_present(fast) then $
   fast = self.fast

if arg_present(slow) then $
   slow = self.slow
end

;;;;;
;
; fabstage::Cleanup()
;
pro fabstage::Cleanup

COMPILE_OPT IDL2, HIDDEN

; Nothing to do

end

;;;;;
;
; fabstage::Init()
;
function fabstage::Init, right = right, $
                         forward = forward, $
                         up = up, $
                         fast = fast, $
                         slow = slow, $
                         _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if ~self.IDLitComponent::Init(_extra = re) then $
   return, 0B

self.name = 'fabstage '
self.description = 'Stage Object '
self.registerproperty, 'x', /integer, sensitive = 0
self.registerproperty, 'y', /integer, sensitive = 0
self.registerproperty, 'z', /integer, sensitive = 0
self.registerproperty, 'fast', /float
self.registerproperty, 'slow', /float

self.right = isa(right, /number, /array) ? float(right[0:1]) : [1., 0.]
self.forward = isa(forward, /number, /array) ? float(forward[0:1]) : [0., 1.]
self.up = isa(up, /number, /scalar) ? float(up) : 1.

self.fast = isa(fast, /number, /scalar) ? float(fast) : 2.
self.slow = isa(slow, /number, /scalar) ? float(slow) : 0.5

return, 1B
end

;;;;;
;
; fabstage__define.pro
;
pro fabstage__define

COMPILE_OPT IDL2, HIDDEN

struct = {fabstage, $
          inherits fab_object, $
          right: [0., 0], $
          forward: [0., 0], $
          up: 0., $
          fast: 0., $
          slow: 0., $
          error: '' $
         }

end
