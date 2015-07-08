(define mod
  (string->symbol (or (getenv "XBINDKEYS_MOD") "mod4")))

(define (xbindmod keys command)
  (if (string? command)
    (xbindkey (cons mod keys) command)
    (xbindkey-function (cons mod keys) command)))
