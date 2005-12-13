" Vim syntax file
" Language:     Simpsons episode capsule
" Maintainer:   Tim Pope <vim@rebelongto.us>
" Last Change:  2005 Dec 13
" URL:          http://www.sexygeek.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/syntax/simpsons.vim
" $Id$

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn case ignore

syn match simpsonsProdCode              "\(MG\|\d[FG]\|[A-Z]ABF\)\d\d"
syn match simpsonsContributor           "{\w\{2,4\}}"

syn region simpsonsDesc                 start="^-- " end="^$"

syn match simpsonsDivider               "^=\+$"
syn match simpsonsComment               "^%.*"
syn match simpsonsSection               "^>.*" contains=simpsonsContributor,simponsProdCode

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_router_syn_inits")
    if version < 508
        let did_router_syn_inits = 1
        command -nargs=+ HiLink hi link <args>
    else
        command -nargs=+ HiLink hi def link <args>
    endif

    HiLink simpsonsDesc         Statement
    HiLink simpsonsProdCode     Number
    HiLink simpsonsDivider      PreProc
    HiLink simpsonsSection      Type
    HiLink simpsonsComment      Comment
    HiLink simpsonsString       String
    HiLink simpsonsContributor  Identifier
    delcommand HiLink
endif

let b:current_syntax = "simpsons"

" vim:set ft=vim sts=4 sw=4:
