" allml.vim - useful XML/HTML mappings
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" These are my personal mappings for XML/XHTML editing, particularly with
" dynamic content like PHP/ERb.  Examples shown are for ERb.
"
" If the binding is pressed on the end of a line consisting of "foo"
"
" Binding       Changed to   (cursor = ^)
" <C-X>=        foo<%= ^ %>
" <C-X>+        <%= foo^ %>
" <C-X>-        foo<% ^ %>
" <C-X>_        <% foo^ %>
" <C-X>'        foo<%# ^ %>
" <C-X>"        <%# foo^ %>
" <C-X><Space>  <foo>^</foo>
" <C-X><CR>     <foo>\n^\n</foo>
" <C-X>/        Last HTML tag closed (requires Vim 7)

if has("autocmd")
    augroup <SID>allml
        autocmd!
        autocmd FileType html,xhtml,xml,wml,cf          call s:Init()
        autocmd FileType php,asp*,mason,eruby           call s:Init()
        autocmd FileType htmltt,tt2html,htmldjango,jsp  call s:Init()
    augroup END
endif

function! s:Init()
    inoremap <silent> <buffer> <SID>dtmenu  <C-R>=<SID>htmlEn()<CR><Lt>!DOCTYPE<C-X><C-O><C-R>=<SID>htmlDis()<CR><C-P>
    imap <silent> <buffer> <SID>xmlversion  <?xml version="1.0" encoding="<C-R>=toupper(<SID>charset())<CR>"?>
    inoremap      <buffer> <SID>htmltrans   <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    "inoremap      <buffer> <SID>htmlstrict  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    inoremap      <buffer> <SID>xhtmltrans  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    "inoremap      <buffer> <SID>xhtmlstrict <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    if &ft == 'xml'
        imap <script> <buffer> <SID>doctype <SID>xmlversion
    elseif &ft == 'xhtml' || &ft == 'eruby'
        imap <script> <buffer> <SID>doctype <SID>xhtmltrans
    else
        imap <script> <buffer> <SID>doctype <SID>htmltrans
    endif
    imap <script> <buffer> <C-X>! <SID>doctype
    if exists("+omnifunc")
        if &ft == 'xhtml' || &ft == 'eruby'
            imap <script> <buffer> <C-X>! <SID>dtmenu<C-N><C-N><C-N><C-N><C-N><C-N><C-N><C-N><C-N><C-N>
        elseif &ft != 'xml'
            imap <script> <buffer> <C-X>! <SID>dtmenu<C-N><C-N><C-N><C-N><C-N><C-N>
        endif
    endif
    imap <buffer> <C-X>& <SID>doctype<C-O>ohtml<C-X><CR>head<C-X><CR><C-X>#<Esc>otitle<C-X><Space><C-R>=expand('%:t:r')<CR><Esc>jobody<C-X><CR><Esc>cc
    imap <silent> <buffer> <C-X># <meta http-equiv="Content-Type" content="text/html; charset=<C-R>=<SID>charset()<CR>"<C-R>=<SID>closetag()<CR>
    "imap <buffer> <SID>Tmu meta http-equiv="Content-Type" content="text/html; charset=utf-8"
    "abbr <buffer> Tmu <SID>Tmu
    "abbr <buffer> Xmu <Lt><SID>Tmu />
    "abbr <buffer> Hmu <Lt><SID>Tmu>
    "map! <buffer> <SID>Tmi meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"
    "abbr <buffer> Tmi <SID>Tmi
    "abbr <buffer> Xmi <Lt><SID>Tmi />
    "abbr <buffer> Hmi <Lt><SID>Tmi>
    "map! <buffer> <SID>Thl html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"
    "abbr <buffer> Thl <SID>Thl
    "abbr <buffer> Xhl <Lt><SID>Thl>
    "map! <buffer> <C-X>h <Thl><CR></html><Esc>O
    if &ft == "eruby" && expand('%:p') =~ '\<app[\\/]views\>'
        inoremap <buffer> <silent> <C-X>@ <%= stylesheet_link_tag 'application' %><Left><Left><Left><Left><Left><Esc>ciw
        inoremap <buffer> <silent> <C-X>$ <%= javascript_include_tag :defaults %><Left><Left><Left><Left><Esc>ciW''<Left>
    else
        inoremap <buffer> <silent> <C-X>@ <link rel="stylesheet" type="text/css" href="/stylesheets/application.css"<C-R>=<SID>closetagback()<CR><Left><Left><Left><Left><Left><Esc>ciw
        inoremap <buffer> <silent> <C-X>$ <script type="text/javascript" src="/javascripts/application.js"><Lt>/script><Left><C-Left><Left><Left><Left><Left><Left><Left><Left><Esc>ciw
    endif
    inoremap <silent> <buffer> <C-X><Space> <Esc>ciw<Lt><C-R>"<C-R>=<SID>tagextras()<CR>></<C-R>"><Esc>b2hi
    inoremap <silent> <buffer> <C-X><CR> <Esc>ciw<Lt><C-R>"<C-R>=<SID>tagextras()<CR>><CR></<C-R>"><Esc>O
    "noremap! <silent> <buffer> <C-X>, <C-R>=<SID>closetagback()<CR>
    if exists("&omnifunc")
        inoremap <silent> <buffer> <C-X>/ <Lt>/<C-R>=<SID>htmlEn()<CR><C-X><C-O><C-R>=<SID>htmlDis()<CR><C-F>
        if exists(":XMLns")
            XMLns xhtml10s
        endif
    else
        inoremap <silent> <buffer> <C-X>/ <Lt>/><Left>
    endif
    map! <buffer> <C-X><C-_> <C-X>/
    imap <buffer> <SID>allmlOopen    <C-X><Lt><Space>
    imap <buffer> <SID>allmlOclose   <Space><C-X>><Left><Left>
    if &ft == "php"
        inoremap <buffer> <C-X><Lt> <?php
        inoremap <buffer> <C-X>>    ?>
        let b:surround_45 = "<?php \n ?>"
    elseif &ft == "htmltt" || &ft == "tt2html"
        inoremap <buffer> <C-X><Lt> [%
        inoremap <buffer> <C-X>>    %]
        let b:surround_45 = "[% \n %]"
    elseif &ft == "htmldjango"
        "inoremap <buffer> <SID>allmlOopen    {{
        "inoremap <buffer> <SID>allmlOclose   }}<Left>
        inoremap <buffer> <C-X><Lt> {{
        inoremap <buffer> <C-X>>    }}
        let b:surround_45 = "{{ \n }}"
    elseif &ft == "mason"
        inoremap <buffer> <SID>allmlOopen    <&<Space>
        inoremap <buffer> <SID>allmlOclose   <Space>&><Left><Left>
        inoremap <buffer> <C-X><Lt> <%
        inoremap <buffer> <C-X>>    %>
        let b:surround_45 = "<% \n %>"
        let b:surround_61 = "<& \n &>"
    elseif &ft == "cf"
        inoremap <buffer> <SID>allmlOopen    <cfoutput>
        inoremap <buffer> <SID>allmlOclose   </cfoutput><Left><C-Left><Left>
        inoremap <buffer> <C-X><Lt> <cf
        inoremap <buffer> <C-X>>    >
        let b:surround_45 = "<cf \n>"
        let b:surround_61 = "<cfoutput>\n</cfoutput>"
    else
        inoremap <buffer> <SID>allmlOopen    <%=<Space>
        inoremap <buffer> <C-X><Lt> <%
        inoremap <buffer> <C-X>>    %>
        let b:surround_45 = "<% \n %>"
        let b:surround_61 = "<%= \n %>"
    endif
    " <%= %>
    "if &ft == "cf"
        "inoremap <buffer> <C-X>= <cfoutput></cfoutput><Left><C-Left><Left><Left>
        "inoremap <buffer> <C-X>+ <C-V><NL><Esc>I<cfoutput><Esc>A</cfoutput><Esc>F<NL>s
    "else
        imap     <buffer> <C-X>= <SID>allmlOopen<SID>allmlOclose<Left>
        imap     <buffer> <C-X>+ <C-V><NL><Esc>I<SID>allmlOopen<Space><Esc>A<Space><SID>allmlOclose<Esc>F<NL>s
    "endif
    " <%\n\n%>
    if &ft == "cf"
        inoremap <buffer> <C-X>] <cfscript><CR></cfscript><Esc>O
    elseif &ft == "mason"
        inoremap <buffer> <C-X>] <%perl><CR></%perl><Esc>O
    elseif &ft == "html" || &ft == "xhtml" || &ft == "xml"
        imap     <buffer> <C-X>] <script<Space>type="text/javascript"><CR></script><Esc>O
    else
        imap     <buffer> <C-X>] <C-X><Lt><CR><C-X>><Esc>O
    endif
    " <% %>
    if &ft == "eruby"
        inoremap  <buffer> <C-X>- <%<Space><Space>-%><Esc>3hi
        inoremap  <buffer> <C-X>_ <C-V><NL><Esc>I<%<Space><Esc>A<Space>-%><Esc>F<NL>s
        let b:surround_61 = "<% \n -%>"
    elseif &ft == "cf"
        inoremap  <buffer> <C-X>- <cf><Left>
        inoremap  <buffer> <C-X>_ <cfset ><Left>
    else
        imap      <buffer> <C-X>- <C-X><Lt><Space><Space><C-X>><Esc>2hi
        imap      <buffer> <C-X>_ <C-V><NL><Esc>I<C-X><Lt><Space><Esc>A<Space><C-X>><Esc>F<NL>s
    endif
    " Comments
    if &ft =~ '^asp'
        imap     <buffer> <C-X>'     <C-X><Lt>'<Space><Space><C-X>><Esc>2hi
        imap     <buffer> <C-X>"     <C-V><NL><Esc>I<C-X><Lt>'<Space><Esc>A<Space><C-X>><Esc>F<NL>s
    elseif &ft == "jsp"
        inoremap <buffer> <C-X>'     <Lt>%--<Space><Space>--%><Esc>4hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<%--<Space><Esc>A<Space>--%><Esc>F<NL>s
    elseif &ft == "cf"
        inoremap <buffer> <C-X>'     <Lt>!---<Space><Space>---><Esc>4hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!---<Space><Esc>A<Space>---><Esc>F<NL>s
        setlocal commentstring=<!---%s--->
    elseif &ft == "html" || &ft == "xml" || &ft == "xhtml"
        inoremap <buffer> <C-X>'     <Lt>!--<Space><Space>--><Esc>3hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!--<Space><Esc>A<Space>--><Esc>F<NL>s
    else
        imap     <buffer> <C-X>'     <C-X><Lt>#<Space><Space><C-X>><Esc>2hi
        imap     <buffer> <C-X>"     <C-V><NL><Esc>I<C-X><Lt>#<Space><Esc>A<Space><C-X>><Esc>F<NL>s
    endif
    "map! <C-Z> <C-X>=
    if has("spell")
        setlocal spell
    endif
    if !exists("b:did_indent")
        if s:subtype() == "xml"
            runtime! indent/xml.vim
        else
            runtime! indent/html.vim
        endif
    endif
    if exists("g:html_indent_tags")
        let g:html_indent_tags = g:html_indent_tags.'\|p'
    endif
    set indentkeys+=!^F
    silent doautocmd User allml
