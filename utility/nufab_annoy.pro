pro nufab_annoy

COMPILE_OPT IDL2, HIDDEN

file = (file_search(fab_path(), 'Its_a_trap.mp3'))[0]
spawn, 'play -q '+file+' &'
end
