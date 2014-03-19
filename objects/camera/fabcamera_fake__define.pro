;+
; NAME
;    fabcamera_fake()
;
; PURPOSE
;    Object interface for simulated digital camera.
;    Returns noisy image.
;
; SUBCLASSES
;    fabcamera
;
; PROPERTIES
;    DIMENSIONS: [w,h,[3]] dimensions of images
;        [IG ]
; 
;    GREYSCALE;  flag: If set deliver greyscale images
;        [IG ]
;
;    DATA: array of image data
;        [ G ]
;
; METHODS
;    READ()
;        Reads image and returns resulting DATA
;
;    READ
;        Read image into DATA
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-
pro fabcamera_fake__define

COMPILE_OPT IDL2, HIDDEN

void = {fabcamera_fake, $
        inherits fabcamera}
end
