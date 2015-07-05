(define mod
  (string->symbol (or (getenv "XBINDKEYS_MOD") "mod4")))

(define (xbindmod keys command)
  (if (string? command)
    (xbindkey (cons mod keys) command)
    (xbindkey-function (cons mod keys) command)))

(xbindkey '(XF86AudioLowerVolume) "tpope media volume -5%")
(xbindkey '(XF86AudioRaiseVolume) "tpope media volume +5%")
(xbindkey '(XF86AudioPrev) "tpope media prev")
(xbindkey '(XF86AudioNext) "tpope media next")
(xbindkey '(XF86AudioPlay) "tpope media toggle")

(xbindmod '(bracketleft) "tpope media volume -5%")
(xbindmod '(bracketright) "tpope media volume +5%")
(xbindmod '(backslash) "tpope media pause")
(xbindmod '(mod1 bracketleft) "tpope media prev")
(xbindmod '(mod1 bracketright) "tpope media next")
(xbindmod '(mod1 backslash) "tpope media toggle")
(xbindmod '(control bracketleft) "tpope media volume -5% --current")
(xbindmod '(control bracketright) "tpope media volume +5% --current")
(xbindmod '(control backslash) "tpope media sink +1 --current")
