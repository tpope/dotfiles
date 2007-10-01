" Vim syntax file
" Language:     Router configuration file
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2005 Dec 13

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

if version < 600
    set iskeyword=48-57,$,.,-,A-Z,a-z,_
else
    setlocal iskeyword=48-57,$,.,-,A-Z,a-z,_
endif

syn case ignore

syn region routerString start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match routerNumber          "\<-\=\d\+\>"
syn match routerNumber          "\<-\=\d\+\.\d*\>"
syn match routerIPAddress       "\<\(\([1-9]\=\d\|1\d\d\|2[0-4]\d\|25[0-5]\)\.\)\{3}\([1-9]\=\d\|1\d\d\|2[0-4]\d\|25[0-5]\)\(/[12]\=\d\|/3[0-2]\)\=\>"
syn match routerComment "^\s*!.*"

syn keyword routerCmd           aa[a] ac[cess-list] ap[pletalk] ara[p] arp
syn keyword routerCmd           as[ync-bootp] au[tonomous-system]
syn keyword routerCmd           ba[nner] bo[ot] br[idge] buf[fers]
syn keyword routerCmd           bus[y-message]
syn keyword routerCmd           ca[ll-history-mib] ch[at-script] cl[ock]
syn keyword routerCmd           co[nfig-register] deb[ug]
syn keyword routerCmd           dec[net] default default-[value] dnsix-d[mdp]
syn keyword routerCmd           dnsix-n[at] do[wnward-compatible-config]
syn keyword routerCmd           ena[ble] end exc[eption] exi[t]
syn keyword routerCmd           f[ile] h[elp] h[ostname]
syn keyword routerCmd           ip[v6] ipx is[dn]
syn keyword routerCmd           k[ey] logg[ing] logi[n-string]
syn keyword routerCmd           map-c[lass] map-l[ist] me[nu] mod[emcap] mop
syn keyword routerCmd           mu[ltilink]
syn keyword routerCmd           ne[tbios] nt[p]
syn keyword routerCmd           pa[rtition] prin[ter] prio[rity-list]
syn keyword routerCmd           priv[ilege] pr[ompt]
syn keyword routerCmd           q[ueue-list]
syn keyword routerCmd           ri[f] rl[ogin] rm[on] route-[map] rt[r]
syn keyword routerCmd           sc[heduler] se[rvice] sm[rp] sn[mp-server]
syn keyword routerCmd           st[ate-machine] su[bscriber-policy]
syn keyword routerCmd           ta[cacs-server] te[rminal-queue] tf[tp-server]
syn keyword routerCmd           u[sername] vi[rtual-profile] x25 x29
syn keyword routerSpecial       no
"nextgroup=routerCmd skipwhite

" syn keyword routerCmd         net[work] pas[sword] sh[utdown] en[capsulation]
" syn keyword routerCmd         clock[rate] rate ban[dwidth] ve[rsion]
" syn keyword routerCmd         tr[ansport]
syn keyword routerCmd           proc[ess-max-time] ve[rsion]
syn keyword routerCmd           router containedin=routerRouterStart contained
syn keyword routerParent        router in[terface] li[ne] end contained

syn match routerIntStart        "\<in\(t\(e\(r\(f\(a\(ce\=\)\=\)\=\)\=\)\=\)\=\)\>.*" transparent nextgroup=routerCommand,routerIntLine contains=routerParent,routerRouterStart skipnl skipwhite
syn keyword routerIntLine       end contained
syn match routerIntLine "[^ \t!].*" transparent nextgroup=routerIntLine contained skipnl skipwhite
syn keyword routerIntCmd ba[ndwidth] clock[rate] enc[apsulation] fa[ir-queue] ip[v6] r[ate] sh[utdown] contained containedin=routerIntLine
syn match   routerInt   contained "\<\I\i*[ \t]*\d\+\>" containedin=routerIntStart
syn keyword routerInt   contained lo containedin=routerIntStart

syn match routerRouterStart     "\<router\>.*" transparent nextgroup=routerRouterLine contains=routerParent,routerNumber skipnl skipwhite
syn keyword routerRouterLine end contained
syn match routerRouterLine "[^ \t!].*" transparent nextgroup=routerRouterLine contained skipnl skipwhite
syn keyword routerRouterCmd     ne[twork] contained containedin=routerRouterLine
syn keyword routerRouter        contained b[gp] eg[p] ei[grp] ig[rp] isi[s] iso[-igrp] m[obile] od[r] os[pf6] ri[png] s[tatic] t[raffic-engineering] containedin=routerRouterStart

syn match routerLineStart       "\<li\(ne\=\)\=\>.*" transparent nextgroup=routerLineLine contains=routerParent,routerNumber skipnl skipwhite
syn keyword routerLineLine end contained
syn match routerLineLine "[^ \t!].*" transparent nextgroup=routerLineLine contained skipnl skipwhite
syn keyword routerLineCmd       logi[n] pas[sword] tra[nsport] contained containedin=routerLineLine
syn keyword routerLine contained c[onsole] a[ux] v[ty] containedin=routerLineStart

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_router_syn_inits")
    if version < 508
        let did_router_syn_inits = 1
        command -nargs=+ HiLink hi link <args>
    else
        command -nargs=+ HiLink hi def link <args>
    endif

    HiLink routerComment        Comment
    HiLink routerString         String
    HiLink routerCmd            Statement
    HiLink routerParent         Statement
    HiLink routerIntLine        routerIntCmd
    HiLink routerInt            Type
    HiLink routerIntCmd         Identifier
    HiLink routerRouterLine     routerRouterCmd
    HiLink routerRouter         Type
    HiLink routerRouterCmd      Identifier
    HiLink routerLineLine       routerLineCmd
    HiLink routerLine           Type
    HiLink routerLineCmd        Identifier
    HiLink routerSpecial        Special
    HiLink routerIPAddress      Number
    HiLink routerNumber         Number
    delcommand HiLink
endif

let b:current_syntax = "router"

" vim:set ft=vim sts=4 sw=4:
