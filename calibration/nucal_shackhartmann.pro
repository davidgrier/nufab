;;;;;
;
; nucal_sh_snap()
;
function nucal_sh_snap, s, ndx

COMPILE_OPT IDL2, HIDDEN

camera = s['camera']
shutter = camera.shutter
repeat begin
   oshutter = camera.shutter
   camera.shutter = oshutter+5
   wait, 0.1
   a = nufab_snap(s)
   max = max(a[ndx])
endrep until (max gt 200) || (camera.shutter eq oshutter)

camera.shutter = shutter

return, a
end

pro nucal_shackhartmann, event

COMPILE_OPT IDL2, HIDDEN

if isa(event, 'hash') then $
   s = event $
else $
   widget_control, event.top, get_uvalue = s

;;; Objects
camera = s['camera']
cgh = s['cgh']
slm = s['slm']
trappingpattern = s['trappingpattern']

;;; Save camera settings
shutter = camera.shutter
camera.shutter = 1

;;; Object properties
camdim = camera.dimensions      ; dimensions of images
slmdim = slm.dimensions         ; dimensions of SLM
roi = cgh.roi                   ; region of interest on SLM
r0 = (cgh.rc)[0:1]              ; center of trapping pattern

;;; Triangular array of domains on SLM
nx = 4
; Domains are located within the ROI on the SLM
w = roi[2] - roi[0]
h = roi[3] - roi[1]
rad = w/(2.*nx + 1.) ; radius of domains

; add enough rows to fill ROI
ny = round(h/(2.*rad))
npts = nx * ny

; coordinates of triangular array on SLM
rs = findgen(2, npts)
x = rebin(findgen(nx), nx, ny, /sample)
x[*,1:*:2] += 0.5
x = 2. * rad * reform(x, 1, npts) + roi[0] + rad
y = reform(rebin(findgen(1,ny), nx, ny, /sample), 1, npts)
y0 = roi[1] + (h - ((ny - 1) * sqrt(3)) * rad)/2.
y = sqrt(3.) * rad * y + y0
rs[0, *] = x
rs[1, *] = y

;;; Fibonacci spiral of traps to avoid interference
rc = findgen(2, npts)           ; coordinates of traps
rmax = min([r0, camdim-r0])
n1 = round(0.75*npts)
theta = findgen(npts) * 2.39996
r = (0.5*rmax)/sqrt(n1) * sqrt(findgen(npts) + n1)
x = r * cos(theta) + r0[0]
y = r * sin(theta) + r0[1]
rc[0, *] = x
rc[1, *] = y

;;; Mask for image analysis
mask = bytarr(camdim)
mask[x, y] = bindgen(npts) + 1B
mrad = 40
mask = dilate(mask, shift(dist(2*mrad+1), mrad, mrad) le mrad, /gray)
wmask = where(mask gt 0)

;;; Conventional CGH
trappingpattern.clear
group = fabtrapgroup(state = 0)
for n = 0, npts-1 do $
   group.add, fabtweezer(rc = rc[*, n])
trappingpattern.add, group
psi = cgh.data                  ; hologram encoding conventional CGH
a = nucal_sh_snap(s, wmask)     ; image projected by conventional CGH

;;; Shack-Hartmann 
trappingpattern.clear
phi = byte(255*randomu(seed, slmdim))
group = fabtrapgroup(state = 0)
group.add, fabtweezer()
trappingpattern.add, group
for n = 0, npts-1 do begin
   group.moveto, rc[*, n], /override
   thisphi = cgh.data; + byte(nufab_phase(s)*128/!pi) ; XXX check this
   w = where((rebin((findgen(slmdim[0]) - rs[0, n])^2, slmdim) + $
              rebin((findgen(1, slmdim[1]) - rs[1, n])^2, slmdim)) le rad^2)
   phi[w] = thisphi[w]
endfor
trappingpattern.clear
slm.data = phi                  ; hologram encoding Shack-Hartmann CGH
b = nucal_sh_snap(s, wmask)     ; image projected by Shack-Hartmann CGH
c = bpass(b, 3, 20)

;;; Displacements
r0 = findgen(2, npts)
r1 = findgen(2, npts)
for n = 1, npts do begin
   w = where(mask eq n)
   xy = array_indices(mask, w)
   ;;; conventional CGH: intended locations
   rho = a[w]
   rho -= min(rho)
   m = total(rho)
   x = total(xy[0, *] * rho)/m
   y = total(xy[1, *] * rho)/m
   r0[*, n-1] = [x, y]
   ;;; Shack-Hartmann CGH: displaced maxima
   rho = c[w]
   rho -= min(rho)
   m = total(rho)
   x = total(xy[0, *] * rho)/m
   y = total(xy[1, *] * rho)/m
   r1[*, n-1] = [x, y]
endfor
dr = r1 - r0

;;; Gradients of phase
;; dxp = griddata(rs[0, *], rs[1, *], dr[0, *], $
;;                start = [0, 0], dimension = slmdim, delta = [1, 1], $
;;                /radial_basis_function)

;; dyp = griddata(rs[0, *], rs[1, *], dr[1, *], $
;;                start = [0, 0], dimension = slmdim, delta = [1, 1], $
;;                /radial_basis_function)

;; ;;; Use Fourier derivative theorem to obtain phase from gradients
;; kxp = fft(dxp - mean(dxp), -1, /center)
;; kyp = fft(dyp - mean(dyp), -1, /center)
;; kx = rebin(findgen(slmdim[0]) - slmdim[0]/2., slmdim)
;; ky = rebin(findgen(1, slmdim[1]) - slmdim[1]/2., slmdim)
;; ksq = kx^2 + ky^2 > 1.
;; kx /= ksq
;; ky /= ksq
;; phase = imaginary(fft(kx * kxp + ky * kyp, 1, /center))

;; ;;; scale phase
;; phase -= min(phase)

;p = plot(rs, symbol = 'o', linestyle = '', /sym_filled, $
;         xrange = [0, slmdim[0]], yrange = [0, slmdim[1]])
;dx = [rs[0, *], rs[0, *] + 2*dr[0, *]]
;dy = [rs[1, *], rs[1, *] + 2*dr[1, *]]
;arrows = arrow(dx, dy, /data, current = p)

s['psi_image'] = a
s['phi_image'] = b
s['psi_r'] = r0
s['phi_r'] = r1
s['rs'] = rs
s['dxphase'] = dxphase
s['dyphase'] = dyphase
s['shphase'] = phase

;;; Restore camera settings
camera.shutter = shutter

end
