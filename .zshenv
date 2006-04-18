# ~/.zshenv
# $Id$

typeset -U path
for dir in /usr/ucb /usr/local/bin /opt/local/bin /opt/sfw/bin "$HOME/bin"; do
    [ -d "$dir" ] && path=($dir $path)
done
for dir in /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/bin/surfraw-elvi /usr/local/sbin /usr/sbin /sbin /usr/etc; do
    [ -d "$dir" ] && path=($path $dir)
done
path=($HOME/bin /usr/bin /bin $path /usr/bin/X11 /usr/games /usr/local/sbin /usr/sbin /sbin)

if [ -f "$HOME/.locale" -a -z "$LANG" -a -z "$LC_ALL" ]; then
    LANG="`cat "$HOME/.locale"`"
    export LANG
fi

CLASSPATH=.
[ -d "$HOME/java" ]  && CLASSPATH="$CLASSPATH$HOME/java"
[ -d "$HOME/.java" ] && CLASSPATH="$CLASSPATH$HOME/.java"

for dir in "$HOME/.perl5" "$HOME/perl5" "$HOME/.perl" "$HOME/perl"; do
    case ":$PERL5LIB:" in
        *:"$dir":*) ;;
        *) [ ! -d "$dir" ] || PERL5LIB="$PERL5LIB$dir"
    esac
done
PERL5LIB="`echo "$PERL5LIB"|sed -e s/^://`"
[ ! -f "$HOME/.perl/Echo.pm" ] || case "$PERL5OPT" in
   *Echo*) ;;
   '') PERL5OPT="-MEcho" ;;
   *)  PERL5OPT="$PERL5OPT -MEcho" ;;
esac

#case "$LD_PRELOAD" in *libtrash*) ;; *)
#if [ -f /usr/lib/libtrash/libtrash.so -a -f "$HOME/.libtrash" ]; then
#    LD_PRELOAD="$LD_PRELOAD${LD_PRELOAD:+:}/usr/lib/libtrash/libtrash.so"
#    export LD_PRELOAD LD_PRELOAD_SCREEN="$LD_PRELOAD"
#fi ;; esac

export ENV="$HOME/.shrc" CLASSPATH PERL5LIB PERL5OPT

if [ -t 1 ]; then
    case $TERM in
    Eterm*) print -Pn "\e]I%m.xpm\e\\" ;;
    esac
fi
