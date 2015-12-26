#!/bin/sh
# vim:set et sw=2:

date
env
unset STY TMUX

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope setup"'
  tpope setup
fi
tpope cron --login

xset r rate 500 30
setxkbmap -option ctrl:nocaps,terminate:ctrl_alt_bksp

[ ! -x "`which bindkeys 2>/dev/null`" ] || xbindkeys -n &
[ ! -x "`which unclutter 2>/dev/null`" ] || unclutter -idle 10 -noevents &
if [ -x /usr/bin/gnome-keyring-daemon -a -z "$GNOME_KEYRING_CONTROL" ]; then
  eval "`gnome-keyring-daemon`"
fi
[ ! -x "`which pulseaudio 2>/dev/null`" ] || pulseaudio --start
[ ! -x "`which bluetooth-applet 2>/dev/null`" ] || bluetooth-applet &
[ ! -x "`which nm-applet 2>/dev/null`" ] || nm-applet &
[ ! -x /usr/lib/notify-osd/notify-osd ] || /usr/lib/notify-osd/notify-osd &
[ ! -x "`which gtk-redshift 2>/dev/null`" ] || gtk-redshift -l 40:-74 -t 6500:3700 &

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

xsetroot -solid '#111111'
[ ! -x "$HOME/.fehbg" ] || "$HOME/.fehbg"

if [ $# -gt 0 ]; then
  exec "$@"
fi

for wm in $wm awesome xmonad icewm fluxbox twm xterm; do
  type $wm >/dev/null && exec $wm
done
