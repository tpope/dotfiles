# ~/.cshrc
# Author: Tim Pope

# Common {{{1
if ( { test -t 1 } && $?TERM ) test "$TERM" = Eterm && echo -n \
"]I.kde/share/icons/`hostname|sed -e 's/[.].*//'`.xpm\" # "

foreach dir ( /usr/ucb /usr/local/bin /opt/sfw/bin "$HOME/bin" )
    if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end
foreach dir ( /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/lib/surfraw /usr/local/sbin /usr/sbin /sbin )
    if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end

#if ( $?LD_PRELOAD) then
    #if ( $LD_PRELOAD !~ *libtrash* && -f "$HOME/.libtrash" && -f /usr/lib/libtrash/libtrash.so ) setenv LD_PRELOAD "${LD_PRELOAD}:/usr/lib/libtrash/libtrash.so"
    #if ( $LD_PRELOAD !~ *libtrash* && -f "$HOME/.libtrash" && -f /usr/lib/libtrash/libtrash.so ) setenv LD_PRELOAD_SCREEN "${LD_PRELOAD}:/usr/lib/libtrash/libtrash.so"
#else
    #if ( -f /usr/lib/libtrash/libtrash.so ) setenv LD_PRELOAD /usr/lib/libtrash/libtrash.so
    #if ( -f /usr/lib/libtrash/libtrash.so ) setenv LD_PRELOAD_SCREEN /usr/lib/libtrash/libtrash.so
#endif

setenv ENV "$HOME/.shrc"
setenv CLASSPATH '.'
if ( -d "$HOME/java" )  setenv CLASSPATH "${CLASSPATH}:$HOME/java"
if ( -d "$HOME/.java" ) setenv CLASSPATH "${CLASSPATH}:$HOME/.java"
setenv PERL5LIB "$HOME/.perl5:$HOME/perl5:$HOME/.perl:$HOME/perl"

unset dir

if ( $?prompt == 0 ) exit
if ( "$prompt" == "" ) exit
# }}}1
# Environment {{{1
umask 022
stty -ixon

setenv VISUAL 'vi'
setenv PAGER 'less'
setenv BROWSER "$HOME/bin/sensible-browser"
setenv LESSOPEN '|lesspipe %s'
setenv RSYNC_RSH 'ssh -a -x'
set hostname = `hostname|sed -e 's/[.].*//'`
setenv CVSROOT ':ext:rebelongto.us:/home/tpope/.cvs'
if ( $hostname == bart ) setenv CVSROOT "$HOME/.cvs"
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
    if ( `id|sed -e 's/^.*gid=[0-9]*(\([^)]*\)).*/\1/'` == `whoami` ) umask 002
endif

if ( -x /usr/bin/tty || -x /usr/local/bin/tty ) then
    set ttyslash=" [`tty|sed -e s,^/dev/,, -e s/^tty//`]"
    set ttydash="`tty|sed -e s,^/dev/,, -e s/^tty// -e s,/,-,g`@"
else
    set ttydash=""
    set ttyslash=""
endif

if ( $?tcsh ) then
    if ( -x "$HOME/bin/hostinfo" ) then
	set hostcolor = `$HOME/bin/hostinfo -c`
	set hostletter = `$HOME/bin/hostinfo -l`
	set hostcode = `$HOME/bin/hostinfo -s`
    else
	set hostcolor = `00;33`
	set hostletter = ``
	set hostcode = `y`
    endif
    set oldterm = "$TERM"
    if ( $?OLDTERM ) then
	set oldterm = "$OLDTERM"
    endif
    switch ($oldterm)

    case screen*:
	if ( `hostname` == grex.cyberspace.org ) then
	    setenv TERM vt220
	    setenv OLDTERM screen
	endif
    case vt220*:
	alias precmd 'echo -n "]1;'"${ttydash}${hostname}"']2;'"{$usercode}${USER}{-}@{$hostcode}${hostname}{-}:{+b B}"'`echo $cwd|sed -e s,^$HOME,~,`'"{-}{k}${ttyslash}{-}"'k'"${ttydash}${hostname}"'\"'
	#echo -n "k${ttydash}${hostname}\" # "
	set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
	breaksw

    case xterm*:
    case rxvt*:
    case kterm*:
    case dtterm*:
	alias precmd 'echo -n "]1;'"i${ttydash}${hostname}"']2;'"${USER}@${hostname}"':`echo $cwd|sed -e s,^$HOME,~,`'"${ttyslash}"'"'
	#alias jobcmd 'echo -n "]2\;\!#"'
	set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
	breaksw

    case Eterm*:
	alias precmd 'echo -n "]1;'"${ttydash}${hostname}"']2;'"${USER}@${hostname}"':`echo $cwd|sed -e s,^$HOME,~,`'"${ttyslash}"']I'"$hostname"'.xpm\"'
	#alias jobcmd 'echo -n "]2\;\!#"'
	set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "
	if ( `hostname` == grex.cyberspace.org ) then
	    setenv TERM xterm
	    setenv OLDTERM Eterm
	endif
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
    #alias setprompt 'set prompt = "[${usercolor}m`whoami`[00m@[${hostcolor}m`hostname`[00m:[01;34m`pwd|sed -e "s,^$HOME,~,"`[00m$promptchar "'
    alias setprompt 'set prompt = "'`whoami`@`hostname|sed -e "s/[.].*//"`':`pwd|sed -e "s,^$HOME,~,"`'"$promptchar"' "'
    setprompt
    set history = 100
    set filec
    if ( $TERM =~ screen* || $TERM =~ vt220* ) then
    	echo -n "k${ttydash}${hostname}\" # "
    endif
endif

unset hostcolor hostletter hostname hostcode usercolor usercode promptchar oldterm ttydash ttyslash
# }}}1
# Aliases {{{1
if ( -x /usr/bin/dircolors && $?tcsh ) then
    eval `/usr/bin/dircolors -c $HOME/.dir_colors`
    alias ls 'ls -F --color=auto'
else if ( -x /usr/local/bin/dircolors && $?tcsh ) then
    eval `/usr/local/bin/dircolors -c $HOME/.dir_colors`
    alias ls 'ls -F --color=auto'
else if ( -x /usr/bin/dircolors || -x /usr/local/bin/dircolors ) then
    #eval `dircolors -c`
    alias ls 'ls -F --color=auto'
else
    alias ls 'ls -F'
endif

if ( -x /usr/bin/finger && -f "$HOME/.hushlogin" ) then
    /usr/bin/finger $USER | grep '^New mail' >&/dev/null && \
	echo "You have new mail."
else if ( -x /usr/ucb/finger && -f "$HOME/.hushlogin" ) then
    /usr/ucb/finger $USER | grep '^New mail' >&/dev/null && \
	echo "You have new mail."
endif

alias mv 'mv -i'
alias cp 'cp -i'
alias rm 'tpope libtrash rm -i'

alias j 'jobs'

if ( -x /usr/bin/vim || -x /usr/local/bin/vim || -x /opt/sfw/bin/vim ) then
    alias vi 'vim -X'
    setenv VISUAL 'vim -X'
endif

if ( -x /usr/bin/sudo || -x /usr/local/bin/sudo ) then
    alias apt-get='sudo apt-get'
endif

if ( `uname` == Linux ) then
    alias less 'less -R'
    alias zless 'zless -R'
    setenv PAGER 'less -R'
    setenv LESSCHARSET 'iso8859'
endif

foreach cmd ( `tpope aliases` )
    alias $cmd "tpope $cmd"
end
# }}}1
