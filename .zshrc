# ~/.zshrc
# $Id$

# Section: Environment {{{1
# -------------------------

setopt rmstarsilent histignoredups

if [[ $ZSH_VERSION == 4.<->* ]]; then
    setopt histexpiredupsfirst histreduceblanks
fi

fpath=($fpath ~/.zsh/functions ~/.zsh/functions.zwc)
watch=(notme)
[ -f $HOME/.friends ] && watch=(`cat $HOME/.friends`)
HISTSIZE=100
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

export ENV="$HOME/.shrc"
interactive=1
. $ENV
#hostname -f|grep -q '\.simpson$' && export PROXY=http://maggie.simpson:3128
#export HTTP_PROXY=$PROXY
#[ -f $HOME/mbox ] && export MAIL=$HOME/mbox

domains=(`grep ^search /etc/resolv.conf`)
[[ -z $domains ]] || shift 1 domains

off=(maggie.simpson bart.simpson marge.simpson lisa.simpson homer.simpson abe.simpson mona.simpson)
for host in $off; do
    [ "${host:s/.simpson//}" != `hostname` ] && family=($family $host)
    [ -d "$HOME/simpson" ] && typeset ${host:s/.simpson//}=$HOME/simpson/${host:s/.simpson//}
    : ~$host
done

friends=($family snowball.simpson clancy.simpson sarah.simpson ralph.simpson carl.simpson lenny.simpson patty.simpson grex.springfield right.springfield left.springfield)

for host in $domains; do
    off=(${off%.$host})
    family=(${family%.$host})
    friends=(${friends%.$host})
done

unset interactive domains host
# Section: Prompt {{{1
# --------------------
local e _find_promptinit hostcolor hostletter hostcode usercolor usercode
e=`echo -ne "\e"`
    if [ -x "$HOME/bin/hostinfo" ]; then
	hostcolor=`$HOME/bin/hostinfo -c`
	hostletter=`$HOME/bin/hostinfo -l`
	hostcode=`$HOME/bin/hostinfo -s`
    else
	hostcolor="01;37"
	hostletter=
	hostcode="+b W"
    fi
    usercolor="01;33" && usercode="+b Y"
    [ $UID = '0' ] && usercolor="01;37" && usercode="+b W"

_find_promptinit=( $^fpath/promptinit(N) )
if (( $#_find_promptinit >= 1 )) && [[ -r $_find_promptinit[1] ]]; then
    autoload -U promptinit && promptinit && prompt simpson
    RPS1=$'%(?..(%{\e[01;35m%}%?%{\e[00m%}%)%<<)'
else
    PS1="%{${e}[${usercolor}m%}%n%{${e}[00m%}@%{${e}[${hostcolor}m%}%m%{${e}[00m%}:%{${e}[01;34m%}%~%{${e}[00m%}%# "
    RPS1="%(?..(%{${e}[01;35m%}%?%{${e}[00m%}%)%<<)"
fi

case ${OLDTERM:-$TERM} in
screen*|vt220*)
    screenhs="\005{$usercode}%n\005{-}@\005{$hostcode}%m\005{-}:\005{+b B}%~\005{-}"
    precmd  () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;\a\e]1;$tty%m\a"
		print -Pn "\e]2;$screenhs [%l]\a"
		print -Pn "\ek$tty%m\e\\"
		}
    preexec () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;\a\e]1;$tty%m*\a"
		print -Pn "\e]2;$screenhs"
		print -Pnr " (%24>..>$1"|tr '\0-\037' '.'
		print -Pn ") [%l]\a"
		print -Pn "\ek$tty%m*\e\\"
		}
    [ "`hostname`" = grex.cyberspace.org ] &&TERM=vt220 &&export OLDTERM=screen
    ;;
xterm*|rxvt*|kterm*|dtterm*)
    precmd  () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;$tty%m\a"
		print -Pn "\e]2;%n@%m:%~ [%l]\a"
		}
    preexec () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;$tty%m*\a"
		print -Pn "\e]2;%n@%m:%~"
		print -Pnr " (%24>..>$1"|tr '\0-\037' '.'
		print -Pn ") [%l]\a"
		} ;;
Eterm*)
    precmd  () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;$tty%m\a"
		print -Pn "\e]2;%n@%m:%~ [%l]\a"
		print -Pn "\e]I%m.xpm\e\\"
		}
    preexec () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;$tty%m*\a"
		print -Pn "\e]2;%n@%m:%~"
		print -Pnr " (%24>..>$1"|tr '\0-\037' '.'
		print -Pn ") [%l]\a"
		} 
    [ "`hostname`" = grex.cyberspace.org ] &&TERM=xterm &&export OLDTERM=Eterm
    ;;
linux) ;;
*)
    PS1="$hostletter%# "
    RPS1="%(?..(%?%)%<<)"
    ;;
