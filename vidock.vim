" Vim global plugin for managing docker just inside editor
" License: GNU GPL 3

" testowanie :source ./vidock.vim

echom "Welcome to ViDock" 

topleft vnew


set nonumber

let docker_version = system('docker -v')

call append(0, 'Welcome to ViDock')
call append(2, 'Your Docker:')
call append(3, split(docker_version, '\v\n'))

" TODO: mapowanie q zeby wychodzil, wylaczenie insertmode, wylaczenie undo (u)
" nowe okno - byc moze buftype=nofile? pokombinowac
