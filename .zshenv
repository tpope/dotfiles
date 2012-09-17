# ~/.zshenv
# vim:set et sw=2:

typeset -U path
for dir in /bin /usr/ucb /usr/local/bin /opt/local/bin /opt/sfw/bin "$HOME/bin"; do
  [ -d "$dir" ] && path=($dir $path)
done
for dir in /usr/bin /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/bin/surfraw-elvi /var/lib/gems/1.9.1/bin /var/lib/gems/1.8/bin /usr/local/sbin /usr/sbin /sbin /usr/etc; do
  [ -d "$dir" ] && path=($path $dir)
done
path=($HOME/bin $path /usr/bin/X11 /usr/games /usr/local/sbin /usr/sbin /sbin)

if [ -f "$HOME/.locale" -a -z "$LANG" -a -z "$LC_ALL" ]; then
  LANG="`cat "$HOME/.locale"`"
  export LANG
fi

CLASSPATH=.
[ -d "$HOME/java" ]  && CLASSPATH="$CLASSPATH:$HOME/java"
[ -d "$HOME/.java" ] && CLASSPATH="$CLASSPATH:$HOME/.java"

for dir in "$HOME/.perl5" "$HOME/perl5" "$HOME/.perl" "$HOME/perl"; do
  case ":$PERL5LIB:" in
    *:"$dir":*) ;;
  *) [ ! -d "$dir" ] || PERL5LIB="$PERL5LIB:$dir"
esac
done
PERL5LIB="`echo "$PERL5LIB"|sed -e s/^://`"

RUBYLIB="$HOME/src/ruby/lib:$HOME/.ruby/lib"

export ENV="$HOME/.shrc" CLASSPATH PERL5LIB PERL5OPT RUBYLIB
