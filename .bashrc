# ~/.bashrc
# $Id$

[ "$PS1" ] && interactive=1
export ENV="$HOME/.shrc"
. $ENV
unset interactive

if [ "$PS1" ]; then
# If running interactively, then:

#set -o noclobber

hostname=`hostname|sed -e 's/[.].*//'`

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

if [ -x "$HOME/bin/hostinfo" ]; then
    hostcolor=`$HOME/bin/hostinfo -c`
    hostletter=`$HOME/bin/hostinfo -l`
    hostcode=`$HOME/bin/hostinfo -s`
else
    hostcolor="01;37"
    hostletter=
    hostcode="+b W"
fi

[ "$UID" ] || UID=`id -u`
usercolor="01;33" && usercode="+b Y"
[ $UID = '0' ] && usercolor="01;37" && usercode="+b W"


if [ -x /usr/bin/tty -o -x /usr/local/bin/tty ]; then
    ttyslash=" [`tty|sed -e s,^/dev/,, -e s/^tty//`]"
    ttydash="`tty|sed -e s,^/dev/,, -e s/^tty// -e s,/,-,g`@"
fi

PS1='\[\e['$usercolor'm\]\u\[\e[00m\]@\[\e['$hostcolor'm\]\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '

#if [ "`basename $0`" = bash ]; then
    bind '"\e[1~": beginning-of-line'
    bind '"\e[3~": delete-char'
    bind '"\e[4~": end-of-line'
#fi
[ "$OLDTERM" ] && TERM=$OLDTERM
case $TERM in
screen*|vt220*)
    PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;\005{'"$usercode}${LOGNAME/\\\\/\\0134}\005{-}@\005{$hostcode}${hostname}\005{-}:\005{+b B}"'`echo ${PWD}|sed -e s,$HOME,~,`'"\005{-}\005{k}${ttyslash}\005{-}"'\007\033k'"${ttydash}${hostname}"'\033\\"'
    #PROMPT_COMMAND='\033]2;\005{'"$usercode}${LOGNAME}\005{-}@\005{$hostcode}${hostname}\005{-}:\005{+b B}"'`echo ${PWD}|sed -e s,$HOME,~,`'"\005{-}\005{k}${ttyslash}\005{-}"'\007\033k'"${ttydash}${hostname}"'\033\\"'
;;
xterm*|rxvt*|kterm*|dtterm*|cygwin*)
    # If this is an xterm set the title to user@host:dir [tty]
    PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;'"${LOGNAME}@${hostname}"':`echo ${PWD}|sed -e s,$HOME,~,`'"${ttyslash}"'\007"'
    ;;
Eterm*)
    # If this is an Eterm set the title to user@host:dir [tty]
    PROMPT_COMMAND='echo -ne "\033]1;'"${ttydash}${hostname}"'\007\033]2;'"${LOGNAME}@${hostname}"':`echo ${PWD}|sed -e s,$HOME,~,`'"${ttyslash}"'\007\033]I'"$hostname"'.xpm\033\\"'
    ;;
linux*) ;;
*)
    PS1=$hostletter'\$ '
    ;;
esac

fi
which sudo >/dev/null 2>&1 && alias sudo='sudo '

unset hostname hostcolor hostletter hostcode usercolor usercode ttyslash ttydash
