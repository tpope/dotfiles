#!/bin/bash
# Author: Tim Pope

PATH="$HOME/bin:/usr/local/bin:/usr/bin/X11:/usr/bin:/bin:/usr/games"
[ -n "$ENV" ] || ENV="$HOME/bin/.shrc"
. "$ENV"
[ -x /bin/zsh ] && export SHELL=/bin/zsh
unset STY

xsetroot -solid '#001010'
xset m 3 3
[ "`hostname`" = lisa ] && xset m 4 3
[ "`hostname`" = mona ] && xset m 3 20
xset r rate 600 30
xset b 40 440 60

hosts="marge bart maggie lisa homer abe mona"
dpy=`echo ${DISPLAY:-:0.0} | sed -e 's/localhost//'`
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
		xauth -i extract - $hname$dpy | ssh -oBatchmode=yes $host xauth merge - &
	done
fi

( [ -d /KNOPPIX ] && ping -c 1 www.sexygeek.org && \
  wget -qO- -T10 http://www.sexygeek.org/tpope.tar.gz|gzip -dc|tar xpC "$HOME" -f - || true
) >/dev/null 2>&1 &

export ESPEAKER="$hname" RPLAY_HOST="$hname"
export WINDOW_MANAGER="fvwm2"

hostname="`hostname|sed -e 's/[.].*//'`"
[ ! -e "$HOME/.pixmaps/.localhost.xpm" ] && ln -s "$hostname.xpm" "$HOME/.pixmaps/.localhost.xpm"
if [ ! -e "$HOME/.pixmaps/$hostname.xpm" ]; then
    ln -s "unknown.xpm" "$HOME/.pixmaps/$hostname.xpm"
    echo "Warning: No host picture found." >&2
fi


#xrdb -merge $HOME/.Xresources

[ ! -x /usr/bin/ssh-askpass ] || export SSH_ASKPASS=/usr/bin/ssh-askpass

if [ -x /usr/bin/ssh-agent -a -z "$SSH_AUTH_SOCK" ]; then
    sshagent="/usr/bin/ssh-agent --"
fi

[ ! -x /bin/pidof ] || [ -z "`pidof q-agent`" ] || kill `pidof q-agent`

[ -f "$HOME/.xsession-local" ] && . "$HOME/.xsession-local"

wait

[ ! -x "`which xscreensaver`" ] || nice -n 2 xscreensaver -no-splash >/dev/null 2>/dev/null &
[ ! -x "`which unclutter`" ] || unclutter -idle 10 &
[ ! -x "`which imwheel`" ] || imwheel -k -b 000067 2>/dev/null &
[ ! -f "$HOME/.lircrc" ] || irexec &
[ ! -x /usr/bin/q-agent ] || eval `/usr/bin/q-agent &`
[ "$GPG_AGENT_INFO" ] || export GPG_AGENT_INFO="$AGENT_SOCKET"

case "$LD_PRELOAD" in *libtrash*) ;; *)
[ -f /usr/lib/libtrash/libtrash.so ] && LD_PRELOAD="$LD_PRELOAD${LD_PRELOAD:+:}/usr/lib/libtrash/libtrash.so"
export LD_PRELOAD
;; esac

xsetroot -solid '#002020'

if [ -x /usr/bin/fvwm2 -a -x /usr/bin/gnome-session -a -x /usr/bin/gnome-control-center ] && fvwm2 --version >/dev/null 2>&1; then
    exec $sshagent $wm
fi

for wm in fvwm2 startkde blackbox wmaker afterstep enlightenment mwm twm xterm; do
    [ -x "`which $wm`" ] && exec $sshagent $wm
done

#echo "Could not launch a window manager.  Aborting..." >&2
#exit 1
