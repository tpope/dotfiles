" $Id$
" vim:set ft=vim et tw=70 sw=2:
version 5.0

" Section: Options {{{1
" ---------------------
set runtimepath^=~/.vim/local,~/.vim.local
set runtimepath+=~/.vim.local/after,~/.vim/local/after

set autoindent
set autowrite       " Automatically save before commands like :next and :make
set backspace=2
set backup          " Do keep a backup file
set cmdheight=2
set grepprg=grep\ -nH\ $*
set incsearch       " Incremental search
set joinspaces
set laststatus=2    " Always show status line
set lazyredraw
"let &listchars="tab:\<M-;>\<M-7>,trail:\<M-7>"
set listchars=tab:>\ ,trail:-
set listchars+=extends:>,precedes:<
set modelines=5     " Debian likes to disable this
set mousemodel=popup
"set nohidden       " Disallow hidden buffers
"set nostartofline
set pastetoggle=<F2>
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
set smartcase       " Case insensitive searches become sensitive with capitals
set smarttab
set splitbelow      " Split windows at bottom
set suffixes+=.dvi
set timeoutlen=1200 " A liiiiittle bit more time for macros
set ttimeoutlen=200 " Make Esc work faster
set visualbell
set virtualedit=block
set wildmenu
set wildmode=longest:full,full
set wildignore+=*~

let spell_auto_type = "mail"
let spell_insert_mode = 0
let c_comment_strings=1
let g:Tex_CompileRule_dvi='latex -interaction=nonstopmode -src-specials $*'
let g:Imap_PlaceHolderStart="\xab"
let g:Imap_PlaceHolderEnd="\xbb"

if has("gui_running")
  if has("unix")
    set guifont=bitstream\ vera\ sans\ mono\ 11,fixed,-bitstream-bitstream\ vera\ sans\ mono-medium-r-normal-*-*-110-*-*-m-*-iso8859-1
    "set guioptions-=T guioptions-=m
  elseif has("win32")
    set guifont=Courier\ New:h11
  endif
  set background=light
  set cmdheight=2 lines=25 columns=80
  set title
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
else
  set background=dark
  set notitle
endif

if version>=600
  set autoread
  set foldmethod=marker
  set printoptions=paper:letter ",syntax:n
  set sidescrolloff=5
endif

if version < 602
  set clipboard+=exclude:screen.*
endif

if has("dos16") || has("dos32") || has("win32")
  if $PATH =~? 'cygwin' && ! exists("no_cygwin_shell")
    set shell=bash
    set shellpipe=2>&1\|tee
    set shellslash
  endif
endif

if version>503
  set statusline=%5*[%n]%*\ %1*%<%.99f%*\ %2*%h%w%m%r%y%*%=%-16(\ %3*%l,%c-%v%*\ %)%4*%P%*
endif

"
" Section: Functions {{{1
" -----------------------

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
command! Invert :call Invert()

function! OpenURL(url)
  if has("win32")
    exe "!start cmd /cstart /b ".a:url.""
  else
    exe "normal :!sensible-browser \"".a:url."\" </dev/null\<CR>"
  endif
endfunction

function! Version()
  return version/100 . "." . version%100
endfunction

function! Run()
  if &ft == "perl"
    wa
    !perl -w %
  elseif &ft == "ruby"
    wa
    !ruby -w %
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
  elseif &ft == "txt" || &ft == "text" || &ft == "mail"
    normal "\ss"
  elseif expand("%:e") == "tex"
    wa
    exe "normal :!rubber %:r && xdvi %:r &\<CR>"
  else
    wa
    make %
    "exe "normal :!Eterm -t White -T 'make test' --pause -e make -s test &\<CR>"
  endif
endfunction

function! SQL()
  edit SQL
  setf sql
  set bt=nofile
endfunction
command! SQL :call SQL()

function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
if version >= 600
  inoremap <silent> <Tab> <C-R>=InsertTabWrapper()<CR>
else
  inoremap <Tab> <C-R>=InsertTabWrapper()<CR><C-O>:<Backspace>
endif

function! TemplateFileFunc_sh()
  $
endfunction

function! TemplateFileFunc_pl()
  $
endfunction

function! FTCheck_asmsyntax()
  " see if file contains any asmsyntax=foo overrides. If so, change
  " b:asmsyntax appropriately
  let head = " ".getline(1)." ".getline(2)." ".getline(3)." ".getline(4).
        \" ".getline( 5)." ".getline( 6)." ".getline( 7)." ".getline( 8).
        \" ".getline( 9)." ".getline(10)." ".getline(11)." ".getline(12).
        \" ".getline(13)." ".getline(14)." ".getline(15)." ".getline(16)." "
  if head =~ '\sasmsyntax=\S\+\s'
    let b:asmsyntax = substitute(head,'.*\sasmsyntax=\(\S\+\)\s.*','\1',"")
  elseif head =~ '\s_ti\d\d'
    let b:asmsyntax = "asm68a89"
  endif
endfunction

