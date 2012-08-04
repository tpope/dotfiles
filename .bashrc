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

shopt -s extglob
set -o noclobber

# don't put duplicate lines in the history
export HISTCONTROL=ignoredups
# In fact, let's not use a history file at all
export HISTFILE=

if [ -x "$HOME/bin/tpope" ]; then
  hostname=`"$HOME/bin/tpope" hostman`
  hostcolor=`"$HOME/bin/tpope" hostman -c`
  hostcode=`"$HOME/bin/tpope" hostman -s`
else
  hostname=`hostname`
  hostcolor="01;37"
  hostcode="+b W"
fi

[ "$UID" ] || UID=`id -u`
usercolor="01;33" && usercode="+b Y"
dircolor='01;34'
case "$TERM" in
  screen*)
  usercolor='38;5;184'
  dircolor='38;5;27'
  ;;
  xterm*|rxvt-unicode)
  usercolor='93'
  dircolor='94'
  ;;
esac
[ $UID = '0' ] && usercolor="01;37" && usercode="+b W"


if [ -x /usr/bin/tty -o -x /usr/local/bin/tty ]; then
  ttyslash=" [`tty|sed -e s,^/dev/,, -e s/^tty//`]"
  ttydash="`tty|sed -e s,^/dev/,, -e s/^tty// -e s,/,-,g`@"
fi

PS1='\[\e['$usercolor'm\]\u\[\e[00m\]@\[\e['$hostcolor'm\]\h\[\e[00m\]:\[\e['$dircolor'm\]\w\[\e[00m\]\$ '

[ "$OLDTERM" ] && TERM=$OLDTERM
case $TERM in
  screen*|vt220*)
  if [ "$STY" ]; then
    PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;\005{'"$usercode}${LOGNAME/\\\\/\\0134}\005{-}@\005{$hostcode}${hostname}\005{-}:\005{+b B}"'`echo ${PWD}|sed -e "s,$HOME,~,"`'"\005{-}\005{k}${ttyslash}\005{-}"'\007\033k'"${ttydash}"'\033\\"'
  else
    PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;\005{'"$usercode}${LOGNAME/\\\\/\\0134}\005{-}@\005{$hostcode}${hostname}\005{-}:\005{+b B}"'`echo ${PWD}|sed -e "s,$HOME,~,"`'"\005{-}\005{k}${ttyslash}\005{-}"'\007\033k'"${ttydash}${hostname}"'\033\\"'
  fi
  ;;
  xterm*|rxvt*|Eterm*|kterm*|dtterm*|ansi*|cygwin*)
  # If this is an xterm set the title to user@host:dir [tty]
  PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;'"${LOGNAME}@${hostname}"':`echo ${PWD}|sed -e "s,$HOME,~,"`'"${ttyslash}"'\007"'
  ;;
  linux*) ;;
  *)
  if [ -x "$HOME/bin/tpope" ]; then
    hostletter=`"$HOME/bin/tpope" hostman -l`
  fi
  PS1=$hostletter'\$ '
  unset hostletter
  ;;
esac

fi

alias sudo='sudo '

[ ! -f /etc/bash_completion ] || . /etc/bash_completion

unset hostname hostcolor hostcode usercolor usercode dircolor ttyslash ttydash
