;+
; NAME
;    nuconf_trappingpattern()
;
; MODIFICATION HISTORY
; 12/26/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013-2014 David G. Grier
;-
function nuconf_trappingpattern, configuration

COMPILE_OPT IDL2, HIDDEN

trappingpattern = fabtrappingpattern(cgh = configuration['cgh'])

if ~isa(trappingpattern, 'fabtrappingpattern') then $
   configuration['error'] = 'could not initialize trapping pattern'

configuration['trappingpattern'] = trappingpattern
return, 'trappingpattern'
end
