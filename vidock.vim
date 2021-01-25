" License: GNU GPL 3

" testing :source ./vidock.vim

" simple printing error msg
function! s:PrintErr(msg) abort
  " error sound
  execute 'normal! \<Esc>'
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

" check if docker engine is up
function! s:CheckDocker() abort  
  let l:isDockerNotRunning = len(system('docker ps 1>/dev/null'))
  return l:isDockerNotRunning
endfunction

" quit script if docker enigne is down
if s:CheckDocker() 
  call s:PrintErr('Docker engine is not running.')
  finish 
endif

echom "Welcome to ViDock" 

topleft vnew

" 'q' shortcut to exit instantly
nnoremap q :q<CR>
" do nothin on visual-mode shortcut
nnoremap v <Nop>

setlocal nonumber
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal noswapfile
setlocal nobl

let docker_version = system('docker -v')

call append(0, 'Welcome to ViDock')
call append(2, 'Your Docker:')
call append(3, split(docker_version, '\v\n'))

" disable file modification
setlocal noma
