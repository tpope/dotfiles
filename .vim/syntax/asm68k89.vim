if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

if version < 600
	source <sfile>:p:h/asm68k.vim
	source <sfile>:p:h/ti89call.vim
else
	runtime! syntax/asm68k.vim
	unlet b:current_syntax
	runtime! syntax/ti89call.vim
endif

let b:current_syntax = "asm68k89"
