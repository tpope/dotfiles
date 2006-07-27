" Vim plugin for editing png/gif files.
" Cribbed from pdftk.vim, by Sid Steward, which was
" Cribbed from gzip.vim, by Bram Moolenaar
" Maintainer: Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
" - some autocommands are already taking care of png files
if exists("loaded_imagemagick") || &cp || exists("#BufReadPre#*.png")
  finish
endif
let loaded_imagemagick = 1

augroup imagemagick
  " Remove all imagemagick autocommands
  au!

  " Enable clear text (XPM) editing of png/gif files
  " set binary mode before reading the file
  autocmd BufReadPre,FileReadPre	*.png,*.gif  setlocal bin
  autocmd BufReadPost,FileReadPost	*.png,*.gif  call s:read("convert")
  autocmd BufWritePost,FileWritePost	*.png,*.gif  call s:write("convert")

augroup END

" Function to check that executing "cmd [-f]" works.
" The result is cached in s:have_"cmd" for speed.
fun s:check(cmd)
  let name = substitute(a:cmd, '\(\S*\).*', '\1', '')
  if !exists("s:have_" . name)
    let e = executable(name)
    if e < 0
      let r = system(name);
      let e = (r !~ "not found" && r != "")
    endif
    exe "let s:have_" . name . "=" . e
  endif
  exe "return s:have_" . name
endfun

" After reading binary file: Convert text in buffer with "cmd"
fun s:read(cmd)
  " don't do anything if the cmd is not supported
  if !s:check(a:cmd)
    return
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
  let tmp = tempname()
  let tmpe = tmp . "." . expand("<afile>:e")
  let tmpo = tmp . ".xpm"
  " write the just read lines to a temp file "'[,']w tmp.xpm"
  execute "silent '[,']w " . tmpe
  " convert the temp file, modified for imagemagick
  call system(a:cmd . " \"" . tmpe . "\" \"" . tmpo . "\"")
  " delete the binary lines; remember the line number
  let l = line("'[") - 1
  if exists(":lockmarks")
    lockmarks '[,']d _
  else
    '[,']d _
  endif
  " read in the converted lines "'[-1r tmpo"
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
  " When converted the whole buffer, do autocommands
  if empty
    if &verbose >= 8
      execute "doau BufReadPost " . expand("%:r") . ".xpm"
    else
      execute "silent! doau BufReadPost " . expand("%:r") . ".xpm"
    endif
  endif
  setf xpm
endfun

" After writing binary file: Convert written file with "cmd"
fun s:write(cmd)
  " don't do anything if the cmd is not supported
  if s:check(a:cmd)
    let nm = expand("<afile>")
    let tmp = tempname() . "." . expand("<afile>:e")
    let cmdout = system(a:cmd . " " . " \"" . nm . "\" \"" . tmp . "\" 2>&1")
    if cmdout !~? "error:"
      call rename(tmp, nm)
      execute "silent edit"
    else
      echo "An error occured while trying to convert the image using imagemagick."
    endif
    " refresh buffer from the disk; this prevents the user from
    " receiving errant "file has changed on disk" messages; plus, it does
    " update the buffer to reflect changes made by imagemagick at save-time
    call s:read("convert")
  endif
endfun

" vim: set sw=2 :
