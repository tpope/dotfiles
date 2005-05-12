#!/bin/sh
# $Id$
# -*- sh -*- vim: ft=sh sw=4 sts=4

PATH="$HOME/bin:/usr/local/bin:/usr/bin/X11:/usr/bin:/bin:/usr/games"
[ -n "$ENV" ] || ENV="$HOME/.shrc"
. "$ENV"
[ ! -x /bin/zsh ] || SHELL=/bin/zsh
unset STY

xsetroot -solid '#001010'

hosts="marge bart maggie lisa homer mona"
dpy=`echo ${DISPLAY:-':0.0'} | sed -e 's/localhost//'`
if echo $dpy|grep '^:' >/dev/null; then
    hname=`hostname`
else
    hname=`echo $dpy|cut -d: -f 1`
    dpy=":`echo $dpy|cut -d: -f 2`"
fi
echo "I believe $DISPLAY is actually $hname $dpy."

if ! xauth list "$hname$dpy" >/dev/null; then
    echo "Warning: $hname$dpy not found in xauth list!" >&2
fi

if /sbin/ifconfig | grep '172\.28\.6' >/dev/null; then
    for host in $hosts; do
	xauth -i extract - $hname$dpy | ssh -axqoBatchmode=yes $host xauth merge - &
    done
fi

xset m 3 3
xset r rate 600 30
xset b 40 440 60

[ ! -f "$HOME/.xmodmap" ] || xmodmap "$HOME/.xmodmap"

if [ ! -f "$HOME/.xmodmap" -a ! -f "$HOME/.Xmodmap" ] && \
	xmodmap 2>/dev/null|grep Super >/dev/null; then
    xmodmap -e "keysym Super_L = Hyper_L"
    xmodmap -e "keysym Caps_Lock = Super_L"
    xmodmap -e "keysym Scroll_Lock = Hyper_R Scroll_Lock"
    xmodmap -e "keysym Menu = Caps_Lock"
    xmodmap -e "clear lock"
    xmodmap -e "clear Mod4"
    xmodmap -e "clear Mod5"
    xmodmap -e "add lock = Caps_Lock"
    xmodmap -e "add Mod4 = Super_L Super_R"
    xmodmap -e "add Mod4 = Hyper_L Hyper_R"
fi

ESPEAKER="$hname"
RPLAY_HOST="$hname"
WINDOW_MANAGER="fvwm2"
export ESPEAKER RPLAY_HOST WINDOW_MANAGER

hostname="`hostname|sed -e 's/[.].*//'`"
if [ ! -f "$HOME/. tpope" ]; then
    echo 'Performing an initial "tpope install"'
    "$HOME/bin/tpope" install
fi
tpope cron --login

#xrdb -merge $HOME/.Xresources

#[ ! -x /usr/bin/ssh-askpass ] || export SSH_ASKPASS=/usr/bin/ssh-askpass

if [ -x /usr/bin/ssh-agent -a -z "$SSH_AUTH_SOCK" ]; then
    sshagent="/usr/bin/ssh-agent --"
fi

[ ! -x /bin/pidof ] || [ -z "`pidof q-agent`" ] || kill `pidof q-agent`

wait

[ ! -x "`which xscreensaver 2>/dev/null`" ] || nice -n 2 xscreensaver -no-splash >/dev/null 2>/dev/null &
#[ ! -x "`which btcid-launch 2>/dev/null`" ] || btcid-launch
[ ! -x "`which unclutter 2>/dev/null`" ] || unclutter -idle 10 &
[ ! -x "`which imwheel 2>/dev/null`" ] || imwheel -k -b 000067 2>/dev/null &
[ ! -f "$HOME/.lircrc" ] || irexec &
[ ! -f "$HOME/.lircrc" ] || irxevent &
[ ! -x /usr/bin/q-agent ] || eval `/usr/bin/q-agent &`
[ "$GPG_AGENT_INFO" -o -z "$AGENT_SOCKET" ] || export GPG_AGENT_INFO="$AGENT_SOCKET"

xsetroot -solid '#002020'

[ -f "$HOME/.xsession.local" ] && . "$HOME/.xsession.local"

#if [ -x /usr/bin/fvwm2 -a -x /usr/bin/gnome-session -a -x /usr/bin/gnome-control-center ] && fvwm2 --version >/dev/null 2>&1; then
#    exec $sshagent gnome-session
#fi

for wm in fvwm2 startkde blackbox wmaker afterstep enlightenment mwm twm xterm; do
    [ -x "`which $wm`" ] && exec $sshagent $wm
done

#echo "Could not launch a window manager.  Aborting..." >&2
#exit 1
