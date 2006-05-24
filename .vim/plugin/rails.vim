" rails.vim - Detect a rails application
" Author:       Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2006 May 23
" $Id$

" The goals of this plugin are as follows:
"
" 1. Automatically detect buffers containing files from Rails applications, and
" apply settings to those buffers (and only those buffers).
"
" 2. Be as unobtrusive as possible.  It should gracefully cope with older Vim
" versions.  Error messages should be limited to those useful to the end user.
"
" 3. Provide reasonable settings for working with Rails applications.
"
" 4. Ease navigation of the Rails directory structure.
"
" Installation
"
" Copy rails.vim to your plugin directory.
"
" Usage
"
" Whenever you edit a file in a Rails application, this plugin will be
" automatically activated.  This sets various options (including shiftwidth=2,
" a strong Rails convention) and defines a few commands.
"
" Examples
"
" Invoke tests
" :make
"
" Load schema
" :make db:schema:load
"
" Change to the top level directory of the application
" :Cd
"
" Change to the controllers directory
" :Cd app/controllers
"
" Run the generator script
" :Script generate controller Blog
"
" Quick console access
" :Console
"
" Find and open a file in your application
" :find blog_controller
"
" Press gf to open the filename under the cursor
" (<C-W>f for a new window, <C-W>gf for a new tab)
"
" Example uses of gf (* indicates cursor position), and where they lead
"
" Pos*t.find(:first)
" => app/models/post.rb (or wherever post.rb is)
"
" has_many :c*omments
" => app/models/comment.rb
"
" link_to "Home", :controller => :bl*og
" => app/controllers/blog_controller.rb
"
" <%= render :partial => 'sh*ared/sidebar' %>
" => app/views/shared/_sidebar.rhtml
"
" <%= stylesheet_link_tag :scaf*fold %>
" => public/stylesheets/scaffold.css
"
" class BlogController < Applica*tionController
" => app/controllers/application.rb
"
" class ApplicationController < ActionCont*roller::Base
" => .../action_controller/base.rb
"
" fixtures :pos*ts
" => test/fixtures/posts.(yml|csv)
"
" layout :pri*nt
" => app/views/layouts/print.rhtml
"
" (In the Blog controller)
" def li*st
" => app/views/blog/list.r(html|xml|js)
"

if has("autocmd")
    augroup <SID>railsDetect
        autocmd!
        autocmd BufNewFile,BufRead * call <SID>Detect(expand("<afile>:p"))
    augroup END
endif

function! s:qq()
    if &shellxquote == "'"
        return '"'
    else
        return "'"
    endif
endfunction

function! <SID>Detect(filename)
    let fn = fnamemodify(a:filename,":p")
    if isdirectory(fn)
        let fn = fnamemodify(fn,":s?/$??")
    else
        let fn = fnamemodify(fn,':s?\(.*\)/[^/]*$?\1?')
    endif
    let ofn = ""
    while fn != ofn
        if filereadable(fn . "/config/environment.rb")
            return s:Init(fn)
        endif
        let ofn = fn
        let fn = fnamemodify(ofn,':s?\(.*\)/\(app\|components\|config\|db\|doc\|lib\|log\|public\|script\|test\|tmp\|vendor\)\($\|/.*$\)?\1?')
    endwhile
    return 0
endfunction

