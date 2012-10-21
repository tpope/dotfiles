# ~/.zshenv
# vim:set et sw=2:

case ":$PATH:" in
  *:"$HOME/bin":*) ;;
  *) PATH="$HOME/bin:$PATH" ;;
esac

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
