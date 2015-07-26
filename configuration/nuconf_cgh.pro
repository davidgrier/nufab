;+
; NAME
;    nuconf_cgh()
;
; Options:
; OBJECT:     name of CGH computational pipeline object
; RC:         [xc,yc] position of optical axis on video screen
; MAT:        3x3 transformation matrix for placing traps in video
; KC:         [kx,ky] position of optical axis on SLM
; WINDOWON:   Flag: If set, compensate for Nyquist windowing.
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
; 07/25/2015 DGG Configure WINDOWON property
;
; Copyright (c) 2013-2015 David G. Grier
;-
function nuconf_cgh, configuration

  COMPILE_OPT IDL2, HIDDEN

  if configuration.haskey('slm') then $
     slm = configuration['slm']

  cgh_object = (configuration.haskey('cgh_object')) ? $
               configuration['cgh_object'] : 'fabcgh_fast'

  if configuration.haskey('cgh_rc') then $
     if execute('a = '+configuration['cgh_rc'], 1, 1) then $
        rc = a $
     else if (configuration.haskey('camera') && $
              isa(configuration['camera'], 'fabcamera')) then $
                 rc = configuration['camera'].dimensions/2.
  
  if configuration.haskey('cgh_kc') then $
     if execute('a = '+configuration['cgh_kc'], 1, 1) then $
        kc = a
  
  if configuration.haskey('cgh_q') then $
     q = float(configuration['cgh_q'])

  if configuration.haskey('cgh_aspect_ratio') then $
     aspect_ratio = float(configuration['cgh_aspect_ratio'])

  if configuration.haskey('cgh_aspect_z') then $
     aspect_z = float(configuration['cgh_aspect_z'])

  if configuration.haskey('cgh_angle') then $
     angle = float(configuration['cgh_angle'])

  if configuration.haskey('cgh_roi') then $
     if execute('a = '+configuration['cgh_roi'], 1, 1) then $
        roi = a

  windowon = (configuration.haskey('cgh_windowon')) ? $
             keyword_set(long(configuration['cgh_windowon'])) : 1
  
  cgh = obj_new(cgh_object, slm = slm, rc = rc, kc = kc, $
                q = q, aspect_ratio = aspect_ratio, angle = angle, $
                aspect_z = aspect_z, roi = roi, windowon = windowon)

  if ~isa(cgh, 'fabcgh') then $
     configuration['error'] = 'could not initialize CGH'

  if configuration.haskey('video') then $
     cgh.registercallback, configuration['video']

  configuration['cgh'] = cgh
  return, 'cgh'
end
