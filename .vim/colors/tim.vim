version 5.6
" File:         $HOME/.vim/colors/tim.vim
" Purpose:      Tim's colors for vim
" Author:       Tim Pope <timpope@sbcglobal.net>
" vim: tw=70 sw=2 sts=2 et

if version>600
  hi clear
endif
if exists("syntax_on")
  syntax reset
endif

let colors_name = "tim"

hi Type gui=none
hi Statement gui=none
hi Search NONE term=underline cterm=underline gui=underline

if &background=="light"
  " Section: Light Background {{{1
  " ------------------------------
  hi Normal	term=reverse ctermfg=Black ctermbg=White guifg=Black guibg=White
  hi StatusLine term=bold,inverse cterm=none ctermfg=White ctermbg=DarkGrey
  hi StatusLineNC term=bold,inverse cterm=none ctermfg=grey ctermbg=Black
  hi Comment	term=bold ctermfg=Blue guifg=Blue
  hi Label	term=bold ctermfg=LightMagenta guifg=LightMagenta
  hi SpecialKey	ctermfg=LightGrey guifg=Grey
" hi mailHeader ctermfg=Cyan guifg=Cyan
" hi mailSubject ctermfg=DarkCyan guifg=DarkCyan
  hi User1 ctermfg=LightBlue ctermbg=Black gui=bold guifg=DodgerBlue guibg=Black
  hi User2 ctermfg=LightGreen ctermbg=Black gui=bold guifg=Green guibg=Black
  hi User3 ctermfg=Yellow ctermbg=Black gui=bold guifg=Yellow guibg=Black
  hi User4 ctermfg=LightRed ctermbg=Black gui=bold guifg=IndianRed1 guibg=Black
  hi SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
  " }}}1
else
  " Section: Dark Background {{{1
  " -----------------------------
  hi Normal	ctermfg=LightGrey ctermbg=Black guifg=LightGrey guibg=Black
  hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=White ctermbg=Black guifg=White
  hi StatusLineNC term=reverse cterm=reverse ctermfg=Grey guifg=White
  hi Comment	term=bold ctermfg=DarkCyan guifg=DarkCyan
  hi SpecialKey	ctermfg=DarkGrey guifg=DimGrey
  hi Label	term=bold ctermfg=DarkMagenta guifg=DarkMagenta
  hi Folded     guibg=DimGrey
" hi mailHeader ctermfg=DarkCyan guifg=DarkCyan
" hi mailSubject ctermfg=Cyan guifg=Cyan
  hi User1 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Blue gui=bold guifg=Blue guibg=White
  hi User2 term=bold,reverse cterm=reverse ctermfg=White ctermbg=DarkGreen gui=bold guifg=DarkGreen guibg=White
  hi User3 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Brown gui=bold guifg=Brown guibg=White
  hi User4 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Red gui=bold guifg=Red guibg=White
  hi SpellErrors ctermfg=LightRed guifg=Red cterm=underline gui=underline term=reverse
  " }}}1
endif
