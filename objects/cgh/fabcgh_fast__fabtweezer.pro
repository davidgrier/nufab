;+
; fabCGH_fast::fabTweezer()
;
; Computes the field for an optical tweezer.
; This method is called by fabCGH to add an optical tweezer to the
; trapping field.
;
; MODIFICATION HISTORY:
; 06/30/2016 Written by David G. Grier, New York University
;
; COPYRIGHT:
; Copyright (c) 2016 David G. Grier
;-
function fabcgh_fast::fabtweezer, trap

  COMPILE_OPT IDL2

  pr = self.rotatescale(trap.rc)
  ex = exp(*self.ikx * pr[0] + *self.ikxsq * pr[2])
  ey = exp(*self.iky * pr[1] + *self.ikysq * pr[2])
  return, trap.alpha * (ex # ey) * self.window(pr)
end
