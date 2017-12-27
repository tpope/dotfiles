# ~/.profile

PATH=$HOME/.local/bin:/usr/local/bin:${PATH:-/usr/bin:/bin}:/usr/sbin:/sbin
ENV=$HOME/.shrc
BASH_ENV=$HOME/.zshenv
[ -n "$RSYNC_RSH" ] || RSYNC_RSH='ssh -ax'
export PATH ENV BASH_ENV RSYNC_RSH

if [ -r "$HOME/.env.local" ]; then
  eval "`command grep '^[A-Z].*=' "$HOME/.env.local"|sed -e 's/^/export /'`"
fi

[ -z "$ZSH_VERSION" ] || setopt shwordsplit
[ ! -r "$HOME/.profile.local" ] || . "$HOME/.profile.local"

if [ -z "$PAGER" ] && type less >/dev/null 2>&1; then
  PAGER=less
  export PAGER
fi
LESS="FXRq#10"
if [ -z "$LESSOPEN" ] && type lesspipe >/dev/null 2>&1; then
  LESSOPEN='|lesspipe %s'
elif [ -z "$LESSOPEN" ]; then
  LESSOPEN='|"$HOME/.lessfilter" %s'
fi
if [ -z "$VISUAL" ]; then
  type vim >/dev/null 2>&1 && VISUAL=vim || VISUAL=vi
fi
EDITOR=$VISUAL
BROWSER="tpope browser"
export LESS LESSOPEN VISUAL EDITOR

IFS=:
newpath=.git/safe/../../bin:$HOME/.local/bin
for dir in $PATHPREPEND $PATH; do
  case :$newpath: in
    *:$dir:*) ;;
    *) [ -z "$dir" -o ! -d "$dir" ] || newpath=$newpath:$dir ;;
  esac
done
PATH=$newpath

unset IFS dir newpath
[ -z "$ZSH_VERSION" ] || setopt noshwordsplit

if [ -t 1 ] && expr "$-" : '.*i' >/dev/null; then
  if [ -f "$HOME/.hushlogin" ]; then
    if [ -x /usr/bin/finger ]; then
      finger $LOGNAME | grep '^New mail' >/dev/null && echo "You have new mail."
    elif [ -f "$MAIL" ]; then
      find "$MAIL" -newerma "$MAIL" -exec echo 'You have new mail.' \;
    fi
  fi

  if [ ! -f "$HOME/. tpope" ]; then
    echo 'Performing an initial "tpope setup"'
    tpope setup
  elif [ -x /usr/games/fortune ] && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ]; then
    /usr/games/fortune
  fi

  tpope cron --login
fi
