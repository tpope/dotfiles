" Vim syntax file
" Language:     A68k Assembler (TI calculator specific)
" Maintainer:   Tim Pope <vim@rebelongto.us>
" URL:          http://www.sexygeek.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/syntax/asm68a89.vim
" Last Change:  2005 Dec 07
" Version:      $Id$

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

if version < 600
    source <sfile>:p:h/asm68a.vim
    unlet b:current_syntax
    if filereadable(expand("<sfile>:p:h/ti89call.vim"))
        source <sfile>:p:h/ti89call.vim
    end if
else
    runtime! syntax/asm68a.vim
    unlet b:current_syntax
    runtime! syntax/ti89call.vim
endif

let b:current_syntax = "asm68a89"
