# ~/.profile

interactive=1
ENV="$HOME/.shrc"
export ENV
. $ENV
unset interactive

. "$HOME/.zlogin"
