(define mod
  (string->symbol (or (getenv "XBINDKEYS_MOD") "mod4")))

(define (xbind keys command)
  (if (string? command)
    (xbindkey keys command)
    (xbindkey-function keys command)))

(define (xbindmod keys command)
  (xbind (cons mod keys) command))

(define (xbindmodmod1 keys command)
  (xbind (list* 'control 'shift mod keys) command)
  (unless (eq? mod 'mod1)
    (xbind (list* 'mod1 mod keys) command)))

(define (toggle command)
  (string-append
    "xdotool search --classname " command "|grep -q `xdotool getactivewindow` && "
    "wmctrl -c :ACTIVE: || "
    "xdotool search --classname " command " windowactivate || "
    "exec " command))

;; ~/bin/tpope-media
(xbindkey '(XF86AudioLowerVolume) "tpope media sink -5%")
(xbindkey '(XF86AudioRaiseVolume) "tpope media sink +5%")
(xbindkey '(XF86AudioMute) "tpope media sink toggle")
(xbindkey '(XF86AudioMicMute) "tpope media source toggle")
(xbindkey '(XF86AudioPrev) "tpope media prev")
(xbindkey '(XF86AudioNext) "tpope media next")
(xbindkey '(XF86AudioPlay) "tpope media toggle")
(xbindkey '(XF86AudioStop) "tpope media stop")

(xbindmod '(minus) "tpope media sink -5%")
(xbindmod '(shift minus) "tpope media sink -5% --current")
(xbindmod '(control minus) "tpope media sink prev")
(xbindmodmod1 '(minus) "tpope media sink prev --current")
(xbindmod '(equal) "tpope media sink +5%")
(xbindmod '(shift equal) "tpope media sink +5% --current")
(xbindmod '(control equal) "tpope media sink 100%")
(xbindmodmod1 '(equal) "tpope media sink 100% --current")

(xbindmod '(backslash) "tpope media pause")
(xbindmod '(shift backslash) "tpope media toggle")
(xbindmod '(control backslash) "tpope media activate")
(xbindmodmod1 '(backslash) (toggle "pavucontrol"))
(unless (eq? mod 'mod1)
  (xbindmod '(control mod1 backslash) (string-append "pkill pulseaudio\n" (toggle "pavucontrol"))))

(xbindmod '(bracketleft) "tpope media rate - || tpope media prev")
(xbindmod '(bracketright) "tpope media rate + || tpope media next")
(xbindmod '(shift bracketleft) "tpope media prev")
(xbindmod '(shift bracketright) "tpope media next")
(xbindmod '(control bracketleft) "tpope media seek -5")
(xbindmod '(control bracketright) "tpope media seek +5")
(xbindmodmod1 '(bracketleft) "tpope media prev")
(xbindmodmod1 '(bracketright) "tpope media next")

(let ((local-file (string-append (or (getenv "HOME") ".") "/.xbindkeysrc.local.scm")))
  (if (access? local-file R_OK)
    (load local-file)))
