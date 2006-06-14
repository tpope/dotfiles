# ~/.zshrc
# $Id$

# Section: Environment {{{1
# -------------------------

setopt rmstarsilent histignoredups
setopt noclobber nonomatch
setopt completeinword extendedglob

if [[ $ZSH_VERSION == 4.<->* ]]; then
    setopt histexpiredupsfirst histreduceblanks
fi

fpath=($fpath ~/.zsh/functions ~/.zsh/functions.zwc)
watch=(notme)
[ -f $HOME/.friends ] && watch=(`cat $HOME/.friends`)
HISTSIZE=100
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'
PERIOD=3600
periodic() { rehash }

export ENV="$HOME/.shrc"
interactive=1
. $ENV
#[ -f $HOME/mbox ] && export MAIL=$HOME/mbox

#domains=(`egrep '^(search|domain)' /etc/resolv.conf 2>/dev/null`)
#[[ -z $domains ]] || shift 1 domains

off=(gob michael lucille tobias lindsay)
work=(arwen tpope-486 tpope-1084 jwxkl81-1061 san-netmon)
for host in $off; do
    [ "${host%.tpope.us}" != `hostname` ] && family=($family $host)
    [ -d "$HOME/friends" ] && typeset ${host%.tpope.us}=$HOME/friends/${host%.tpope.us}
    : ~${host%.tpope.us}
done

if [ -n "$USERPROFILE" ] && which cygpath >/dev/null; then
    typeset home="`cygpath "$USERPROFILE"`"
    typeset docs="$home/My Documents"
    typeset desktop="`cygpath -D 2>/dev/null`"
    [ -n "$APPDATA" ] || APPDATA="$USERPROFILE/Application Data"
    typeset appdata="`cygpath "$APPDATA"`"
    : ~home ~docs ~desktop ~appdata
elif [ -d "$HOME/Documents" ]; then
    typeset docs="$HOME/Documents"
    : ~docs
fi

namedir() { export $1=$PWD; : ~$1 }

friends=($family buster oscar maeby steve grex $work)

#for host in $domains; do
#    off=(${off%.$host})
#    family=(${family%.$host})
#    friends=(${friends%.$host})
#done

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
                if [ "$STY" ]; then
                    print -Pn "\ek$tty\e\\"
                else
                    print -Pn "\ek$tty%m\e\\"
                fi
		}
    preexec () {local tty="`print -P "%l@"|sed -e s,/,-,g`"
		print -Pn "\e]1;\a\e]1;$tty%m*\a"
		print -Pn "\e]2;$screenhs"
		print -Pnr " (%24>..>$1"|tr '\0-\037' '.'
		print -Pn ") [%l]\a"
                if [ "$STY" ]; then
                    print -Pn "\ek$tty*\e\\"
                else
                    print -Pn "\ek$tty%m*\e\\"
                fi
		}
    #[ "`hostname`" = grex.cyberspace.org ] &&TERM=vt220 &&export OLDTERM=screen
    ;;
xterm*|rxvt*|kterm*|dtterm*|ansi*|cygwin*)
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
    #[ "`hostname`" = grex.cyberspace.org ] &&TERM=xterm &&export OLDTERM=Eterm
    ;;
linux) ;;
*)
    PS1="$hostletter%# "
    RPS1="%(?..(%?%)%<<)"
    ;;
esac

unset _find_promptinit hostcolor hostletter hostcode usercolor usercode
unset e
# Section: Keybindings {{{1
# -------------------------
bindkey -e
#bindkey -m
bindkey "\e[3~" delete-char
bindkey "\e[1~" beginning-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\e[H"  beginning-of-line
bindkey "\eOH"  beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[F"  end-of-line
bindkey "\eOF"  end-of-line
bindkey -r "^Q"

bindkey "\eb"   emacs-backward-word
bindkey "\ef"   emacs-forward-word

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
[[ -z "$terminfo[kf12]" ]] || bindkey "$terminfo[kf12]" new-screen
[[ -z "$terminfo[kf11]" ]] || bindkey -s "$terminfo[kf11]" "^Ascreen ^E\n"

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
	    reply=(_complete _ignored:complete _prefix _complete:full)
	else
	    reply=(_complete _ignored:complete _prefix _complete:full _correct _approximate)
	fi' #'
zstyle ':completion::prefix:*' completer _complete _ignored:complete
#zstyle ':completion:*' completer _complete _ignored _prefix
#zstyle ':completion:*' completions 1
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion::complete:*:(all-|)files' ignored-patterns '*\~' '(|*/)CVS'
zstyle ':completion::complete:*:(local-|)directories' ignored-patterns '(|*/)CVS'
zstyle ':completion::complete:*' ignore-parents parent pwd
zstyle ':completion::complete:rm::(all-|)files' ignored-patterns
zstyle ':completion::complete:rmdir::(local-|)directories' ignored-patterns
zstyle ':completion:*' group-name ''
zstyle ':completion:*' hosts localhost $friends sexygeek.us cunn.iling.us rebelongto.us
zstyle ':completion:*' urls http://www.tpope.net/ http://www.google.com/
zstyle ':completion:*' insert-unambiguous true
# NO NO NO!!! This makes things SLOW
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors no=00 fi=00 di=01\;34 pi=33 so=01\;35 bd=00\;35 cd=00\;34 or=00\;41 mi=00\;45 ex=01\;32
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' local localhost /var/www public_html
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}'
zstyle ':completion::full:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-/]=* r:|=* l:|[._-/]=* l:|=*'
#zstyle ':completion:*:hosts' hosts ${(A)_cache_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}} }
zstyle -e ':completion:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX+1)/3 )) numeric )'
zstyle ':completion:*' menu select
zstyle ':completion:*:(xdvi|xpdf|gv):*' menu yes select
zstyle ':completion:*:(xdvi|xpdf|gv):*' file-sort time
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' users tpope root $USER ${watch/notme/}
zstyle ':completion:*' verbose true
zstyle ':completion:*:rm:*' ignore-line yes
#zstyle ':completion:*:rsync:*:files' command ssh -a -x '${words[CURRENT]%:*}' ls -d1F '${${:-${${${:-${words[CURRENT]#*:}-}:h}/${slash}(#e)/}/\*}/#.$slash/}' 2>/dev/null
zstyle :compinstall filename '/home/tpope/.zshrc'

autoload -U compinit
compinit -u
# End of lines added by compinstall
compdef 'local expl; _description files expl "LaTeX aux file"; _files "$expl[@]" -g "*.aux"' bibtex
compdef 'local expl; _description files expl "picture file"; _files "$expl[@]" -g "*.(#i)(png|gif|jpeg|jpg|tiff|tif|pbm|pgm|ppm|xbm|xpm|ras(|t)|tga|rle|rgb|bmp|pcx|fits|pm)(-.)"' feh
