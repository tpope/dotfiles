# ~/.profile
# Author: Tim Pope

interactive=1
if [ "`basename $0`" = ash ]; then
    ENV="$HOME/.bashrc"
else
    ENV="$HOME/.shrc"
    . $ENV
fi
export ENV
unset interactive

test -f "$HOME/.profile.local" && . "$HOME/.profile.local"

[ -x /usr/games/fortune ] && [ -z "$SSH_TTY" -o "$SHLVL" > 1 -o "$TERMCAP" ] \
    && /usr/games/fortune
