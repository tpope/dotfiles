# ~/.bash_profile
# $Id$

. $HOME/.bashrc
test -f "$HOME/.profile.local" && . "$HOME/.profile.local"

if [ ! -f "$HOME/. tpope" ]; then
    echo 'Performing an initial "tpope install"'
    "$HOME/bin/tpope" install
elif [ -x /usr/games/fortune ] && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ]; then
    /usr/games/fortune
fi
