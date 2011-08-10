" rake.vim - It's like rails.vim without the rails
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.0
" GetLatestVimScripts: 3669 1 :AutoInstall: rake.vim

if exists('g:loaded_rake') || &cp || v:version < 700
  finish
endif
let g:loaded_rake = 1

" Utility {{{1

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

function! s:sub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:shellesc(arg) abort
  if a:arg =~ '^[A-Za-z0-9_/.-]\+$'
    return a:arg
  else
    return shellescape(a:arg)
  endif
endfunction

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

function! s:shellslash(path)
  if exists('+shellslash') && !&shellslash
    return s:gsub(a:path,'\\','/')
  else
    return a:path
  endif
endfunction

function! s:fuzzyglob(arg)
  return s:gsub(s:gsub(a:arg,'[^/.]','[&]*'),'%(/|^)\.@!|\.','&*')
endfunction

function! s:completion_filter(results,A)
  let results = sort(copy(a:results))
  call filter(results,'v:val !~# "\\~$"')
  let filtered = filter(copy(results),'v:val[0:strlen(a:A)-1] ==# a:A')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'[^/:]','[&].*')
  let filtered = filter(copy(results),'v:val =~# "^".regex')
  if !empty(filtered) | return filtered | endif
  let filtered = filter(copy(results),'"/".v:val =~# "[/:]".regex')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'.','[&].*')
  let filtered = filter(copy(results),'"/".v:val =~# regex')
  return filtered
endfunction

function! s:throw(string) abort
  let v:errmsg = 'rake: '.a:string
  throw v:errmsg
endfunction

function! s:warn(str)
  echohl WarningMsg
  echomsg a:str
  echohl None
  let v:warningmsg = a:str
endfunction

function! s:add_methods(namespace, method_names) abort
  for name in a:method_names
    let s:{a:namespace}_prototype[name] = s:function('s:'.a:namespace.'_'.name)
  endfor
endfunction

let s:commands = []
function! s:command(definition) abort
  let s:commands += [a:definition]
endfunction

function! s:define_commands()
  for command in s:commands
    exe 'command! -buffer '.command
  endfor
endfunction

augroup rake_utility
  autocmd!
  autocmd User Rake call s:define_commands()
augroup END

let s:abstract_prototype = {}

" }}}1
" Initialization {{{1

function! s:FindRakeRoot(path) abort
  let path = s:shellslash(a:path)
  for p in [$GEM_HOME] + split($GEM_PATH,':')
    if p !=# '' && s:shellslash(p.'/gems/') ==# (path)[0 : strlen(p)+5]
      return simplify(s:shellslash(p.'/gems/')).matchstr(path[strlen(p)+6:-1],'[^\\/]*')
    endif
  endfor
  let fn = fnamemodify(path,':s?[\/]$??')
  let ofn = ""
  let nfn = fn
  while fn != ofn
    if filereadable(fn.'/Rakefile')
      if filereadable(fn.'/config/environment.rb')
        return ''
      else
        return s:sub(simplify(fnamemodify(fn,':p')),'[\\/]$','')
      endif
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':h')
  endwhile
  return ''
endfunction

function! s:Detect(path)
  if exists('b:rake_root') && b:rake_root ==# ''
    unlet b:rake_root
  endif
  if !exists('b:rake_root')
    let dir = s:FindRakeRoot(a:path)
    if dir != ''
      let b:rake_root = dir
    endif
  endif
  if exists('b:rake_root')
    silent doautocmd User Rake
  endif
endfunction

augroup rake
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
  autocmd FileType           netrw call s:Detect(expand('<afile>:p'))
  autocmd VimEnter * if expand('<amatch>')==''|call s:Detect(getcwd())|endif
augroup END

" }}}1
" Project {{{1

let s:project_prototype = {}
let s:projects = {}

