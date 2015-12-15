#! sh

# This file is sourced into all Bourne compatible shells.

if [ -r "$HOME/.env.local" ]; then
  eval "`command grep '^[A-Z].*=' "$HOME/.env.local"|sed -e 's/^/export /'`"
fi

ENV="$HOME/.shrc"
BASH_ENV="$HOME/.zshenv"
export ENV BASH_ENV

ifs=$IFS
IFS=:
PATH=$HOME/.local/bin:$PATHPREPEND:$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:$PATH:/usr/sbin:/sbin
newpath=.git/safe/../../bin
for dir in ${path:-$PATH}; do
  case :$newpath: in
    *:$dir:*) ;;
    *) [ -z "$dir" -o ! -d "$dir" ] || newpath=$newpath:$dir ;;
  esac
done
PATH=$newpath

if [ -n "$ifs" ]; then
  IFS=$ifs
else
  unset IFS
fi
unset ifs dir newpath
export PATH

[ -n "$CLASSPATH" ] || CLASSPATH=.:$HOME/.java/*
[ -n "$RSYNC_RSH" ] || RSYNC_RSH='ssh -ax'
[ -n "$SRC" ] || SRC=$HOME/src
export CLASSPATH RSYNC_RSH SRC

ulim="ulimit -S -u"
$ulim >/dev/null 2>/dev/null || ulim="ulimit -S -p"
unum=2048
[ -z "$CRON" ] || unum=1536
cunum="`$ulim 2>/dev/null`"
case "$cunum" in [0-9]*) ;; *) cunum=65535 ;; esac
[ "$unum" -ge "$cunum" ] || $ulim "$unum" 2>/dev/null
unset ulim unum cunum
