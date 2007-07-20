" Vim plugin for editing plist files.
" Cribbed from pdftk.vim, by Sid Steward, which was
" Cribbed from gzip.vim, by Bram Moolenaar
" Maintainer: Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" Install in your plugin directory to use.  This plugin converts binary plist
" files to XML on read, and reverses to the process on save.  Be careful, it
" will not be converted back if the file is malformed.

" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
" - some autocommands are already taking care of plist files
if exists("loaded_plutil") || &cp || exists("#BufReadPre#*.plist")
  finish
endif
let loaded_plutil = 1

augroup plutil
  " Remove all plutil autocommands
  au!

  " Enable clear text (XML) editing of plist files
  " set binary mode before reading the file
  autocmd BufReadPre,FileReadPre	*.plist  setlocal bin ts=2
  autocmd BufReadPost,FileReadPost	*.plist  call s:readplist()
  autocmd BufWritePost,FileWritePost	*.plist  call s:writeplist()

augroup END

function! s:esc(arg)
  if exists("*shellescape")
    return (shellescape(a:arg))
  else
    return '"'.a:arg.'"'
  endif
endfunction

" Function to check that executing "cmd [-f]" works.
" The result is cached in s:have_"cmd" for speed.
function! s:check(cmd)
  let name = substitute(a:cmd, '\(\S*\).*', '\1', '')
  if !exists("s:have_" . name)
    let e = executable(name)
    if e < 0
      let r = system(name)
      let e = (r !~ "not found" && r != "")
    endif
    exe "let s:have_" . name . "=" . e
  endif
  exe "return s:have_" . name
endfunction

" After reading binary file: Convert text in buffer with "cmd"
function! s:readplist()
  " don't do anything if the cmd is not supported
  if getline(1) =~ '<?xml\>'
    " If already XML, make a note and exit
    let b:plist_format = "xml1"
    setlocal nobin
    return
  endif
  let b:plist_format = "binary1"
  let cmd = "plutil -convert xml1 %s -o %s"

  call s:read(cmd)

  " When converted the whole buffer, do autocommands
  if &verbose >= 8
    execute         "doau BufReadPost " . expand("%:r") . ".xml"
  else
    execute "silent! doau BufReadPost " . expand("%:r") . ".xml"
  endif
endfunction

function! s:read(cmd)
  " don't do anything if the cmd is not supported
  if !s:check(a:cmd)
    return 0
  endif
  " make 'patchmode' empty, we don't want a copy of the written file
  let pm_save = &pm
  set pm=
  " remove 'a' and 'A' from 'cpo' to avoid the alternate file changes
  let cpo_save = &cpo
  set cpo-=a cpo-=A
  " set 'modifiable'
  let ma_save = &ma
  setlocal ma
  " when filtering the whole buffer, it will become empty
  let empty = line("'[") == 1 && line("']") == line("$")
  let tmpe = tempname()
  let tmpo = tempname()
  " write the just read lines to a temp file
  execute "silent '[,']w " . tmpe
  " convert the temp file, modified for plutil
  call system(printf(a:cmd,s:esc(tmpe),s:esc(tmpo)))
  " delete the binary lines; remember the line number
  let l = line("'[") - 1
  if exists(":lockmarks")
    lockmarks '[,']d _
  else
    '[,']d _
  endif
  " read in the converted lines
  setlocal bin
  if exists(":lockmarks")
    execute "silent lockmarks " . l . "r " . tmpo
  else
    execute "silent " . l . "r " . tmpo
  endif

  " if buffer became empty, delete trailing blank line
  if empty
    silent $delete _
    1
  endif
  " delete the temp file and the used buffers
  call delete(tmpo)
  call delete(tmpe)
  silent! exe "bwipe " . tmpo
  silent! exe "bwipe " . tmpe
  let &pm = pm_save
  let &cpo = cpo_save
  let &l:ma = ma_save

  return 1
endfunction

function! s:writeplist()
  if exists("b:plist_format")
    call s:write("plutil -convert ".b:plist_format." %s -o %s")
    " I don't know why this is sometimes necessary
    if &ft == "xml"
      let &syn = &ft
    endif
  endif
endfunction

" After writing binary file: Convert written file with "cmd"
function s:write(cmd)
  " don't do anything if the cmd is not supported
  if s:check(a:cmd)
    let nm = expand("<afile>")
    let tmp = tempname()
    call system(printf(a:cmd,s:esc(nm),s:esc(tmp)))
    if !v:shell_error
      call rename(tmp, nm)
    else
      echohl ErrorMsg
      echo "An error occured while trying to convert the file."
      echohl NONE
      return
    endif
    " refresh buffer from the disk; this prevents the user from
    " receiving errant "file has changed on disk" messages; plus, it does
    " update the buffer to reflect changes made at save-time
    execute "silent edit"
    execute "silent doau BufReadPost ".nm
  endif
endfunction

" vim: set sw=2 :
