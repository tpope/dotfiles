if version < 600
  so <sfile>:p:h/sh.vim
else
  runtime! syntax/sh.vim
  unlet b:current_syntax
endif

syn match  zshShellVariables "\<\([bwglsav]:\)\=\w*\ze="
hi link zshShellVariables	Identifier
hi link zshSpecialShellVar	PreProc
hi link zshDerefOpr		PreProc
hi link zshDerefIdentifier	PreProc
