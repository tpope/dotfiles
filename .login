# ~/.login
# $Id$

if ( ! $?SHLVL && ( ! $?SSH_TTY || $?TERMCAP ) ) then
    if ( -x /usr/games/fortune ) /usr/games/fortune
endif
