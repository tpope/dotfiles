" Vim syntax file
" Language:	Simpsons episode capsule
" Maintainer:	Tim Pope <tpope@hotpop.com>
" Last Change:	2002 Nov 23

  syn case ignore

  syn match simpsonsProdCode		"\(MG\|\d[FG]\|[A-Z]ABF\)\d\d"
  syn match simpsonsContributor		"{\w\{2,4\}}"

" syn region simpsonsString		start=+"+ skip=+\\\\\|\\"+ end=+"+

  syn region simpsonsDesc		start="^-- " end="^$"

  syn match simpsonsDivider		"^=\+$"
  syn match simpsonsComment		"^%.*"
  syn match simpsonsSection		"^>.*" contains=simpsonsContributor,simponsProdCode


  syn case match



if !exists("did_simpsons_syntax_inits")
  let did_simpsons_syntax_inits = 1

  hi link simpsonsDesc		Statement
  hi link simpsonsProdCode	Number
  hi link simpsonsDivider	PreProc
  hi link simpsonsSection	Type
  hi link simpsonsComment	Comment
  hi link simpsonsString	String
  hi link simpsonsContributor	Identifier
  "Type Statement

  " My default-color overrides:



endif

let b:current_syntax = "SIMPSONS"

" vim: ts=8
