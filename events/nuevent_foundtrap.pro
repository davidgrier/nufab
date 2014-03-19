;+
; NAME:
;    nuevent_foundtrap()
;
; PURPOSE:
;    Returns an object reference to a group of traps in the vicinity of a specified position
;
; CALLING SEQUENCE:
;    group = nuevent_foundtrap(state, xy)
;
; INPUTS:
;    state: state of the fabrication system
;    xy: in-plane position at which a trap is being sought
;
; OUTPUT:
;    group: object reference to the group of traps containing the
;        selected trap.  If no trap is located at XY, a
;        NULL object reference is returned.
;
; KEYWORD PARAMETER:
;    trap: on output, an object to the particular trap that was
;        selected.
;        If no trap is located at XY, a NULL object reference is returned.
; 
; KEYWORD FLAG:
;    movable: if set, only return a trapping group that can be moved.
;        Default: return immutable trapping groups if no movable
;        groups are found
;
; MODIFICATION HISTORY:
; 12/20/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-
function nuevent_foundtrap, s, xy, $
                            trap = trap,   $  ; particular trap that was found
                            movable = movable ; only return movable groups

COMPILE_OPT IDL2, HIDDEN

found = s['screen'].select(s['overlay'], xy, dimensions = [10,10])

if ~obj_valid(found[0]) then $               ; nothing found
   return, obj_new()

foreach trap, found do begin                 ; found at least one trap
   trap.getproperty, parent = group, rc = rc ; get trap's group and position
   group.setproperty, rs = rc                ; select group at trap's position
   if (group.ismoveable()) then $
      return, group             ; return first movable group
endforeach
                                
if keyword_set(movable) then $               ; no movable groups found
   return, obj_new()

return, group                   ; return an unmovable group

end
