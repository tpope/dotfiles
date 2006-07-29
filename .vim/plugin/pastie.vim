" pastie.vim: Vim plugin for pastie.caboo.se
" Maintainer: Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" Installation: #!!
" Place in ~/.vim/plugin or vimfiles/plugin
" A working ruby install is required (Vim interface not necessary).

" Usage: #!!
" :Pastie creates a new paste (example arguments shown below).  Use :w to save
" it by posting it to the server.  This updates the filename and stores the
" new url in the primary selection/clipboard when successful.  :Pastie!
" creates a paste, saves, and closes the buffer, except when loading an
" existing paste.

" :Pastie                   Create a paste from all open windows
" :Pastie!                  Create a paste from all open windows and paste it
" :1,10Pastie               Create a paste from the specified range
" :%Pastie                  Use the entire current file to create a new paste
" :Pastie foo.txt bar.txt   Create a paste from foo.txt and bar.txt
" :Pastie! foo.txt          Paste directly from foo.txt
" :Pastie a                 Create a paste from the "a register
" :Pastie @                 Create a paste from the default (unnamed) register
" :Pastie *                 Create a paste from the primary selection/clipboard
" :Pastie _                 Create a new, blank paste
" :768Pastie                Load existing paste 768
" :0Pastie                  Load the newest paste

" Regardless of the command used, on the first write, this script will create
" a new paste, and on subsequent writes, it will update the existing paste.
" If a bang is passed to a command that load an existing paste (:768), the
" first write will update as well.  If the loaded paste was not created in the
" same vim session, updates will almost certainly silently fail.  (Advanced
" users can muck around with g:pastie_session_id if desired).

" At the shell you can directly create a new pastie with a command like
" $ vim +Pastie
" or, assuming no other plugins conflict
" $ vim +Pa
" And, to read an existing paste
" $ vim +768Pa
" You could even paste a file directly
" $ vim '+Pa!~/.irbrc' +q

" Lines ending in #!! will be sent as lines beginning with !!.  This alternate
" format is easier to read and is less likely to interfere with code
" execution.  In Vim 7 highlighting is done with :2match (use ":2match none"
" to disable it) and in previous versions, :match (use ":match none" to
" disable).

if exists("g:loaded_pastie") || &cp
    finish
endif
let g:loaded_pastie = 1

augroup pastie
    autocmd!
    autocmd BufReadPost http://pastie.caboo.se/*[0-9]/download call s:PastieRead(expand("<amatch>"))
    autocmd BufReadPost http://pastie.caboo.se/*[0-9]/text     call s:PastieRead(expand("<amatch>"))
    autocmd BufWriteCmd http://pastie.caboo.se/*[0-9]/download call s:PastieWrite(expand("<amatch>"))
    autocmd BufWriteCmd http://pastie.caboo.se/*[0-9]/text     call s:PastieWrite(expand("<amatch>"))
    autocmd BufWriteCmd http://pastie.caboo.se/paste*          call s:PastieWrite(expand("<amatch>"))
augroup END

let s:domain = "pastie.caboo.se"

let s:dl_suffix = "/text" " Used only for :file

if !exists("g:pastie_destination")
    if version >= 700
        let g:pastie_destination = 'tab'
    else
        let g:pastie_destination = 'window'
    endif
    "let g:pastie_destination = 'buffer'
endif

command! -bar -bang -nargs=* -range=0 -complete=file Pastie :call s:Pastie(<bang>0,<line1>,<line2>,<count>,<f-args>)

