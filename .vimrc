" $Id$
" vim:set ft=vim et tw=78 sw=2 sts=2:
version 5.0

" Section: Options {{{1
" ---------------------
set runtimepath^=~/.config/vim,~/.vim.local
set runtimepath+=~/.vim.local/after,~/.config/vim/after

set nocompatible
set autoindent
set autowrite       " Automatically save before commands like :next and :make
set backspace=2
set backup          " Do keep a backup file
set backupskip+=*.tmp,crontab.*
if has("balloon_eval") && has("unix")
  set ballooneval
endif
set cmdheight=2
set copyindent
set dictionary+=/usr/share/dict/words
"set foldlevelstart=1
set grepprg=grep\ -nH\ $*
set incsearch       " Incremental search
set joinspaces
set laststatus=2    " Always show status line
if ! has("mac")
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
"set nohidden       " Disallow hidden buffers
set pastetoggle=<F2>
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
set smartcase       " Case insensitive searches become sensitive with capitals
set smarttab        " sw at the start of the line, sts everywhere else
if exists("+spelllang")
  set spelllang=en_gb
endif
set splitbelow      " Split windows at bottom
set statusline=%5*[%n]%*\ %1*%<%.99f%*\ %2*%h%w%m%r%y%*%=%-16(\ %3*%l,%c-%v%*\ %)%4*%P%*
set suffixes+=.dvi  " Lower priority in wildcards
set timeoutlen=1200 " A little bit more time for macros
set ttimeoutlen=50  " Make Esc work faster
set visualbell
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set wildignore+=*~
set winaltkeys=no

let g:treeExplVertical=1
let g:c_comment_strings=1
let g:EnhCommentifyBindInInsert='No'
let g:EnhCommentifyRespectIndent='Yes'
"let g:Imap_PlaceHolderStart="\xab"
"let g:Imap_PlaceHolderEnd="\xbb"
let g:Tex_CompileRule_dvi='latex -interaction=nonstopmode -src-specials $*'
let g:lisp_rainbow=1
"let g:loaded_parenquote=1
let g:rails_level=9
let g:rails_default_database='sqlite3'
let g:rails_menu=1
let g:rubyindent_match_parentheses=0
let g:ruby_no_identifiers=1
let g:rubycomplete_rails=1
if !has("gui_running")
  let g:showmarks_enable=0
endif

if has("gui_running")
  if has("mac")
    set guifont=Monaco:h12
  elseif has("unix")
    if &guifont == ""
      set guifont=bitstream\ vera\ sans\ mono\ 11 ",fixed,-bitstream-bitstream\ vera\ sans\ mono-medium-r-normal-*-*-110-*-*-m-*-iso8859-1
    endif
    "set guioptions-=T guioptions-=m
    set guioptions-=e
  elseif has("win32")
    set guifont=Courier\ New:h10
  endif
  set background=light
  "set cmdheight=2 lines=25 columns=80
  set title
  if has("diff") && &diff
    set columns=165
  endif
else
  set background=dark
  set notitle noicon
endif

if version>=600
  set autoread
  set foldmethod=marker
  set printoptions=paper:letter ",syntax:n
  set sidescrolloff=5
  set mouse=nvi
endif

if version < 602
  set clipboard+=exclude:screen.*
elseif $TERM =~ '^screen'
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

" Section: Functions {{{1
" -----------------------

command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
command! -bar -nargs=0 SudoW   :silent write !sudo tee % >/dev/null
command! -bar -nargs=* -bang W :write<bang> <args>

function! Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunction

function! Invert()
  if &background=="light"
    set background=dark
  else
    set background=light
  endif
  if filereadable(expand("~/.vim/colors/tim.vim")) && version < 600
    source ~/.vim/colors/tim.vim
  endif
endfunction
command! -bar Invert :call Invert()

function! Fancy()
  if &number
    if has("gui_running")
      let &columns=&columns-12
    endif
    set nonumber foldcolumn=0
    if exists("+cursorcolumn")
      set nocursorcolumn nocursorline
    endif
  else
    if has("gui_running")
      let &columns=&columns+12
    endif
    set number foldcolumn=4
    if exists("+cursorcolumn")
      set cursorcolumn cursorline
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

