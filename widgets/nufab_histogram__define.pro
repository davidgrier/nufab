;+
; NAME:
;    nufab_histogram
;
; PURPOSE:
;    widget for displaying histograms of images
;
; INHERITS:
;    nufab_widget
;
; PROPERTIES:
; [R  ] WTOP:   Widget ID of the top-level widget
; [R  ] CAMERA: Object reference to a camera that will supply image data.
; [  S] TITLE:  Title of the widget
;
; MODIFICATION HISTORY
; 11/01/2015 Written by David G. Grier, New York University
;
; Copyright (c) 2015 David G. Grier
;-

;+
; nufab_histogram::handleEvent
;-
pro nufab_histogram::handleEvent, event

  COMPILE_OPT IDL2, HIDDEN

  widget_control, self.widget_id, timer = 0.1
  if widget_info(self.widget_id, /visible) then begin
     data = self.cam.data
     if self.cam.grayscale then begin
        (self.pl)[0].setdata, histogram(data, min = 0, max = 255)/1000.
        for c = 1, 2 do $
           (self.pl)[c].setdata, [0, 0]
     endif else $
        foreach pl, self.pl, c do $
           pl.setdata, histogram(data[c, *, *], min = 0, max = 255)/1000.
  endif
end

;+
; nufab_histogram::Create
;-
pro nufab_histogram::Create, wtop

  COMPILE_OPT IDL2, HIDDEN

  geometry = widget_info(wtop, /geometry)
  wid = widget_base(wtop, TITLE = self.title, $
                    RESOURCE_NAME = 'nufab')
  wdraw = widget_window(wid, $
                        xsize = geometry.xsize, $
                        ysize = geometry.ysize)
  widget_control, wid, /realize
  widget_control, wdraw, get_value = wdrawid
  xrange = [0, 255] ; XXX use camera's actual range
  pl = list()
  pl.add, plot(xrange, [0, 1], /nodata, current = wdrawid, $
               color = 'red', $
               xrange = xrange, /xstyle, $
               xtitle = 'Intensity', ytitle = 'Counts (x1000)', $
               font_size = 9, $
               position = [45, 40, geometry.xsize-10, geometry.ysize-10], $
               /device)
  pl.add, plot(xrange, [0, 1], /nodata, over = pl[0], $
               color = 'green')
  pl.add, plot(xrange, [0, 1], /nodata, over = pl[0], $
               color = 'blue')

  pl[0].setdata, $
     histogram(self.cam.data, min = xrange[0], max = xrange[1]) / 1000.
  self.pl = pl
  
  widget_control, wid, timer = 0.2
  self.widget_id = wid
end

;+
; nufab_histogram::Init
;-
function nufab_histogram::Init, wtop, camera, title

  COMPILE_OPT IDL2, HIDDEN

  self.title = title
  self.cam = camera
  return, self.nufab_widget::Init(wtop)
end

;+
; nufab_histogram__define
;-
pro nufab_histogram__define

  COMPILE_OPT IDL2, HIDDEN

  struct = {nufab_histogram, $
            inherits nufab_widget, $
            title: '', $
            pl: obj_new(), $
            cam: obj_new() $
           }
end
