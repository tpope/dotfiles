version 5.4
" $Id$
" vim:tw=70 sw=2 sts=2 et

" Section: Options {{{1
" ---------------------
" set guioptions-=T guioptions-=m guioptions+=f
set guioptions-=T guioptions-=m
set laststatus=2   " Always show status line
set cmdheight=2
set hidden
set joinspaces
set lazyredraw
set pastetoggle=<F2>
set nostartofline
set splitbelow
set list
set visualbell
set listchars=tab:»·,trail:·
set wildmenu
set wildmode=longest:full,full
set backspace=2
set showcmd     " Show (partial) command in status line.
set showmatch   " Show matching brackets.
set incsearch   " Incremental search
set autowrite   " Automatically save before commands like :next and :make
set autoindent
set backup      " Do keep a backup file
set modelines=5
set grepprg=grep\ -nH\ $*
let spell_auto_type = "mail"
let spell_insert_mode = 0
let c_comment_strings=1
let g:Tex_CompileRule_dvi='latex -interaction=nonstopmode -src-specials $*'
let g:Imap_PlaceHolderStart="\xab"
let g:Imap_PlaceHolderEnd="\xbb"

set background=dark
if has ("gui_running")
  set guifont=bitstream\ vera\ sans\ mono\ 11,fixed,-bitstream-bitstream\ vera\ sans\ mono-medium-r-normal-*-*-110-*-*-m-*-iso8859-1
  set background=light
  set cmdheight=2 lines=26 columns=80
  set title
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif

if version>600
    set printoptions=paper:letter,syntax:n
    set foldmethod=marker
    set autoread
endif

if has("dos16") || has("dos32") || has("gui_win32")
  set shell=bash
  set shellpipe=2>&1<BAR><SPACE>tee
  set shellslash
  set guifont=Courier\ New:h11
else
  " UNIX
endif
"
" Section: Functions {{{1
" -----------------------

fu! Invert()
  if &background=="light"
    set background=dark
  else
    set background=light
  endif
  if version>600
    colorscheme tim
  else
    source $HOME/.vim/colors/tim.vim
  endif
endf


fu! Version()
  return version
endf

fu! TemplateFileFunc_sh()
  $
endf

fu! TemplateFileFunc_pl()
  $
endf

" Section: Status Line {{{1
" -------------------------

if version>503
  set statusline=%1*%.99f%*\ %2*%h%w%m%r%y%*%=%-16(\ %3*%l,%c-%v%*\ %)%4*%P%*
endif

