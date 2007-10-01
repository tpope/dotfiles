" Vim syntax file
" Language:     A68k Assembler (TI calculator specific)
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2006 Jan 12

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
    endif
else
    runtime! syntax/asm68a.vim
    unlet b:current_syntax
    runtime! syntax/ti89call.vim
endif

let b:current_syntax = "asm68a89"
