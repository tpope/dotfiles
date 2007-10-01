" Vim syntax file
" Language:     C (TI calculator specific)
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2005 Dec 07

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

runtime! syntax/c.vim
unlet b:current_syntax
runtime! syntax/ti89call.vim

let b:current_syntax = "c89"