if ! has("gui_running")
  set notitle titlestring=Vim-%{Version()}@%{hostname()}:%{fnamemodify(getcwd(),\":p:~\")}
endif

" Section: Mappings {{{1
" ----------------------

" if filereadable(expand("~/.vim/mappings.vim"))
"     source ~/.vim/mappings.vim
" endif
fun! Make()
  wa
  if expand("%:e") == "tex"
    exe "!rubber ".expand("%:r")." && xdvi ".expand("%:r")."&"
  else
    !Eterm -t White -T 'make test' --pause -e make -s test
  endif
endfun

map Q       gq        " Don't use Ex mode; use Q for formatting
" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>
map <F3>    :call Invert()<CR>
map <F4>    :cprev<CR>
map <F5>    :cc<CR>
map <F6>    :cnext<CR>
map <F7>    :wa<BAR>make<CR>
map <F8>    :call Make()<CR><CR>
map <F9>    :wa<BAR>make %<CR>
map <F10>   :wa<BAR>make 
map <F12>   :![ -z "$STY" ] \|\| screen<CR><CR>
imap <F12> <C-O>:![ -z "$STY" ] \|\| screen<CR><CR>
"map <t_%9>  :hardcopy<CR>         " Print Screen

map <C-Z>   :shell<CR>
map <Leader>at gg}jWdWWPX " Attribution Fixing
map <Leader>sa <Esc>:!aspell -c --dont-backup "%"<CR>:e! "%"<CR><CR>
map <Leader>si <Esc>:!ispell "%"<CR>:e! "%"<CR><CR>
map <Leader>sh <Esc>:so `sh /usr/share/doc/vim/tools/vimspell.sh %`<CR><CR>
map <Leader>sw <Esc>:!echo "<cword>"\|aspell -a --<CR>
map <Leader>fj <Esc>{:.,/^ *$/-2 call Justify('',3,)<CR>
map <Leader>fJ <Esc>% call Justify('',3,)<CR>
map <Leader>fp gqap
map <Leader>fd <Esc>:!webster "<cword>" &<CR>
map <Leader>ft <Esc>:!thesaurus "<cword>" &<CR>

" Emacs style mappings
noremap! <C-A>    <Home>
noremap! <C-B>    <Left>
cnoremap <C-D>    <Del>
noremap! <C-E>    <End>
noremap! <C-F>    <Right>
noremap! <C-N>    <Down>
noremap! <C-P>    <Up>
noremap! <M-a>    <C-O>(
cnoremap <Esc>b   <S-Left>
noremap! <M-b>    <S-Left>
noremap! <M-d>    <C-O>dw
noremap! <M-e>    <C-O>)
noremap! <M-f>    <S-Right>
cnoremap <Esc>f   <S-Right>
noremap! <Esc>{   <C-O>{
noremap! <Esc>}   <C-O>}

" Section: Abbreviations {{{1
" ---------------------------
" if filereadable(expand("~/.vim/abbr.vim"))
"     source ~/.vim/abbr.vim
" endif
iab Ysuper supercalifragilisticexpialidocious
iab YTqb The quick, brown fox jumps over the lazy dog
iab Ysg http://www.sexygeek.org
iab YDATE <C-R>=strftime("%a %b %d %T %Z %Y")<CR>
iab teh the

" Section: Syntax Highlighting and Colors {{{1
" --------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && has("syntax")
syntax on
set list
"  set hlsearch
else

endif

if version>600
colorscheme tim
else
source $HOME/.vim/colors/tim.vim
endif

" Section: Autocommands {{{1
" --------------------------

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  if version>600
    filetype plugin indent on
    autocmd FileType zsh runtime! indent/sh.vim
  else
    filetype on
  endif
augroup myfiletypedetect
autocmd!

fun! FTCheck_asmsyntax()
  " see if file contains any asmsyntax=foo overrides. If so, change
  " b:asmsyntax appropriately
  let head = " ".getline(1)." ".getline(2)." ".getline(3)." ".getline(4).
	\" ".getline(5)." ".getline(6)." ".getline(7)." ".getline(8).
	\" ".getline(9)." ".getline(10)." ".getline(11)." ".getline(12).
	\" ".getline(13)." ".getline(14)." ".getline(15)." ".getline(16)." "
  if head =~ '\sasmsyntax=\S\+\s'
    let b:asmsyntax = substitute(head, '.*\sasmsyntax=\(\S\+\)\s.*','\1', "")
  endif
  if head =~ '\s_ti\d\d'
    let b:asmsyntax = "asm68a89"
  endif
endfun

autocmd BufNewFile *bin/?,*bin/??,*bin/???,*bin/*[^.][^.][^.][^.] if filereadable(expand($HOME . "/.vim/templates/skel.sh")) | execute "0r " . $HOME . "/.vim/templates/skel.sh" | silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/g" | endif | set ft=sh | $
"autocmd BufWritePost *bin/*,*/init.d/* silent! execute "!chmod +x %"
autocmd BufNewFile */init.d/* if filereadable("/etc/init.d/skeleton") | 0r /etc/init.d/skeleton | $d | silent! execute "%s/\\$\\(Id\\):[^$]*\\$/$\\1$/g" | endif | set ft=sh | 1
 autocmd BufNewFile,BufRead *.txt			set tw=78 linebreak nolist
 autocmd BufNewFile,BufRead *[0-9BM][FG][0-9][0-9]*	set ft=simpsons
 autocmd BufNewFile,BufRead *Fvwm*			set ft=fvwm
 autocmd BufNewFile,BufRead *.cl[so]			set ft=tex
 autocmd BufNewFile,BufRead *.bbl			set ft=tex
 " autocmd BufNewFile,BufRead *.cfg			set ft=tex isk+=@
 autocmd BufNewFile,BufRead /var/www/*.module		set ft=php
 autocmd BufNewFile,BufRead *named.conf*		set ft=named
 autocmd BufNewFile,BufRead *.bst			set ft=bst sw=2 sts=2 smartindent
 autocmd BufNewFile,BufRead,StdinReadPost *
	\ if !did_filetype()
	\    && (getline(1) =~ '^!' || getline(2) =~ '^!' || getline(3) =~ '^!'
	\	|| getline(4) =~ '^!' || getline(5) =~ '^!') |
	\   setf router |
	\ endif
 autocmd FileType perl,php,sh,zsh,csh,c,cpp,vim,java set sw=4 sts=4 ai
 autocmd FileType html,tex,css set sw=2 sts=2 ai
 autocmd FileType java set efm=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
 autocmd FileType mail if getline(1) =~ '^[A-Za-z-]*:\|^From ' | exe 'norm 1G}' |endif
 autocmd FileType html set isk+=:,~
 autocmd FileType tex set makeprg=latex\ \\\\nonstopmode\ \\\\input\\{$*\\} efm=%E!\ LaTeX\ %trror:\ %m,
	\%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#,
	\%+W%.%#\ at\ lines\ %l--%*\\d,
	\%WLaTeX\ %.%#Warning:\ %m,
	\%Cl.%l\ %m,
	\%+C\ \ %m.,
	\%+C%.%#-%.%#,
	\%+C%.%#[]%.%#,
	\%+C[]%.%#,
	\%+C%.%#%[{}\\]%.%#,
	\%+C<%.%#>%.%#,
	\%C\ \ %m,
	\%-GSee\ the\ LaTeX%m,
	\%-GType\ \ H\ <return>%m,
	\%-G\ ...%.%#,
	\%-G%.%#\ (C)\ %.%#,
	\%-G(see\ the\ transcript%.%#),
	\%-G\\s%#,
	\%+P(%f%r,
	\%+P\ %\\=(%f%r,
	\%+P%*[^()](%f%r,
	\%+P[%\\d%[^()]%#(%f%r,
	\%+Q)%r,
	\%+Q%*[^()])%r,
	\%+Q[%\\d%*[^()])%r
 autocmd FileType tex if exists("*IMAP") | call IMAP('{}','{}','tex')|call IMAP('[]','[]','tex')|call IMAP('$$','$$','tex')|call IMAP('`\','`\','tex')|call IMAP('`/','`/','tex')|call IMAP('{{','{{','tex')|call IMAP('^^','^^','tex')|endif
 autocmd BufWritePost ~/.vimrc   so ~/.vimrc
augroup END
endif " has("autocmd")

" }}}1
