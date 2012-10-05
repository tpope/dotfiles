# ~/.zlogin

test ! -f "$HOME/.profile.local" || . "$HOME/.profile.local"

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope install"'
  "$HOME/bin/tpope" install
elif [ -x /usr/games/fortune ] && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ]; then
  /usr/games/fortune
fi

if [ -f "$HOME/.hushlogin" -a -f "$MAIL" ]; then
  if [ -x /usr/bin/finger ]; then
    finger $LOGNAME | grep '^New mail' >/dev/null 2>&1 && echo "You have new mail."
  else
    find "$MAIL" -newerma "$MAIL" -exec echo 'You have new mail.' \;
  fi
fi

tpope cron --login
