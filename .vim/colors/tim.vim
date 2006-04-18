" Vim color file
" File:         ~/.vim/colors/tim.vim
" Author:       Tim Pope <vim@rebelongto.us>
" URL:          http://www.sexygeek.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/colors/tim.vim
" Last Change:  2006 Mar 29
" Version:      $Id$

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
  hi Normal     term=reverse ctermfg=Black ctermbg=White guifg=Black guibg=White
  hi LineNr     ctermfg=Black ctermbg=LightGrey guifg=Black guibg=LightGrey
  hi Folded     ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi FoldColumn ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi Comment    term=bold ctermfg=Blue guifg=Blue
" hi Label      term=bold ctermfg=LightMagenta guifg=LightMagenta
  hi SpecialKey ctermfg=LightGrey guifg=Grey
  hi StatusLine term=bold,inverse cterm=none ctermfg=White ctermbg=DarkGrey
  hi StatusLineNC term=bold,inverse cterm=none ctermfg=grey ctermbg=Black
  hi User1 ctermfg=LightBlue ctermbg=Black gui=bold guifg=DodgerBlue guibg=Black
  hi User2 ctermfg=LightGreen ctermbg=Black gui=bold guifg=Green guibg=Black
  hi User3 ctermfg=Yellow ctermbg=Black gui=bold guifg=Yellow guibg=Black
  hi User4 ctermfg=LightRed ctermbg=Black gui=bold guifg=IndianRed1 guibg=Black
  hi User5 ctermfg=LightCyan ctermbg=Black gui=bold guifg=Cyan guibg=Black
  hi SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
  hi MatchParen  term=reverse ctermbg=LightCyan guibg=Cyan
  " }}}1
else
  " Section: Dark Background {{{1
  " -----------------------------
  hi Normal     ctermfg=LightGrey ctermbg=Black guifg=LightGrey guibg=Black
  hi LineNr     ctermfg=White ctermbg=DarkBlue guifg=White guibg=DarkBlue
  hi Folded     ctermfg=LightCyan ctermbg=DarkBlue guifg=Cyan guibg=DarkBlue
  hi FoldColumn ctermfg=LightCyan ctermbg=DarkBlue guifg=Cyan guibg=DarkBlue
  hi Todo       ctermfg=White ctermbg=Black
  hi Comment    term=bold ctermfg=DarkCyan guifg=DarkCyan
" hi Label      term=bold ctermfg=DarkMagenta guifg=DarkMagenta
  hi SpecialKey ctermfg=DarkGrey guifg=DimGrey
  if has("win32") && ! has("win32_gui")
    hi StatusLine term=bold,reverse cterm=bold ctermbg=White ctermfg=Black guifg=White
    hi StatusLineNC term=reverse ctermbg=Grey guifg=White
    hi User1 term=bold,reverse ctermbg=White ctermfg=Blue gui=bold guifg=Blue guibg=White
    hi User2 term=bold,reverse ctermbg=White ctermfg=DarkGreen gui=bold guifg=DarkGreen guibg=White
    hi User3 term=bold,reverse ctermbg=White ctermfg=Brown gui=bold guifg=Brown guibg=White
    hi User4 term=bold,reverse ctermbg=White ctermfg=Red gui=bold guifg=Red guibg=White
    hi User5 term=bold,reverse ctermbg=White ctermfg=DarkCyan gui=bold guifg=DarkCyan guibg=White
  else
    hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=White ctermbg=Black guifg=White
    hi StatusLineNC term=reverse cterm=reverse ctermfg=Grey guifg=White
    hi User1 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Blue gui=bold guifg=Blue guibg=White
    hi User2 term=bold,reverse cterm=reverse ctermfg=White ctermbg=DarkGreen gui=bold guifg=DarkGreen guibg=White
    hi User3 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Brown gui=bold guifg=Brown guibg=White
    hi User4 term=bold,reverse cterm=reverse ctermfg=White ctermbg=Red gui=bold guifg=Red guibg=White
    hi User5 term=bold,reverse cterm=reverse ctermfg=White ctermbg=DarkCyan gui=bold guifg=DarkCyan guibg=White
  endif
  hi SpellErrors ctermfg=LightRed guifg=Red cterm=underline gui=underline term=reverse
  hi MatchParen  term=reverse ctermbg=DarkCyan guibg=DarkCyan
  " }}}1
endif
" vim:set ft=vim sts=2 sw=2:
