;; vim:set lispwords+=xbind,xbindmod,xbindmods:

;; /usr/include/X11/keysymdef.h
;; /usr/include/X11/XF86keysym.h
;; /usr/share/doc/xbindkeys/examples/xbindkeysrc.scm.gz

(putenv "TMUX")
(putenv "TMUX_PANE")
(putenv "STY")
(putenv "WINDOWID")

(define mod
  (string->symbol (or (getenv "XBINDKEYS_MOD") "mod4")))

(define (xbind keys command)
  (if (string? command)
    (xbindkey keys command)
    (xbindkey-function keys command)))

(define (xbindmod keys command)
  (xbind (cons mod keys) command))

(define (xbindmods keys command)
  (unless (cdr keys)
    (xbind (cons* 'control 'shift mod keys) command))
  (if (eq? mod 'mod1)
    (xbind (cons* 'mod4 mod keys) command)
    (xbind (cons* 'mod1 mod keys) command)))

(define active-window
  "`xprop -root _NET_ACTIVE_WINDOW|sed -e 's/.* //'`")

(define (toggle . commands)
  (let ((class (string-join commands "|")))
    (string-append
     "xdotool search --classname '" class "'|grep -q `xdotool getactivewindow` && "
     "wmctrl -c :ACTIVE: || "
     "xdotool search --classname '" class "' windowactivate || "
     "exec " (string-join commands " || "))))

(define xmessage
  (or (getenv "XMESSAGE")
      (if (access? "/usr/bin/gxmessage" X_OK)
        "gxmessage -wrap"
        "xmessage")))

(xbindmods '(a) "sleep 1; xdg-screensaver lock || xset dpms force standby")

(xbindmod '(control c)
  (string-append
    "xprop -id " active-window " -format _NET_WM_ICON  '32o'  ' = ...\n' |"
    xmessage " -default okay -title " active-window " -file -"))

(xbindmod '(x) "exec tpope browser")
(xbindmod '(control x) "exec xdg-open \"$HOME\"")

(xbindmod '(control z) "exec tpope terminal -e tpope host shell localhost")
(xbindmod '(mod1 z) "xdotool search --classname '^mux@localhost$' windowactivate || exec tpope terminal -e tpope host mux localhost")
(xbindmod '(z) "xdotool search --desktop `xdotool get_desktop` --classname '@localhost$' windowactivate || xdotool search --classname '@localhost$' windowactivate")

(xbindmod '(shift p) "dmenu_run")

(xbindmod '(control a)
  "if xdotool getmouselocation 2>/dev/null | grep 'y:0 ' >/dev/null; then
    import -window root \"$HOME/Pictures/Screenshots/`date +%Y-%m-%d_%H-%M-%S`_Screenshot.png\"
  else
    import \"$HOME/Pictures/Screenshots/`date +%Y-%m-%d_%H-%M-%S`_`xdotool getactivewindow getwindowname | tr '[ /:~$]' '_'`.png\"
  fi")
(xbindmod '(shift control a)
  "import -window root \"$HOME/Pictures/Screenshots/`date +%Y-%m-%d_%H-%M-%S`_Screenshot.png\"")

;; ~/.local/bin/tpope-media

(xbindkey '(XF86AudioLowerVolume) "tpope media sink -5%")
(xbindkey '(XF86AudioRaiseVolume) "tpope media sink +5%")
(xbindkey '(XF86AudioMute) "tpope media sink toggle")
(xbindkey '(XF86AudioMicMute) "tpope media source toggle")

(xbindmod '(minus) "tpope media sink -5%")
(xbindmod '(shift minus) "tpope media sink -5% --current")
(xbindmod '(control minus) "tpope media sink prev")
(xbindmods '(minus) "tpope media sink prev --current")
(xbindmod '(equal) "tpope media sink +5%")
(xbindmod '(shift equal) "tpope media sink +5% --current")
(xbindmod '(control equal) "tpope media sink 100%")
(xbindmods '(equal) "tpope media sink 100% --current")

(xbindkey '(XF86AudioPrev) "tpope media prev")
(xbindkey '(XF86AudioNext) "tpope media next")
(xbindkey '(XF86AudioPlay) "tpope media toggle")
(xbindkey '(XF86AudioStop) "tpope media stop")

(xbindmod '(bracketleft) "tpope media rate - || tpope media prev")
(xbindmod '(bracketright) "tpope media rate + || tpope media next")
(xbindmod '(shift bracketleft) "tpope media prev")
(xbindmod '(shift bracketright) "tpope media next")
(xbindmod '(control bracketleft) "tpope media seek -5")
(xbindmod '(control bracketright) "tpope media seek +5")
(xbindmods '(bracketleft) "tpope media prev")
(xbindmods '(bracketright) "tpope media next")

(xbindmod '(backslash) "tpope media toggle")
(xbindmod '(shift backslash) "tpope media pause")
(xbindmod '(control backslash) "tpope media activate")
(xbindmods '(backslash) (toggle "pavucontrol"))
(xbindmods '(control backslash) (string-append "pkill pulseaudio\n"
                                               (toggle "pavucontrol")))

(define (clone resolution)
  (string-append
    "resolution=" resolution "
set --
for display in `xrandr -q | grep ' connected' | awk '{print $1}'`; do
  d=`xrandr -q | sed -ne \"/^$display connected/,+1p\"|awk '/^ / {print $1}'`
  set -- \"$@\" --output $display --pos 0x0 --panning $resolution
  if [ \"${d%x*}\" -ge \"${resolution%x*}\" ]; then
    set -- \"$@\" --mode $resolution --scale 1x1 --panning $resolution
  else
    set -- \"$@\" --mode $d --scale-from $resolution --panning $resolution
  fi
done
exec xrandr \"$@\""))
(xbindmod '(o) (toggle "arandr" "lxrandr"))
(xbindmod '(shift o) "xrandr --auto")
(xbindmod '(control o)
  (clone "`xrandr -q | grep '^  '|sort -rn|head -1|awk '{print $1}'`"))
(xbindmods '(o) (clone "1920x1080"))

(let ((local-file (string-append (or (getenv "HOME") ".") "/.xbindkeysrc.local.scm")))
  (if (access? local-file R_OK)
    (primitive-load local-file)))
