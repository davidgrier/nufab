;+
; NAME: 
;    textcoords
;
; PURPOSE: 
;    Returns (x,y) coordinates for rasterized text
;
; CATEGORY: 
;    Holography, graphics, computational geometry
;
; CALLING SEQUENCE:
;    xy = textcoords(s)
;
; INPUTS:
;    s: String to be rasterized.  Can include all standard IDL text
;        formatting commands, including those for font selection.
;
; KEYWORD PARAMETERS:
;    size: Size of typical text in the form [ch_width, ch_height]
;        where ch_width and ch_height are measured in pixels.
;        Default: [6,8].
;
;    wsize: Size of target graphics window: [width, height].
;        Default: [640,512].
;
;    center: If set, text coordinates are centered.
;
; OUTPUTS:
;    xy: (x,y) coordinates of the rasterized text.
;
; OPTIONAL OUTPUTS:
;    width: Width of the text string (pixels).
;    height: Height of the text string (pixels).
;
; SIDE EFFECTS:
;    Assumes X or equivalent graphics device capable of
;    (1) creating pixmaps and (2) reading from them.
;
; PROCEDURE:
;    Formats text in a pixmap, uses tvrd() to read it in,
;    and where() to extract the lit pixels.
;
; EXAMPLE:
;    xy = textcoords("!5Rasterize This", size = [10,12])
;
; MODIFICATION HISTORY:
; 07/01/2001 Written by David G. Grier, The University of Chicago
; 02/15/2011 DGG, NYU: Code modernizations, documentation fixes,
;    added FUZZ keyword
;
; Copyright (c) 2001-2011, David G. Grier
;-

function textcoords, s, width, height, $
                     size = size, $
                     wsize = wsize, $
                     center = center, $
                     fuzz = fuzz

currentWindow = !d.window
currentXSize = !d.x_ch_size
currentYSize = !d.y_ch_size

width = 512
height = 2.*!d.y_ch_size
if not keyword_set(size) then $
   size = [6, 8]
device, set_character_size = size
if n_elements(wsize) eq 2 then begin
   width = wsize[0]
   height = wsize[1]
endif
window, /free, /pixmap, xsize = width, ysize = height
xyouts, 0, !d.y_ch_size, s, /dev
height = !d.y_ch_size
p = tvrd()
wdelete

if currentWindow ne -1 then $
   wset, currentWindow
device, set_character_size = [currentXSize, currentYSize]

w = transpose(where(p gt 0))
x = w mod width
y = fix(w / width)

x -= min(x)
y -= min(y)
width = max(x)
height = max(y)

if keyword_set(center) then begin
   x -= width/2
   y -= height/2
endif

if keyword_set(fuzz) then begin
   npts = n_elements(x)
   x += fuzz * randomu(seed, npts)
   y += fuzz * randomu(seed, npts)
endif

return, [x, y]
end