function! Run()
  let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
  if cmd != '' && executable(cmd)
    w
    exe "!".matchstr(getline(1),'^#!\zs.*').' %'
  elseif &ft == "mail" || &ft == "text" || &ft == "help"
    setlocal spell!
  elseif exists("b:rails_root") && exists(":Rake")
    wa
    Rake
  elseif &ft == "perl"
    wa
    !perl -w %
  elseif &ft == "ruby"
    wa
    !ruby %
  elseif &ft == "python"
    wa
    !python %
  elseif &ft == "sh"
    !sh %
  elseif &ft == "html" || &ft == "xhtml" || &ft == "php" || &ft == "aspvbs" || &ft == "aspperl"
    wa
    if !exists("b:url")
      "let b:url=expand("%:p")
      call OpenURL(expand("%:p"))
    else
      call OpenURL(b:url)
    endif
  elseif &ft == "vim"
    source %
  elseif &ft == "sql"
    1,$DBExecRangeSQL
  elseif expand("%:e") == "tex"
    wa
    exe "normal :!rubber -f %:r && xdvi %:r 2>/dev/null &\<CR>"
  else
    wa
    if &makeprg =~ "%"
      make
    else
      make %
    endif
    "exe "normal :!Eterm -t White -T 'make test' --pause -e make -s test &\<CR>"
  endif
endfunction
command! -bar Run :call Run()

function! SQL()
  edit SQL
  setf sql
  set bt=nofile
endfunction
command! -bar SQL :call SQL()

function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction

function! InsertCtrlLWrapper()
  if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
    return "0\<C-T>\<BS>"
    "return "\<Esc>d^xkJs"
  elseif exists("b:rails_root")
    return "\<C-X>\<C-U>\<C-P>"
  elseif &filetype =~ 'sh$'
    return "\<C-X>\<C-F>\<C-P>"
  else
    return "\<C-X>\<C-L>"
  endif
endfunction

if version >= 600
  "inoremap <silent> <Tab> <C-R>=InsertTabWrapper()<CR>
  inoremap <silent> <C-L> <C-R>=InsertCtrlLWrapper()<CR>
else
  "inoremap <Tab> <C-R>=InsertTabWrapper()<CR>
  inoremap <C-L> <C-R>=InsertCtrlLWrapper()<CR>
endif

function! InsertQuoteWrapper(char)
  if col('.')>strlen(getline('.')) && strlen(substitute(getline('.'),'[^'.a:char.']','','g')) % 2 == 1
    return a:char
    "if synIDattr(synID(line('.'),col('.'),1),'name') =~ 'String'
    "endif
  elseif getline('.')[col('.')-1] == a:char && getline('.')[col('.')-2] != "\\"
    return "\<Right>"
  else
    return a:char.a:char."\<Left>"
  endif
endfunction
if version >= 600
  "inoremap <silent> " <C-R>=InsertQuoteWrapper('"')<CR>
  "inoremap <silent> ' <C-R>=InsertQuoteWrapper("'")<CR>
endif

function! TemplateFileFunc_pm()
  let module = expand("%:p:r")
  let module = substitute(module,'.*\<\(perl\d*\%([\/][0-9.]*\)\=\|lib\|auto\)[\/]','','')
  if module =~ '^/' || module =~ '^[A-Za-z]:'
    let module = fnamemodify(module,':t')
  endif
  let module = substitute(module,'[\/]','::','g')
  silent! exe "%s/@MODULE@/".module."/g"
  norm gg4}
endfunction

if version >= 600
  runtime! macros/matchit.vim
endif

" Section: Mappings {{{1
" ----------------------

map  <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>
" Don't use Ex mode; use Q for formatting
map Q       gqj
" open URL under cursor in browser
map gb      :call OpenURL(expand("<cfile>"))<CR>
"inoremap <C-L> <Esc>d^xkJs
" Run p in Visual mode replace the selected text with the "" register.
"vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
"vnoremap <C-C> "+y
imap <F1>   <C-O><F1>
map <F1>    K<CR>
if has("gui_running")
  map <F2>  :Fancy<CR>
