# ~/.zshenv
# $Id$

typeset -U path
for dir in /usr/ucb /usr/local/bin /opt/sfw/bin "$HOME/bin"; do
    [ -d "$dir" ] && path=($dir $path)
done
for dir in /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/bin/surfraw-elvi /usr/local/sbin /usr/sbin /sbin; do
    [ -d "$dir" ] && path=($path $dir)
done
path=($HOME/bin $path /usr/bin /bin /usr/bin/X11 /usr/games /usr/local/sbin /usr/sbin /sbin)

CLASSPATH=.
[ -d "$HOME/java" ]  && CLASSPATH="$CLASSPATH$HOME/java"
[ -d "$HOME/.java" ] && CLASSPATH="$CLASSPATH$HOME/.java"
PERL5LIB="$HOME/.perl5:$HOME/perl5:$HOME/.perl:$HOME/perl"

#case "$LD_PRELOAD" in *libtrash*) ;; *)
#if [ -f /usr/lib/libtrash/libtrash.so -a -f "$HOME/.libtrash" ]; then
#    LD_PRELOAD="$LD_PRELOAD${LD_PRELOAD:+:}/usr/lib/libtrash/libtrash.so"
#    export LD_PRELOAD LD_PRELOAD_SCREEN="$LD_PRELOAD"
#fi ;; esac

export ENV="$HOME/.shrc"

if [ -t 1 ]; then
    case $TERM in
    Eterm*) print -Pn "\e]I%m.xpm\e\\" ;;
    esac
fi
