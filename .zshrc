# ~/.zshrc
# vim:set et sw=2:

# External {{{1

. "$HOME/.shrc"

# }}}1
# Prompt {{{1

_git_prompt_info() {
  case "$PWD" in
    /net/*|/Volumes/*) return ;;
  esac
  if [ -d .svn ]; then
    ref=.svn
  else
    ref=${$(command git symbolic-ref HEAD 2> /dev/null)#refs/heads/} || \
      ref=${$(command git rev-parse HEAD 2>/dev/null)[1][1,7]} || \
      return
  fi
  case "$TERM" in
    *-256color)             branchcolor=$'\e[38;5;31m'   ;;
    *-88color|rxvt-unicode) branchcolor=$'\e[38;5;22m'   ;;
    xterm*)                 branchcolor=$'\e[00;94m'     ;;
    *)                      branchcolor="$fg_bold[blue]" ;;
  esac
  print -Pn '(%%{$branchcolor%%}%20>..>$ref%<<%%{\e[00m%%})'
}

autoload -Uz colors && colors

hostcolor=$'\e['`tpope-host ansi 2>/dev/null`m

local usercolor="$fg_bold[yellow]"
local dircolor="$fg_bold[blue]"
# Use echotc Co?
case "$TERM" in
  *-256color)
    usercolor=$'\e[38;5;184m'
    dircolor=$'\e[38;5;27m'
    ;;
  *-88color|rxvt-unicode)
    usercolor=$'\e[38;5;56m'
    dircolor=$'\e[38;5;23m'
    ;;
esac
[ $UID = '0' ] && usercolor="$fg_bold[white]"
reset_color=$'\e[00m'

PROMPT="%{$usercolor%}%n%{$reset_color%}@%{${hostcolor}%}%m%{$reset_color%}:%{$dircolor%}%30<...<%~%<<%{$reset_color%}\$(_git_prompt_info)%# "
RPS1="%(?..(%{"$'\e[01;35m'"%}%?%{$reset_color%}%)%<<)"
setopt promptsubst

_set_title() {
  case "$1" in
    *install*)
      hash -r ;;
  esac
  print -Pn '\e]1;%l@%m${1+*}\a'
  print -Pn '\e]2;%n@%m:%~'
  if [ -n "$1" ]; then
    print -Pnr ' (%24>..>$1%>>)'|tr '\0-\037' '?'
  fi
  print -Pn " [%l]\a"
}

case $TERM in
  screen*)
    PROMPT="${PROMPT//01;3/00;9}"
    precmd() {
      _set_title "$@"
      if [ "$STY" -o "$TMUX" ]; then
        # print -Pn "\e]1;\a\e]1;@%m\a"
        print -Pn '\ek@\e\\'
      else
        print -Pn '\ek@%m\e\\'
      fi
    }
    preexec() {
      _set_title "$@"
      print -n "\ek"
      print -Pnr '%10>..>$1' | tr '\0-\037' '?'
      if [ "$STY" -o "$TMUX" ]; then
        print -Pn '@\e\\'
      else
        print -Pn '@%m\e\\'
      fi
    }
  ;;

  xterm*|rxvt*|Eterm*|kterm*|putty*|dtterm*|ansi*|cygwin*)
    PROMPT="${PROMPT//01;3/00;9}"
    precmd () { _set_title "$@" }
    preexec() { _set_title "$@" }
    ;;

  linux*|vt220*) ;;

  *)
    PS1="%n@%m:%~%# "
    RPS1="%(?..(%?%)%<<)"
    ;;
esac

unset hostcolor hostletter hostcode dircolor usercolor usercode reset_color

# Options {{{1

setopt rmstarsilent histignoredups
setopt nonomatch
setopt completeinword extendedglob
setopt autocd cdable_vars

HISTSIZE=100

if [[ $ZSH_VERSION == 3.<->* ]]; then
  which zmodload >&/dev/null && zmodload zsh/compctl
  compctl -c sudo
  compctl -c which
  compctl -g '*(-/)' + -g '.*(-/)' -v cd pushd rmdir
  compctl -k hosts -x 'p[2,-1]' -l '' -- rsh ssh
  return 0
fi

setopt histexpiredupsfirst histreduceblanks

fpath=($fpath ~/.zsh/functions ~/.zsh/functions.zwc)
watch=(notme)
PERIOD=3600
periodic() { rehash }

# }}}1
# Named directories {{{1

hosts=(`tpope-host list`)
local host
for host in $hosts; do
  [ "$host" != "$HOST" ] && family=($family $host)
  if [ -L "$HOME/homes/$host" ]; then
    typeset $host="$HOME/homes/$host"
    : ~$host
  fi
done

unset host

# }}}1
# Aliases {{{1

alias lsd='ls -d *(-/DN)'
alias b='noglob tpope open'
autoload -Uz zmv
alias zmv='noglob zmv'
alias ru='noglob ru'

autoload -Uz zrecompile

# }}}1
# Completion {{{1

zmodload -i zsh/complist
# The following lines were added by compinstall

zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
      _last_try="$HISTNO$BUFFER$CURSOR"
      reply=(_complete _ignored:complete _prefix _complete:full _correct _approximate)
    else
      rehash
      reply=(_complete _ignored:complete _prefix _complete:full _correct _approximate)
    fi' #'
zstyle ':completion::prefix:*' completer _complete _ignored:complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion::complete:*:(all-|)files' ignored-patterns '*\~' tags
zstyle ':completion::complete:*' ignore-parents parent pwd
zstyle ':completion::complete:rm::(all-|)files' ignored-patterns
# zstyle ':completion:*' group-name ''
zstyle ':completion:*' hosts localhost $hosts
zstyle ':completion:*' urls http://tpo.pe/ http://www.google.com/ https://github.com/
zstyle ':completion:*' insert-unambiguous true
# NO NO NO!!! This makes things SLOW
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' local localhost /var/www public_html
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}'
zstyle ':completion::full:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-/]=* r:|=* l:|[._-/]=* l:|=*'
zstyle -e ':completion:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*' menu select
zstyle ':completion:*:(xdvi|xpdf|gv|mpl):*' menu yes select
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' users tpope root $USER ${watch/notme/}
zstyle ':completion:*' verbose true
zstyle ':completion:*:rm:*' ignore-line yes
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit -u
# End of lines added by compinstall

compdef '_files -W /var/log -g "*~*.(gz|old|*[0-9])(-.)"' lv logview
compdef '_arguments "-T[force console]" :url:_webbrowser' tpope-open tpope-browser
compdef '_arguments "*:picture file:_files -g \*.\(\#i\)\(png\|gif\|jpeg\|jpg\|tiff\|tif\|pbm\|pgm\|ppm\|xbm\|xpm\|ras\(\|t\)\|tga\|rle\|rgb\|bmp\|pcx\|fits\|pm\)\(-.\)"' feh
compdef _tpope tpope

_tpope() {
  local cmd=$(basename $words[1])
  if [[ $CURRENT = 2 ]]; then
    local tmp
    tmp=($(grep '^  [a-z-]*[|)]' "$HOME/.local/bin/$cmd" 2>/dev/null | sed -e 's/).*//' | tr '|' ' '))
    _describe -t commands "${words[1]} command" tmp --
  else

    shift words
    (( CURRENT-- ))
    curcontext="${curcontext%:*:*}:$cmd-${words[1]}:"

    local selector=$(egrep "^  ([a-z-]*[|])*${words[1]}([|][a-z-]*)*[)] *# *[_a-z-]*$" "$HOME/.local/bin/$cmd" | sed -e 's/.*# *//')
    _call_function ret _$selector && return $ret

    if [[ -n "$selector" ]]; then
      words[1]=$selector
    elif [[ -f "$HOME/.local/bin/$cmd-${words[1]}" ]]; then
      words[1]=$cmd-${words[1]}
      _tpope
    fi
    _normal
  fi
}

# }}}1
# Mime {{{1

autoload -Uz zsh-mime-setup
zstyle ':mime:*' x-browsers 'tpope open'
zstyle ':mime:*' mailcap ~/.mailcap

# }}}1
# Keybindings {{{1

bindkey -e
bindkey -r '^Q'

bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^B' backward-char
bindkey -M viins '^D' delete-char-or-list
bindkey -M viins '^E' end-of-line
bindkey -M viins '^F' forward-char
bindkey -M viins '^K' kill-line
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^S' history-incremental-search-forward
bindkey -M viins '^T' transpose-chars
bindkey -M viins '^Y' yank

bindkey -M emacs '^X^[' vi-cmd-mode

bindkey -M emacs ' ' magic-space
bindkey -M viins ' ' magic-space

bindkey -M isearch '^J' accept-search 2>/dev/null

# [[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
# [[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
# [[ -z "$terminfo[kend]"  ]] || bindkey -M emacs "$terminfo[kend]" end-of-line

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

autoload -Uz select-word-style
select-word-style bash

change-first-word() {
  zle beginning-of-line -N
  zle kill-word
}
zle -N change-first-word
bindkey -M emacs "\ea" change-first-word

bindkey -M emacs "^XD" describe-key-briefly

fg-widget() {
  if [[ $#BUFFER -eq 0 ]]; then
    if jobs %- >/dev/null 2>&1; then
      BUFFER='fg %-'
    else
      BUFFER='fg'
    fi
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fg-widget
bindkey -M emacs "^Z" fg-widget
bindkey -M vicmd "^Z" fg-widget
bindkey -M viins "^Z" fg-widget

autoload -Uz incarg
zle -N incarg
bindkey -M emacs "^X^A" incarg
bindkey -M vicmd "^A" incarg

bindkey -M vicmd ga what-cursor-position

new-screen() {
  [ -z "$STY" ] || screen < "$TTY"
  [ -z "$TMUX" ] || tmux new-window
}
zle -N new-screen
[[ -z "$terminfo[kf12]" ]] || bindkey "$terminfo[kf12]" new-screen

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M emacs '^[e'  edit-command-line
bindkey -M emacs '^X^E' edit-command-line
bindkey -M vicmd v      edit-command-line

for binding in ${(f)$(bindkey -M emacs|grep '^"\^X')}; do
  bindkey -M viins "${(@Qz)binding}"
done
unset binding

# }}}1
