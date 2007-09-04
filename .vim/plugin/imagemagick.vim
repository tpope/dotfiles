" imagemagick.vim - binary formatted file conversions
" Author: Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" Inspired by gzip.vim.
" Licensed under the same terms as Vim itself.

" Builtins:
"
" PNGs and GIFs are converted to/from XPM with ImageMagick.
"
" PDFs are uncompressed/recompressed with pdftk.
"
" Word documents are decoded (one way) with antiword.
"
" OS X plists are converted to from XML with plutil.
"
" Customization:
"
" The easiest way to provide custom handlers is to learn from the examples in
" the autocmd section below.  Briefly:
"
" The SmartReadPost function should be called from a BufReadPost,FileReadPost
" autocmd, with the argument being a string containing the command to run.
" The source and destination files should each be replaced by %s and must
" appear in that order.  If this function returns true, that means that an
" entire file was successfully converted, and that it is appropriate to issue
" commands like "set readonly" or "setf myfiletype".
"
" The SmartWriteCmd function should be called from a BufWriteCmd,FileWriteCmd
" autocmd.  The argument is a command in the same format SmartReadPost
" requires.
"
" Don't forget to setlocal binary in a BufReadPre,FileReadPre autocmd if the
" file is in fact binary.
"
" The customization interface is experimental and subject to change.  If you
" have a customization you think others could use, feel free to submit it to
" the author of this plugin.

" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
if exists("loaded_imagemagick") || &cp
  finish
endif
let loaded_imagemagick = 1

augroup imagemagick
  au!

  if !exists("#BufWriteCmd#*.png")
    autocmd BufReadPre,FileReadPre    *.png,*.gif  setlocal bin
    autocmd BufReadPost,FileReadPost  *.png,*.gif  if SmartReadPost("convert %s xpm:%s")|setf xpm|endif|setlocal nobin
    autocmd BufWriteCmd,FileWriteCmd  *.png call SmartWriteCmd("convert %s png:%s")
    autocmd BufWriteCmd,FileWriteCmd  *.gif call SmartWriteCmd("convert %s gif:%s")
  endif

  if !exists("#BufWriteCmd#*.pdf")
    autocmd BufReadPre,FileReadPre    *.pdf setlocal bin
    autocmd BufReadPost,FileReadPost  *.pdf call SmartReadPost("pdftk %s output %s uncompress")
    autocmd BufWriteCmd,FileWriteCmd  *.pdf call SmartWriteCmd("pdftk %s output %s compress")
  endif

  if !exists("#BufReadPre#*.doc")
    autocmd BufReadPre,FileReadPre    *.doc setlocal bin
    autocmd BufReadPost,FileReadPost  *.doc if SmartReadPost("antiword %s > %s") | setlocal readonly | endif
  endif

  if !exists("#BufWriteCmd#*.plist")
    autocmd BufReadPre,FileReadPre    *.plist   setlocal bin ts=2 sw=2
    autocmd BufReadPost,FileReadPost  *.plist   call s:readplist()
    autocmd BufWriteCmd,FileWriteCmd  *.plist   call s:writeplist()
  endif

augroup END

" Helper functions {{{1

function! s:esc(arg)
  if exists("*shellescape")
    return (shellescape(a:arg))
  else
    return '"'.a:arg.'"'
  endif
endfunction

" Function to check that executing "cmd" works.
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

" }}}1

function! SmartReadPost(cmd) " {{{1
  " SmartReadPost() returns true if the process was successful *and* if it was
  " an entire file that was converted.  This is a good condition on which to
  " do things like setting the filetype.
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
  let tmp1 = tempname()
  let tmp2 = tempname()
  " write the just read lines to a temp file
  execute "silent '[,']w " . tmp1
  " convert the temp file, modified for imagemagick
  call system(printf(a:cmd,s:esc(tmp1),s:esc(tmp2)))
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
    execute "silent lockmarks " . l . "r " . tmp2
  else
    execute "silent " . l . "r " . tmp2
  endif

  " if buffer became empty, delete trailing blank line
  if empty
    silent $delete _
    1
  endif
  " delete the temp file and the used buffers
  call delete(tmp2)
  call delete(tmp1)
  silent! exe "bwipe " . tmp2
  silent! exe "bwipe " . tmp1
  let &pm = pm_save
  let &cpo = cpo_save
  let &l:ma = ma_save

  return empty
endfunction " }}}1

function! SmartWriteCmd(cmd) " {{{1
  " don't do anything if the cmd is not supported
  if s:check(a:cmd)
    let nm = expand("<afile>")
    let tmp1 = tempname()
    let tmp2 = tempname()
    exe "noautocmd w ".tmp1
    call system(printf(a:cmd,s:esc(tmp1),s:esc(tmp2)))
    if !v:shell_error
      call rename(tmp2, nm)
      setlocal nomodified
    else
      echohl ErrorMsg
      echo "An error occured while trying to convert the file."
      echohl NONE
    endif
    call delete(tmp1)
  else
    noautocmd w
  endif
endfunction " }}}1

" plist helpers {{{1

function! s:readplist()
  if getline(1) =~ '<?xml\>'
    " If already XML, make a note and exit
    let b:plist_format = "xml1"
    setlocal nobin
    return
  endif
  let b:plist_format = "binary1"
  if SmartReadPost("plutil -convert xml1 %s -o %s")
    setf xml
    return 1
  else
    return 0
  endif

  " When converted the whole buffer, do autocommands
  "if &verbose >= 8
    "execute         "doau BufReadPost " . expand("%:r") . ".xml"
  "else
    "execute "silent! doau BufReadPost " . expand("%:r") . ".xml"
  "endif
endfunction

function! s:writeplist()
  if exists("b:plist_format")
    call SmartWriteCmd("plutil -convert ".b:plist_format." %s -o %s")
    " I don't know why this is sometimes necessary
    "if &ft == "xml"
      "let &syn = &ft
    "endif
  endif
endfunction

" }}}1

" vim: set sw=2:
