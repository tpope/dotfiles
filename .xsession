#!/bin/sh
# vi: set et sw=2:

PATH="$HOME/bin:/usr/local/bin:/usr/bin/X11:/usr/bin:/bin:/usr/games"
[ -n "$ENV" ] || ENV="$HOME/.shrc"
. "$ENV"
unset STY

xsetroot -solid '#000420'
xset r rate 600 30
xset b 40 440 60

if [ -f "$HOME/.xmodmap" ]; then
  xmodmap "$HOME/.xmodmap"
else
  xmodmap -e "keysym Caps_Lock = Control_L"
  xmodmap -e "keysym Scroll_Lock = Caps_Lock Scroll_Lock"
  xmodmap -e "clear control"
  xmodmap -e "clear lock"
  xmodmap -e "add lock = Caps_Lock"
  xmodmap -e "add control = Control_L Control_R"
fi

if [ ! -f "$HOME/. tpope" ]; then
  echo 'Performing an initial "tpope install"'
  tpope install
fi
tpope cron --login

if [ -x /usr/bin/ssh-agent -a -z "$SSH_AUTH_SOCK" ]; then
  sshagent="/usr/bin/ssh-agent --"
fi

if [ -x "`which xscreensaver 2>/dev/null`" ]; then
  nice -n 2 xscreensaver -no-splash >/dev/null 2>/dev/null &
fi

[ ! -x "`which unclutter 2>/dev/null`" ] || unclutter -idle 10 -noevents &
[ ! -x "`which pulseaudio 2>/dev/null`" ] || pulseaudio &
[ ! -x "`which bluetooth-applet 2>/dev/null`" ] || bluetooth-applet &

xsetroot -solid '#000840'

[ ! -f "$HOME/.xsession.local" ] || . "$HOME/.xsession.local"

if [ -n "$GNOME_FVWM" -a -x /usr/bin/fvwm2 -a -x /usr/bin/gnome-session -a -x /usr/bin/gnome-control-center ] && fvwm2 --version >/dev/null 2>&1; then
  export WINDOW_MANAGER=fvwm2
  exec $sshagent gnome-session
fi

for wm in fvwm2 icewm startkde fluxbox enlightenment mwm twm xterm; do
  [ -x "`which $wm 2>/dev/null`" ] && exec $sshagent $wm
done