endfunction

function! s:htmlEn()
    let b:allml_omni = &l:omnifunc
    setlocal omnifunc=htmlcomplete#CompleteTags
    return ""
endfunction

function! s:htmlDis()
    if exists("b:allml_omni")
        let &l:omnifunc = b:allml_omni
        unlet b:allml_omni
    endif
    return ""
endfunction

function s:subtype()
    let top = getline(1)."\n".getline(2)
    if top =~ '<?xml\>' || &ft == "xml"
        return "xml"
    elseif top =~? '\<xhtml\>'
        return 'xhtml'
    elseif top =~ '[^<]\<html\>'
        return "html"
    elseif &ft == "xhtml" || &ft == "eruby"
        return "xhtml"
    else
        return "html"
    endif
endfunction

function s:closetagback()
    if s:subtype() == "html"
        return ">\<Left>"
    else
        return " />\<Left>\<Left>\<Left>"
    endif
endfunction

function s:closetag()
    if s:subtype() == "html"
        return ">"
    else
        return " />"
    endif
endfunction

function s:charset()
    let enc = &fileencoding
    if enc == ""
        let enc = &encoding
    endif
    if enc == "latin1"
        return "ISO-8859-1"
    elseif enc == ""
        return "US-ASCII"
    else
        return enc
    endif
endfunction

function s:tagextras()
    if @" == "html" && s:subtype() == "xhtml"
        return ' xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"'
    elseif @" == 'style'
        return ' type="text/css"'
    elseif @" == 'script'
        return ' type="text/javascript"'
    else
        return ""
    endif
endfunction
