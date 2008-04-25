" flatfoot.vim - Flatfoot
" Maintainer:   Tim Pope

" Flatfoot helps you to quickly jump to arbitrary predefined short patterns
" within a line.  An example might be to jump between the "humps" of a
" camelCaseWord.  The interface involves passing f, t, F, or T a control
" character which corresponds to a predefiend regexp.  The ; and , commands
" will use this regexp as one would expect.
"
" A global variable named flatfoot_1 contains the regexp for CTRL-A, and
" flatfoot_26 CTRL-Z.  In other words, the decimal ASCII value of the key
" press becomes the number at the end of the variable.  For example,
"
"   :let flatfoot_21 = '\u'
"
" sets CTRL-U to find the next uppercase character.  CTRL-U comes predefined
" for this, and CTRL-W and CTRL-E comes predefined to handle the beginning and
" ending of camelCase and snake_case words.
"
" If you like the power of this plugin but don't like the awkward use of
" control characters, the following alternate (but discouraged) alternative is
" provided:
"
"   nmap <silent><expr> <Leader>u Flatfoot('f','\u')
"   xmap <silent><expr> <Leader>u Flatfoot('f','\u')
"   omap <silent><expr> <Leader>u Flatfoot('f','\u','o')
"
" The first argument is the kind of search to use (f, t, F, or T), and the
" second is the pattern.  The optional third argument indicates the mode.
" Since there is no way to detect operator pending mode, you MUST provide
" both a regular map and an omap, as shown above.

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
" - the version is less than 7.0
if (exists("g:loaded_flatfoot") && g:loaded_flatfoot) || &cp || v:version < 700
    finish
endif
let g:loaded_flatfoot = 1

let s:cpo_save = &cpo
set cpo&vim

" Defaults {{{1

if !exists("g:flatfoot_".char2nr("\<C-U>"))
    let flatfoot_{char2nr("\<C-U>")} = '\u'
endif
if !exists("g:flatfoot_".char2nr("\<C-W>"))
    let flatfoot_{char2nr("\<C-W>")} = '\C[[:alnum:]]\@<![[:alnum:]]\|[^[:upper:]]\@<=[[:upper:]]\|[[:upper:]][[:lower:]]\@='
endif
if !exists("g:flatfoot_".char2nr("\<C-E>"))
    let flatfoot_{char2nr("\<C-E>")} = '\C[[:alnum:]][[:alnum:]]\@!\|[[:lower:][:digit:]][[:upper:]]\@=\|[[:upper:]]\%([[:upper:]][[:lower:]]\)\@='
endif

" }}}1
" Code {{{1

function! s:escapemode(mode)
    let mode = a:mode == "" ? mode() : a:mode
    let mode = mode == "\<C-V>" ? "\<C-V>" . mode : mode
    return mode
endfunction

function! Flatfoot(op,pattern,...)
    let mode = s:escapemode(a:0 ? a:1 : mode())
    return ''.":\<C-U>call FlatfootFindPattern(".string(a:op).",".string(a:pattern).",'".mode."')\<CR>"
endfunction

function! s:findexpr(op,mode,...)
    let c = a:0 ? a:1 : getchar()
    if !exists("g:flatfoot_".c) && !exists("b:flatfoot_".c)
        unlet! s:last_pattern
        unlet! s:last_reverse
        return a:op.nr2char(c)
    endif
    let mode = s:escapemode(a:mode)
    return ''.":\<C-U>call FlatfootFindChar('".a:op."',".c.",'".mode."')\<CR>"
endfunction

function! FlatfootFindChar(op,c,mode)
    let pat = exists("b:flatfoot_".a:c) ? b:flatfoot_{a:c} : g:flatfoot_{a:c}
    return FlatfootFindPattern(a:op,pat,a:mode)
endfunction

function! FlatfootFindPattern(op,pattern,mode)
    let pattern = a:pattern
    let reverse = ''
    if a:op ==# 't'
        let pattern = '.\%(' . pattern . '\)'
    elseif a:op ==# 'T'
        let pattern = '\%(' . pattern . '\)\zs.'
        let reverse = 'b'
    elseif a:op ==# 'F'
        let reverse = 'b'
    endif
    let s:last_pattern = pattern
    let s:last_reverse = reverse
    return s:go(pattern, reverse, v:count1, a:mode)
