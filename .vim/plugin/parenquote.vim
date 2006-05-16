" Vim plugin to create parenthesizing, bracketing, and quoting operators
" Maintainer:   Tim Pope <vim@tpope.info>
" Last Change:  2006 May 10
" $Id$

" This plugin uses Vim 7's new |:map-operator| feature to create mappings for
" enquoting and parenthesizing text.  Pick your desired operation and follow
" it with any motion of your choosing.  For example, to parenthesize from the
" cursor to the end of the line, use \($ .  To quote the word under the
" cursor, you can do \"iw .
"
" There are also visual mode mappings: V\{ puts the whole line in { }.  It
" works by entering visual line mode (thus selecting the entire line), and
" then activating the mapping.  These visual mode mappings are available in
" older versions of Vim, too.
"
" The default mappings are as follows (<Leader> is typically backslash):
"
"  <Leader>( => (text)
"  <Leader>{ => {text}
"  <Leader>[ => [text]
"  <Leader>< => <text>
"  <Leader>' => 'text'
"  <Leader>" => "text"
"  <Leader>` => `text`
"
" To disable the built-in mappings, put the following in your .vimrc:
"
"  let g:parenquote_no_mappings = 1
"
" Creating your own mappings is simple.  Create a new file called
" ~/.vim/after/plugins/parenquote.vim and put your mappings in it.  To create
" a g< mapping to enclose text <like this>, you add something like the
" following:
"
"  ParenquoteMap g< < >
"
" Of course, g< could actually become a a built-in vim command sometime in the
" future, so you might not want to use that.  Instead, you can start your
" mappings with <Leader>.  A handy shortcut for this is provided.  Both of the
" following produce a <Leader>/ mapping for creating regexes:
"
"  ParenquoteMap <Leader>/ / /
"  ParenquoteMap!        / / /
"
" You can also create mappings local to a buffer.  This is most useful in
" autocmds.
"
"  autocmd FileType perl,ruby ParenquoteMapLocal <LocalLeader>/ / /
"  autocmd FileType perl,ruby ParenquoteMapLocal!             / / /
"
" Remember, this plugin is still in development and the interface is subject
" to change.  Good luck and enjoy parenquote!

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if exists("g:loaded_parenquote") || &cp
  finish
endif
let g:loaded_parenquote = 1

function! <SID>DoSurround(type,beg,end)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@
  let common_end = "`>a" . a:end . "\<Esc>`<i" . a:beg . "\<Esc>`["
  if strlen(a:type) == 1  " Invoked from Visual mode
    silent exe "normal! " . common_end
  elseif a:type == 'line'
    silent exe "normal! '[V']V" . common_end
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]\<C-V>" . common_end
  else
    silent exe "normal! `[v`]v" . common_end
  endif
  let &selection = sel_save
  let @@ = reg_save
endfunction

function! s:escstr(str)
  return substitute(a:str,"[\\\"]","\\\\\\0","g")
endfunction

if !exists("s:parenID")
  let s:parenID = 0
endif

function! s:ParenquoteMap(bang,map,beg,end)
  let s:parenID += 1
  let funcname = "<SID>ParenFunc" . s:parenID
  if a:bang
    let amap = "<Leader>" . a:map
  else
    let amap = a:map
  endif
  silent exe "normal! :function! ".funcname."(type)\<CR>".
        \"call <SID>DoSurround(a:type,\"".s:escstr(a:beg)."\",\"".s:escstr(a:end)."\")\<CR>".
        \"endfunction\<CR>"
  if version>=700
    exe "nnoremap <silent> ".amap." :set opfunc=".funcname."<CR>g@"
  endif
exe "vnoremap <silent> ".amap." :<C-U>call ".funcname."(visualmode())<CR>"
endfunction

function! s:ParenquoteMapLocal(bang,map,beg,end)
  let s:parenID += 1
  let funcname = "<SID>ParenFunc" . s:parenID
  if a:bang
    let amap = "<LocalLeader>" . a:map
  else
    let amap = a:map
  endif
  silent exe "normal! :function! ".funcname."(type)\<CR>".
        \"call <SID>DoSurround(a:type,\"".s:escstr(a:beg)."\",\"".s:escstr(a:end)."\")\<CR>".
        \"endfunction\<CR>"
  if version>=700
    exe "nnoremap <silent> <buffer> ".amap." :set opfunc=".funcname."<CR>g@"
  endif
  exe "vnoremap <silent> <buffer> ".amap." :<C-U>call ".funcname."(visualmode())<CR>"
endfunction
command! -bang -nargs=+ ParenquoteMap call s:ParenquoteMap(<bang>0,<f-args>)
command! -bang -nargs=+ ParenquoteMapLocal call s:ParenquoteMapLocal(<bang>0,<f-args>)

if !exists("g:parenquote_no_mappings")
  ParenquoteMap! ( ( )
  ParenquoteMap! { { }
" } "<-- Syntax highlighting fix
  ParenquoteMap! [ [ ]
  ParenquoteMap! < < >
  ParenquoteMap! ' ' '
  ParenquoteMap! " " "
  ParenquoteMap! ` ` `
endif

" vim:set sw=2 sts=2:
