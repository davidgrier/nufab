;+
; NAME:
;    fabslm_monitor
;
; PURPOSE:
;    Object class for transmitting computed holograms to a
;    spatial light modulator whose interface is implemented
;    with an X-Window display.
;
; INHERITS:
;    fabslm
;
; PROPERTIES:
; [ GS] DATA: Byte-valued hologram
;
; [IG ] DEVICE_NAME: Name of the X Window display
;
; [IG ] DIMENSIONS: Dimensions of the SLM.
;       Determined automatically for a physical SLM attached to
;       a secondary display.  If no SLM is detected, or if
;       DIMENSIONS are specified, a secondary window is opened
;       on the current display to simulate an SLM.
;
; [IGS] GAMMA: Gamma factor for presenting hologram data on SLM display
;
; METHODS:
;    SetProperty
;    GetProperty
;
; MODIFICATION HISTORY:
; 01/26/2011 Written by David G. Grier, New York University
; 02/02/2011 DGG removed RC and MAT calibration constants into
;    the definition of the fabCGH class.  Added COMPILE_OPT.
; 11/04/2011 DGG updated object creation syntax.
; 12/09/2011 DGG inherit IDL_Object.  Remove KC.  Documentation fixes.
; 05/04/2012 DGG check that DIM is a number in Init
; 12/20/2013 DGG overhauled for new fab version.
; 04/06/2014 DGG try to set TLB_FRAME_ATTR properties.
; 04/24/2014 DGG Introduced GAMMA property.
; 07/11/2015 DGG Update monitor selection logic.
;
; Copyright (c) 2011-2015, David G. Grier
;-

;;;;;
;
; fabslm_monitor::SetProperty
;
; Set SLM properties
;
pro fabslm_monitor::SetProperty, data = data, $
                                 gamma = gamma

  COMPILE_OPT IDL2, HIDDEN

  if isa(data, /number, /array) then $
     self.hologram.setproperty, data = data

  if isa(gamma, /number, /scalar) then $
     self.palette.setproperty, gamma = gamma

  self.slm.draw
end

;;;;;
;
; fabslm_monitor::GetProperty
;
; Get SLM properties
;
pro fabslm_monitor::GetProperty, device_name = device_name, $
                                 dimensions = dimensions, $
                                 data = data, $
                                 gamma = gamma
                        
  COMPILE_OPT IDL2, HIDDEN
    
  if arg_present(device_name) then $
     device_name = self.device_name

  if arg_present(dimensions) then $
     dimensions = self.dimensions

  if arg_present(data) then $
     data = self.hologram.data

  if arg_present(gamma) then $
     self.palette.getproperty, gamma = gamma
end

;;;;;
;
; fabslm_monitor::FindDevice()
;
function fabslm_monitor::FindDevice, primary = primary

  COMPILE_OPT IDL2, HIDDEN

  monitors = IDLsysMonitorInfo()
  nmonitors = monitors.getnumberofmonitors()

  if nmonitors le 0 then begin
     obj_destroy, monitors
     return, 0B
  endif
  
  names = monitors.getmonitornames()

  if strlen(self.device_name gt 0) then begin ; specific device
     slm = where(self.device_name eq names, success)
     if ~success then begin
        obj_destroy, monitors
        return, 0B
     endif
  endif else if (keyword_set(primary) || (nmonitors eq 1)) then $
     slm = monitors.getprimarymonitorindex() $
  else $
     slm = (monitors.getprimarymonitorindex() + 1) mod 2
    
  rect = monitors.getrectangles()
  self.dimensions = (nmonitors eq 1) ? $
                    rect[[2, 3]] - rect[[0, 1]] : $
                    rect[[2, 3], slm] - rect[[0, 1], slm]
  self.device_name = names[slm]

  obj_destroy, monitors
  return, 1B
end

;;;;;
;
; fabslm_monitor::Init()
;
function fabslm_monitor::Init, device_name = device_name, $
                               primary = primary, $
                               dimensions = dimensions, $
                               gamma = gamma, $
                               _ref_extra = re


  COMPILE_OPT IDL2, HIDDEN
  
  if ~self.fabslm::init(_extra = re) then $
     return, 0B

;;; Display for SLM
  self.device_name =  isa(device_name, 'string') ? device_name : ''

  if ~self.finddevice(primary = primary) then $
     return, 0B

;;; Widget hierarchy
  self.wtlb = (keyword_set(primary)) ? $
              widget_base(title = 'SLM', resource_name = 'SLM', $
                          tlb_frame_attr=31) : $
              widget_base(title = 'SLM', resource_name = 'SLM', $
                          display_name = self.device_name, $
                          tlb_frame_attr=31)

  if isa(dimensions, /number, /array) && $
     total(dimensions gt 0) && $
     total(dimensions le self.dimensions) then $
        self.dimensions = long(dimensions)
     
  wslm = widget_draw(self.wtlb, $
                     xsize = self.dimensions[0], $
                     ysize = self.dimensions[1], $
                     graphics_level = 2)
  
  widget_control, self.wtlb, /realize
  
;;; Graphics hierarchy
  widget_control, wslm, get_value = slm
  self.slm = slm

  ramp = bindgen(256)
  mygamma = isa(gamma, /number, /scalar) ? (float(gamma) > 0.) < 10. : 1.
  self.palette = IDLgrPalette(ramp, ramp, ramp, gamma = mygamma)
  data = bytarr(self.dimensions)
  self.hologram = IDLgrImage(data, palette = self.palette)
  
  model = IDLgrModel()
  model.add, self.hologram
  
  view = IDLgrView(viewplane_rect = [0., 0, self.dimensions])
  view.add, model

;;; Embed graphics hierarchy in widget hierarchy
  self.slm.setproperty, graphics_tree = view
  
  return, 1B
end

;;;;;
;
; fabslm_monitor::Cleanup
;
pro fabslm_monitor::Cleanup

  COMPILE_OPT IDL2, HIDDEN

  widget_control, self.wtlb, /destroy
end

;;;;;
;
; fabslm_monitor__define
;
pro fabslm_monitor__define

  COMPILE_OPT IDL2, HIDDEN
  
  struct = {fabslm_monitor,         $
            inherits fabslm,        $
            device_name: '',        $ ; name of SLM device
            wtlb:        0L,        $ ; top-level base
            slm:         obj_new(), $ ; IDLgrWindow for drawing
            hologram:    obj_new(), $ ; IDLgrImage for data
            palette:     obj_new()  $ ; lookup table
           }
end
