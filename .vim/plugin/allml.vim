" allml.vim - useful XML/HTML mappings
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" $Id$

" These are my personal mappings for XML/XHTML editing, particularly with
" dynamic content like PHP/ASP/ERb.  Examples shown are for ERb.
"
" If the binding is pressed on the end of a line consisting of "foo"
"
" Mapping       Changed to   (cursor = ^)
" <C-X>=        foo<%= ^ %>
" <C-X>+        <%= foo^ %>
" <C-X>-        foo<% ^ %>
" <C-X>_        <% foo^ %>
" <C-X>'        foo<%# ^ %>
" <C-X>"        <%# foo^ %>
" <C-X><Space>  <foo>^</foo>
" <C-X><CR>     <foo>\n^\n</foo>
" <C-X>/        Last HTML tag closed (requires Vim 7)
" <C-X>!        <!DOCTYPE...>/<?xml ...?> (Vim 7 allows selection from menu)
" <C-X>@        <link rel="stylesheet" type="text/css" href="/stylesheets/^.css" />
" <C-X>#        <meta http-equiv="Content-Type" ... />
" <C-X>$        <script type="text/javascript" src="/javascripts/^.css"></script>
"
" Combined with surround.vim, you also get three "replacements".  Below, the ^
" indicates the location of the wrapped text.  See the documentation of
" surround.vim for details.
"
" Character     Replacement
" -             <% ^ %>
" =             <%= ^ %>
" #             <%# ^ %>

if exists("g:loaded_allml") || &cp
    finish
endif
let g:loaded_allml = 1

if has("autocmd")
    augroup <SID>allml
        autocmd!
        autocmd FileType html,xhtml,xml,wml,cf          call s:Init()
        autocmd FileType php,asp*,mason,eruby           call s:Init()
        autocmd FileType htmltt,tt2html,htmldjango,jsp  call s:Init()
    augroup END
endif

"if maparg('<M-o>','i') == ''
    "inoremap <M-o> <Esc>o
"endif

function! s:Init()
    let b:surround_indent = 1
    "inoremap <silent> <buffer> <SID>dtmenu  <C-R>=<SID>htmlEn()<CR><Lt>!DOCTYPE<C-X><C-O><C-R>=<SID>htmlDis()<CR><C-P>
    imap <silent> <buffer> <SID>xmlversion  <?xml version="1.0" encoding="<C-R>=toupper(<SID>charset())<CR>"?>
    inoremap      <buffer> <SID>htmltrans   <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    "inoremap      <buffer> <SID>htmlstrict  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    inoremap      <buffer> <SID>xhtmltrans  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    "inoremap      <buffer> <SID>xhtmlstrict <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    if &ft == 'xml'
        imap <script> <buffer> <SID>doctype <SID>xmlversion
    elseif exists("+omnifunc")
        inoremap <silent> <buffer> <SID>doctype  <C-R>=<SID>htmlEn()<CR><!DOCTYPE<C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N><C-R>=<SID>doctypeSeek()<CR>
    elseif &ft == 'xhtml' || &ft == 'eruby'
        imap <script> <buffer> <SID>doctype <SID>xhtmltrans
    else
        imap <script> <buffer> <SID>doctype <SID>htmltrans
    endif
    imap <script> <buffer> <C-X>! <SID>doctype

    imap <buffer> <C-X>& <SID>doctype<C-O>ohtml<C-X><CR>head<C-X><CR><C-X>#<Esc>otitle<C-X><Space><C-R>=expand('%:t:r')<CR><Esc>jobody<C-X><CR><Esc>cc
    imap <silent> <buffer> <C-X># <meta http-equiv="Content-Type" content="text/html; charset=<C-R>=<SID>charset()<CR>"<C-R>=<SID>closetag()<CR>
    "map! <buffer> <SID>Thl html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"
    "abbr <buffer> Thl <SID>Thl
    "abbr <buffer> Xhl <Lt><SID>Thl>
    "map! <buffer> <C-X>h <Thl><CR></html><Esc>O
    inoremap <silent> <buffer> <SID>HtmlComplete <C-R>=<SID>htmlEn()<CR><C-X><C-O><C-P><C-R>=<SID>htmlDis()<CR><C-N>
    imap     <buffer> <C-X>H <SID>HtmlComplete
    inoremap <silent> <buffer> <C-X>$ <C-R>=<SID>javascriptIncludeTag()<CR>
    inoremap <silent> <buffer> <C-X>@ <C-R>=<SID>stylesheetTag()<CR>
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
    imap <buffer> <C-X><C-_> <C-X>/
    imap <buffer> <SID>allmlOopen    <C-X><Lt><Space>
    imap <buffer> <SID>allmlOclose   <Space><C-X>><Left><Left>
    if &ft == "php"
        inoremap <buffer> <C-X><Lt> <?php
        inoremap <buffer> <C-X>>    ?>
        inoremap <buffer> <SID>allmlOopen    <?php<Space>print<Space>
        let b:surround_45 = "<?php \r ?>"
        let b:surround_61 = "<?php print \r ?>"
    elseif &ft == "htmltt" || &ft == "tt2html"
        inoremap <buffer> <C-X><Lt> [%
        inoremap <buffer> <C-X>>    %]
        let b:surround_45 = "[% \r %]"
        let b:surround_61 = "[% \r %]"
    elseif &ft == "htmldjango"
        "inoremap <buffer> <SID>allmlOopen    {{
        "inoremap <buffer> <SID>allmlOclose   }}<Left>
        inoremap <buffer> <C-X><Lt> {{
        inoremap <buffer> <C-X>>    }}
        let b:surround_45 = "{{ \r }}"
        let b:surround_61 = "{{ \r }}"
    elseif &ft == "mason"
        inoremap <buffer> <SID>allmlOopen    <&<Space>
        inoremap <buffer> <SID>allmlOclose   <Space>&><Left><Left>
        inoremap <buffer> <C-X><Lt> <%
        inoremap <buffer> <C-X>>    %>
        let b:surround_45 = "<% \r %>"
        let b:surround_61 = "<& \r &>"
    elseif &ft == "cf"
        inoremap <buffer> <SID>allmlOopen    <cfoutput>
        inoremap <buffer> <SID>allmlOclose   </cfoutput><Left><C-Left><Left>
        inoremap <buffer> <C-X><Lt> <cf
        inoremap <buffer> <C-X>>    >
        let b:surround_45 = "<cf\r>"
        let b:surround_61 = "<cfoutput>\r</cfoutput>"
    else
        inoremap <buffer> <SID>allmlOopen    <%=<Space>
        inoremap <buffer> <C-X><Lt> <%
        inoremap <buffer> <C-X>>    %>
        let b:surround_45 = "<% \r %>"
        let b:surround_61 = "<%= \r %>"
    endif
    imap     <buffer> <C-X>= <SID>allmlOopen<SID>allmlOclose<Left>
    imap     <buffer> <C-X>+ <C-V><NL><Esc>I<SID>allmlOopen<Space><Esc>A<Space><SID>allmlOclose<Esc>F<NL>s
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
        let b:surround_45 = "<% \r -%>"
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
        let b:surround_35 = maparg("<C-X><Lt>","i")."' \r ".maparg("<C-X>>","i")
    elseif &ft == "jsp"
        inoremap <buffer> <C-X>'     <Lt>%--<Space><Space>--%><Esc>4hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<%--<Space><Esc>A<Space>--%><Esc>F<NL>s
        let b:surround_35 = "<%-- \r --%>"
    elseif &ft == "cf"
        inoremap <buffer> <C-X>'     <Lt>!---<Space><Space>---><Esc>4hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!---<Space><Esc>A<Space>---><Esc>F<NL>s
        setlocal commentstring=<!---%s--->
        let b:surround_35 = "<!--- \r --->"
    elseif &ft == "html" || &ft == "xml" || &ft == "xhtml"
        inoremap <buffer> <C-X>'     <Lt>!--<Space><Space>--><Esc>3hi
        inoremap <buffer> <C-X>"     <C-V><NL><Esc>I<!--<Space><Esc>A<Space>--><Esc>F<NL>s
        let b:surround_35 = "<!-- \r -->"
    else
        imap     <buffer> <C-X>'     <C-X><Lt>#<Space><Space><C-X>><Esc>2hi
        imap     <buffer> <C-X>"     <C-V><NL><Esc>I<C-X><Lt>#<Space><Esc>A<Space><C-X>><Esc>F<NL>s
        let b:surround_35 = maparg("<C-X><Lt>","i")."# \r ".maparg("<C-X>>","i")
    endif
    "if has("spell")
        "setlocal spell
    "endif
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

