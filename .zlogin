#!/bin/zsh

test -f "$HOME/.profile.local" && . "$HOME/.profile.local"
which fortune >/dev/null && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ] && fortune

if [ -f /tmp/ups-batt-flag ]; then
    echo
    cat /tmp/ups-batt-flag
fi
