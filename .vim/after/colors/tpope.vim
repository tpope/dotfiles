" Vim color file
" File:         ~/.vim/colors/tim.vim
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2011 May 02

if v:version > 600
  hi clear
endif
if exists("syntax_on")
  syntax reset
endif

let colors_name = "tpope"

hi Type        gui=none
hi Statement   gui=none
hi Search NONE gui=underline term=underline cterm=underline
hi QuickfixLine NONE gui=underline term=underline cterm=underline

hi link rubyBlockParameter  NONE
hi TabLineFill NONE
hi! link TabLineFill TabLine

if &background=="light"
  " Section: Light Background {{{1
  " ------------------------------
  hi Normal     term=reverse ctermfg=Black ctermbg=White guifg=Black guibg=White
  hi LineNr     ctermfg=Black ctermbg=LightGrey guifg=Black guibg=LightGrey
  hi Folded     ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi FoldColumn ctermfg=DarkBlue ctermbg=LightGrey guifg=DarkBlue guibg=LightGrey
  hi PmenuSel   ctermfg=Black ctermbg=LightCyan
  hi Comment    term=bold ctermfg=Blue guifg=Blue
  hi SpecialKey ctermfg=LightGrey guifg=Grey
  if v:version >= 700
    " hi Visual     ctermbg=LightMagenta cterm=none
    hi VisualNOS  ctermbg=LightRed     cterm=none guibg=LightRed gui=none
  endif
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
  hi SpecialKey ctermfg=DarkGrey guifg=DimGrey
  if v:version >= 700
    hi Visual     ctermbg=DarkMagenta cterm=none
    hi VisualNOS  ctermbg=DarkRed     cterm=none guibg=DarkRed gui=none
  endif
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
  hi DiffChange guibg=#5f005f
  hi DiffAdd    guibg=#00005f
  hi DiffRemove guibg=#005f5f
  hi DiffText   guibg=#5f0000
  if &t_Co == 256
    hi DiffChange ctermbg=53
    hi DiffAdd    ctermbg=17
    hi DiffDelete ctermbg=23
    hi DiffText   ctermbg=52
  endif
  " }}}1
endif
" vim:set ft=vim sts=2 sw=2:
