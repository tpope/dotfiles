. "$HOME/.shrc"

shopt -s extglob cdable_vars 2>/dev/null

export HISTCONTROL=ignoredups
unset HISTFILE

_running_cmd() {
  builtin history 1|sed -E -e "1 s/^ *[0-9][0-9]*[* ] //" -e "s/^(.{${1:-9}})...*/\1…/"|tr -d '\n'|tr '\0-\037' '?'
}

hostcolor=`tpope-host ansi 2>/dev/null`

[ "$UID" ] || UID=`id -u`
usercolor='00;93'
dircolor='00;94'
case "$TERM" in
  *-256color|xterm-kitty)
  usercolor='38;5;184'
  dircolor='38;5;27'
  ;;
  *-88color|rxvt-unicode)
  usercolor='38;5;56'
  dircolor='38;5;23'
  ;;
esac
[ $UID = '0' ] && usercolor="00;97"

if [ -x /usr/bin/tty -o -x /usr/local/bin/tty ]; then
  ttybracket=" [`tty|sed -e s,^/dev/,,`]"
  ttyat="`tty|sed -e s,^/dev/,,`@"
fi

PS1='\[\e['$usercolor'm\]\u\[\e[00m\]@\[\e['$hostcolor'm\]\h\[\e[00m\]:\[\e['$dircolor'm\]\w\[\e[00m\]\$ '
PS0=

case "$TERM" in
  linux*|vt220*) ;;
  screen*|xterm*|rxvt*|Eterm*|kterm*|dtterm*|ansi*|cygwin*)
    PS1='\[\e]1;'$ttyat'\h\007\e]2;\u@\h:\w'$ttybracket'\007\]'"$PS1"
    PS0='\[\e]1;'$ttyat'\h*\007\e]2;\u@\h:\w ($(_running_cmd 23))'$ttybracket'\007\]'$PS0
  ;;
  dumb*)
    PS1='\u@\h:\w\$ '
  ;;
esac

case $TERM in
  screen*)
    PS1="$PS1"'\[\ek'"@`[ "$STY" -o "$TMUX" ] || echo '\h'`"'\e\\\]'
    PS0='\[\ek$(_running_cmd 9)@'`[ "$STY" -o "$TMUX" ] || echo '\h'`'\e\\\]'
    ;;
esac

[ ! -f /etc/bash_completion ] || . /etc/bash_completion

if ! type _command_offset >/dev/null 2>&1; then
  _command_offset() {
    if [[ $(($1 + 1)) == $COMP_CWORD ]]; then
      COMPREPLY=($(compgen -c "$cur"))
    else
      COMPREPLY=($(compgen -f "$cur"))
    fi
  }
fi

_tpope() {
  local cmd=${COMP_WORDS[0]} sub=${COMP_WORDS[1]} cur=${COMP_WORDS[COMP_CWORD]}
  if [[ $COMP_CWORD == 1 ]]; then
    COMPREPLY=($(compgen -W "$(grep '^  [a-z-]*[|)]' "$HOME/.local/bin/$cmd" | sed -e 's/).*//' | tr '|' ' ')" "$cur"))
  else
    local selector=$(egrep "^  ([a-z-]*[|])*$sub([|][a-z-]*)*[)] *# *[_a-z-]*$" "$HOME/.local/bin/$cmd" | sed -e 's/.*# *//')
    case "$selector" in
      hosts|ssh)
        COMPREPLY=($(compgen -W "localhost $(tpope-host list)" "$cur")) ;;
      services)
        _services ;;
      directories|rmdir)
        COMPREPLY=($(compgen -d "$cur")) ;;
      precommand|exec)
        _command_offset 2
        ;;
      nothing|true)
        COMPREPLY=() ;;
      '')
        if [ -x "$HOME/.local/bin/$cmd-$sub" ]; then
          COMP_CWORD=$((COMP_CWORD-1))
          COMP_WORDS=("$cmd-$sub" "${COMP_WORDS[@]:2}")
          COMP_LINE=${COMP_LINE/ /-/}
          _tpope
        else
          _command_offset 1
        fi
        ;;
      *)
        COMP_WORDS[1]=$selector
        COMP_LINE=${COMP_LINE/ $sub/ $selector}
        COMP_POINT=$(($COMP_POINT + ${#selector} - ${#sub}))
        _command_offset 1
        ;;
    esac
  fi
}

complete -F _tpope tpope
complete -F _services start stop restart reload force-reload

unset hostcolor usercolor dircolor ttybracket ttyat