esac

unset _find_promptinit hostcolor hostletter hostcode usercolor usercode
# Section: Keybindings {{{1
# -------------------------
bindkey -e
bindkey "\e[3~" delete-char
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey -r "^Q"

case $ZSH_VERSION in
3.*) ;;
*)
beginning-of-sentence() {
    local WORDCHARS="'"'*?_-.[]~=/!#$%^(){}<>" 	' #'
    zle backward-word
}
zle -N beginning-of-sentence
bindkey "\ea" beginning-of-sentence

end-of-sentence() {
    local WORDCHARS="'"'*?_-.[]~=/!#$%^(){}<>" 	' #'
    zle forward-word
}
zle -N end-of-sentence
bindkey "\ee" end-of-sentence

change-first-word() {
    zle beginning-of-line -N
    zle kill-word
}
zle -N change-first-word
bindkey "\eE" change-first-word

new-screen() {
    [ -z "$STY" ] || screen < "$TTY"
}
zle -N new-screen
bindkey "$terminfo[kf12]" new-screen
bindkey -s "$terminfo[kf11]" "^Ascreen ^E\n"

;;
esac

[[ -z "$terminfo[kich1]" ]] || bindkey -M emacs "$terminfo[kich1]" overwrite-mode
[[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
[[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
[[ -z "$terminfo[kend]"  ]] || bindkey -M emacs "$terminfo[kend]" end-of-line
[[ -z "$terminfo[kpp]"   ]] || bindkey -M emacs "$terminfo[kpp]" beginning-of-history
[[ -z "$terminfo[knp]"   ]] || bindkey -M emacs "$terminfo[knp]" end-of-history
#for widget in kill-word backward-kill-word forward-word backward-word up-case-word down-case-word transpose-words; do autoload bash-$widget; zle -N $widget bash-$widget; done

# Section: Aliases {{{1
# ---------------------
alias lsd='ls -ld *(-/DN)' # directories only
alias sb='noglob sensible-browser'
alias zmv='noglob zmv'

which sudo >/dev/null && alias sudo='sudo ' # this makes $1 expand as an alias

# Global aliases -- These do not have to be
# at the beginning of the command line.
alias -g MM='|more'
alias -g HH='|head'
alias -g TT='|tail'
alias -g LL='|less'

xdvi() { command xdvi ${*:-*.dvi(om[1])} }
gv()   { command gv ${*:-*.(ps|pdf)(om[1])} }
# Section: Modules {{{1
# ---------------------
if [[ $ZSH_VERSION == 3.<->* ]]; then
    which zmodload >&/dev/null && zmodload zsh/compctl
    compctl -c sudo
    compctl -c which
    compctl -g '*(-/)' + -g '.*(-/)' -v cd pushd rmdir
    compctl -k hosts -x 'p[2,-1]' -l '' -- rsh ssh
    return 0
fi

zmodload -i zsh/mathfunc
#zmodload -i zsh/complist
autoload -U zrecompile
autoload -U zmv
autoload -U zsh-mime-setup
# Section: Styles {{{1
# ------------------------
zstyle ':mime:*' x-browsers sensible-browser
zstyle ':mime:*' tty-browsers sensible-browser
zstyle ':mime:*' mailcap ~/.mailcap
# The following lines were added by compinstall

zstyle ':completion:*' add-space true
zstyle -e ':completion:*' completer '
	if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
	    _last_try="$HISTNO$BUFFER$CURSOR"
	    reply=(_complete)
	else
	    reply=(_match _complete:ignored _prefix _correct _approximate)
	fi' #'
#zstyle ':completion:*' completer _complete _ignored _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*:complete:*files' ignored-patterns '*\~'
zstyle ':completion:*:complete:rm:*files' ignored-patterns
zstyle ':completion:*' group-name ''
zstyle ':completion:*' hosts localhost $friends sexygeek.us cunn.iling.us rebelongto.us
zstyle ':completion:*' insert-unambiguous true
# NO NO NO!!! This makes things SLOW
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' local localhost /var/www public_html
zstyle ':completion:*:complete:*' matcher-list ''
zstyle ':completion:*:ignored:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#zstyle ':completion:*:hosts' hosts ${(A)_cache_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}} }
zstyle ':completion:*' max-errors 1 numeric
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' users tpope root $USER ${watch/notme/}
zstyle ':completion:*' verbose true
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:rsync:*:files' command ssh -a -x '${words[CURRENT]%:*}' ls -d1F '${${:-${${${:-${words[CURRENT]#*:}-}:h}/${slash}(#e)/}/\*}/#.$slash/}' 2>/dev/null
zstyle :compinstall filename '/home/tpope/.zshrc'

autoload -U compinit
compinit -u
# End of lines added by compinstall
