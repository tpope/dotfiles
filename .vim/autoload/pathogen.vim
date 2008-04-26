" pathogen.vim - path option manipulation
" Maintainer:   Tim Pope
" Last Change:  Apr 26, 2008

" Install in ~/.vim/autoload (or ~\vimfiles\autoload).
"
" API is documented below.

if exists("g:loaded_pathogen") || &cp
  finish
endif
let g:loaded_pathogen = 1

" Split a path into a list.
function! pathogen#split(path) abort " {{{1
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" Convert a list to a path.
function! pathogen#join(...) abort " {{{1
  let i = 0
  let path = ""
  while i < a:0
    if type(a:000[i]) == type([])
      let list = a:000[i]
      let j = 0
      while j < len(list)
        if type(list[j]) == type([])
          "let path .= "," . pathogen#join(list[j])
        else
          let path .= "," . substitute(list[j],'[\\,]','\\&','g')
        endif
        let j += 1
      endwhile
    else
      let path .= "," . a:000[i]
    endif
    let i += 1
  endwhile
  return substitute(path,'^,','','')
endfunction " }}}1

" Convenience wrapper around glob() which returns a list
function! pathogen#glob(pattern) abort " {{{1
  return split(glob(a:pattern),"\n")
endfunction "}}}1

" Prepend all subdirectories of path to the rtp, and append all after
" directories in those subdirectories.
function! pathogen#runtime_prepend(path) " {{{1
  let before = pathogen#glob(a:path."/*[^~]")
  let after  = pathogen#glob(a:path."/*[^~]/after")
  let rtp = pathogen#split(&rtp)
  let path = expand(a:path)
  call filter(rtp,'v:val[0:strlen(path)-1] !=# path')
  let &rtp = pathogen#join(before + rtp + after)
  return &rtp
endfunction " }}}1

" For each directory in rtp, check for a subdirectory named dir.  If it
" exists, add all subdirectories of that subdirectory to the rtp, immediately
" after the original directory.  If no argument is given, 'bundle' is used.
" Repeated calls with the same arguments are ignored.
function! pathogen#runtime_append_all_bundles(...) " {{{1
  let name = a:0 ? a:1 : 'bundle'
  if "\n".s:done_bundles =~# "\\M\n".name."\n"
    return ""
  endif
  let s:done_bundles .= name . "\n"
  let list = []
  for dir in pathogen#split(&rtp)
    if dir =~# '\<after$'
      let list +=  pathogen#glob(substitute(dir,'after$',name.'/*[^~]/after','')) + [dir]
    else
      let list +=  [dir] + pathogen#glob(dir.'/'.name.'/*[^~]')
    endif
  endfor
  let &rtp = pathogen#join(list)
  return 1
endfunction

let s:done_bundles = ''
" }}}1

" vim:set ft=vim ts=8 sw=2 sts=2:
