" ~/.vimrc
" vim:set ft=vim et tw=78 sw=2:

" Section: Options {{{1
" ---------------------
if has("win32")
  let &runtimepath = substitute(&runtimepath,'\(\~\|tpope\)/vimfiles\>','\1/.vim','g')
endif
silent! call pathogen#runtime_append_all_bundles()
silent! call pathogen#runtime_prepend_subdirectories("~/src/vim/bundle")

set nocompatible
set autoindent
set autowrite       " Automatically save before commands like :next and :make
set backspace=2
set backup          " Do keep a backup file
set backupskip+=*.tmp,crontab.*
if has("balloon_eval") && has("unix")
  set ballooneval
endif
if exists("&breakindent")
  set breakindent showbreak=+++
elseif has("gui_running")
  set showbreak=\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ +++
endif
set cmdheight=2
set complete-=i     " Searching includes can be slow
set dictionary+=/usr/share/dict/words
set display=lastline
if has("eval")
  let &fileencodings = substitute(&fileencodings,"latin1","cp1252","")
endif
set grepprg=grep\ -nH\ --exclude='.*.swp'\ --exclude='*~'\ --exclude='*.svn-base'\ --exclude='*.tmp'\ --exclude=tags\ $*
if has("eval")
  let &highlight = substitute(&highlight,'NonText','SpecialKey','g')
endif
set incsearch       " Incremental search
set joinspaces
set laststatus=2    " Always show status line
if has("mac")
  silent! set nomacatsui
else
  set lazyredraw
endif
"let &listchars="tab:\<M-;>\<M-7>,trail:\<M-7>"
set listchars=tab:>\ ,trail:-
set listchars+=extends:>,precedes:<
if version >= 700
  set listchars+=nbsp:+
endif
set modelines=5     " Debian likes to disable this
set mousemodel=popup
set pastetoggle=<F2>
set scrolloff=1
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
set smartcase       " Case insensitive searches become sensitive with capitals
set smarttab        " sw at the start of the line, sts everywhere else
if exists("+spelllang")
  set spelllang=en_us
endif
set splitbelow      " Split windows at bottom
set statusline=%5*[%n]%*\ %1*%<%.99f%*\ %2*%h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%*%=%-16(\ %3*%l,%c-%v%*\ %)%4*%P%*
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%=%-16(\ %l,%c-%v\ %)%P
set suffixes+=.dvi  " Lower priority in wildcards
set tags+=../tags,../../tags,../../../tags,../../../../tags
set timeoutlen=1200 " A little bit more time for macros
set ttimeoutlen=50  " Make Esc work faster
if v:version >= 700
  set viminfo=!,'20,<50,s10,h
endif
set visualbell
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set wildignore+=*~
set winaltkeys=no

if v:version >= 600
  set autoread
  set foldmethod=marker
  set printoptions=paper:letter
  set sidescrolloff=5
  set mouse=nvi
endif

if v:version < 602 || $DISPLAY =~ '^localhost:' || $DISPLAY == ''
  set clipboard-=exclude:cons\\\|linux
  set clipboard+=exclude:cons\\\|linux\\\|screen.*
  if $TERM =~ '^screen'
    set mouse=
  endif
endif

if !has("gui_running") && $DISPLAY == '' || !has("gui")
  set mouse=
endif

if $TERM =~ '^screen'
  if exists("+ttymouse") && &ttymouse == ''
    set ttymouse=xterm
  endif
  if $TERM != 'screen.linux' && &t_Co == 8
    set t_Co=16
  endif
endif

if $TERM == 'xterm-color' && &t_Co == 8
  set t_Co=16
endif

if has("dos16") || has("dos32") || has("win32") || has("win64")
  if $PATH =~? 'cygwin' && ! exists("g:no_cygwin_shell")
    set shell=bash
    set shellpipe=2>&1\|tee
    set shellslash
  endif