function! s:project(...) abort
  let dir = a:0 ? a:1 : (exists('b:rake_root') && b:rake_root !=# '' ? b:rake_root : s:FindRakeRoot(expand('%:p')))
  if dir !=# ''
    if has_key(s:projects,dir)
      let project = get(s:projects,dir)
    else
      let project = {'root': dir}
      let s:projects[dir] = project
    endif
    return extend(extend(project,s:project_prototype,'keep'),s:abstract_prototype,'keep')
  endif
  call s:throw('not a rake project: '.expand('%:p'))
endfunction

function! s:project_path(...) dict abort
  return join([self.root]+a:000,'/')
endfunction

call s:add_methods('project',['path'])

function! s:project_dirglob(base) dict abort
  let base = s:sub(a:base,'^/','')
  let matches = split(glob(self.path(s:gsub(base,'/','*&').'*/')),"\n")
  call map(matches,'v:val[ strlen(self.path())+(a:base !~ "^/") : -1 ]')
  return matches
endfunction

function! s:project_has_file(file) dict
  return filereadable(self.path(a:file))
endfunction

function! s:project_has_directory(file) dict
  return isdirectory(self.path(a:file))
endfunction

function! s:project_first_file(...) dict abort
  for file in a:000
    if s:project().has_file(file)
      return file
    endif
  endfor
  for file in a:000
    if s:project().has_directory(matchstr(file,'^[^/]*'))
      return file
    endif
  endfor
  return a:000[0]
endfunction

call s:add_methods('project',['dirglob','has_file','has_directory','first_file'])

" }}}1
" Buffer {{{1

let s:buffer_prototype = {}

function! s:buffer(...) abort
  let buffer = {'#': bufnr(a:0 ? a:1 : '%')}
  call extend(extend(buffer,s:buffer_prototype,'keep'),s:abstract_prototype,'keep')
  if buffer.getvar('rake_root') !=# ''
    return buffer
  endif
  call s:throw('not a rake project: '.expand('%:p'))
endfunction

function! rake#buffer(...) abort
  return s:buffer(a:0 ? a:1 : '%')
endfunction

function! s:buffer_getvar(var) dict abort
  return getbufvar(self['#'],a:var)
endfunction

function! s:buffer_setvar(var,value) dict abort
  return setbufvar(self['#'],a:var,a:value)
endfunction

function! s:buffer_getline(lnum) dict abort
  return getbufline(self['#'],a:lnum)[0]
endfunction

function! s:buffer_project() dict abort
  return s:project(self.getvar('rake_root'))
endfunction

function! s:buffer_name() dict abort
  return self.path()[strlen(self.project().path())+1 : -1]
endfunction

function! s:buffer_path() dict abort
  let bufname = bufname(self['#'])
  return s:shellslash(bufname == '' ? '' : fnamemodify(bufname,':p'))
endfunction

call s:add_methods('buffer',['getvar','setvar','getline','project','name','path'])

" }}}1
" Rake {{{1

function! s:push_chdir(...)
  if !exists("s:command_stack") | let s:command_stack = [] | endif
  let chdir = exists("*haslocaldir") && haslocaldir() ? "lchdir " : "chdir "
  call add(s:command_stack,chdir.s:fnameescape(getcwd()))
  exe chdir.'`=s:project().path()`'
endfunction

function! s:pop_command()
  if exists("s:command_stack") && len(s:command_stack) > 0
    exe remove(s:command_stack,-1)
  endif
endfunction

function! s:Rake(bang,arg)
  let old_makeprg = &l:makeprg
  let old_errorformat = &l:errorformat
  call s:push_chdir()
  try
    let &l:makeprg = 'rake'
    let &l:errorformat = '%D(in\ %f),'
          \.'%\\s%#from\ %f:%l:%m,'
          \.'%\\s%#from\ %f:%l:,'
          \.'%\\s#{RAILS_ROOT}/%f:%l:\ %#%m,'
          \.'%\\s%#[%f:%l:\ %#%m,'
          \.'%W%m\ (Cucumber::Undefined),'
          \.'%E%m\ (%.%#),'
          \.'%Z%f:%l,'
          \.'%Z%f:%l:%.%#,'
          \.'%\\s%#%f:%l:\ %#%m,'
          \.'%\\s%#%f:%l:,'
          \.'%m\ [%f:%l]:'
    execute 'make! '.a:arg
    if a:bang !=# '!'
      return 'cwindow'
    endif
    return ''
  finally
    let &l:errorformat = old_errorformat
    let &l:makeprg = old_makeprg
    call s:pop_command()
  endtry
endfunction

function! s:RakeComplete(A,L,P)
  return s:completion_filter(s:project().tasks(),a:A)
endfunction

function! s:project_tasks()
  call s:push_chdir()
  try
    let lines = split(system('rake -T'),"\n")
  finally
    call s:pop_command()
  endtry
  if v:shell_error != 0
    return []
  endif
  call map(lines,'matchstr(v:val,"^rake\\s\\+\\zs\\S*")')
  call filter(lines,'v:val != ""')
  return lines
endfunction

call s:add_methods('project',['tasks'])

call s:command("-bar -bang -nargs=? -complete=customlist,s:RakeComplete Rake :execute s:Rake('<bang>',<q-args>)")

" }}}1
" Rcd, Rlcd {{{1

function! s:DirComplete(A,L,P) abort
  return s:project().dirglob(a:A)
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:DirComplete Rcd  :cd<bang>  `=s:project().path(<q-args>)`")
call s:command("-bar -bang -nargs=? -complete=customlist,s:DirComplete Rlcd :lcd<bang> `=s:project().path(<q-args>)`")

" }}}1
" R {{{1

function! s:buffer_related() dict abort
  if self.name() =~# '^lib/'
    let bare = s:sub(self.name()[4:-1],'\.rb$','')
    return s:project().first_file(
          \'test/'.bare.'_test.rb',
          \'spec/'.bare.'_spec.rb',
          \'test/unit/'.bare.'_test.rb',
          \'spec/unit/'.bare.'_spec.rb')
  elseif self.name() =~# '^\(test\|spec\)/.*_\1\.rb$'
    return 'lib/'.self.name()[5:-9].'.rb'
  elseif self.name() ==# 'Gemfile'
    return 'Gemfile.lock'
  elseif self.name() ==# 'Gemfile.lock'
    return 'Gemfile'
  endif
  return ''
endfunction

call s:add_methods('buffer',['related'])

function! s:project_relglob(path,glob,...) dict
  if exists("+shellslash") && ! &shellslash
    let old_ss = &shellslash
  endif
  try
    let &shellslash = 1
    let path = a:path
    if path !~ '^/' && path !~ '^\w:'
      let path = self.path(path)
    endif
    let suffix = a:0 ? a:1 : ''
    let full_paths = split(glob(path.a:glob.suffix),"\n")
    let relative_paths = []
    for entry in full_paths
      if suffix == '' && isdirectory(entry) && entry !~ '/$'
        let entry .= '/'
      endif
      let relative_paths += [entry[strlen(path) : -strlen(suffix)-1]]
    endfor
    return relative_paths
  finally
    if exists("old_ss")
      let &shellslash = old_ss
    endif
  endtry
endfunction

call s:add_methods('project',['relglob'])

function! s:R(cmd,bang,...) abort
  let cmds = {'E': 'edit', 'S': 'split', 'V': 'vsplit', 'T': 'tabedit', 'D': 'read'}
  let cmd = cmds[a:cmd] . a:bang
  try
    if a:0
      let goal = s:project().path(a:1)
    else
      let related = s:buffer().related()
      if related == ''
        call s:throw('no related file')
      else
        let goal = s:project().path(related)
      endif
    endif
    if goal =~# '[#:]\d\+$'
      let cmd .= ' +'.matchstr(goal,'\d\+$')
      let goal = matchstr(goal,'.*\ze[:#].*$')
    elseif goal =~ '[#:]\w\+[?!=]\=$'
      let cmd .= ' +/^\\s*def\\s\\+'.matchstr(goal,'[:#]\zs.\{-\}$')
      let goal = matchstr(goal,'.*\ze[:#].*$')
    endif
    let parent = fnamemodify(goal,':h')
    if !isdirectory(parent)
      if a:bang ==# '!' && isdirectory(fnamemodify(parent,':h'))
        call mkdir(parent)
      endif
      call s:throw('No such directory: '.parent)
    endif
    return cmd.' '.s:fnameescape(goal)
    return ''
  catch /^rake:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:RComplete(A,L,P) abort
  return s:completion_filter(s:project().relglob('',s:fuzzyglob(a:A).'*'),a:A)
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete R  :execute s:R('E','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete RS :execute s:R('S','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete RV :execute s:R('V','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete RT :execute s:R('T','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete RD :execute s:R('D','<bang>',<f-args>)")

call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete A  :execute s:R('E','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete AS :execute s:R('S','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete AV :execute s:R('V','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete AT :execute s:R('T','<bang>',<f-args>)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:RComplete AD :execute s:R('D','<bang>',<f-args>)")

" }}}1
" Rlib, etc. {{{1

function! s:navcommand(name) abort
  for type in ['', 'S', 'V', 'T', 'D']
    call s:command("-bar -bang -nargs=? -complete=customlist,s:R".a:name."Complete R".type.a:name." :execute s:Edit('".type."','<bang>',s:R".a:name."(matchstr(<q-args>,'[^:#]*')).matchstr(<q-args>,'[:#].*'))")
  endfor
endfunction

function! s:Edit(cmd,bang,file)
  return s:R(a:cmd == '' ? 'E' : a:cmd, a:bang, a:file)
endfunction

function! s:Rlib(file)
  if a:file ==# ''
    return 'Gemfile'
  elseif a:file =~# '/$'
    return 'lib/'.a:file
  else
    return 'lib/'.a:file.'.rb'
  endif
endfunction

function! s:RlibComplete(A,L,P)
  return s:completion_filter(s:project().relglob('lib/','**/*','.rb'),a:A)
endfunction

function! s:first_file(choices)
  return call(s:project().first_file,a:choices,s:project())
endfunction

function! s:Rtestorspec(order,file)
  if a:file ==# ''
    return s:first_file(map(copy(a:order),'v:val."/".v:val."_helper.rb"'))
  elseif a:file =~# '/$'
    return s:first_file(map(copy(a:order),'v:val."/".a:file."/"'))
  elseif a:file ==# '.'
    return s:first_file(map(copy(a:order),'v:val."/"'))
  else
    return s:first_file(map(copy(a:order),'v:val."/".a:file."_".v:val.".rb"'))
  endif
endfunction

function! s:Rtest(...)
  return call('s:Rtestorspec',[['test', 'spec']] + a:000)
endfunction

function! s:RtestComplete(A,L,P)
  return s:completion_filter(s:project().relglob('test/','**/*','_test.rb')+s:project().relglob('spec/','**/*','_spec.rb'),a:A)
endfunction

function! s:Rspec(...)
  return call('s:Rtestorspec',[['spec', 'test']] + a:000)
endfunction

function! s:RspecComplete(A,L,P)
  return s:completion_filter(s:project().relglob('spec/','**/*','_spec.rb')+s:project().relglob('test/','**/*','_test.rb'),a:A)
endfunction

function! s:Rtask(file)
  if a:file ==# ''
    return 'Rakefile'
  elseif a:file =~# '/$'
    return 'rakelib/'.a:file
  else
    return 'rakelib/'.a:file.'.rake'
  endif
endfunction

function! s:RtaskComplete(A,L,P)
  return s:completion_filter(s:project().relglob('rakelib/','**/*','.rake'),a:A)
endfunction

call s:navcommand('lib')
call s:navcommand('test')
call s:navcommand('spec')
call s:navcommand('task')

" }}}1
" Rtags {{{1

function! s:project_tags_file() dict abort
  if filewritable(self.path())
    return self.path('tags')
  else
    if !has_key(self,'_tags_file')
      let self._tags_file = tempname()
    endif
  endif
  return self._tags_file
endfunction

call s:add_methods('project',['tags_file'])

function! s:Tags(args)
  if exists("g:Tlist_Ctags_Cmd")
    let cmd = g:Tlist_Ctags_Cmd
  elseif executable("exuberant-ctags")
    let cmd = "exuberant-ctags"
  elseif executable("ctags-exuberant")
    let cmd = "ctags-exuberant"
  elseif executable("ctags")
    let cmd = "ctags"
  elseif executable("ctags.exe")
    let cmd = "ctags.exe"
  else
    call s:throw("ctags not found")
  endif
  return escape('!'.cmd.' -f '.s:shellesc(s:project().tags_file()).' -R '.s:shellesc(s:project().path()),'%#').' '.a:args
endfunction

call s:command("-bar -bang -nargs=? Rtags :execute s:Tags(<q-args>)")

augroup rake_tags
  autocmd!
  autocmd User Rake
        \ if s:project().path() !~# ',' &&
        \     stridx(&tags, s:project().tags_file()) < 0 |
        \   let &l:tags .= ',' . s:project().tags_file() |
        \ endif
augroup END

" }}}1
" Path {{{1

augroup rake_path
  autocmd!
  autocmd User Rake
        \ if stridx(&path, escape(s:project().path('lib'),', ')) < 0 |
        \   let &l:path = escape(s:project().path('lib'),', ') . ',' . &l:path |
        \ endif
augroup END

" }}}1

" vim:set sw=2 sts=2:
