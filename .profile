# ~/.profile

[ ! -f "$HOME/.profile.local" ] || . "$HOME/.profile.local"
[ -n "$ENV" ] || . "$HOME/.zshenv"
. "$HOME/.zlogin"
