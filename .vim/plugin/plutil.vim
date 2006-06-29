" Vim plugin for editing plist files.
" Cribbed from pdftk.vim, by Sid Steward, which was
" Cribbed from gzip.vim, by Bram Moolenaar
" Maintainer: Tim Pope <vimNOSPAM@tpope.info>
" $Id$

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
  autocmd BufReadPre,FileReadPre	*.plist  setlocal bin
  autocmd BufReadPost,FileReadPost	*.plist  call s:read("plutil")
  autocmd BufWritePost,FileWritePost	*.plist  call s:write("plutil")

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
  if getline(1) =~ '<?xml\>'
    " If already XML, make a note and exit
    let b:plist_format = "xml1"
    setlocal nobin
    return
  else
    let b:plist_format = "binary1"
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
  " write the just read lines to a temp file "'[,']w tmp.plist"
  execute "silent '[,']w " . tmpe
  " convert the temp file, modified for plutil
  call system(a:cmd . " -convert xml1 -o \"" . tmp . "\" \"" . tmpe . "\"")
  " delete the binary lines; remember the line number
  let l = line("'[") - 1
  if exists(":lockmarks")
    lockmarks '[,']d _
  else
    '[,']d _
  endif
  " read in the converted lines "'[-1r tmp"
  setlocal bin
  if exists(":lockmarks")
    execute "silent lockmarks " . l . "r " . tmp
  else
    execute "silent " . l . "r " . tmp
  endif

  " if buffer became empty, delete trailing blank line
  if empty
    silent $delete _
    1
  endif
  " delete the temp file and the used buffers
  call delete(tmp)
  call delete(tmpe)
  silent! exe "bwipe " . tmp
  silent! exe "bwipe " . tmpe
  let &pm = pm_save
  let &cpo = cpo_save
  let &l:ma = ma_save
  " When converted the whole buffer, do autocommands
  if empty
    if &verbose >= 8
      execute "doau BufReadPost " . expand("%:r")
    else
      execute "silent! doau BufReadPost " . expand("%:r")
    endif
  endif
endfun

" After writing binary file: Convert written file with "cmd"
fun s:write(cmd)
  " don't do anything if the cmd is not supported or the old format is unknown
  if s:check(a:cmd) && exists("b:plist_format")
    let nm = expand("<afile>")
    let tmp = tempname()
    let cmdout = system(a:cmd . " -convert " . b:plist_format . " -o \"" . tmp . "\" \"" . nm . "\" 2>&1")
    if cmdout !~? "error:"
      call rename(tmp, nm)
      execute "silent edit"
    else
      echo "An error occured while trying to convert the plist using plutil."
    endif
    " refresh buffer from the disk; this prevents the user from
    " receiving errant "file has changed on disk" messages; plus, it does
    " update the buffer to reflect changes made by plutil at save-time
    call s:read("plutil")
    " I don't know why this is sometimes necessary
    if &ft == "xml"
      let &syn = &ft
    endif
  endif
endfun

" vim: set sw=2 :
