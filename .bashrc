# ~/.bashrc
# vim:set et sw=2:

[ "$PS1" ] && interactive=1
export ENV="$HOME/.shrc"
. "$ENV"
unset interactive

[ ! -f "$HOME/.rvm/scripts/rvm" ] || . "$HOME/.rvm/scripts/rvm"
[ ! -f "$HOME/.rbenv/bin/rbenv" ] || eval "$(rbenv init -|grep -v export.PATH)"

if [ "$PS1" ]; then
# If running interactively, then:

shopt -s extglob 2>/dev/null
set -o noclobber

export HISTCONTROL=ignoredups HISTFILE=

if [ -x "$HOME/bin/tpope" ]; then
  hostcolor=`"$HOME/bin/tpope" hostman ansi`
else
  hostcolor="01;37"
fi

[ "$UID" ] || UID=`id -u`
usercolor='01;33'
dircolor='01;34'
case "$TERM" in
  *-256color)
  usercolor='38;5;184'
  dircolor='38;5;27'
  ;;
  *-88color|rxvt-unicode)
  usercolor='38;5;56'
  dircolor='38;5;23'
  ;;
  xterm*)
  usercolor='93'
  dircolor='94'
  ;;
esac
[ $UID = '0' ] && usercolor="01;37"

if [ -x /usr/bin/tty -o -x /usr/local/bin/tty ]; then
  ttybracket=" [`tty|sed -e s,^/dev/,,`]"
  ttyat="`tty|sed -e s,^/dev/,,`@"
fi

PS1='\[\e['$usercolor'm\]\u\[\e[00m\]@\[\e['$hostcolor'm\]\h\[\e[00m\]:\[\e['$dircolor'm\]\w\[\e[00m\]\$ '

case "$TERM" in
  screen*|xterm*|rxvt*|Eterm*|kterm*|dtterm*|ansi*|cygwin*)
    PS1='\[\e]1;'$ttyat'\h\007\e]2;\u@\h:\w'$ttybracket'\007\]'"$PS1"
  ;;
  linux*) ;;
  *)
  PS1='\u@\h:\w\$ '
  ;;
esac

case $TERM in
  screen*)
    PS1="$PS1"'\[\ek'"$ttyat`[ -n "$STY" ] || echo '\h'`"'\e\\\]'
    ;;
esac

alias sudo='sudo '

[ ! -f /etc/bash_completion ] || . /etc/bash_completion

unset hostcolor usercolor dircolor ttybracket ttyat

fi
