version 5.4
" $Id$
" vim:tw=70 sw=2 sts=2 et

augroup ZTemplate

fun! MakeNum(number)
  return 0+substitute(a:number, "^0*", "", "")
endfun

fun! GetMonth(month)
  if a:month ==  1 | return "Jan." | endif
  if a:month ==  2 | return "Feb." | endif
  if a:month ==  3 | return "Mar." | endif
  if a:month ==  4 | return "Apr." | endif
  if a:month ==  5 | return "May"  | endif
  if a:month ==  6 | return "June" | endif
  if a:month ==  7 | return "July" | endif
  if a:month ==  8 | return "Aug." | endif
  if a:month ==  9 | return "Sept."| endif
  if a:month == 10 | return "Oct." | endif
  if a:month == 11 | return "Nov." | endif
  if a:month == 12 | return "Dec." | endif
endfun

fun! FTSubstituteClassData()
  let s:raw = substitute(expand("<afile>:p"),".*/\\([A-Za-z]\\{4\\}\\)\\([0-9]\\{4\\}\\)/.*", "\\1\\2", "")
  let s:class = substitute(expand("<afile>:p"),".*/\\([A-Za-z]\\{4\\}\\)\\([0-9]\\{4\\}\\)/.*", "\\U\\1-\\2", "")
  if s:class == ""
      return
  endif
  if     filereadable(expand("~/schedule.csv"))
    let  s:filename = expand("~/schedule.csv")
  elseif filereadable(expand("~/.schedule.csv"))
    let  s:filename = expand("~/.schedule.csv")
  elseif filereadable(expand("~/text/schedule.csv"))
    let  s:filename = expand("~/text/schedule.csv")
  elseif filereadable(expand("~/public_html/schedule.csv"))
    let  s:filename = expand("~/public_html/schedule.csv")
  else
    return
  endif
    let s:content = substitute(system("grep ^" . s:class . " " . s:filename), "\\n$", "", "")
    let s:course = substitute(s:content, ",.*", "", "")
    let s:instructor = substitute(s:content, "[^,]*,[^,]*, *\\(\"\\=\\)\\([^\",]*\\)\\1,.*", "\\2", "")
    let s:date = substitute(s:content, ".*,", "", "")
    let s:date = substitute(s:date, "^\\([0-9][0-9][0-9][0-9]\\)-*\\([0-9][0-9]\\)-*\\([0-9][0-9]\\)$", "\\=MakeNum(submatch(3)) . ' ' . GetMonth(MakeNum(submatch(2))) . ' ' . submatch(1)", "")
    silent! execute "%s/@COURSE@/" .  s:course . "/g"
    silent! execute "%s/@INSTRUCTOR@/" .  s:instructor . "/g"
    silent! execute "%s/@DATE@/" .  s:date . "/g"
  if expand("<afile>:e") == "tex"
    silent! execute "%s/\\\\today/" .  s:date . "/g"
    silent! %s/\\\(instructor\|date\|course\){\([^}.]*\)\. \([^}]*\)}/\\\1{\2.\\ \3}/eg
    silent! %s/^%\\\(instructor\|date\|course\)/\\\1/e
    silent! %s/^\\documentclass{tim}/\\documentclass[mla]{tim}/e
    if filereadable(expand("%:p:h") . "/" . s:raw . ".sty")
      silent! %s/^\\documentclass\[mla\]{tim}/\="\\\\documentclass[mla]{tim}\\\\usepackage{" . s:raw . "}"/e
    else
      let foo=expand("%:p:h") . "/." . s:raw . ".vim"
    endif
    /^\\title/
    norm f{l
  endif
  if filereadable(expand("%:p:h") . "/." . expand("%:e") . ".vim")
    exe "source ".expand("%:p:h") . "/." . expand("%:e") . ".vim"
  endif
  silent! /NONEXISTENT\nPATTERN/
endfun

autocmd BufNewFile */[a-z][a-z][a-z][a-z][0-9][0-9][0-9][0-9]/* call FTSubstituteClassData()

augroup END