function! s:Pastie(bang,line1,line2,count,...)
    let newfile = "http://".s:domain."/paste/"
    let ft = &ft
    let num = 0
    if a:0 == 0 && a:count == a:line1 && a:count > line('$')
        let num = a:count
    elseif a:0 == 1 && a:1 =~ '^\d\d+$' && !a:count
        let num = a:1
    elseif a:0 == 0 && a:line1 == 0 && a:line2 == 0
        let num = s:latestid()
        if num == 0
            return s:error("Could not determine latest paste")
        endif
    endif
    if num
        call s:newwindow()
        let file = "http://".s:domain."/".num.s:dl_suffix
        silent exe 'doautocmd BufReadPre '.file
        silent exe 'read !ruby -rnet/http -e "Net::HTTP.get_print \%{'.s:domain.'}, \%{/'.num.'/download}"'
        if v:shell_error
            return s:error("Something went wrong: shell returned ".v:shell_error)
        else
            silent exe "file ".file
            1d_
            set nomodified
            call s:dobufreadpost()
            "call s:PastieRead(file)
            if a:bang
                " Instead of saving an identical paste, take ! to mean "do not
                " create a new paste on first save"
                let b:pastie_update = 1
            endif
            return
        endif
    elseif a:0 == 1 && !a:count && a:1 == '&'
        " Extract session id with :Pastie&
        call s:sessionid()
        if exists("g:pastie_session_id")
            echo g:pastie_session_id
            "silent! let @* = g:pastie_session_id
        endif
    elseif a:0 == 1 && !a:count && a:1 =~ '^&'
        " Set session id with :Pastie&deadbeefcafebabe
        let g:pastie_session_id = strpart(a:1,1)
    elseif a:0 == 0 && !a:count && a:line1
        let ft = 'conf'
        let sum = ""
        let cnt = 0
        let keep = @"
        windo let tmp = s:grabwin() | if tmp != "" | let cnt = cnt + 1 | let sum = sum . tmp | end
        let sum = substitute(sum,'\n\+$',"\n",'')
        if cnt == 1
            let ft = matchstr(sum,'^##.\{-\} \[\zs\w*\ze\]')
            if ft != ""
                let sum = substitute(sum,'^##.\{-\} \[\w*\]\n','','')
            endif
        endif
        call s:newwindow()
        silent exe "file ".newfile
        "silent exe "doautocmd BufReadPre ".newfile
        if sum != ""
            let @" = sum
            silent $put
            1d _
        endif
        if ft == 'plaintext'
            "set ft=conf
        elseif ft != ''
            let &ft = ft
        endif
        let @" = keep
        call s:dobufreadpost()
    else
        let keep = @"
        let args = ""
        if a:0 > 0 && a:1 =~ '^[-"@0-9a-zA-Z:.%#*+~_/]$'
            let i = 1
            let register = a:1
        else
            let i = 0
            let register = ""
        endif
        while i < a:0
            let i = i+1
            if strlen(a:{i})
                let file = fnamemodify(expand(a:{i}),':~:.')
                let args = args . file . "\n"
            endif
        endwhile
        let range = ""
        if a:count
            silent exe a:line1.",".a:line2."yank"
            let range = @"
            let @" = keep
        endif
        call s:newwindow()
        silent exe "file ".newfile
        "silent exe "doautocmd BufReadPre ".newfile
        if range != ""
            let &ft = ft
            let @" = range
            silent $put
        endif
        if register != '' && register != '_'
            silent exe "$put ".(register =~ '^[@"]$' ? '' : register)
        endif
        while args != ''
            let file = matchstr(args,'^.\{-\}\ze\n')
            let args = substitute(args,'^.\{-\}\n','','')
            let @" = "## ".file." [".s:parser(file)."]\n"
            if a:0 != 1 || a:count
                silent $put
            else
                if s:parser(file) !~ '^\%(plaintext\)\=$'
                    let &ft = s:parser(file)
                endif
            endif
            silent exe "$read ".substitute(file,' ','\ ','g')
        endwhile
        let @" = keep
        1d_
        call s:dobufreadpost()
        if (a:0 + (a:count > 0)) > 1
            set ft=conf
        endif
    endif
    1
    call s:afterload()
    if a:bang
        write
        silent! bdel
    endif
endfunction

function! s:dobufreadpost()
    if expand("%") =~ '/\d\+\.\@!'
        silent exe "doautocmd BufReadPost ".expand("%")
    else
        silent exe "doautocmd BufNewFile ".expand("%")
    endif
endfunction


function! s:PastieRead(file)
    let lnum = line(".")
    silent %s/^!!\(.*\)/\1 #!!/e
    exe lnum
    set nomodified
    let url = substitute(a:file,'\c/\%(download/\=\|text/\=\)\=$','','')
    let url = url."/download"
    let g:reading = url
    let result = system('ruby -rnet/http -e "puts Net::HTTP.get_response(URI.parse(%{'.url.'}))[%{Content-Disposition}]"')
    let fn = matchstr(result,'filename="\zs.*\ze"')
    let type = s:parser(fn)
    if type == 'plaintext'
        "set ft=conf
    else
        let &ft = type
    endif
    if &ft =~ '^\%(html\|ruby\)$' && getline(1).getline(2).getline(3) =~ '<%'
        setf eruby
    endif
    call s:afterload()
endfunction

