" Vim syntax file
" Language:     @TITLE@
" Maintainer:   @AUTHOR_EMAIL@
" Filenames:    *.@BASENAME@

if exists("b:current_syntax")
    finish
endif

syn case ignore

syn region  @BASENAME@String   start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match   @BASENAME@Comment  "#.*"
@CURSOR@

hi def link @BASENAME@Comment           Comment
hi def link @BASENAME@String            String

let b:current_syntax = "@BASENAME@"

" vim:set sts=4 sw=4:
