# ~/.zlogin

test ! -f "$HOME/.profile.local" || . "$HOME/.profile.local"

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope setup"'
  tpope setup
elif [ -x /usr/games/fortune ] && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ]; then
  /usr/games/fortune
fi

if [ -f "$HOME/.hushlogin" ]; then
  if [ -x /usr/bin/finger ]; then
    finger $LOGNAME | grep '^New mail' >/dev/null 2>&1 && echo "You have new mail."
  elif [ -f "$MAIL" ]; then
    find "$MAIL" -newerma "$MAIL" -exec echo 'You have new mail.' \;
  fi
fi

tpope cron --login
