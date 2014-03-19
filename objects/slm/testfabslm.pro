pro testfabslm

COMPILE_OPT IDL2

slm = fabslm()
if isa(slm, 'fabslm') then print, 'ok'

slm.data = bytscl(randomu(seed, slm.dimensions))

wait, 1

end
