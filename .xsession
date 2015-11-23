#!/bin/sh
# vim:set et sw=2:

date
env
PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11"
. "$HOME/.zshenv"
unset STY TMUX

BROWSER="tpope browse"
TERMINAL="$HOME/bin/x-terminal-emulator"
export TERMINAL BROWSER

xsetroot -solid '#000420'
xset r rate 600 30
xset b 40 440 60
xset dpms 600

if [ -f "$HOME/.xmodmap" ]; then
  xmodmap "$HOME/.xmodmap"
else
  setxkbmap -option ctrl:nocaps
fi

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope install"'
  tpope install
fi
tpope cron --login

if [ -x /usr/bin/ssh-agent -a -z "$SSH_AUTH_SOCK" ]; then
  sshagent="/usr/bin/ssh-agent --"
fi

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

{
  while xrandr --auto; do
    sleep 5
  done
} &

if [ $# -gt 0 ]; then
  exec "$@"
fi

for wm in $wm awesome xmonad icewm fluxbox twm xterm; do
  type $wm >/dev/null && exec $execpre $wm
done