function! s:length(str)
    return strlen(substitute(a:str,'.','.','g'))
endfunction

function! s:repeat(str,cnt)
    let cnt = a:cnt
    let str = ""
    while cnt > 0
        let str = str . a:str
        let cnt = cnt - 1
    endwhile
    return str
endfunction

function! s:doctypeSeek()
    if !exists("b:allml_doctype_index")
        if &ft == 'xhtml' || &ft == 'eruby'
            let b:allml_doctype_index = 10
        elseif &ft != 'xml'
            let b:allml_doctype_index = 6
        endif
    endif
    let index = b:allml_doctype_index - 1
    return (index < 0 ? s:repeat("\<C-P>",-index) : s:repeat("\<C-N>",index))
endfunction

function! s:stylesheetTag()
    if !exists("b:allml_stylesheet_link_tag")
        if &ft == "eruby" && expand('%:p') =~ '\<app[\\/]views\>'
            " This will ultimately be factored into rails.vim
            let b:allml_stylesheet_link_tag = "<%= stylesheet_link_tag '\r' %>"
        else
            let b:allml_stylesheet_link_tag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/\r.css\" />"
        endif
    endif
    return s:insertTag(b:allml_stylesheet_link_tag)
endfunction

function! s:javascriptIncludeTag()
    if !exists("b:allml_javascript_include_tag")
        if &ft == "eruby" && expand('%:p') =~ '\<app[\\/]views\>'
            " This will ultimately be factored into rails.vim
             let b:allml_javascript_include_tag = "<%= javascript_include_tag :\rdefaults\r %>"
         else
             let b:allml_javascript_include_tag = "<script type=\"text/javascript\" src=\"/javascripts/\r.js\"></script>"
        endif
    endif
    return s:insertTag(b:allml_javascript_include_tag)
endfunction

function! s:insertTag(tag)
    let tag = a:tag
    if s:subtype() == "html"
        let tag = substitute(a:tag,'\s*/>','>','g')
    endif
    let before = matchstr(tag,'^.\{-\}\ze\r')
    let after  = matchstr(tag,'\r\zs\%(.*\r\)\@!.\{-\}$')
    " middle isn't currently used
    let middle = matchstr(tag,'\r\zs.\{-\}\ze\r')
    return before.after.s:repeat("\<Left>",s:length(after))
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

function! s:subtype()
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

function! s:closetagback()
    if s:subtype() == "html"
        return ">\<Left>"
    else
        return " />\<Left>\<Left>\<Left>"
    endif
endfunction

function! s:closetag()
    if s:subtype() == "html"
        return ">"
    else
        return " />"
    endif
endfunction

function! s:charset()
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

function! s:tagextras()
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