if version < 600
" Never actually tested this
  command -nargs=* setlocal set <args>
else
  runtime! macros/matchit.vim
endif

" Section: Mappings {{{1
" ----------------------

" if filereadable(expand("~/.vim/mappings.vim"))
"     source ~/.vim/mappings.vim
" endif

if ! has("gui_running")
  map <Esc>[3^ <C-Del>
  map <Esc>[5^ <C-PageUp>
  map <Esc>[6^ <C-PageDown>
  map <Esc>[3;5~ <C-Del>
  map <Esc>[5;5~ <C-PageUp>
  map <Esc>[6;5~ <C-PageDown>
endif

map Q       gq        " Don't use Ex mode; use Q for formatting
map gb      :call OpenURL(expand("<cfile>"))<CR>
" Run p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
vnoremap <C-C> "+y
imap <F1>   <C-O><F1>
map <F1>    K<CR>
map <F3>    :Invert<CR>
map <F4>    :cprev<CR>
map <F5>    :cc<CR>
map <F6>    :cnext<CR>
"map <F7>    :wa<BAR>make<CR>
map <F8>    :wa<BAR>make<CR>
map <F9>    :call Run()<CR>
map <F10>   :wa<BAR>make
map <F12>   :![ -z "$STY" ] \|\| screen<CR><CR>
imap <F12> <C-O><F12>
map <C-F4>  :bdelete<CR>
"map <t_%9>  :hardcopy<CR>         " Print Screen

map <C-Z> :shell<CR>
map <Leader>at gg}jWdWWPX " Attribution Fixing
map <Leader>sa :!aspell -c --dont-backup "%"<CR>:e! "%"<CR><CR>
map <Leader>si :!ispell "%"<CR>:e! "%"<CR><CR>
"map <Leader>sh :so `sh /usr/share/doc/vim/tools/vimspell.sh %`<CR><CR>
map <Leader>sw :!echo "<cword>"\|aspell -a --<CR>
map <Leader>fj {:.,/^ *$/-2 call Justify('',3,)<CR>
map <Leader>fJ :% call Justify('',3,)<CR>
map <Leader>fp gqap
map <Leader>fd :!webster "<cword>" &<CR>
map <Leader>ft :!thesaurus "<cword>" &<CR>
map <Leader>v :so ~/.vimrc<CR>
" Merge consecutive empty lines
map <Leader>Sj :g/^\s*$/,/\S/-j<CR>
" Wrap visual in parentheses
vmap <Leader>( v`>a)<ESC>`<i(<ESC>
") <-- Fix syntax highlighting

" Emacs style mappings
noremap! <C-A>    <Home>
noremap! <C-B>    <Left>
cnoremap <C-D>    <Del>
noremap! <C-E>    <End>
noremap! <C-F>    <Right>
"noremap! <C-N>    <Down>
"noremap! <C-P>    <Up>
noremap! <M-a>    <C-O>(
noremap! <M-e>    <C-O>)
noremap! <M-b>    <S-Left>
noremap! <M-d>    <C-O>dw
noremap! <M-f>    <S-Right>
noremap! <M-{>   <C-O>{
noremap! <M-}>   <C-O>}
if ! has("gui")
  cnoremap <Esc>b   <S-Left>
  cnoremap <Esc>f   <S-Right>
endif

noremap <C-PageUp> :bprevious<CR>
noremap <C-PageDown> :bnext<CR>
noremap <C-Del> :bdelete<CR>
noremap <S-Left> :bprevious<CR>
noremap <S-Right> :bnext<CR>
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
" if filereadable(expand("~/.vim/abbr.vim"))
"     source ~/.vim/abbr.vim
" endif
iab Ysuper supercalifragilisticexpialidocious
iab Ytqb The quick, brown fox jumps over the lazy dog
iab Ysg http://www.sexygeek.org
iab Ydate <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
iab teh the
iab seperate separate
iab relevent relevant
iab relavent relevant

" Section: Syntax Highlighting and Colors {{{1
" --------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && has("syntax")
  if exists("syntax_on") || exists("syntax_manual")
  else
    syntax on
    "syntax enable
  endif
  set list
  "  set hlsearch
else

endif

if has("syntax")
  hi link User1 StatusLineNC
  hi link User2 StatusLineNC
  hi link User3 StatusLineNC
  hi link User4 StatusLineNC
  hi link User5 StatusLineNC
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
    "autocmd FileType zsh runtime! indent/sh.vim
  else
    filetype on
  endif
  augroup FTMisc
    autocmd!
    autocmd BufNewFile *bin/?,*bin/??,*bin/???,*bin/*[^.][^.][^.][^.] 
          \ if filereadable(expand("~/.vim/templates/skel.sh")) |
          \   0r ~/.vim/templates/skel.sh |
          \   silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/eg" |
          \ endif |
          \ set ft=sh | $
    autocmd BufNewFile */init.d/*
          \ if filereadable("/etc/init.d/skeleton") |
          \   0r /etc/init.d/skeleton |
          \   $delete |
          \   silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/eg" |
          \ endif |
          \ set ft=sh | 1
    autocmd BufNewFile *bin/*,*/init.d/* let b:chmod_new="+x"
    autocmd BufNewFile *.sh,*.tcl,*.pl,*.py,*.rb let b:chmod_new="+x"
    autocmd BufNewFile */.netrc,*/.fetchmailrc let b:chmod_new="go-rwx"
    autocmd BufWritePost,FileWritePost * if exists("b:chmod_new")|
          \ silent! execute "!chmod ".b:chmod_new." <afile>"|
          \ unlet b:chmod_new|
          \ endif
    autocmd BufWritePost,FileWritePost ~/.Xdefaults,~/.Xresources silent! !xrdb -load % >/dev/null 2>&1
    autocmd BufWritePre,FileWritePre */.vim/*.vim,~/.vimrc* exe "normal msHmt" |
          \ %s/^\(" Last [Cc]hange:\s\+\).*/\=submatch(1).strftime("%Y %b %d")/e |
          \ exe "normal `tzt`s"
    autocmd BufRead /usr/src/* setlocal patchmode=.org
    autocmd BufReadPre *.doc | setlocal readonly
    autocmd BufReadCmd *.doc execute "0read! antiword \"<afile>\""|$delete|1|set nomodifiable
    autocmd FileReadCmd *.doc execute "read! antiword \"<afile>\""
  augroup END
  augroup FTCheck
    autocmd!
    autocmd BufNewFile,BufRead *Fvwm*             set ft=fvwm
    autocmd BufNewFile,BufRead *.cl[so],*.bbl     set ft=tex
    " autocmd BufNewFile,BufRead *.cfg            set ft=tex isk+=@
    autocmd BufNewFile,BufRead /var/www/*.module  set ft=php
    autocmd BufNewFile,BufRead *named.conf*       set ft=named
    autocmd BufNewFile,BufRead *.bst              set ft=bst
    autocmd BufNewFile,BufRead /var/www/*
          \ let b:url=expand("<afile>:s?^/var/www/?http://localhost/?")
    autocmd BufNewFile,BufRead *.txt,README,INSTALL set ft=text
    autocmd BufNewFile,BufRead *[0-9BM][FG][0-9][0-9]*  set ft=simpsons
    autocmd BufRead * if expand("%") =~? '^https\=://.*/$'|setf html|endif
    autocmd BufNewFile,BufRead,StdinReadPost *
          \ if !did_filetype()
          \   && (getline(1) =~ '^!' || getline(2) =~ '^!' || getline(3) =~ '^!'
          \   || getline(4) =~ '^!' || getline(5) =~ '^!') |
          \   setf router |
          \ endif
    "if filereadable(expand("$VIMRUNTIME/tools/efm_perl.pl"))
      "autocmd FileType perl setlocal makeprg=$VIMRUNTIME/tools/efm_perl.pl\ -c\ % errorformat=%f:%l:%m
    "else
      "autocmd FileType perl setlocal makeprg=perl\ -wc\ %
    "endif
  augroup END
  augroup FTOptions
    autocmd!
    autocmd FileType sh,csh,tcsh,zsh        setlocal ai et sta sw=4 sts=4
    autocmd FileType tcl,perl,python,ruby   setlocal ai et sta sw=4 sts=4
    autocmd FileType c,cpp,cs,java          setlocal ai et sta sw=4 sts=4 cin
    autocmd FileType php,aspperl,aspvbs     setlocal ai et sta sw=4 sts=4
    autocmd FileType html,xhtml,tex,css     setlocal ai et sta sw=2 sts=2
    autocmd FileType text,txt,mail          setlocal noai noet sw=8 sts=8
    autocmd FileType aspvbs runtime! indent/vb.vim | setlocal comments=sr:'\ -,mb:'\ \ ,el:'\ \ ,:',b:rem formatoptions=crq " | unlet b:did_ftplugin|runtime! ftplugin/vb.vim
    autocmd FileType bst setlocal smartindent ai sta sw=2 sts=2
    autocmd FileType java silent! compiler javac | setlocal makeprg=javac\ %
    autocmd FileType mail setlocal tw=70|if getline(1) =~ '^[A-Za-z-]*:\|^From ' | exe 'norm 1G}' |endif
    autocmd FileType html setlocal iskeyword+=:,~
    autocmd FileType perl silent! compiler perl | setlocal iskeyword+=: keywordprg=perl\ -e'$c=shift;exec\ q{perldoc\ }.($c=~/^[A-Z]\|::/?q{}:q{-f}).qq{\ $c}'
    autocmd FileType python setlocal keywordprg=pydoc
    autocmd FileType ruby silent! compiler ruby | setlocal makeprg=ruby\ -wc\ % keywordprg=ri
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
          \ endif
    autocmd FileType vim  setlocal ai et sta sw=4 sts=4 keywordprg=:help
    "autocmd BufWritePost ~/.vimrc   so ~/.vimrc
  augroup END
endif " has("autocmd")

" }}}1
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
