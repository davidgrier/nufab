;+
; fabCGH_fast::fabRingtrap()
;
; Computes the field for an optical vortex.
; This method is called by fabCGH to add an optical vortex to the
; trapping field.
;
; MODIFICATION HISTORY:
; 06/30/2016 Written by David G. Grier, New York University
;
; COPYRIGHT:
; Copyright (c) 2016 David G. Grier
;-
function fabcgh_fast::fabRingtrap, trap

  COMPILE_OPT IDL2

  return, trap.alpha * beselj(*self.kr*trap.radius, trap.ell) * $
          exp(complex(0, 1) * trap.ell * *self.theta)
end