function! s:afterload()
    set commentstring=%s\ #!!
    hi def link pastieIgnore    Ignore
    hi def link pastieNonText   NonText
    if exists(":match")
        hi def link pastieHighlight MatchParen
        if version >= 700
            2match pastieHighlight /^!!\s*.*\|^.\{-\}\ze\s*#!!\s*$/
        else
            match  pastieHighlight /^!!\s*.*\|^.\{-\}\ze\s*#!!\s*$/
        endif
    else
        hi def link pastieHighlight Search
        syn match pastieHighlight '^.\{-\}\ze\s*#!!\s*$' nextgroup=pastieIgnore skipwhite
        syn region pastieHighlight start='^!!\s*' end='$' contains=pastieNonText
    endif
    syn match pastieIgnore '#!!\ze\s*$' containedin=rubyComment,rubyString
    syn match pastieNonText '^!!' containedin=rubyString
endfunction

function! s:PastieWrite(file)
    let parser=s:parser(&ft)
    let tmp = tempname()
    let num = matchstr(a:file,'/\zs\d\+\.\@!')
    if num == ''
        let num = 'pastes'
    endif
    if exists("b:pastie_update") && s:sessionid() != ''
        let url = "/".num."/update"
    else
        let url = "/".num."/create"
    endif
    silent exe "write ".tmp
    let result = ""
    let rubycmd = 'print Net::HTTP.start(%{'.s:domain.'}){|h|h.post(%{'.url.'}, %q{paste[parser]='.parser.'&paste[body]=} + File.read(%q{'.tmp.'}).gsub(/^(.*?) *#!! *$/,%{!!}+92.chr+%{1}).gsub(/[^a-zA-Z0-9_.-]/n) {|s| %{%%%02x} % s[0]},{%{Cookie} => %{'.s:sessionid().'}})}[%{Location}]'
    let result = system('ruby -rnet/http -e "'.rubycmd.'"')
    call delete(tmp)
    if result =~ '^\w\+://'
        set nomodified
        let b:pastie_update = 1
        "silent! let @+ = result
        silent! let @* = result
        silent exe "file ".result.s:dl_suffix
        " TODO: make a proper status message
        echo '"'.result.'" written'
        silent exe "doautocmd BufWritePost ".result.s:dl_suffix
    else
        if result == 'nil'
            let result = "Could not post to ".url
        endif
        let result = substitute(result,'^-e:1:\s*','','')
        call s:error(result)
    endif
endfunction

function! s:error(msg)
    echohl Error
    echo a:msg
    echohl NONE
    let v:errmsg = a:msg
endfunction

function! s:parser(type)
    " Accepts a filename, extension, or vim filetype
    let type = tolower(substitute(a:type,'.*\.','',''))
    if type =~ '^\%(eruby\|x\=html\|php\|asp\w*\)$'
        return "html"
    elseif type =~ '^\%(ruby\|rb\|rake\|rxml\|rjs\|mab\|irbrc\)'
        return "ruby"
    elseif type == 'js' || type == 'javascript'
        return "javascript"
    elseif type == 'c' || type == 'cpp'
        return "c"
    elseif type == 'diff' || type == 'sql'
        return type
    else
        return "plaintext"
    endif
endfunction

function! s:grabwin()
    let ft = (&ft == '' ? expand("%:e") : &ft)
    let top = "## ".expand("%:~:.")." [".s:parser(ft)."]\n"
    let keep = @"
    silent %yank
    let file = @"
    let @" = keep
    if file == "" || file == "\n"
        return ""
    else
        return top.file."\n"
    endif
endfunction

function! PastieSessionID()
    return s:sessionid()
endfunction

function! s:sessionid()
    if exists("g:pastie_session_id")
        return "_session_id=".g:pastie_session_id
    else
        let cookie = system('ruby -rnet/http -e "print Net::HTTP.get_response(URI.parse(%{http://'.s:domain.'/}))[%{Set-Cookie}]"')
        let session_id = matchstr(cookie,'_session_id=\zs.\{-\}\ze\%(;\|$\)')
        if session_id != ""
            let g:pastie_session_id = session_id
            return "_session_id=".g:pastie_session_id
        else
            if !exists("s:session_warning")
                echohl WarningMsg
                echo "Warning: could not extract session id"
                let s:session_warning = 1
                echohl NONE
            endif
            return ""
        endif
    endif
endfunction

function! s:latestid()
    return system('ruby -rnet/http -e "print Net::HTTP.get_response(URI.parse(%{http://'.s:domain.'/all})).body.match(%r{<a href=.http://'.s:domain.'/(\d+).>View})[1]"')
endfunction

function! s:newwindow()
    if !(&modified) && (expand("%") == '' || (version >= 700 && winnr("$") == 1))
        enew
    else
        if g:pastie_destination == 'tab'
            tabnew
        elseif g:pastie_destination == 'window'
            new
        else
            enew
        endif
    endif
    setlocal noswapfile
endfunction

" vim:set sw=4 sts=4 et:
