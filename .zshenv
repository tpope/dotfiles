# ~/.zshenv
# $Id$

typeset -U path
for dir in /bin /usr/bin /usr/ucb /usr/local/bin /opt/local/bin /opt/sfw/bin "$HOME/bin"; do
    [ -d "$dir" ] && path=($dir $path)
done
for dir in /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/bin/surfraw-elvi /var/lib/gems/1.8/bin /usr/local/sbin /usr/sbin /sbin /usr/etc; do
    [ -d "$dir" ] && path=($path $dir)
done
path=($HOME/bin $path /usr/bin/X11 /usr/games /usr/local/sbin /usr/sbin /sbin)

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
[ ! -f "$HOME/.perl/TPope.pm" ] || case "$PERL5OPT" in
   *Echo*) ;;
   '') PERL5OPT="-MTPope" ;;
   *)  PERL5OPT="$PERL5OPT -MTPope" ;;
esac

for dir in "$HOME/.ruby/lib" "$HOME/ruby/lib" "$HOME/.ruby"; do
    case ":$RUBYLIB:" in
        *:"$dir":*) ;;
        *) [ ! -d "$dir" ] || RUBYLIB="$RUBYLIB$dir"
    esac
done
RUBYLIB="`echo "$RUBYLIB"|sed -e s/^://`"
[ ! -f "$HOME/.ruby/lib/tpope.rb" ] || RUBYOPT="rtpope"

export ENV="$HOME/.shrc" CLASSPATH PERL5LIB PERL5OPT

if false && [ -t 1 ]; then
    local tinfo=/usr/share/terminfo
    case "$TERM" in
        rxvt|rxvt-16color|rxvt-unicode)
        if  [ -f $tinfo/r/rxvt-unicode -o -f $tinfo/72/rxvt-unicode ]; then
            TERM=rxvt-unicode
        elif [ -f $tinfo/r/rxvt-16color -o -f $tinfo/72/rxvt-16color ]; then
            TERM=rxvt-16color
        else
            TERM=rxvt
        fi
        ;;
        xterm|xterm-256color|xterm-256color)
        if [ -f $tinfo/x/xterm-256color -o -f $tinfo/78/xterm-256color ]; then
            TERM=xterm-256color
        else
            TERM=xterm
        fi
        ;;
    esac
    unset tinfo
fi