elseif has("mac")
  set backupskip+=/private/tmp/*
endif

" Plugin Settings {{{2

if has("eval")
let g:is_bash = 1
let g:lisp_rainbow = 1
" let g:rubyindent_match_parentheses = 0
let g:ruby_minlines = 500
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 1
let g:spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'

let g:allml_global_maps = 1
let g:EnhCommentifyUseAltKeys = 'Yes'
let g:EnhCommentifyBindInInsert = 'No'
let g:EnhCommentifyRespectIndent = 'Yes'
let g:miniBufExplForceSyntaxEnable = 1
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDShutUp = 1
let g:VCSCommandDisableMappings = 1
let g:Tex_CompileRule_dvi = 'latex -interaction=nonstopmode -src-specials $*'
let g:Tex_SmartKeyQuote = 0
if !has("gui_running")
  let g:showmarks_enable = 0
endif
let g:surround_45 = "<% \r %>"
let g:surround_61 = "<%= \r %>"
let g:surround_{char2nr('8')} = "/* \r */"
let g:surround_{char2nr('s')} = " \r"
let g:surround_indent = 1
let g:dbext_default_history_file = "/tmp/dbext_sql_history.txt"
endif

" }}}2
" Section: Commands {{{1
" -----------------------

if has("ruby")
  silent! ruby require 'tpope'; require 'vim'
endif

if has("eval")
command! -bar -nargs=1 E       :exe "edit ".substitute(<q-args>,'\(.*\):\(\d\+\):\=$','+\2 \1','')
command! -bar -nargs=0 SudoW   :silent exe "write !sudo tee % >/dev/null"|silent edit!
command! -bar -nargs=* -bang W :write<bang> <args>
command! -bar -nargs=0 -bang Scratch :silent edit<bang> \[Scratch]|set buftype=nofile bufhidden=hide noswapfile buflisted
command! -bar -count=0 RFC     :e http://www.ietf.org/rfc/rfc<count>.txt|setl ro noma
command! -bar -nargs=* -bang -complete=file Rename :
      \ let v:errmsg = ""|
      \ saveas<bang> <args>|
      \ if v:errmsg == ""|
      \   call delete(expand("#"))|
      \ endif

function! Synname()
  if exists("*synstack")
    return map(synstack(line('.'),col('.')),'synIDattr(v:val,"name")')
  else
    return synIDattr(synID(line('.'),col('.'),1),'name')
  endif
endfunction

command! -bar Invert :let &background = (&background=="light"?"dark":"light")

function! Fancy()
  if &number
    if has("gui_running")
      let &columns=&columns-12
    endif
    windo set nonumber foldcolumn=0
    if exists("+cursorcolumn")
      set nocursorcolumn nocursorline
    endif
  else
    if has("gui_running")
      let &columns=&columns+12
    endif
    windo set number foldcolumn=4
    if exists("+cursorcolumn")
      set cursorline
    endif
  endif
endfunction
command! -bar Fancy :call Fancy()

function! OpenURL(url)
  if has("win32")
    exe "!start cmd /cstart /b ".a:url.""
  elseif $DISPLAY !~ '^\w'
    exe "silent !sensible-browser \"".a:url."\""
  else
    exe "silent !sensible-browser -T \"".a:url."\""
  endif
  redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)
" open URL under cursor in browser
nnoremap gb :OpenURL <cfile><CR>
nnoremap gA :OpenURL http://www.answers.com/<cword><CR>
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
nnoremap gW :OpenURL http://en.wikipedia.org/wiki/Special:Search?search=<cword><CR>

function! Run()
  let old_makeprg = &makeprg
  let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
  if exists("b:run_command")
    exe b:run_command
  elseif cmd != '' && executable(cmd)
    wa
    let &makeprg = matchstr(getline(1),'^#!\zs.*').' %'
    make
  elseif &ft == "mail" || &ft == "text" || &ft == "help" || &ft == "gitcommit"
    setlocal spell!
  elseif exists("b:rails_root") && exists(":Rake")
    wa
    Rake
  elseif &ft == "ruby"
    wa
    if executable(expand("%:p")) || getline(1) =~ '^#!'
      compiler ruby
      let &makeprg = "ruby"
      make %
    elseif expand("%:t") =~ '_test\.rb$'
      compiler rubyunit
      let &makeprg = "ruby"
      make %
    elseif expand("%:t") =~ '_spec\.rb$'
      compiler ruby
      let &makeprg = "spec"
      make %
    else
      !irb -r"%:p"
    endif
  elseif &ft == "html" || &ft == "xhtml" || &ft == "php" || &ft == "aspvbs" || &ft == "aspperl"
    wa
    if !exists("b:url")
      call OpenURL(expand("%:p"))
    else
      call OpenURL(b:url)
    endif
  elseif &ft == "vim"
    wa
    unlet! g:loaded_{expand("%:t:r")}
    return 'source %'
  elseif &ft == "sql"
    1,$DBExecRangeSQL
  elseif expand("%:e") == "tex"
    wa
    exe "normal :!rubber -f %:r && xdvi %:r >/dev/null 2>/dev/null &\<CR>"
  else
    wa
    if &makeprg =~ "%"
      make
    else
      make %
    endif
  endif
  let &makeprg = old_makeprg
  return ""
