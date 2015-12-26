#!/bin/sh
# vim:set et sw=2:

unset STY TMUX

date >&2
env >&2

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope setup"'
  tpope setup
fi
tpope cron --login

xset r rate 500 30
setxkbmap -option ctrl:nocaps,terminate:ctrl_alt_bksp

[ ! -f "$HOME/.xsession.local" ] || . "$HOME/.xsession.local"

: > "$HOME/.env.$DISPLAY"
chmod 0600 "$HOME/.env.$DISPLAY"
for var in DISPLAY XAUTHORITY DESKTOP_SESSION GDMSESSION \
  XDG_SEAT XDG_SEAT_PATH XDG_SESSION_TYPE XDG_SESSION_ID XDG_VTNR \
  XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_CONFIG_DIRS XDG_DATA_DIRS \
  XDG_RUNTIME_DIR XDG_GREETER_DATA_DIR MANDATORY_PATH DEFAULTS_PATH \
  DBUS_SESSION_BUS_ADDRESS SSH_AGENT_PID SSH_AUTH_SOCK GNOME_KEYRING_PID; do
  eval val=\$$var
  if [ -n "$val" ]; then
    echo "$var='$val'" >> "$HOME/.env.$DISPLAY"
    exports="$exports $var"
    if [ "$DISPLAY" = ":0" ]; then
      screen -S `tpope host name` -X setenv $var "$val" >/dev/null 2>&1
      tmux setenv -g $var "$val" 2>/dev/null
    fi
  fi
done
[ -z "$exports" ] || echo "export$exports" >> "$HOME/.env.$DISPLAY"

if [ $# = 0 ]; then
  set -- x-terminal-emulator
  for wm in $wm awesome xmonad gnome-session lxsession twm; do
    if type $wm >/dev/null 2>&1; then
      set -- $wm
      break
    fi
  done
fi

case $1 in
  *xmonad-session) ;;
  *start*|*session|true) exec "$@" ;;
esac

xsetroot -solid '#111111'
[ ! -x "$HOME/.fehbg" ] || "$HOME/.fehbg"

"$@" &
wmpid=$!

sleep 0.1

: ${XDG_CURRENT_DESKTOP:=${XDG_SESSION_DESKTOP:-${GDMSESSION:-Old}}}
if type xdg-autostart >/dev/null 2>&1; then
  xdg-autostart "$XDG_CURRENT_DESKTOP"
elif type dex >/dev/null 2>&1; then
  dex -a -e "$XDG_CURRENT_DESKTOP"
elif type lxsession-xdg-autostart >/dev/null 2>&1; then
  lxsession-xdg-autostart -d "$XDG_CURRENT_DESKTOP"
elif type fbautostart >/dev/null 2>&1; then
  FBXDG_DE="$XDG_CURRENT_DESKTOP" fbautostart
elif type xbindkeys >/dev/null 2>&1; then
  xbindkeys -n &
fi

wait $wmpid
