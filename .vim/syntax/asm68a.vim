" Vim syntax file
" Language:     A68k Assembler
" Maintainer:   Tim Pope <vim@rebelongto.us>
" URL:          http://www.sexygeek.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/syntax/asm68a.vim
" Last Change:  2005 Dec 07
" Version:      $Id$

" Remove any old syntax stuff hanging around
if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

  syn case ignore

  syn match asmLabel		"^[a-z_][a-z0-9_]*:"he=e-1
  syn match asmLabel		"^[a-z_][a-z0-9_]*$"
  "syn match asmIdentifier		"[a-z_][a-z0-9_]*"

"a68k registers
  syn match asmDataReg	"\<d[0-7]\>"
  syn match asmAddrReg	"\<a[0-7]\>"
  syn keyword asmReg	sp sr ccr pc
"  syn match asmReg	"\(s[pr]\|ccr\|pc\)"

"Numbers
  syn match asmBinNumber	"#\=-\=%[01]\+\>"
  syn match asmOctNumber	"#\=-\=@[0-7]\+\>"
  syn match asmHexNumber	"#\=-\=\$[0-9A-Fa-f]\+\>"
  syn match asmDecNumber	"\(\<\|#\)-\=[0-9]\+\>"

  syn region	asmString	start=+"+ skip=+\\\\\|\\"+ end=+"+
  syn region	asmString	start=+'+ skip=+\\\\\|\\'+ end=+'+

  syn match asmComment		";.*"
  syn match asmComment		"^[*#].*"

  syn keyword asmInclude	include
  syn keyword asmPreProc	xdef end equ
  syn keyword asmMacro		macro endm

  syn match asmDirective		"\.[a-z][a-z]\+"

  syn case match


" Read the 68k opcodes
syn case match

source <sfile>:p:h/asm68op.vim



if !exists("did_a68a_syntax_inits")
  let did_a68a_syntax_inits = 1

  hi link asmInclude		Include
  hi link asmPreProc		PreProc
  hi link asmBinNumber		Number
  hi link asmOctNumber		Number
  hi link asmHexNumber		Number
  hi link asmDecNumber		Number
  hi link asmMacro		Macro
  hi link asmComment		Comment
  hi link asmString		String
  hi link asmDataReg		asmReg
  hi link asmAddrReg		asmReg
  hi link asmReg		Identifier
  hi link asmOpcode		Statement

  " My default-color overrides:
"  hi asmOpcode ctermfg=yellow guifg=purple
"  hi asmReg	ctermfg=lightmagenta guifg=brown



endif

let b:current_syntax = "asm68a"

" vim: ts=8
