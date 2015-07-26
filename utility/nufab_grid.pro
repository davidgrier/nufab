;+
; NAME:
;    nufab_grid
;
; PURPOSE:
;    Project traps in a grid
;
; CATEGORY:
;    Utility, hardware control
;
; CALLING SEQUENCE:
;    nufab_grid, nx [, ny]
;
; INPUTS:
;    nx: number of traps along x
;
; OPTIONAL INPUTS:
;    ny: number of rows of traps.  Default: 1
;
; KEYWORD PARAMETERS:
;    scale: number of screen pixels between adjacent traps
;        Default: text fills 80 percent of screen.
;
;    fuzz: random offset of pixels from grid.
;        Default: 10 percent of scale
;
; SIDE EFFECTS:
;    Projects optical tweezers on current nufab session.
;
; RESTRICTIONS:
;    Does nothing unless nufab is running
;
; MODIFICATION HISTORY:
; 07/26/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

pro nufab_grid, nx, ny, scale = scale, fuzz = fuzz, theta = _theta

  COMPILE_OPT IDL2

  ;; Get access to a running nuFab instance
  s = getnufab()
  if ~s.count() then return

  ;; Create a pattern of points
  if n_params() lt 1 then return
  if n_params() lt 2 then ny = 1
  theta = isa(_theta, /number, /scalar) ? !dtor * _theta : 0.

  px = findgen(1, nx*ny)
  py = floor(px / nx)
  px = px mod nx
  px -= mean(px)
  py -= mean(py)
  p = [px*cos(theta) - py*sin(theta), px*sin(theta) + py*cos(theta)]

  if isa(fuzz, /number, /scalar) then $
     p += fuzz * randomn(seed, 2, nx*ny)

  ;; Scale the pixel positions to fit into
  ;; nuFab's field of view
  if ~isa(scale, /number, /scalar) then begin
     dim = s['camera'].dimensions ; scale is set by camera
     scale = 0.8 * max(dim/[nx+2, ny+2])
  endif
  p *= scale

  ;; Center the pixels over the center of
  ;; nuFab's trapping pattern
  rc = s['cgh'].rc              ; CGH determines the center
  p[0, *] += rc[0]
  p[1, *] += rc[1]

  ;; Add these traps to the trapping pattern
  group = fabTrapGroup(state = 1) ; create the group of traps
  npts = n_elements(p[0,*])
  for n = 0, npts-1 do $              ; add each pixel to group
     group.add, fabTweezer(rc = p[*,n]) ; ... each at its own position
  s['trappingpattern'].add, group       ; add the group to the pattern
  s['trappingpattern'].project          ; project the pattern
  s['cgh'].refine
   
  ;;; We can move the group around with commands of the form
  ;;; IDL> group.moveto, rnew ; which moves group's center to rnew
  ;;; IDL> group.moveby, dr   ; which moves its center by dr
  ;;; where rnew and dr are 2- or 3-dimensional vectors with
  ;;; distances measured in screen pixels.
end
