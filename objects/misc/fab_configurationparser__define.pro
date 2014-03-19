;+
; NAME:
;    fab_configurationparser
;
; PURPOSE:
;    Object for parsing XML configuration files
;
; SUBCLASSES:
;    IDLffXMLSAX
;    IDL_Object
;
; PROPERTIES:
;    configuration: ordered hash of nufab properties and values
;
; METHODS:
;    ParseFile, filename
;        Extract properties and values from specified file into
;        configuration.
;        INPUTS:
;            filename: string containing name of xml configuration
;            file.
;        NOTE:
;            Parsing multiple files yields cumulative configuration
;
;    Parsefile(filename)
;        Parse configuration file and return current configuration
;
;    Clear
;        Clear current configuration
;    
; MODIFICATION HISTORY:
; 12/29/2013 Written by David G. Grier, New York University
;
; Copyright (c) 2013 David G. Grier
;-

;;;;;
;
; fab_configurationparser::clear
;
pro fab_configurationparser::clear

COMPILE_OPT IDL2, HIDDEN

self.configuration.remove, /all
end

;;;;;
;
; fab_configurationparser::parsefile()
;
function fab_configurationparser::parsefile, filename

COMPILE_OPT IDL2, HIDDEN

self.parsefile, filename
return, self.configuration

end

;;;;;
;
; fab_configurationparser::parsefile
;
pro fab_configurationparser::parsefile, filename, $
                                        _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

fn = file_search(filename, /test_read, count = found)
if found then $
   self.IDLffXMLSAX::parsefile, fn[0], _extra = re

end

;;;;;
;
; fab_configurationparser::startDocument
;
;pro fab_configurationparser::startDocument
;
;COMPILE_OPT IDL2, HIDDEN
;
;self.clear
;
;end

;;;;;
;
; fab_configurationparser::startElement
;
pro fab_configurationparser::startElement, uri, local, name, attributes, values

COMPILE_OPT IDL2, HIDDEN

if ~isa(attributes) then return

foreach attribute, attributes, ndx do $
   self.configuration[name+'_'+attribute] = values[ndx]

end

;;;;;
;
; fab_configurationparser::getproperty
;
pro fab_configurationparser::getproperty, configuration = configuration, $
                                          _ref_extra = re

COMPILE_OPT IDL2, HIDDEN

if arg_present(configuration) then $
   configuration = self.configuration

self.idlffxmlsax::getproperty, _extra = re

end

;;;;;
;
; fab_configurationparser::cleanup
;
pro fab_configurationparser::cleanup

COMPILE_OPT IDL2, HIDDEN

self.idlffxmlsax::cleanup ; XXX is this necessary?

end

;;;;;
;
; fab_configurationparser::init()
;
function fab_configurationparser::init, _extra = extra

COMPILE_OPT IDL2, HIDDEN

if ~self.idlffxmlsax::init(_extra = extra) then $
   return, 0B

self.configuration = hash()

return, 1B
end

;;;;;
;
; fab_configurationparser__define
;
pro fab_configurationparser__define

COMPILE_OPT IDL2, HIDDEN

struct = {fab_configurationparser, $
          inherits IDLffXMLSAX, $
          inherits IDL_Object, $
          configuration: hash() $
         }
end
