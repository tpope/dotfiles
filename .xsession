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

xsetroot -solid '#000840'

[ ! -f "$HOME/.xsession.local" ] || . "$HOME/.xsession.local"

rm -f "$HOME/.env.$DISPLAY"
touch "$HOME/.env.$DISPLAY"
chmod 0600 "$HOME/.env.$DISPLAY"
for var in DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS SSH_AGENT_PID SSH_AUTH_SOCK GNOME_KEYRING_PID; do
  eval val=\$$var
  if [ -n "$val" ]; then
    echo "$var='$val'" >> "$HOME/.env.$DISPLAY"
    exports="$exports $var"
    if [ "$DISPLAY" = ":0" ]; then
      screen -S `tpope host name` -X setenv $var "$val" 2>/dev/null
      tmux setenv -g $var "$val" 2>/dev/null
    fi
  fi
done
[ -z "$exports" ] || echo "export$exports" >> "$HOME/.env.$DISPLAY"

if [ $# -gt 0 ]; then
  exec "$@"
fi

for wm in $wm awesome xmonad icewm fluxbox twm xterm; do
  type $wm >/dev/null && exec $wm
done
