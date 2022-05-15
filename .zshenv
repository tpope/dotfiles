# ~/.zshenv

if [ -z "$ENV" -a -n "$PATH" ]; then
  case $- in
    *l*) ;;
    *)
      if [ -n "$ZSH_VERSION" ]; then
        emulate sh -c '. "$HOME/.profile"' >/dev/null
      else
        . "$HOME/.profile" >/dev/null
      fi
      ;;
  esac
fi