else
  " pastetoggle
endif

map <F3>    :cnext<CR>
map <F4>    :cc<CR>
map <F5>    :cprev<CR>
map <F6>    :bnext<CR>
map <F7>    :bprevious<CR>
map <F8>    :wa<BAR>make<CR>
map <F9>    :Run<CR>
"map <F10>   :wa<BAR>make
map <F12>   :![ -z "$STY" ] \|\| screen<CR><CR>
imap <F12> <C-O><F12>
map <C-F4>  :bdelete<CR>
"map <t_%9>  :hardcopy<CR>         " Print Screen

"map <C-Z> :shell<CR>
" Attribution Fixing
map <Leader>at gg}jWdWWPX
"map <Leader>sa :!aspell -c --dont-backup "%"<CR>:e! "%"<CR><CR>
"map <Leader>si :!ispell "%"<CR>:e! "%"<CR><CR>
"map <Leader>sh :so `sh /usr/share/doc/vim/tools/vimspell.sh %`<CR><CR>
map <Leader>sw :!echo "<cword>"\|aspell -a --<CR>
map <Leader>fj {:.,/^ *$/-2 call Justify('',3,)<CR>
map <Leader>fJ :% call Justify('',3,)<CR>
map <Leader>fp gqap
map <Leader>fd :!webster "<cword>"<CR>
map <Leader>ft :!thesaurus "<cword>"<CR>
" Merge consecutive empty lines
map <Leader>fm :g/^\s*$/,/\S/-j<CR>
map <Leader>v :so ~/.vimrc<CR>
" Wrap visual in parentheses
vmap <Leader>( v`>a)<Esc>`<i(<Esc>
vmap <Leader>{ v`>a}<Esc>`<i{<Esc>
vmap <Leader>[ v`>a]<Esc>`<i[<Esc>
vmap <Leader>< v`>a><Esc>`<i<<Esc>
vmap <Leader>" v`>a"<Esc>`<i"<Esc>
vmap <Leader>' v`>a'<Esc>`<i'<Esc>
") <-- Fix syntax highlighting
" EnhancedCommentify
map <silent> \\      <Plug>Traditionalj

"inoremap <C-]> <Esc>`^
inoremap <C-C> <Esc>`^
inoremap <C-X><C-A> <C-A>
if ! has("gui_running")
  "map <Esc>[3^ <C-Del>
  "map <Esc>[5^ <C-PageUp>
  "map <Esc>[6^ <C-PageDown>
  "map <Esc>[3;5~ <C-Del>
  "map <Esc>[5;5~ <C-PageUp>
  "map <Esc>[6;5~ <C-PageDown>
endif

" Emacs style mappings
if version >= 600
  " If at end of a line of spaces, delete back to the previous line.
  " Otherwise, <Left>
  inoremap <silent> <C-B> <C-R>=getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-T>\<Lt>Esc>kJs":"\<Lt>Left>"<CR>
  " If at end of line, decrease indent, else <Del>
  inoremap <silent> <C-D> <C-R>=col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"<CR>
  " If at end of line, fix indent, else <Right>
  inoremap <silent> <C-F> <C-R>=col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"<CR>
else
  inoremap <C-B> <Left>
  inoremap <C-F> <Right>
endif
inoremap <C-A>      <C-O>^
cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-D>      <Del>
inoremap <C-E>      <End>
cnoremap <C-F>      <Right>
"noremap! <C-N>      <Down>
"noremap! <C-P>      <Up>
noremap! <M-a>      <C-O>(
map!     <M-b>      <S-Left>
noremap! <M-d>      <C-O>dw
noremap! <M-e>      <C-O>)
map!     <M-f>      <S-Right>
noremap! <M-h>      <C-W>
noremap  <M-l>      guiww
noremap  <M-u>      gUiww
noremap! <M-l>      <Esc>guiw`]a
noremap! <M-u>      <Esc>gUiw`]a
noremap! <M-{>      <C-O>{
noremap! <M-}>      <C-O>}
if !has("gui_running")
  silent! exe "set <S-Left>=\<Esc>b"
  silent! exe "set <S-Right>=\<Esc>f"
  silent! exe "set <F31>=\<Esc>d"
  map! <F31> <M-d>
endif

cnoremap <C-O> <Up>
inoremap <M-o> <C-O>o
inoremap <M-O> <C-O>O
inoremap <M-i> <Left>
inoremap <M-I> <C-O>^
inoremap <M-A> <C-O>$
noremap! <C-J> <Down>
noremap! <C-K><C-K> <Up>
inoremap <CR> <C-G>u<CR>
inoremap <C-X>^ <C-R>=substitute(&commentstring,' \=%s\>'," -*- ".&ft." -*- vim:set ft=".&ft." ".(&et?"et":"noet")." sw=".&sw." sts=".&sts.':','')<CR>

map <M-,> :Smaller<CR>
map <M-.> :Bigger<CR>
noremap <M-PageUp> :bprevious<CR>
noremap <M-PageDown> :bnext<CR>
noremap <C-Del> :bdelete<CR>
noremap <M-Up> :bprevious<CR>
noremap <M-Down> :bnext<CR>
noremap <M-Left> :tabprevious<CR>
noremap <M-Right> :tabnext<CR>
noremap <S-Left> :tabprevious<CR>
noremap <S-Right> :tabnext<CR>
"noremap <C-PageUp> :tabprevious<CR>
"noremap <C-PageDown> :tabnext<CR>
noremap <C-Up>  <C-W><Up>
noremap <C-Down> <C-W><Down>
noremap <C-Left> <C-W><Left>
noremap <C-Right> <C-W><Right>
noremap <S-Home> <C-W><Up>
noremap <S-End> <C-W><Down>
noremap <S-Up> <C-W><Up>
noremap <S-Down> <C-W><Down>
noremap! <C-Up> <Esc><C-W><Up>
noremap! <C-Down> <Esc><C-W><Down>
noremap! <C-Left> <Esc><C-W><Left>
noremap! <C-Right> <Esc><C-W><Right>
noremap! <S-Home> <Esc><C-W><Up>
noremap! <S-End> <Esc><C-W><Down>
noremap! <S-Up> <Esc><C-W><Up>
noremap! <S-Down> <Esc><C-W><Down>

" Section: Abbreviations {{{1
" ---------------------------
iab scflead supercalifragilisticexpialidocious
iab Tqb The quick, brown fox jumps over the lazy dog
"iab Ysg http://www.sexygeek.org
iab Ydate <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
iab teh the
iab seperate separate
iab relevent relevant
iab relavent relevant
iab consistant consistent
iab anomoly anomaly

" Section: Syntax Highlighting and Colors {{{1
" --------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
if (&t_Co > 2 || has("gui_running")) && has("syntax")
  if exists("syntax_on") || exists("syntax_manual")
  else
    syntax on
    "syntax enable
  endif
  set list
  set hlsearch
else

endif

if has("syntax")
  hi link User1 StatusLine
  hi link User2 StatusLine
  hi link User3 StatusLine
  hi link User4 StatusLine
  hi link User5 StatusLine
  if filereadable(expand("~/.vim/colors/tim.vim"))
    source ~/.vim/colors/tim.vim
  endif
endif

" Section: Autocommands {{{1
" --------------------------

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  if version>600
    filetype plugin indent on
  else
    filetype on
  endif
  augroup FTMisc " {{{2
    autocmd!
    autocmd VimEnter * let g:rails_debug=1
    "autocmd User Rails* silent! Rlcd
    "autocmd BufNewFile *bin/?,*bin/??,*bin/???,*bin/*[^.][^.][^.][^.]
          "\ if filereadable(expand("~/.vim/templates/skel.sh")) |
          "\   0r ~/.vim/templates/skel.sh |
          "\   silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/eg" |
          "\ endif |
          "\ set ft=sh | $
    autocmd BufNewFile */init.d/*
          \ if filereadable("/etc/init.d/skeleton") |
          \   0r /etc/init.d/skeleton |
          \   $delete |
          \   silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/eg" |
          \ endif |
          \ set ft=sh | 1
    autocmd BufNewFile */.netrc,*/.fetchmailrc,*/.my.cnf let b:chmod_new="go-rwx"
    autocmd BufNewFile *bin/*,*/init.d/* let b:chmod_exe=1
    autocmd BufNewFile *.sh,*.tcl,*.pl,*.py,*.rb let b:chmod_exe=1
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
"    autocmd BufWritePre,FileWritePre */.vim/*.vim,*/.vim.*/*.vim,~/.vimrc* exe "normal msHmt" |
"          \ %s/^\(" Last [Cc]hange:\s\+\).*/\=submatch(1).strftime("%Y %b %d")/e |
"          \ exe "normal `tzt`s"
"    autocmd BufRead /usr/* setlocal patchmode=.org
    autocmd BufReadPre *.doc | setlocal readonly
    autocmd BufReadCmd *.doc execute "0read! antiword \"<afile>\""|$delete|1|set nomodifiable
    autocmd FileReadCmd *.doc execute "read! antiword \"<afile>\""
    autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
      \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif
    "if version >= 700
      "autocmd SwapExists * let v:swapchoice = "e" | echohl MoreMsg | echomsg 'Swap file "'.fnamemodify(v:swapname,':~:.').'" already exists!' | echohl None
    "else
      "set shortmess+=A
    "endif
  augroup END " }}}2
  augroup FTCheck " {{{2
    autocmd!
    autocmd BufNewFile,BufRead *Fvwm*             set ft=fvwm
    autocmd BufNewFile,BufRead *.cl[so],*.bbl     set ft=tex
    " autocmd BufNewFile,BufRead *.cfg            set ft=tex isk+=@
    autocmd BufNewFile,BufRead /var/www/*.module  set ft=php
    autocmd BufNewFile,BufRead *named.conf*       set ft=named
    autocmd BufNewFile,BufRead *.bst              set ft=bst
    autocmd BufNewFile,BufRead *.vb               set ft=vbnet
    autocmd BufNewFile,BufRead *.tt,*.tt2         set ft=tt2html
    autocmd BufNewFile,BufRead *.asm              if getline(1).getline(2).getline(3).getline(4).getline(5).getline(6).getline(7).getline(8).getline(9).getline(10) =~ '\<_ti\d\d' | set ft=asm68a89 | endif
    autocmd BufNewFile,BufRead /var/www/*
          \ let b:url=expand("<afile>:s?^/var/www/?http://localhost/?")
    autocmd BufNewFile,BufRead /etc/udev/*.rules set ft=udev
    autocmd BufNewFile,BufRead *.txt,README,INSTALL if &ft == ""|set ft=text|endif
    autocmd BufNewFile,BufRead *[0-9BM][FG][0-9][0-9]*  set ft=simpsons
    "autocmd BufRead * if expand("%") =~? '^https\=://.*/$'|setf html|endif
    autocmd BufNewFile,BufRead,StdinReadPost *
          \ if !did_filetype() &&
          \   (getline(1) =~ '^!' || getline(2) =~ '^!' || getline(3) =~ '^!'
          \   || getline(4) =~ '^!' || getline(5) =~ '^!') |
          \   setf router |
          \ endif
    autocmd BufRead * if ! did_filetype() && getline(1)." ".getline(2).
          \ " ".getline(3) =~? '<\%(!DOCTYPE \)\=html\>' | setf html | endif
  augroup END " }}}2
  augroup FTOptions " {{{2
    autocmd!
    autocmd FileType c,cpp,cs,java          setlocal ai et sta sw=4 sts=4 cin
    autocmd FileType sh,csh,tcsh,zsh        setlocal ai et sta sw=4 sts=4
    autocmd FileType tcl,perl,python        setlocal ai et sta sw=4 sts=4
    autocmd FileType javascript             setlocal ai et sta sw=4 sts=4 cin
    autocmd FileType php,aspperl,aspvbs,vb  setlocal ai et sta sw=4 sts=4
    autocmd FileType apache,sql,vbnet       setlocal ai et sta sw=4 sts=4
    autocmd FileType tex,css                setlocal ai et sta sw=2 sts=2
    autocmd FileType html,xhtml,xml,wml,cf  setlocal ai et sta sw=2 sts=2
    autocmd FileType eruby,yaml,ruby        setlocal ai et sta sw=2 sts=2
    autocmd FileType tt2html,htmltt,mason   setlocal ai et sta sw=2 sts=2
    autocmd FileType text,txt,mail          setlocal noai noet sw=8 sts=8
    autocmd FileType cs,vbnet               setlocal foldmethod=syntax fdl=2
    autocmd FileType sh,zsh,csh,tcsh        inoremap <silent> <buffer> <C-X>! #!/bin/<C-R>=&ft<CR>
    autocmd FileType perl,python,ruby       inoremap <silent> <buffer> <C-X>! #!/usr/bin/<C-R>=&ft<CR>
    autocmd FileType sh,zsh,csh,tcsh,perl,python,ruby imap <buffer> <C-X>& <C-X>!<Esc>o<C-U># $I<C-V>d$<Esc>o<C-U><C-X>^<Esc>o<C-U><C-G>u
    autocmd User     allml                  imap <C-Z> <C-X>=|imap <C-J> <Down>
    if !filereadable(expand("~/.config/vim/syntax/tt2html.vim"))
     autocmd BufNewFile,BufRead *.tt,*.tt2        set syn=html
    endif
    autocmd FileType aspvbs,vbnet setlocal comments=sr:'\ -,mb:'\ \ ,el:'\ \ ,:',b:rem formatoptions=crq
    autocmd FileType asp*         runtime! indent/html.vim
    autocmd FileType bst  setlocal smartindent ai sta sw=2 sts=2
    autocmd FileType cobol setlocal ai et sta sw=4 sts=4 tw=72 makeprg=cobc\ %
    autocmd FileType cs   silent! compiler cs | setlocal makeprg=gmcs\ %
    "autocmd FileType eruby setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType help setlocal ai fo+=2n | silent! setlocal nospell
    autocmd FileType html setlocal iskeyword+=:,~
    autocmd FileType java silent! compiler javac | setlocal makeprg=javac\ %
    autocmd FileType mail setlocal tw=70|if getline(1) =~ '^[A-Za-z-]*:\|^From ' | exe 'norm 1G}' |endif|silent! setlocal spell
    autocmd FileType perl silent! compiler perl | setlocal iskeyword+=: keywordprg=perl\ -e'$c=shift;exec\ q{perldoc\ }.($c=~/^[A-Z]\|::/?q{}:q{-f}).qq{\ $c}'
    autocmd FileType python setlocal keywordprg=pydoc
    autocmd FileType ruby silent! compiler ruby | setlocal makeprg=ruby\ -wc\ % keywordprg=ri | imap <C-Z> <CR>end<C-O>O
    autocmd FileType sql map! <buffer> <C-Z> <Esc>`^gUaw`]a
    autocmd FileType text,txt setlocal tw=78 linebreak nolist
    autocmd FileType tex  silent! compiler tex | setlocal makeprg=latex\ -interaction=nonstopmode\ % wildignore+=*.dvi formatoptions+=l
    autocmd FileType tex if exists("*IMAP")|
          \ call IMAP('{}','{}',"tex")|
          \ call IMAP('[]','[]',"tex")|
          \ call IMAP('$$','$$',"tex")|
          \ call IMAP('`"\','`"\',"tex")|
          \ call IMAP('`/','`/',"tex")|
          \ call IMAP('{{','{{',"tex")|
          \ call IMAP('^^','^^',"tex")|
          \ call IMAP('::','::',"tex")|
          \ endif
    autocmd FileType vbnet        runtime! indent/vb.vim
    autocmd FileType vim  setlocal ai et sta sw=4 sts=4 keywordprg=:help | map! <buffer> <C-Z> <C-X><C-V>
    "autocmd BufWritePost ~/.vimrc   so ~/.vimrc
    autocmd FileType * if exists("+omnifunc") && &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
    autocmd FileType * if exists("+completefunc") && &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | endif
  augroup END "}}}2
endif " has("autocmd")

" }}}1
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