endfunction
command! -bar Run :execute Run()

  runtime! plugin/matchit.vim
  runtime! macros/matchit.vim
  runtime! plugin/abolish.vim
endif

" Section: Mappings {{{1
" ----------------------

map Y       y$
" Don't use Ex mode; use Q for formatting
map Q       gqj
if exists(":nohls")
  nnoremap <silent> <C-L> :nohls<CR><C-L>
endif
inoremap <C-C> <Esc>`^
nnoremap zS  r<CR>ddkP=j

nnoremap =p m`=ap``
nnoremap == ==
vnoremap     <M-<> <gv
vnoremap     <M->> >gv
vnoremap     <Space> I<Space><Esc>gv

inoremap <C-X>^ <C-R>=substitute(&commentstring,' \=%s\>'," -*- ".&ft." -*- vim:set ft=".&ft." ".(&et?"et":"noet")." sw=".&sw." sts=".&sts.':','')<CR>

cnoremap <C-O>      <Up>
inoremap <M-o>      <C-O>o
inoremap <M-O>      <C-O>O
inoremap <M-i>      <Left>
inoremap <M-I>      <C-O>^
inoremap <M-A>      <C-O>$
noremap! <C-J>      <Down>
noremap! <C-K><C-K> <Up>
inoremap <CR>       <C-G>u<CR>
if has("eval")
  command! -buffer -bar -range -nargs=? Slide :exe 'norm m`'|exe '<line1>,<line2>move'.((<q-args> < 0 ? <line1>-1 : <line2>)+(<q-args>=='' ? 1 : <q-args>))|exe 'norm ``'
endif

inoremap     <C-X><C-@> <C-A>
" Emacs style mappings
inoremap          <C-A> <C-O>^
cnoremap          <C-A> <Home>
" If at end of a line of spaces, delete back to the previous line.
" Otherwise, <Left>
inoremap <silent> <C-B> <C-R>=getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"<CR>
cnoremap          <C-B> <Left>
" If at end of line, decrease indent, else <Del>
inoremap <silent> <C-D> <C-R>=col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"<CR>
cnoremap          <C-D> <Del>
" If at end of line, fix indent, else <Right>
inoremap <silent> <C-F> <C-R>=col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"<CR>
inoremap          <C-E> <End>
cnoremap          <C-F> <Right>
noremap!          <M-a> <C-O>(
map!              <M-b> <S-Left>
noremap!          <M-d> <C-O>dw
noremap!          <M-e> <C-O>)
map!              <M-f> <S-Right>
noremap!          <M-h> <C-W>
noremap           <M-l> guiww
noremap           <M-u> gUiww
noremap!          <M-l> <Esc>guiw`]a
noremap!          <M-u> <Esc>gUiw`]a
noremap!          <M-{> <C-O>{
noremap!          <M-}> <C-O>}
if !has("gui_running")
  silent! exe "set <S-Left>=\<Esc>b"
  silent! exe "set <S-Right>=\<Esc>f"
  silent! exe "set <F31>=\<Esc>d"
  map! <F31> <M-d>
endif

if has("gui_mac")
  noremap <C-6> <C-^>
endif

map  <F1>   <Esc>
map! <F1>   <Esc>
if has("gui_running")
  map <F2>  :Fancy<CR>
endif
map <F3>    :cnext<CR>
map <F4>    :cc<CR>
map <F5>    :cprev<CR>
map <F8>    :wa<Bar>make<CR>
map <F9>    :Run<CR>
map <silent> <F10>   :let tagsfile = tempname()\|silent exe "!ctags -f ".tagsfile." \"%\""\|let &l:tags .= "," . tagsfile\|unlet tagsfile<CR>
map <silent> <F11> :if exists(":BufExplorer")<Bar>exe "BufExplorer"<Bar>else<Bar>buffers<Bar>endif<CR>
map <C-F4>  :bdelete<CR>

noremap  <S-Insert> <MiddleMouse>
noremap! <S-Insert> <MiddleMouse>

