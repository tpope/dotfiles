" ztemplate.vim - Templates
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" URL:          http://tpope.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/plugin/ztemplate.vim
" $Id$
"
" Loads a template based on filename/filetype.  Loosely inspired by
" templatefile.vim, and aims for backwards compatibility with it in certain
" aspects.

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_ztemplate") && g:loaded_ztemplate) || &cp
  finish
endif
let g:loaded_ztemplate = 1

augroup ZTemplate$$
  autocmd!
  autocmd BufNewFile * call s:LoadFilename(expand("<amatch>"))
  autocmd FileType   * call s:LoadFiletype(expand("<amatch>"),expand("<afile>"))
  autocmd BufNewFile */[a-z][a-z][a-z][a-z][0-9][0-9][0-9][0-9]/* call s:FTSubstituteClassData()
augroup END

" Disable templatefile.vim
let g:load_templates = "no"

function! s:LoadFilename(filename)
  let ext = fnamemodify(a:filename,':e')
  if ext == ''
    let ext = (fnamemodify(a:filename,':t'))
  endif
  if ext =~ '['
    return
  endif
  call s:ReadTemplate(ext,a:filename)
endfunction

function! s:LoadFiletype(type,filename)
  "if a:type == "perl"
    "let ext = "pl"
  if a:type == "python"
    let ext = "py"
  elseif a:type == "ruby"
    let ext = "rb"
  else
    let ext = a:type
  endif
  call s:ReadTemplate(ext,a:filename)
endfunction

function! s:ReadTemplate(type,filename)
  if !(line("$") == 1 && getline("$") == "") || filereadable(a:filename)
    return
  endif
  let template = a:type
  if ! s:TemplateFindRead(substitute(fnamemodify(a:filename,':h:t'),'\W','_','g').".".template)
    if fnamemodify(a:filename,':h:t') != 'sbin' || ! s:TemplateFindRead("bin.".template)
      if ! s:TemplateFindRead("skel.".template)
        if ! s:TemplateFindRead(template)
          return
        endif
      endif
    endif
  endif
  let filename = fnamemodify(a:filename,':t')
  let basename = fnamemodify(a:filename,':t:r')
  let name     = substitute(basename,'\C\(\l\)\(\u\|\d\)','\1_\l\2','g')
  let name     = substitute(name,'_\(.\)',' \u\1','g')
  let name     = substitute(name,'^.','\u&','g')
  silent! execute '%s/\$\(Id\|Rev\|Revision\):[^$]*\$/$\1$/g'
  if exists("g:template_email")
    call s:Replace('@AUTHOR_EMAIL@','@AUTHOR@ <@EMAIL@>')
    call s:Replace('@EMAIL@',g:template_email)
  else
    call s:Replace('@AUTHOR_EMAIL@','@AUTHOR@')
  endif
  if s:author() != ""
    call s:Replace('@AUTHOR@',s:author())
  endif
  call s:Replace('@FILETYPE@',a:type)
  call s:Replace('@INCLUDE_GUARD@\%(_H\>\)\=',toupper(substitute(filename,'\W','_','g')))
  call s:Replace('@\%(NAME\|TITLE\)@',name)
  call s:Replace('@FILENAME@',filename)
  call s:Replace('@\%(FILE\|BASENAME\)@',basename)
  $ delete
  if line('$') > &lines
    1
  endif
  call s:Replace('@CURSOR@','')
  if exists("*TemplateFileFunc_".template)
    call TemplateFileFunc_{template}()
  endif
endfunction

function s:author()
  if exists("g:template_author")
    return g:template_author
  else
    let g:template_author = ""
    if has("unix") && executable("perl")
      silent! let g:template_author = system('perl -e "eval {print [getpwuid($<)]->[6]}"')
      let g:template_author = substitute(g:template_author,',.*','','')
    endif
    if g:template_author == "" && exists("$USER")
      let g:template_author = $USER
    endif
    return g:template_author
  endif
endfunction

function! s:TemplateFind(filename)
  if filereadable(expand("~/.vim/template/".a:filename))
    return "~/.vim/template/".a:filename
  elseif filereadable(expand("~/.vim/templates/".a:filename))
    return "~/.vim/templates/".a:filename
  else
    return ""
  endif
endfunction

function! s:TemplateFindRead(filename)
  if exists("g:template_".substitute(a:filename,'\.','_','g'))
    let keep = @l
    let @l = g:template_{substitute(a:filename,'\.','_','g')}
    silent 0put l
    let @l = keep
  else
    let template = s:TemplateFind(a:filename)
    if template == ""
      return 0
    endif
    let cpopts = &cpoptions
    set cpoptions-=a
    silent exe "0r ".template
    let &cpoptions = cpopts
  endif
  return 1
endfunction

function! s:Replace(pattern,replacement)
  silent! execute '%s/'.a:pattern.'/'.a:replacement.'/g'
endfunction

function! s:MakeNum(number)
  return 0+substitute(a:number, "^0*", "", "")
endfunction

function! s:GetMonth(month)
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
endfunction

function! s:FTSubstituteClassData()
  let raw = substitute(expand("<afile>:p"),".*/\\([A-Za-z]\\{4\\}\\)\\([0-9]\\{4\\}\\)/.*", "\\1\\2", "")
  let class = substitute(expand("<afile>:p"),".*/\\([A-Za-z]\\{4\\}\\)\\([0-9]\\{4\\}\\)/.*", "\\U\\1-\\2", "")
  if class == ""
    return
  endif
  if     filereadable(expand("~/schedule.csv"))
    let  filename = expand("~/schedule.csv")
  elseif filereadable(expand("~/.schedule.csv"))
    let  filename = expand("~/.schedule.csv")
  elseif filereadable(expand("~/Documents/schedule.csv"))
    let  filename = expand("~/Documents/schedule.csv")
  elseif filereadable(expand("~/public_html/schedule.csv"))
    let  filename = expand("~/public_html/schedule.csv")
  else
    return
  endif
  let content = substitute(system("grep ^" . class . " " . filename), "\\n$", "", "")
  let course = substitute(content, ",.*", "", "")
  let instructor = substitute(content, "[^,]*,[^,]*, *\\(\"\\=\\)\\([^\",]*\\)\\1,.*", "\\2", "")
  let date = substitute(content, ".*,", "", "")
  let date = substitute(date, "^\\([0-9][0-9][0-9][0-9]\\)-*\\([0-9][0-9]\\)-*\\([0-9][0-9]\\)$", "\\=s:MakeNum(submatch(3)) . ' ' . s:GetMonth(s:MakeNum(submatch(2))) . ' ' . submatch(1)", "")
  call s:Replace('@COURSE@',course)
  call s:Replace('@INSTRUCTOR@',instructor)
  call s:Replace('@DATE@',date)
  if expand("%:e") == "tex"
    call s:Replace('\\today',date)
    silent! %s/\\\(instructor\|date\|course\){\([^}.]*\)\. \([^}]*\)}/\\\1{\2.\\ \3}/eg
    silent! %s/^%\ze\\\(instructor\|date\|course\)//e
    silent! %s/^\\documentclass{tim}/\\documentclass[mla]{tim}/e
    if filereadable(expand("%:p:h") . "/" . raw . ".sty")
      silent! %s/^\\documentclass\[mla\]{tim}/\="\\\\documentclass[mla]{tim}\\\\usepackage{" . raw . "}"/e
    else
      let foo=expand("%:p:h") . "/." . raw . ".vim"
    endif
    1
    call search('^\\title{.','e')
  endif
  if filereadable(expand("%:p:h") . "/." . expand("%:e") . ".vim")
    exe "source ".expand("%:p:h:~:.") . "/." . expand("%:e") . ".vim"
  endif
endfunction

" vim:set ft=vim sts=2 sw=2:
