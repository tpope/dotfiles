# ~/.cshrc
# vim:set et sw=2:

# Common {{{1

if ( -r "$HOME/.env.local" ) then
  eval `grep '^[A-Z].*=' "$HOME/.env.local"|sed -e 's/=/ /' -e 's/^/;setenv /'`
endif

if ( $?CDPATH ) then
  set cdpath = ("`echo $CDPATH|tr ':' '\n'`")
endif

set newpath = ()
if ( $?PATHPREPEND ) then
  set newpath = ( `echo "$PATHPREPEND"|tr ':' '\n'` )
endif
set newpath = ( $newpath $path )
setenv PATH ".git/safe/../../bin:$HOME/.local/bin"
foreach dir ( $newpath )
  if ( :${PATH}: !~ *:${dir}:* ) setenv PATH "${PATH}:${dir}"
end
unset dir newpath

setenv ENV "$HOME/.shrc"
setenv BASH_ENV "$HOME/.zshenv"
if ( ! $?CLASSPATH ) setenv CLASSPATH ".:$HOME/.java/*"
if ( ! $?RSYNC_RSH ) setenv RSYNC_RSH 'ssh -ax'
if ( ! $?SRC ) setenv SRC "$HOME/src"

if ( $?prompt == 0 ) exit
if ( "$prompt" == "" ) exit
# }}}1
# Environment {{{1
umask 022
if ( -x /bin/stty ) stty -ixon

if ( -x /usr/local/bin/vim || -x /usr/bin/vim ) then
  setenv VISUAL vim
else if ( -x /usr/bin/vi || -x /bin/vi ) then
  setenv VISUAL vi
endif
setenv BROWSER "tpope browser"
if ( -x /usr/local/bin/less || -x /usr/bin/less || -x /bin/less ) setenv PAGER less
setenv LESS 'RFX#10'
if ( -x /usr/bin/lesspipe ) then
  setenv LESSOPEN '|lesspipe %s'
else
  setenv LESSOPEN '|"$HOME/.lessfilter" %s'
endif
if ( ! $?HOST ) set HOST = `tpope host name`

set noclobber
# }}}
# Prompt {{{1
if ( `id|sed -e 's/^uid=\([0-9]*\).*$/\1/'` == 0 ) then
  set usercolor = "01;37"
  set promptchar = "#"
else
  set usercolor = "01;33"
  set promptchar = "%"
  if ( `id|sed -e 's/^.*gid=[0-9]*(\([^)]*\)).*/\1/'` == `id -un` ) umask 002
endif

if ( -x /usr/bin/tty || -x /usr/local/bin/tty ) then
  set ttybracket=" [`tty|sed -e s,^/dev/,,`]"
  set ttyat="`tty|sed -e s,^/dev/,,`@"
else
  set ttyat=""
  set ttybracket=""
endif

if ( $?tcsh ) then
  set hostcolor = `tpope host ansi`

  set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "

  switch ($TERM)
  case screen*:
    if ( $?STY || $?TMUX ) then
      set prompt = "%{\ek%l\e\\%}$prompt"
    else
      set prompt = "%{\ek%l%m\e\\%}$prompt"
    endif
    breaksw
  endsw

  switch ($TERM)

  case screen*:
  case xterm*:
  case rxvt*:
  case Eterm*:
  case kterm*:
  case putty*:
  case dtterm*:
  case ansi*:
  case cygwin*:
    set prompt = "%{\e]1;${ttyat}%m\a\e]2;%n@%m:%~${ttybracket}\a%}$prompt"
    breaksw

  case linux*:
  case vt220*:
    breaksw

  default:
    set prompt = "%n@%m:%~%# "
    breaksw

  endsw
else
  alias cd 'cd \!* && setprompt'
  alias chdir 'chdir \!* && setprompt'
  alias pushd 'pushd \!* && setprompt'
  alias popd  'popd  \!* && setprompt'
  alias setprompt 'set prompt = "'`id -un`@$HOST':`pwd|sed -e "s,^$HOME,~,"`'"$promptchar"' "'
  setprompt
  set history = 100
  set filec
  if ( $TERM =~ screen* ) then
      printf "\033k%s\033\\" "$ttyat$HOST"
  endif
endif

unset hostcolor usercolor promptchar oldterm ttyat ttybracket
# }}}1
# Aliases {{{1
if ( -x /usr/bin/dircolors || -x /usr/local/bin/dircolors ) then
  set ls_colors = `dircolors -c $HOME/.dir_colors|cut -d"'" -f 2`
  alias ls 'env LS_COLORS="$ls_colors" ls -hF --color=auto'
else
  alias ls 'env CLICOLOR=1 LSCOLORS=ExGxFxdxCxfxDxxbadacad ls -hF'
endif

eval `grep '^    alias' $HOME/.shrc | sed -e 's/=/ /' -e 's/$/;/'`

if ( $?VISUAL && "$VISUAL" == vim ) alias vi vim

foreach cmd ( `tpope aliases` )
  alias $cmd "tpope $cmd"
end
# }}}1
# Completion {{{1

if ( $?tcsh ) then
  if ( -f /etc/complete.tcsh ) source /etc/complete.tcsh
  set hosts=(localhost `tpope host list`)
  alias _extract_subcommands 'grep "^  [a-z-]*[|)]" \!*|sed -e "s/).*//"|tr "|" " "'
  complete tpope 'p@1@`_extract_subcommands "$HOME/.local/bin/tpope"`@' \
  'n/*/f/'
  foreach cmd ( start stop restart reload force-reload status )
    complete $cmd 'p@1@`(cd /etc/init.d; echo *)`@'
  end
endif

# }}}1
