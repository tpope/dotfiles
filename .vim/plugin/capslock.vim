" capslock.vim - Software Caps Lock
" Maintainer:   Tim Pope
" GetLatestVimScripts: 1725 1 :AutoInstall: capslock.vim
" $Id$

" This plugin enables a software caps lock.  This is advantageous over a
" regular caps lock in that normal mode commands, other buffers, and other
" applications are unaffected.
"
" The default insert mode mapping is <C-G>c, and there is no default normal
" mode mapping..  If you make frequent use of this feature, you will probably
" want to change this.  Try something like
"
"   imap <C-L>     <Plug>CapsLockToggle
"   nmap <Leader>l <Plug>CapsLockToggle
"
" Alternatively, enable the shorter insert mode mapping on a per-filetype
" basis:
"
"   autocmd FileType sql,cobol imap <buffer> <C-L> <Plug>CapsLockToggle
"
" <Plug>CapsLockEnable and <Plug>CapsLockDisable are also provided.
"
" One may prefer a normal mode mapping that enters insert mode and activates
" caps lock:
"
"   nmap <Leader>i i<Plug>CapsLockToggle
"
" By default, caps lock is automatically disabled after leaving insert mode
" for the insert mode mappings, but must be explicitly disabled for the normal
" mode mappings.  If you always want to use the latter method, make your
" insert mode mapping call the normal mode one.
"
"   imap <C-L> <C-O><Plug>CapsLockToggle
"
" Two functions, CapsLockStatusline() and CapsLockSTATUSLINE(), are provided
" for use inside %{} in your statusline.  These respectively return "[caps]"
" and ",CAPS" if the software caps lock is enabled.  Here's an example usage
" that won't cause problems if capslock.vim is missing:
"
"   set statusline=...%{exists('*CapsLockStatusline')?CapsLockStatusline():''}

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_capslock") && g:loaded_capslock) || &cp
    finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

" Uses for this should be rare, but if you :let the following variable, caps
" lock state should be tracked globally.  Largely untested, let me know if you
" have problems.
if exists('g:capslock_global')
    let s:buffer = ''
else
    let s:buffer = '<buffer>'
endif

function! s:enable(mode,...)
    let i = char2nr('A')
    while i <= char2nr('Z')
        exe a:mode."noremap" s:buffer nr2char(i) nr2char(i+32)
        exe a:mode."noremap" s:buffer nr2char(i+32) nr2char(i)
        let i = i + 1
    endwhile
    if a:0 && a:1
        if exists('g:capslock_global')
            let g:capslock_persist = 1
        else
            let b:capslock_persist = 1
        endif
    endif
    return ""
endfunction

function! s:disable(mode)
    if s:enabled(a:mode)
        let i = char2nr('A')
        while i <= char2nr('Z')
            silent! exe a:mode."unmap" s:buffer nr2char(i)
            silent! exe a:mode."unmap" s:buffer nr2char(i+32)
            let i = i + 1
        endwhile
    endif
    unlet! b:capslock_persist
    if exists('g:capslock_global')
        unlet! g:capslock_persist
    endif
    return ""
endfunction

function! s:toggle(mode,...)
    if s:enabled(a:mode)
        call s:disable(a:mode)
    else
        if a:0
            call s:enable(a:mode,a:1)
        else
            call s:enable(a:mode)
        endif
    endif
    return ""
endfunction

function! s:enabled(mode)
    return maparg('a',a:mode) == 'A'
endfunction

function! s:exitcallback()
    if !exists('g:capslock_persist') && !exists('b:capslock_persist') && s:enabled('i')
        call s:disable('i')
    endif
endfunction

function! CapsLockStatusline()
    if mode() == 'c' && s:enabled('c')
        " This won't actually fire because the statusline is apparently not
        " updated in command mode
        return '[(caps)]'
    elseif s:enabled('i')
        return '[caps]'
    else
        return ''
    endif
endfunction

function! CapsLockSTATUSLINE()
    if mode() == 'c' && s:enabled('c')
        return ',(CAPS)'
    elseif s:enabled('i')
        return ',CAPS'
    else
        return ''
    endif
endfunction

augroup capslock
    if v:version >= 700
        autocmd InsertLeave * call s:exitcallback()
    endif
    autocmd CursorHold  * call s:exitcallback()
augroup END

" }}}1
" Maps {{{1

noremap  <silent> <Plug>CapsLockToggle  :<C-U>call <SID>toggle('i',1)<CR>
noremap  <silent> <Plug>CapsLockEnable  :<C-U>call <SID>enable('i',1)<CR>
noremap  <silent> <Plug>CapsLockDisable :<C-U>call <SID>disable('i')<CR>
inoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('i')<CR>
inoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('i')<CR>
inoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('i')<CR>
cnoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('c')<CR>
cnoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('c')<CR>
cnoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('c')<CR>
cnoremap <silent>  <SID>CapsLockDisable <C-R>=<SID>disable('c')<CR>

if !hasmapto("<Plug>CapsLockToggle")
    imap <C-G>c <Plug>CapsLockToggle
endif

" Enable g:capslock_command_mode if you want capslock.vim to attempt to
" disable command mode caps lock after each :command.  This is hard to trap
" elegantly so it is disabled by default.  If you use this, you still must
" provide your own command mode mapping.
if exists('g:capslock_command_mode')
    map  <script> :    :<SID>CapsLockDisable
    map  <script> /    /<SID>CapsLockDisable
    map  <script> ?    ?<SID>CapsLockDisable
    "Sometimes breaks with <C-R>=
    "cmap <script> <CR>  <SID>CapsLockDisable<CR>
    " Breaks arrow keys
    "cmap <script> <Esc> <SID>CapsLockDisable<Esc>
endif

" }}}1

let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=8 sw=4 sts=4:
