# ~/.bash_profile

[ ! -f "$HOME/.profile.local" ] || . "$HOME/.profile.local"
case $- in
  *i*) . "$HOME/.bashrc" ;;
  *) . "$HOME/.shrc" ;;
esac
. "$HOME/.zlogin"
