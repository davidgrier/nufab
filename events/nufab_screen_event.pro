function nufab_screen_event, event

COMPILE_OPT IDL2, HIDDEN

case event.type of
   0: begin                           ; mouse down event
      case event.modifiers of
         0: nuevent_trapselect, event ; no modifier
         1: nuevent_trapadd, event    ; shift-click
         2: nuevent_trapremove, event ; control-click
      endcase
   end
   1: nuevent_mouseup, event
   2: nuevent_motion, event
   6: return, nuevent_keyboard(event)
   7: nuevent_wheel, event
   else: return, event
endcase

return, 0

end