endfunction


function! s:repeatexpr(op,mode)
    let mode = s:escapemode(a:mode)
    if exists("s:last_pattern")
        return ''.":\<C-U>call FlatfootFindLast('".a:op."','".mode."')\<CR>"
    else
        return a:op
    endif
endfunction

function! FlatfootFindLast(op,mode)
    if a:op == ","
        let reverse = s:last_reverse ==# 'b' ? '' : 'b'
    else
        let reverse = s:last_reverse
    endif
    return s:go(s:last_pattern, reverse, v:count1, a:mode)
endfunction

function! s:adjustmode(mode)
    if a:mode ==? "v" || a:mode == "\<C-V>"
        norm! gv
    elseif a:mode == "o"
        norm! v
    endif
endfunction

function! s:go(pattern,reverse,count,mode)
    call s:adjustmode(a:mode)
    "let g:debug = v:count1 . a:pattern . a:reverse . col('.')
    let oldcol = virtcol('.')
    let i = 0
    while i < v:count1
        if !search(a:pattern,a:reverse,line('.'))
            exe "norm! ".oldcol."|"
            " Use escape to beep, but don't cancel visual mode
            if a:mode !=? "v" && a:mode != "\<C-V>"
                exe "norm! \<Esc>"
            endif
            return 0
        endif
        let i = i + 1
    endwhile
    return col('.')
endfunction

" }}}1
" Maps {{{1

nnoremap <silent> <expr> <SID>f <SID>findexpr('f',mode(),getchar())
nnoremap <silent> <expr> <SID>F <SID>findexpr('F',mode(),getchar())
nnoremap <silent> <expr> <SID>t <SID>findexpr('t',mode(),getchar())
nnoremap <silent> <expr> <SID>T <SID>findexpr('T',mode(),getchar())
nnoremap <silent> <expr> <SID>; <SID>repeatexpr(';',mode())
nnoremap <silent> <expr> <SID>, <SID>repeatexpr(',',mode())
xnoremap <silent> <expr> <SID>f <SID>findexpr('f',mode(),getchar())
xnoremap <silent> <expr> <SID>F <SID>findexpr('F',mode(),getchar())
xnoremap <silent> <expr> <SID>t <SID>findexpr('t',mode(),getchar())
xnoremap <silent> <expr> <SID>T <SID>findexpr('T',mode(),getchar())
xnoremap <silent> <expr> <SID>; <SID>repeatexpr(';',mode())
xnoremap <silent> <expr> <SID>, <SID>repeatexpr(',',mode())
onoremap <silent> <expr> <SID>f <SID>findexpr('f','o',getchar())
onoremap <silent> <expr> <SID>F <SID>findexpr('F','o',getchar())
onoremap <silent> <expr> <SID>t <SID>findexpr('t','o',getchar())
onoremap <silent> <expr> <SID>T <SID>findexpr('T','o',getchar())
onoremap <silent> <expr> <SID>; <SID>repeatexpr(';','o')
onoremap <silent> <expr> <SID>, <SID>repeatexpr(',','o')

nnoremap  <silent> <script> f <SID>f
nnoremap  <silent> <script> F <SID>F
nnoremap  <silent> <script> t <SID>t
nnoremap  <silent> <script> T <SID>T
nnoremap  <silent> <script> ; <SID>;
nnoremap  <silent> <script> , <SID>,
xnoremap  <silent> <script> f <SID>f
xnoremap  <silent> <script> F <SID>F
xnoremap  <silent> <script> t <SID>t
xnoremap  <silent> <script> T <SID>T
xnoremap  <silent> <script> ; <SID>;
xnoremap  <silent> <script> , <SID>,
onoremap  <silent> <script> f <SID>f
onoremap  <silent> <script> F <SID>F
onoremap  <silent> <script> t <SID>t
onoremap  <silent> <script> T <SID>T
onoremap  <silent> <script> ; <SID>;
onoremap  <silent> <script> , <SID>,

" }}}1

let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=8 sw=4 sts=4:
