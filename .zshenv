# ~/.zshenv

if [ -z "$ENV" -a -n "$PATH" ]; then
  case $- in
    *l*) ;;
    *) . "$HOME/.profile" >/dev/null ;;
  esac
fi
