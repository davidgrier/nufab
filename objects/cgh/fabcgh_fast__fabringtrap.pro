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

  pr = self.rotatescale(trap.rc)
  ex = exp(*self.ikx * pr[0] + *self.ikxsq * pr[2])
  ey = exp(*self.iky * pr[1] + *self.ikysq * pr[2])
  return, trap.alpha * self.window(pr) * $
          (ex # ey) * $
          beselj(*self.kr*trap.radius, trap.ell) * $
          exp(complex(0, 1) * trap.ell * *self.theta)
end