map \\              <Plug>NERDCommenterInvert
map <Leader>l       <Plug>CapsLockToggle
imap <C-L>          <Plug>CapsLockToggle
imap <C-G>c         <Plug>CapsLockToggle
nmap du             <Plug>SpeedDatingNowUTC
nmap dx             <Plug>SpeedDatingNowLocal
" Merge consecutive empty lines and clean up trailing whitespace
map <Leader>fm :g/^\s*$/,/\S/-j<Bar>%s/\s\+$//<CR>
map <Leader>v  :so ~/.vimrc<CR>

inoremap <silent> <C-G><C-T> <C-R>=repeat(complete(col('.'),map(["%Y-%m-%d %H:%M:%S","%a, %d %b %Y %H:%M:%S %z","%Y %b %d","%d-%b-%y","%a %b %d %T %Z %Y"],'strftime(v:val)')+[localtime()]),0)<CR>

" Section: Autocommands {{{1
" --------------------------

if has("autocmd")
  if $HOME !~# '^/Users/'
    filetype off " Debian preloads this before the runtimepath is set
  endif
  if version>600
    filetype plugin indent on
  else
    filetype on
  endif
  augroup FTMisc " {{{2
    autocmd!

    if v:version >= 700 && isdirectory(expand("~/.trash"))
      autocmd BufWritePre,BufWritePost * if exists("s:backupdir") | set backupext=~ | let &backupdir = s:backupdir | unlet s:backupdir | endif
      autocmd BufWritePre ~/*
            \ let s:path = expand("~/.trash").strpart(expand("<afile>:p:~:h"),1) |
            \ if !isdirectory(s:path) | call mkdir(s:path,"p") | endif |
            \ let s:backupdir = &backupdir |
            \ let &backupdir = escape(s:path,'\,').','.&backupdir |
            \ let &backupext = strftime(".%Y%m%d%H%M%S~",getftime(expand("<afile>:p")))
    endif

    autocmd User Rails setlocal ts=2

    autocmd BufNewFile */init.d/*
          \ if filereadable("/etc/init.d/skeleton") |
          \   0r /etc/init.d/skeleton |
          \   $delete |
          \   silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/eg" |
          \ endif |
          \ set ft=sh | 1

    autocmd BufNewFile */.netrc,*/.fetchmailrc,*/.my.cnf let b:chmod_new="go-rwx"
    autocmd BufNewFile  * let b:chmod_exe=1
    autocmd BufWritePre * if exists("b:chmod_exe") |
          \ unlet b:chmod_exe |
          \ if getline(1) =~ '^#!' | let b:chmod_new="+x" | endif |
          \ endif
    autocmd BufWritePost,FileWritePost * if exists("b:chmod_new")|
          \ silent! execute "!chmod ".b:chmod_new." <afile>"|
          \ unlet b:chmod_new|
          \ endif

    autocmd BufWritePost,FileWritePost ~/.Xdefaults,~/.Xresources silent! !xrdb -load % >/dev/null 2>&1
    autocmd BufWritePre,FileWritePre /etc/* if &ft == "dns" |
          \ exe "normal msHmt" |
          \ exe "gl/^\\s*\\d\\+\\s*;\\s*Serial$/normal ^\<C-A>" |
          \ exe "normal g`tztg`s" |
          \ endif
    autocmd BufReadPre *.pdf setlocal binary
    autocmd BufReadCmd *.jar call zip#Browse(expand("<amatch>"))
    autocmd FileReadCmd *.doc execute "read! antiword \"<afile>\""
    autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
      \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif
  augroup END " }}}2
  augroup FTCheck " {{{2
    autocmd!
    autocmd BufNewFile,BufRead */apache2/[ms]*-*/* set ft=apache
    autocmd BufNewFile,BufRead       *named.conf* set ft=named
    autocmd BufNewFile,BufRead *Fvwm*             set ft=fvwm
    autocmd BufNewFile,BufRead *.cl[so],*.bbl     set ft=tex
    autocmd BufNewFile,BufRead /var/www/*.module  set ft=php
    autocmd BufNewFile,BufRead *.bst              set ft=bst
    autocmd BufNewFile,BufRead *.vb               set ft=vbnet
    autocmd BufNewFile,BufRead *.tt,*.tt2         set ft=tt2html
    autocmd BufNewFile,BufRead *.pdf              set ft=pdf
    autocmd BufNewFile,BufRead *.CBL,*.COB,*.LIB  set ft=cobol
    autocmd BufNewFile,BufRead /var/www/*
          \ let b:url=expand("<afile>:s?^/var/www/?http://localhost/?")
    autocmd BufNewFile,BufRead /etc/udev/*.rules set ft=udev
    autocmd BufNewFile,BufRead *[0-9BM][FG][0-9][0-9]*  set ft=simpsons
    autocmd BufNewFile,BufRead,StdinReadPost *
          \ if !did_filetype() && (getline(1) =~ '^!!\@!'
          \   || getline(2) =~ '^!!\@!' || getline(3) =~ '^!'
          \   || getline(4) =~ '^!' || getline(5) =~ '^!') |
          \   setf router |
          \ endif
    autocmd BufRead * if ! did_filetype() && getline(1)." ".getline(2).
          \ " ".getline(3) =~? '<\%(!DOCTYPE \)\=html\>' | setf html | endif
    autocmd BufRead,StdinReadPost * if ! did_filetype() && getline(1) =~ '^%PDF-' | setf pdf | endif
    autocmd BufNewFile,BufRead *.txt,README,INSTALL,NEWS,TODO if &ft == ""|set ft=text|endif
    autocmd BufNewFile,BufRead *.erb set ft=eruby
    autocmd BufNewFile,BufRead *.pl.erb let b:eruby_subtype = 'perl'|set ft=eruby
  augroup END " }}}2
  augroup FTOptions " {{{2
    autocmd!
    autocmd BufNewFile,BufRead *.kml        setlocal ts=2 noet
    autocmd FileType c,cpp,cs,java          setlocal ai et sta sw=4 sts=4 cin
    autocmd FileType sh,csh,tcsh,zsh        setlocal ai et sta sw=4 sts=4
    autocmd FileType tcl,perl,python        setlocal ai et sta sw=4 sts=4
    autocmd FileType javascript             setlocal ai et sta sw=4 sts=4 cin isk+=$
    autocmd FileType php,aspperl,aspvbs,vb  setlocal ai et sta sw=4 sts=4
    autocmd FileType apache,sql,vbnet       setlocal ai et sta sw=4 sts=4
    autocmd FileType tex,css                setlocal ai et sta sw=2 sts=2
    autocmd FileType html,xhtml,wml,cf      setlocal ai et sta sw=2 sts=2
    autocmd FileType xml,xsd,xslt           setlocal ai et sta sw=2 sts=2
    autocmd FileType eruby,yaml,ruby        setlocal ai et sta sw=2 sts=2
    autocmd FileType tt2html,htmltt,mason   setlocal ai et sta sw=2 sts=2
    autocmd FileType text,txt,mail          setlocal ai com=fb:*,fb:-,n:>
    autocmd FileType cs,vbnet               setlocal foldmethod=syntax fdl=2
    autocmd FileType sh,zsh,csh,tcsh        inoremap <silent> <buffer> <C-X>! #!/bin/<C-R>=&ft<CR>
    autocmd FileType perl,python,ruby       inoremap <silent> <buffer> <C-X>! #!/usr/bin/<C-R>=&ft<CR>
    autocmd FileType sh,zsh,csh,tcsh,perl,python,ruby imap <buffer> <C-X>& <C-X>!<Esc>o <C-U># $I<C-V>d$<Esc>o <C-U><C-X>^<Esc>o <C-U><C-G>u
    autocmd FileType c,cpp,cs,java,perl,javscript,php,aspperl,tex,css let b:surround_101 = "\r\n}"
    autocmd User     allml                  inoremap <buffer> <C-J> <Down>
    autocmd FileType tt2html,htmltt if !exists("b:current_syntax") | setlocal syntax=html | endif
    autocmd FileType aspvbs,vbnet setlocal comments=sr:'\ -,mb:'\ \ ,el:'\ \ ,:',b:rem formatoptions=crq
    autocmd FileType asp*         runtime! indent/html.vim
    autocmd FileType bst  setlocal smartindent cinkeys-=0# ai sta sw=2 sts=2 comments=:% commentstring=%%s
    autocmd FileType cobol setlocal ai et sta sw=4 sts=4 tw=72 makeprg=cobc\ -x\ -Wall\ %
    autocmd FileType cs   silent! compiler cs | setlocal makeprg=gmcs\ %
    autocmd FileType css  silent! setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType gitcommit setlocal spell
    autocmd FileType gitrebase nnoremap <buffer> S :Cycle<CR>
    autocmd FileType haml let b:surround_45 = "- \r"|let b:surround_61 = "= \r"
    autocmd FileType help setlocal ai fo+=2n | silent! setlocal nospell
    autocmd FileType help nnoremap <silent><buffer> q :q<CR>
    autocmd FileType html setlocal iskeyword+=~
    autocmd FileType java silent! compiler javac | setlocal makeprg=javac\ %
    autocmd FileType mail setlocal tw=70|if getline(1) =~ '^[A-Za-z-]*:\|^From ' | exe 'norm 1G}' |endif|silent! setlocal spell
    autocmd FileType perl silent! compiler perl | setlocal iskeyword+=: keywordprg=perl\ -e'$c=shift;exec\ q{perldoc\ }.($c=~/^[A-Z]\|::/?q{}:q{-f}).qq{\ $c}'
    autocmd FileType pdf  setlocal foldmethod=syntax foldlevel=1 | if !exists("b:current_syntax") | setlocal syntax=postscr | endif
    autocmd FileType python setlocal keywordprg=pydoc
    autocmd FileType ruby silent! compiler ruby | setlocal tw=79 isfname+=: makeprg=rake keywordprg=ri comments=:#\  | let &includeexpr = 'tolower(substitute(substitute('.&includeexpr.',"\\(\\u\\+\\)\\(\\u\\l\\)","\\1_\\2","g"),"\\(\\l\\|\\d\\)\\(\\u\\)","\\1_\\2","g"))' | imap <buffer> <C-Z> <CR>end<C-O>O
    autocmd FileType sql map! <buffer> <C-Z> <Esc>`^gUaw`]a
    autocmd FileType text,txt setlocal tw=78 linebreak nolist
    autocmd FileType tex  silent! compiler tex | setlocal makeprg=latex\ -interaction=nonstopmode\ % wildignore+=*.dvi formatoptions+=l
    autocmd FileType tex if exists("*IMAP")|
          \ call IMAP('{}','{}',"tex")|
          \ call IMAP('[]','[]',"tex")|
          \ call IMAP('{{','{{',"tex")|
          \ call IMAP('$$','$$',"tex")|
          \ call IMAP('^^','^^',"tex")|
          \ call IMAP('::','::',"tex")|
          \ call IMAP('`/','`/',"tex")|
          \ call IMAP('`"\','`"\',"tex")|
          \ endif
    autocmd FileType vbnet        runtime! indent/vb.vim
    autocmd FileType vim  setlocal ai et sta sw=4 sts=4 keywordprg=:help | map! <buffer> <C-Z> <C-X><C-V>
    autocmd FileType * if exists("+omnifunc") && &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
    autocmd FileType * if exists("+completefunc") && &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | endif
  augroup END "}}}2
endif " has("autocmd")

" Section: Visual {{{1
" --------------------

" Switch syntax highlighting on, when the terminal has colors
if (&t_Co > 2 || has("gui_running")) && has("syntax")
  function! s:initialize_font()
    if exists("&guifont")
      if has("mac")
        set guifont=Monaco:h12
      elseif has("unix")
        if &guifont == ""
          set guifont=bitstream\ vera\ sans\ mono\ 11
        endif
      elseif has("win32")
        set guifont=Consolas:h11,Courier\ New:h10
      endif
    endif
  endfunction

  command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
  command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
  noremap <M-,>        :Smaller<CR>
  noremap <M-.>        :Bigger<CR>

  if exists("syntax_on") || exists("syntax_manual")
  else
    syntax on
  endif
  set list
  set hlsearch
  if !exists('g:colors_name')
    if filereadable(expand("~/.vim/colors/tim.vim"))
      colorscheme tim
    elseif filereadable(expand("~/.vim/colors/tpope.vim"))
      colorscheme tpope
    endif
  endif

  augroup RCVisual
    autocmd!

    autocmd VimEnter *  set background=dark notitle noicon
    autocmd GUIEnter *  set background=light title icon cmdheight=2 lines=25 columns=80 guioptions-=e
    autocmd GUIEnter *  if has("diff") && &diff | set columns=165 | endif
    autocmd GUIEnter *  colorscheme vividchalk
    autocmd GUIEnter *  call s:initialize_font()
    autocmd Syntax css  syn sync minlines=50
    autocmd Syntax csh  hi link cshBckQuote Special | hi link cshExtVar PreProc | hi link cshSubst PreProc | hi link cshSetVariables Identifier
  augroup END
endif

" }}}1
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
