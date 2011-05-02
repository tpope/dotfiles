" Vim color file
" File:         ~/.vim/colors/tim.vim
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2011 May 02

if version>600
  hi clear
endif
if exists("syntax_on")
  syntax reset
endif

let colors_name = "tim"

hi Type        gui=none
hi Statement   gui=none
hi Search NONE gui=underline term=underline cterm=underline

hi link rubyBlockParameter  NONE
hi link rubyConstant        Type
"hi link rubyType            Type
hi link rubySymbol          Constant
"hi link railsMethod         Type
"hi TabLineFill  term=underline cterm=underline gui=underline
hi TabLineFill NONE
hi link TabLineFill TabLine

if &background=="light"
  " Section: Light Background {{{1
  " ------------------------------
  hi Normal     term=reverse ctermfg=Black ctermbg=White guifg=Black guibg=White
  hi LineNr     ctermfg=Black ctermbg=LightGrey guifg=Black guibg=LightGrey
  hi Folded     ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi FoldColumn ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi PmenuSel   ctermfg=Black ctermbg=LightCyan
  hi Comment    term=bold ctermfg=Blue guifg=Blue
" hi Label      term=bold ctermfg=LightMagenta guifg=LightMagenta
  hi SpecialKey ctermfg=LightGrey guifg=Grey
  if version >= 700
    " hi Visual     ctermbg=LightMagenta cterm=none
    hi VisualNOS  ctermbg=LightRed     cterm=none guibg=LightRed gui=none
  endif
  "hi TabLine    term=underline cterm=underline,bold gui=underline guibg=NONE
  "hi TabLineSel term=bold cterm=none gui=bold
  hi StatusLine term=bold,inverse cterm=none ctermfg=White ctermbg=0
  hi StatusLineNC term=bold,inverse cterm=none ctermfg=grey ctermbg=Black
  hi SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
  hi MatchParen  term=reverse ctermbg=LightCyan guibg=Cyan
  " }}}1
else
  " Section: Dark Background {{{1
  " -----------------------------
  hi Identifier cterm=none ctermfg=Cyan
  hi Normal     ctermfg=LightGrey ctermbg=Black guifg=LightGrey guibg=Black
  hi LineNr     ctermfg=White ctermbg=DarkBlue guifg=White guibg=DarkBlue
  hi Folded     ctermfg=LightCyan ctermbg=DarkBlue guifg=Cyan guibg=DarkBlue
  hi FoldColumn ctermfg=LightCyan ctermbg=DarkBlue guifg=Cyan guibg=DarkBlue
  hi PmenuSel   ctermfg=White ctermbg=DarkBlue
  hi Pmenu      ctermfg=Grey  ctermbg=DarkMagenta
  hi Todo       ctermfg=White ctermbg=Black
  hi Comment    term=bold ctermfg=DarkCyan guifg=DarkCyan
" hi Label      term=bold ctermfg=DarkMagenta guifg=DarkMagenta
  hi SpecialKey ctermfg=DarkGrey guifg=DimGrey
  if version >= 700
    hi Visual     ctermbg=DarkMagenta cterm=none
    hi VisualNOS  ctermbg=DarkRed     cterm=none guibg=DarkRed gui=none
  endif
  "hi TabLine    term=underline cterm=underline gui=underline guibg=NONE
  "hi TabLineSel term=bold cterm=bold gui=bold
  if &t_Co > 8
    hi StatusLine term=bold,reverse ctermbg=White ctermfg=Black cterm=none guifg=White
    hi StatusLineNC term=reverse ctermbg=Grey ctermfg=Black cterm=none guifg=White
  elseif &t_Co > 2
    hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=White ctermbg=Black guifg=White
    hi StatusLineNC term=reverse cterm=reverse ctermfg=Grey guifg=White
  endif
  hi SpellLocal  ctermbg=DarkGreen
  hi SpellErrors ctermfg=LightRed guifg=Red cterm=underline gui=underline term=reverse
  hi MatchParen  term=reverse ctermbg=DarkBlue guibg=DarkCyan
  " }}}1
endif
" vim:set ft=vim sts=2 sw=2:
