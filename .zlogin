# ~/.zlogin
# $Id$

test -f "$HOME/.profile.local" && . "$HOME/.profile.local"
if [ ! -f "$HOME/. tpope" ]; then
    echo 'Performing an initial "tpope install"'
    "$HOME/bin/tpope" install
else
    which fortune >/dev/null && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ] && fortune
fi

if [ -f /tmp/ups-batt-flag ]; then
    echo
    cat /tmp/ups-batt-flag
fi
