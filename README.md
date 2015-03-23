# nufab

**An IDL application for controlling a 
Holographic Characterization System**

IDL is the Interactive Data language, and is a product of
[Exelis Visual Information Solutions](http://www.exelisvis.com)

*nufab* is released under the
[GPLv3](https://www.gnu.org/copyleft/gpl.html)
and is maintained by David G. Grier (david.grier@nyu.edu).

## What it does

*nufab* creates a GUI representation of a holographic optical
trapping system, including control over such hardware elements
as a video camera, a trapping laser, an imaging laser and the
sample manipulation stage.  Interacting with the interface
allows the user to create and manipulate optical traps in real time.

*nufab* also can be controlled programmatically, with all hardware
and software objects exposed in an object-oriented API.
This facilitates a combination of automated and interactive
control over the instrument and the
trapping pattern.

## Requirements

*nufab* runs under IDL version 8.3 or better on GNU/linux or MacOS systems.
Some elements of hardware control, particularly cameras, requires
additional interface libraries, which are distributed separately.

### Camera Libraries

+ [*idlvideo*](https://github.com/davidgrier/idlvideo) IDL interface
for video cameras that are supported by the
[OpenCV](http://opencv.org) library.

+ [*idlpgr*](https://github.com/davidgrier/idlpgr) IDL interface
for [Point Grey](http://www.ptgrey.com/)  video cameras.

### Hardware acceleration

+ [*cudacgh*](https://github.com/davidgrier/cudacgh) CUDA-accelerated
hologram calculation improves system performance, particularly for
high-resolution spatial light modulators and large trapping patterns.