function! s:Init(path)
    call s:InitRuby()
    let b:rails_app_path = a:path
    let rp = s:EscapePath(b:rails_app_path)
    silent exe 'command! -buffer -nargs=+ Script :!ruby '.s:qq().b:rails_app_path.'/script/'.s:qq().'<args>'
    if b:rails_app_path =~ ' '
        " irb chokes if there is a space in $0
        silent exe 'command! -buffer -nargs=* Console :!ruby '.substitute(s:qq().fnamemodify(b:rails_app_path.'/script/console',":~:."),'"\~/','\~/"','').s:qq().' <args>'
    else
        command! -buffer -nargs=* Console :Script console <args>
    endif
    command! -buffer -nargs=1 Controller :find <args>_controller
    silent exe "command! -buffer -nargs=? Cd :cd ".rp."/<args>"
    silent! compiler rubyunit
    let &l:makeprg='rake -f '.rp.'/Rakefile'
    setlocal isfname+=\",',:
    setlocal isfname-=+,,,#,$,%,~,=
    call s:SetRubyBasePath()
    if &filetype == "ruby" || &filetype == "eruby"
        " This is a strong convention in Rails, so we'll break the usual rule
        " of considering shiftwidth to be a personal preference
        setlocal sw=2 sts=2 et
        setlocal isfname-=.
        " It would be nice if we could do this without pulling in half of Rails
        " set include=\\<\\zs\\u\\f*\\l\\f*\\ze\\>\\\|^\\s*\\(require\\\|load\\)\\s\\+['\"]\\zs\\f\\+\\ze
        set include=\\<\\zsAct\\f*::Base\\ze\\>\\\|^\\s*\\(require\\\|load\\)\\s\\+['\"]\\zs\\f\\+\\ze
        setlocal includeexpr=RailsFilename()
    endif
    if &filetype == "ruby"
        setlocal suffixesadd=.rb,.rhtml,.rxml,.rjs,.yml,.csv,s.rb
        setlocal define=^\\s*def\\s\\+\\(self\\.\\)\\=
        let views = substitute(expand("%:p"),'/app/controllers/\(.\{-\}\)_controller.rb','/app/views/\1','')
        if views != expand("%:p")
            let &l:path = &l:path.",".s:EscapePath(views)
        endif
    elseif &filetype == "eruby"
        set include=\\<\\zsAct\\f*::Base\\ze\\>\\\|^\\s*\\(require\\\|load\\)\\s\\+['\"]\\zs\\f\\+\\ze\\\|\\zs<%=\\ze
        setlocal suffixesadd=.rhtml,.rxml,.rjs,.rb,.css,.js
        let &l:path = rp."/app/views,".&l:path.",".rp."/public"
    else
        " Does this cause problems in any filetypes?
        setlocal includeexpr=RailsFilename()
        setlocal suffixesadd=.rb,.rhtml,.rxml,.rjs,.css,.js,.yml,.csv,.sql,.html
    endif
    " Since so many generated files are malformed...
    set eol
    silent doautocmd User rails
    if filereadable(b:rails_app_path."/config/rails.vim")
        " sandbox
        exe "source ".rp."/config/rails.vim"
    endif
    return b:rails_app_path
endfunction

function! s:EscapePath(p)
    return substitute(a:p,' ','\\ ','g')
endfunction

function! s:SetRubyBasePath()
    let rp = s:EscapePath(b:rails_app_path)
"    if exists("s:rails_app_path") && b:rails_app_path == s:rails_app_path
        " Reuse the ruby path
    if !exists("g:rails_smart_path") || !executable("ruby")
        let s:rubypath = '.,'.rp.",".rp."/app/controllers,".rp."/app,".rp."/app/models,".rp."/app/helpers,".rp."/components,".rp."/config,".rp."/lib,".rp."/vendor/plugins/*/lib,".rp."/vendor,".rp."/test/units,".rp."/test/functional,".rp."/test/integration,".rp."/test,".substitute(&l:path,'^\.,','','')
    else
        let env = fnamemodify(b:rails_app_path.'/config/environment.rb',':.')
        let code = "print $:.map{|d|File.expand_path(d)}.uniq.join(%q{,}) rescue nil"
        let s:rubypath = system('ruby -r '.s:qq().env.s:qq().' -e '.s:qq().code.s:qq())
        let s:rubypath = '.,' . s:EscapePath(substitute(s:rubypath, '\%(^\|,\)\.\%(,\|$\)', ',,', ''))
    endif
    let s:rails_app_path = b:rails_app_path
    let &l:path = s:rubypath
endfunction

function! s:InitRuby()
    if has("ruby") && ! exists("s:ruby_initialized")
        let s:ruby_initialized = 1
        " Is there a drawback to doing this?
        ruby require "rubygems" rescue nil
        ruby require "active_support" rescue nil
    endif
endfunction

function! RailsFilename()
    " Is this foolproof?
    if mode() =~ '[iR]' || expand("<cfile>") != v:fname
        return s:RailsUnderscore(v:fname)
    else
        return s:RailsUnderscore(v:fname,line("."),col("."))
    endif
endfunction

function! s:RailsUnderscore(str,...)
    if a:str == "ApplicationController"
        return "controllers/application.rb"
    elseif a:str == "<%="
        " Probably a silly idea
        return "action_view.rb"
    endif
    let g:mymode = mode()
    let str = a:str
    if a:0 == 2
        " Get the text before the filename under the cursor.
        " We'll cheat and peak at this in a bit
        let line = getline(a:1)
        let line = substitute(line,'^\(.\{'.a:2.'\}\).*','\1','')
        let line = substitute(line,'\([:"'."'".']\|%[qQ]\=[[({<]\)\=\f*$','','')
    else
        let line = ""
    endif
    if line =~ '\<\(require\|load\)\s*(\s*'
        return str
    endif
    let str = substitute(str,'^\s*','','')
    let str = substitute(str,'\s*$','','')
    let str = substitute(str,'^[:@]','','')
    let str = substitute(str,"\\([\"']\\)\\(.*\\)\\1",'\2','')
    let str = substitute(str,'::','/','g')
    let str = substitute(str,'\(\u\+\)\(\u\l\)','\1_\2','g')
    let str = substitute(str,'\(\l\|\d\)\(\u\)','\1_\2','g')
    let str = substitute(str,'-','_','g')
    let str = substitute(str,'.*','\L&','')
    let fpat = '\(\s*\%("\f*"\|:\f*\|'."'\\f*'".'\)\s*,\s*\)*'
    if a:str =~ '\u'
        " Classes should always be in .rb's
        let str = str . '.rb'
    elseif line =~ '\(:partial\|"partial"\|'."'partial'".'\)\s*=>\s*'
        let str = substitute(str,'\([^/]\+\)$','_\1','')
        let str = substitute(str,'^/','views/','')
    elseif line =~ '\<layout\s*(\=\s*' || line =~ '\(:layout\|"layout"\|'."'layout'".'\)\s*=>\s*'
        let str = substitute(str,'^/\=','views/layouts/','')
    elseif line =~ '\(:controller\|"controller"\|'."'controller'".'\)\s*=>\s*'
        let str = 'controllers/'.str.'_controller.rb'
    elseif line =~ '\<helper\s*(\=\s*'
        let str = 'helpers/'.str.'_helper.rb'
    elseif line =~ '\<fixtures\s*(\='.fpat
        let str = substitute(str,'^/\@!','test/fixtures/','')
    elseif line =~ '\<stylesheet_\(link_tag\|path\)\s*(\='.fpat
        let str = substitute(str,'^/\@!','/stylesheets/','')
        let str = 'public'.substitute(str,'^[^.]*$','\1.css','')
    elseif line =~ '\<javascript_\(include_tag\|path\)\s*(\='.fpat
        let str = substitute(str,'^/\@!','/javascripts/','')
        let str = 'public'.substitute(str,'^[^.]*$','\1.js','')
    elseif line =~ '\<\(has_one\|belongs_to\)\s*(\=\s*'
        let str = 'models/'.str.'.rb'
    elseif line =~ '\<has_\(and_belongs_to_\)\=many\s*(\=\s*'
        let str = 'models/'.s:RailsSingularize(str).'.rb'
    elseif line =~ '\<def\s\+' && expand("%:t") =~ '_controller\.rb'
        let str = substitute(expand("%:p"),'.*/app/controllers/\(.\{-\}\)_controller.rb','views/\1','').'/'.str
    else
        " If we made it this far, we'll risk making it singular.
        let str = s:RailsSingularize(str)
        let str = substitute(str,'_id$','','')
    endif
    if str =~ '^/' && !filereadable(str)
        let str = substitute(str,'^/','','')
    endif
    return str
endfunction

function! s:RailsSingularize(word)
    " Probably not worth it to be as comprehensive as Rails but we can
    " still hit the common cases.
    let word = a:word
    let word = substitute(word,'eople$','erson','')
    let word = substitute(word,'[aeio]\@<!ies$','y','')
    let word = substitute(word,'s$','','')
    return word
endfunction

