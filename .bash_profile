# ~/.bash_profile

. $HOME/.bashrc
test -f "$HOME/.profile.local" && . "$HOME/.profile.local"

[ -x /usr/games/fortune ] && [ "$SHLVL" -le 1 -a \( -z "$SSH_TTY" -o "$TERMCAP" \) ] && fortune
