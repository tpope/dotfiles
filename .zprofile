# ~/.zprofile

[ ! -f "$HOME/.profile.local" ] || . "$HOME/.profile.local"
[[ -o interactive ]] || . "$HOME/.shrc"
