function nufab_stack, s, $
                 nframes = nframes, $
                 framerate = framerate

COMPILE_OPT IDL2

if ~isa(s, 'hash') then $
   s = getnufab()

if ~s.haskey('camera') then $
   return, 0

if ~isa(nframes, /number, /scalar) then $
   nframes = 10

if ~isa(framerate, /number, /scalar) then $
   framerate = 30.

s['video'].play = 0

interval = 1./framerate

camera = s['camera']
dim = camera.dimensions
stack = bytarr(nframes, dim[0], dim[1], /nozero)

schedule = (findgen(nframes) + 1)*interval
schedule += systime(1)
for n = 0, nframes-1 do begin
   wait, (schedule[n] - systime(1)) > 0
   stack[n, *, *] = camera.read()
end

s['video'].play = 1

return, stack
end
