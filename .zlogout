# ~/.zlogout, ~/.bash_logout

#[ `who|grep -c "^$USER\\>"` -le 1 -a "0$SHLVL" -le 1 ] && \
#    [ -x /usr/bin/sudo -o -x /usr/local/bin/sudo ] && sudo -k

[ "0$SHLVL" -le 1 -a -z "$SSH_TTY" -a "$TERM" = linux ] && clear
