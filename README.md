# nufab

**An IDL application for controlling a 
Holographic Characterization System**

IDL is the Interactive Data language, and is a product of
[Exelis Visual Information Solutions](http://www.exelisvis.com)

## What it does

*nufab* creates a GUI representation of a holographic optical
trapping system, including control over such hardware elements
as a video camera, a trapping laser, an imaging laser and the
sample manipulation stage.  Interacting with the interface
allows the user to create and manipulate optical traps in real time.

*nufab* also can be controlled programmatically, with all hardware
and software objects exposed in an object-oriented API.  This makes
possible computer control of parts of the trapping pattern and
interactive control of other parts.

## Requirements

*nufab* runs under IDL version 8.3 or better on linux or MacOS systems.
Some elements of hardware control, particularly cameras, requires
additional interface libraries, which are distributed separately.
