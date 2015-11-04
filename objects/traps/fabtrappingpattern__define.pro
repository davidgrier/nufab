;+
; NAME:
;    fabTrappingPattern
;
; PURPOSE:
;    Container object for groups of optical traps that both
;    provides an IDLgrModel for their graphical representation
;    and also transmits their physical characteristics to a
;    fabCGH object that computes the pattern's hologram.
;
; SUBCLASSES
;    IDLgrModel
;
; PROPERTIES:
; [IGS] GROUPS: fabTrapGroup objects contained within the pattern.
;       Groups are added with the fabTrappingPattern::Add method.
;       Groups are automatically removed when they are destroyed.
;
; [IGS] TRAPS: fabTrap objects contained within the pattern.
;       Traps are added with the fabTrappingPattern::Add method
;       by which they are bundled into groups of type fabTrapGroup.
;
; [IGS] CGH: Object that computes the hologram associated with the
;       groups of traps in the pattern.  This computational pipeline
;       must inherit the class fabCGH.
;
; [ G ] NGROUPS: Number of groups in the trapping pattern.
;
; [ G ] COUNT: Number of traps in the trapping pattern.
;
; METHODS:
;    fabTrappingPattern::GetProperty
;
;    fabTrappingPattern::SetProperty
;
;    fabTrappingPattern::Add, groups, /noproject
;        Add objects of type fabTrapGroup to the trapping
;        pattern, and project the result using the Project method.
;        Setting NOPROJECT adds the groups without projecting
;        the result.
;
;    fabTrappingPattern::Randomize, [seed]
;        Randomize the phases of all of the traps in the trapping
;        pattern.
;
;    fabTrappingPattern::Project
;        Project the hologram encoding the groups of traps by
;        transferring trap data to the CGH.
;
;    fabTrappingPattern::Clear
;        Destroy all groups of traps in the trapping pattern, and
;        projects the result.
;
; MODIFICATION HISTORY:
; 01/20/2011 Written by David G. Grier, New York University
; 03/23/2011 DGG Use _ref_extra in Get/SetProperty and Init
; 03/25/2011 DGG added TRAPS property to Get/Set trap objects
;     in the trapping pattern, rather than just the trap groups.
;     Compute holograms with TRAPS rather than TRAPDATA.
;     Documentation fixes.
; 02/03/2012 DGG Using SetProperty for TRAPS or GROUPS now clears the
;     trapping pattern and sets it explicitly to the specified traps
;     or groups of traps.  The Add method now works for both traps and
;     groups.  Added traps are bundled into a group.
; 12/22/2013 DGG Overhauled for new fab implementation.
; 01/22/2014 DGG Added RANDOMIZE method.
; 04/05/2014 DGG Revised amplitude definition.
;
; Copyright (c) 2011-2015 David G. Grier
;-
;;;;;
;
; fabTrappingPattern::Project
;
; Transfer data from the traps to the CGH pipeline
;
pro fabTrappingPattern::Project

  COMPILE_OPT IDL2, HIDDEN
  
  self.getproperty, traps = traps
  self.cgh.traps = traps
end

;;;;;
;
; fabTrappingPattern::Clear
;
; Delete all traps in trapping pattern
;
pro fabTrappingPattern::Clear

  COMPILE_OPT IDL2, HIDDEN

  groups = self.get(/all)
  foreach group, groups do begin
     if isa(group, 'fabtrapgroup') then begin
        obj_destroy, group
     endif
  endforeach

  self.project
end

;;;;;
;
; fabTrappingPattern::Randomize
;
pro fabTrappingPattern::Randomize, seed

  COMPILE_OPT IDL2, HIDDEN

  if n_params() lt 1 then $
     seed = systime(1)
  groups = self.get(/all)
  foreach group, groups do begin
     if isa(group, 'fabtrapgroup') then begin
        group.randomize, seed
     endif
  endforeach

  self.project
end

;;;;;
;
; fabTrappingPattern::GetProperty
;
pro fabTrappingPattern::GetProperty, groups = groups, $
                                     ngroups = ngroups, $
                                     count = count, $
                                     traps  = traps,  $
                                     data   = data,   $
                                     _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.IDLgrModel::GetProperty, _extra = re

  groups = self.get(/all, isa = 'fabtrapgroup', count = ngroups)
  if ngroups le 0 then $
     groups = []

  if arg_present(count) then begin
     count = 0
     foreach group, groups do $
        count += group.count
  endif

  if arg_present(traps) then begin
     traps = list()
     foreach group, groups do $
        traps.add, group.traps, /extract
  endif
  
  if arg_present(data) then begin
     data = []
     foreach group, groups do $
        data = [[data], [group.data]]
  endif
end

;;;;;
;
; fabTrappingPattern::SetProperty
;
pro fabTrappingPattern::SetProperty, cgh    = cgh,    $
                                     traps  = traps,  $
                                     groups = groups, $
                                     data   = data,   $
                                     _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  self.IDLgrModel::SetProperty, _extra = re

  if isa(cgh, 'fabcgh') then $
     self.cgh = cgh

  if isa(traps, 'objref') then begin
     self.clear
     self.add, traps
  endif

  if isa(groups, 'objref') then begin
     if ~isa(traps) then self.clear
     self.add, groups
  endif

  if n_elements(data) ge 5 then begin
     self.clear
     group = fabtrapgroup()
     ntraps = n_elements(data[0,*])
     for n = 0, ntraps-1 do $
        group.add, fabtweezer(rc = data[0:2, n], $
                              amplitude = data[3, n], $
                              phase = data[4, n])
     self.add, group
  endif
end
                                        
;;;;;
;
; fabTrappingPattern::Add
;
; Add the Trap to the Model and project the full trapping pattern
;
pro fabTrappingPattern::Add, this, $
                             noproject = noproject

  COMPILE_OPT IDL2, HIDDEN

  if isa(this) then begin
     if isa(this[0], 'fabtrapgroup') then $
        self.IDLgrModel::Add, this $
     else if isa(this[0], 'fabtrap') then $
        self.IDLgrModel::Add, fabtrapgroup(this)
  endif

  if ~keyword_set(noproject) then $
     self.project
end

;;;;;
;
; fabTrappingPattern::Cleanup
;

;;;;;
;
; fabTrappingPattern::Init
;
; Initialize the Model and computational pipeline
; for a trapping pattern
;
function fabTrappingPattern::Init, traps = traps, $
                                   groups = groups, $
                                   cgh = cgh, $
                                   _ref_extra = re

  COMPILE_OPT IDL2, HIDDEN

  if (self.IDLgrModel::Init(_extra = re) ne 1) then $
     return, 0

  if isa(cgh, 'fabcgh') then $
     self.cgh = cgh

  if isa(traps, 'objref') then $
     self.add, traps

  if isa(groups, 'objref') then $
     self.add, groups

  return, 1
end

;;;;;
;
; fabTrappingPattern__define
;
pro fabTrappingPattern__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {fabTrappingPattern, $
            inherits IDLgrModel, $ ; graphical representation of traps
            inherits IDL_Object, $ ; for implicit get/set
            cgh: obj_new() $       ; pipeline for calculating hologram
           }
end
