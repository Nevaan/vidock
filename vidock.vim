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
    file imagesList
    call s:ListImagesMenu()  
  elseif w:MyLine == 7
    file containerList
    call s:ListContainersMenu() 
  endif

  setlocal noma 
endfunction

function! s:ListImagesMenu() abort
  call append(0, 'ViDock::Images')
  nnoremap <buffer> q :call <SID>GoToView('vidockMain')<cr>
endfunction

function! s:ToggleShowAllContainers() abort

  if b:ShowAllToggle
    let b:ShowAllToggle = 0
  else
    let b:ShowAllToggle = 1
  endif


  call s:drawContainerList()

endfunction

function! s:drawContainerList() abort

  if b:ShowAllToggle
    let b:containers = systemlist('docker ps -a --format "{{.ID}} {{.Names}} {{.Image}} {{.State}}"')
  else
    let b:containers = systemlist('docker ps --format "{{.ID}} {{.Names}} {{.Image}} {{.State}}"')
  endif

  let l:lineIdx = 6
  let l:afterIdx = (l:lineIdx + 1)

  let b:containers = sort(b:containers, 's:sortContainers')

  setlocal ma 

  let l:buffL = line('$')
  if l:buffL>l:lineIdx
    execute 'normal '.(l:lineIdx+1).'GVGd' 
    call append((l:lineIdx-1), '')
  endif

  if len(b:containers) == 0
    call append(l:lineIdx, 'No containers to display')
  else
    for x in b:containers[0:-1]
       call append(l:lineIdx, x)
       let l:lineIdx += 1
    endfor
  endif
  setlocal noma
  
  execute 'normal '.(l:afterIdx).'G'
endfunction

fu! s:sortContainers(fst, snd)
  let fs = split(a:fst)[3]
  let ss = split(a:snd)[3]

  let l:run = 'running'
  let l:exit = 'exited'

  if (fs == l:run && ss == l:run) || ( fs == l:exit && ss == l:exit)
    return 0
  elseif ss == l:run
    return 1
  elseif fs == l:run
    return -1
  endif

endfunction

function! s:StartStopContainer() abort

  let l:container = getline(line('.'))
  let l:splittedC = split(l:container)

  let l:state = l:splittedC[3]  
  let l:id = l:splittedC[0]

  if l:state == 'running'
    echo 'Stopping: '.l:id
    call system('docker stop '.l:id) 
  elseif l:state == 'exited'
    echo 'Starting: '.l:id
    call system('docker start '.l:id) 
  endif

  call s:drawContainerList()

endfunction

function! s:ShowContainerInfo() abort


  let l:container = getline(line('.'))
  let l:splittedC = split(l:container)

  echo l:splittedC[0]

  enew 
  setlocal nonumber
  setlocal buftype=nofile
  setlocal noswapfile
  call append(0, l:splittedC[0])
  
  nnoremap <buffer> q :call <SID>GoToView('containerList')<cr>

endfunction

function! s:ListContainersMenu() abort
  call append(0, 'ViDock::Containers')
  call append(1, 'Commands: ')
  call append(2, 'a - toggle active/all')
  call append(3, 's - start/stop container')
  call append(4, 'i - container details')

  let b:ShowAllToggle = 1

  call s:ToggleShowAllContainers()
  nnoremap <buffer> a :call <SID>ToggleShowAllContainers()<cr>
  nnoremap <buffer> s :call <SID>StartStopContainer()<cr>
  nnoremap <buffer> i :call <SID>ShowContainerInfo()<cr>
  nnoremap <buffer> q :call <SID>GoToView('vidockMain')<cr>
endfunction

function! s:QuitViDock() abort
  execute 'bdelete vidockMain'
endfunction

function! s:GoToView(viewName) abort
  let l:current = bufnr('%')
  execute 'b '.bufnr(a:viewName)
  execute 'bdelete '.l:current
endfunction

" quit script if docker enigne is down
if s:CheckDocker() 
  call s:PrintErr('Docker engine is not running.')
  finish 
endif

echom "Welcome to ViDock" 

topleft 40vnew vidockMain

" 'q' shortcut to exit instantly
nnoremap <buffer> q :call <SID>QuitViDock() <cr>
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
nnoremap <buffer> <cr> :call <SID>EnterHandler() <cr>

