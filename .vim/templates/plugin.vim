" @FILENAME@ - @TITLE@
" Maintainer:   @AUTHOR_EMAIL@

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_@BASENAME@") && g:loaded_@BASENAME@) || &cp
    finish
endif
let g:loaded_@BASENAME@ = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1
@CURSOR@
" }}}1

let &cpo = s:cpo_save

" vim:set ft=vim ts=8 sw=4 sts=4:
