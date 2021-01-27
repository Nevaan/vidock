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

" print main menu
function! s:MainMenu() abort
  execute 'normal 4G'
  setlocal ma
  execute 'normal! o'

  execute 'normal! o1. List images'
  execute 'normal! o2. List containers'

  setlocal noma
endfunction

"
function! s:CursorMoveHandler() abort
  let w:MyLine=line('.')

  if w:MyLine>5
    setlocal cursorline
  else
    setlocal nocursorline
  endif
endfunction

function! s:EnterHandler() abort
  if w:MyLine<6 
    return 0
  endif

  enew 
  setlocal nonumber
  setlocal buftype=nofile
  setlocal noswapfile

  if w:MyLine == 6
    call s:ListImagesMenu()  
  elseif w:MyLine == 7
    call s:ListContainersMenu() 
  endif

  setlocal noma 
endfunction

function! s:ListImagesMenu() abort
  call append(0, 'ViDock::Images')

endfunction

function! s:ToggleShowAllContainers() abort

  if b:ShowAllToggle
    let b:ShowAllToggle = 0
  else
    let b:ShowAllToggle = 1
  endif

  if b:ShowAllToggle
    let b:containers = systemlist('docker ps -a --format "{{.ID}} {{.Image}} {{.State}}"')
  else
    let b:containers = systemlist('docker ps --format "{{.ID}} {{.Image}} {{.State}}"')
  endif

  let l:lineIdx = 2

  setlocal ma 

  let l:buffL = line('$')
  if l:buffL>2
    execute 'normal 3GVGd' 
    call append(1, '')
  endif

  if len(b:containers) == 0
    call append(2, 'No containers to display')
  else
    for x in reverse(b:containers)[0:-1]
       call append(l:lineIdx, x)
       let l:lineIdx += 1
    endfor
  endif
  setlocal noma

endfunction

function! s:ListContainersMenu() abort
  call append(0, 'ViDock::Containers')

  let b:ShowAllToggle = 1

  call s:ToggleShowAllContainers()
  nnoremap <buffer> a :call <SID>ToggleShowAllContainers()<cr>

endfunction

function! s:QuitViDock() abort
  let l:currB = bufnr("%")
  b vidockMain
  execute 'bdelete '.l:currB
endfunction

" quit script if docker enigne is down
if s:CheckDocker() 
  call s:PrintErr('Docker engine is not running.')
  finish 
endif

echom "Welcome to ViDock" 

topleft 40vnew vidockMain

" 'q' shortcut to exit instantly
nnoremap q :call <SID>QuitViDock() <cr>
" do nothin on visual-mode shortcut
nnoremap v <Nop>

setlocal nonumber
setlocal buftype=nofile
setlocal noswapfile
setlocal winfixwidth
setlocal hidden

let docker_version = system('docker -v')

setlocal ma

call append(0, 'Welcome to ViDock')
call append(2, 'Your Docker:')
call append(3, split(docker_version, '\v\n'))

" disable file modification
setlocal noma

setlocal ma
call s:MainMenu()
autocmd CursorMoved <buffer> call s:CursorMoveHandler()
nnoremap <cr> :call <SID>EnterHandler() <cr>

