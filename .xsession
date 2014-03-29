#!/bin/sh
# vim:set et sw=2:

date
env
PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11"
. "$HOME/.zshenv"
unset STY TMUX

BROWSER="$HOME/bin/sensible-browser"
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

{
  while xrandr --auto; do
    sleep 5
  done
} &

for wm in awesome fvwm2 icewm startkde fluxbox enlightenment mwm twm xterm; do
  [ -x "`which $wm 2>/dev/null`" ] && exec $sshagent $wm
done
