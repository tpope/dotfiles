# ~/.cshrc
# vim:set et sw=2:

# Common {{{1

foreach dir ( /usr/ucb /usr/local/bin /opt/local/bin /opt/sfw/bin "$HOME/.rbenv/bin" "$HOME/.rbenv/shims" "$HOME/bin" )
  if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end
foreach dir ( /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/lib/surfraw /var/lib/gems/1.8/bin /usr/local/sbin /usr/sbin /sbin /usr/etc )
  if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end

if ( -f "$HOME/.locale" && ! $?LANG && ! $?LC_ALL ) then
  setenv LANG "`cat ~/.locale`"
endif

setenv ENV "$HOME/.shrc"
setenv CLASSPATH '.'
if ( -d "$HOME/.java" ) setenv CLASSPATH "${CLASSPATH}:$HOME/.java"
if ( -d "$HOME/java" )  setenv CLASSPATH "${CLASSPATH}:$HOME/java"
setenv RUBYLIB  "$HOME/.ruby/lib:$HOME/.ruby"
setenv PERL5LIB "$HOME/.perl5:$HOME/perl5:$HOME/.perl:$HOME/perl"
setenv RSYNC_RSH 'ssh -axqoBatchMode=yes'
if ( { test -t 1 } ) setenv RSYNC_RSH 'ssh -ax'
setenv CVS_RSH 'ssh'

unset dir

if ( { limit maxproc 256 } ) then >&/dev/null
  limit maxproc 256 >&/dev/null
  if ($?CRON == 1) limit maxproc 128 >&/dev/null
endif

if ( $?prompt == 0 ) exit
if ( "$prompt" == "" ) exit
# }}}1
# Environment {{{1
umask 022
if ( -x /bin/stty ) stty -ixon

setenv VISUAL "$HOME/bin/sensible-editor"
setenv PAGER "$HOME/bin/sensible-pager"
setenv BROWSER "$HOME/bin/sensible-browser"
setenv LESS 'RFX#10'
if ( -x /usr/bin/lesspipe ) then
  setenv LESSOPEN '|lesspipe %s'
else
  setenv LESSOPEN '|"$HOME/.lessfilter" %s'
endif
if ( $HOST == '') set HOST = `tpope hostman`
setenv CVSROOT ':ext:michael:/home/tpope/.cvs'
if ( $HOST == michael ) setenv CVSROOT "$HOME/.cvs"
setenv LYNX_CFG "$HOME/.lynx.cfg"

set noclobber
# }}}
# Prompt {{{1
if ( `id|sed -e 's/^uid=\([0-9]*\).*$/\1/'` == 0 ) then
  set usercolor = "01;37"
  set usercode = "+b W"
  set promptchar = "#"
else
  set usercolor = "01;33"
  set usercode = "+b Y"
  set promptchar = "%"
  if ( `id|sed -e 's/^.*gid=[0-9]*(\([^)]*\)).*/\1/'` == `id -un` ) umask 002
endif

if ( -x /usr/bin/tty || -x /usr/local/bin/tty ) then
  set ttyslash=" [`tty|sed -e s,^/dev/,, -e s/^tty//`]"
  set ttydash="`tty|sed -e s,^/dev/,, -e s/^tty// -e s,/,-,g`@"
else
  set ttydash=""
  set ttyslash=""
endif

if ( $?tcsh ) then
  if ( -x "$HOME/bin/tpope" ) then
    set hostcolor = `$HOME/bin/tpope hostman -c`
    set hostletter = `$HOME/bin/tpope hostman -l`
    set hostcode = `$HOME/bin/tpope hostman -s`
  else
    set hostcolor = `00;33`
    set hostletter = ``
    set hostcode = `y`
  endif
  if ( ! $?TERM ) setenv TERM vt220
  #set oldterm = "$TERM"
  #if ( $?OLDTERM ) then
    #set oldterm = "$OLDTERM"
  #endif
  switch ($TERM)

  case screen*:
  case vt220*:
    if ( $?STY ) then
    alias precmd 'echo -n "]1;'"${ttydash}${HOST}"']2;'"{$usercode}${USER}{-}@{$hostcode}${HOST}{-}:{+b B}"'`echo $cwd|sed -e s,^$HOME,~,`'"{-}{k}${ttyslash}{-}"'k'"${ttydash}${HOST}"'\"'
    else
    alias precmd 'echo -n "]1;'"${ttydash}${HOST}"']2;'"{$usercode}${USER}{-}@{$hostcode}${HOST}{-}:{+b B}"'`echo $cwd|sed -e s,^$HOME,~,`'"{-}{k}${ttyslash}{-}"'k'"${ttydash}"'\"'
    endif
    #echo -n "k${ttydash}${HOST}\" # "
    set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
    breaksw

  case xterm*:
  case rxvt*:
  case Eterm*:
  case kterm*:
  case putty*:
  case dtterm*:
  case ansi*:
  case cygwin*:
    alias precmd 'echo -n "]1;'"i${ttydash}${HOST}"']2;'"${USER}@${HOST}"':`echo $cwd|sed -e s,^$HOME,~,`'"${ttyslash}"'"'
    #alias jobcmd 'echo -n "]2\;\!#"'
    set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
    breaksw

  case linux*:
    set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
    breaksw

  default:
    set prompt = "$hostletter%# "
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
  if ( $TERM =~ screen* || $TERM =~ vt220* ) then
      echo -n "k${ttydash}${HOST}\" # "
  endif
endif

unset hostcolor hostletter hostcode usercolor usercode promptchar oldterm ttydash ttyslash
# }}}1
# Aliases {{{1
if ( -x /usr/bin/dircolors && $?tcsh ) then
  eval `/usr/bin/dircolors -c $HOME/.dir_colors`
  alias ls 'ls -F --color=auto'
else if ( -x /usr/local/bin/dircolors && $?tcsh ) then
  eval `/usr/local/bin/dircolors -c $HOME/.dir_colors`
  alias ls 'ls -F --color=auto'
else if ( -x /usr/bin/dircolors || -x /usr/local/bin/dircolors ) then
  alias ls 'ls -F --color=auto'
else
  alias ls 'ls -F'
  setenv CLICOLOR ''
  setenv LSCOLORS ExGxFxdxCxfxexCaCdEaEd
endif

grep --color |& grep unknown >/dev/null || alias grep 'grep --color=auto --exclude="*~"'

if ( -x /usr/bin/finger && -f "$HOME/.hushlogin" ) then
  /usr/bin/finger $USER | grep '^New mail' >&/dev/null && \
    echo "You have new mail."
else if ( -x /usr/ucb/finger && -f "$HOME/.hushlogin" ) then
  /usr/ucb/finger $USER | grep '^New mail' >&/dev/null && \
    echo "You have new mail."
endif

alias mv 'mv -i'
alias cp 'cp -i'

alias j 'jobs'

if ( -x /usr/bin/vim || -x /usr/local/bin/vim || -x /opt/sfw/bin/vim ) then
  alias vi 'vim'
endif

if ( -x /usr/bin/gvim || -x /usr/local/bin/gvim || -x /opt/sfw/bin/gvim ) then
  alias vi 'vim' # -X
endif

if ( `uname` == Linux ) then
  alias less 'less -R'
  alias zless 'zless -R'
endif

foreach cmd ( `tpope aliases` )
  alias $cmd "tpope $cmd"
end
# }}}1
