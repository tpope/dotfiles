# ~/.login

if ( -f "$HOME/.login.local" ) source "$HOME/.login.local"

if ( ! -f "$HOME/. tpope" ) then
    echo 'Performing an initial "tpope install"'
    "$HOME/bin/tpope" install
else if ( ! $?SHLVL && ( ! $?SSH_TTY || $?TERMCAP ) ) then
    if ( -x /usr/games/fortune ) /usr/games/fortune
endif

if ( $?MAIL && -f "$HOME/.hushlogin" && -f "$MAIL" ) then
  find "$MAIL" -newerma "$MAIL" -exec echo 'You have new mail.' \;
endif

tpope cron --login
