" Vim syntax file
" Language:	BST configuration file
" Maintainer:	Tim Pope <tpope@hotpop.com>
" Last Change:	2003-Oct-03

if version < 600
  set iskeyword=48-57,$,.,A-Z,a-z
else
  setlocal iskeyword=48-57,$,.,A-Z,a-z
endif

  syn case ignore

  syn region  bstString	start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=bstField,bstType
  syn match   bstNumber		"#-\=\d\+\>"
  syn keyword bstNumber		entry.max$ global.max$
  syn match bstComment	"%.*"

  syn keyword bstCommand	ENTRY FUNCTION INTEGERS MACRO STRINGS
  syn keyword bstCommand	READ EXECUTE ITERATE REVERSE SORT
  syn match   bstBuiltIn	"\s[-<>=+*]\|\s:="
  syn keyword bstBuiltIn	add.period$
  syn keyword bstBuiltIn	call.type$ change.case$ chr.to.int$ cite$
  syn keyword bstBuiltIn	duplicate$ empty$ format.name$
  syn keyword bstBuiltIn	if$ int.to.chr$ int.to.str$
  syn keyword bstBuiltIn	missing$
  syn keyword bstBuiltIn	newline$ num.names$
  syn keyword bstBuiltIn	pop$ preamble$ purify$ quote$
  syn keyword bstBuiltIn	skip$ stack$ substring$ swap$
  syn keyword bstBuiltIn	text.length$ text.prefix$ top$ type$
  syn keyword bstBuiltIn	warning$ while$ width$ write$
  syn match   bstIdentifier	"'\k*"
  syn keyword bstType		article book booklet conference
  syn keyword bstType		inbook incollection inproceedings
  syn keyword bstType		manual mastersthesis misc
  syn keyword bstType		phdthesis proceedings
  syn keyword bstType		techreport unpublished
  syn keyword bstField		abbr address annote author
  syn keyword bstField		booktitle chapter crossref comment
  syn keyword bstField		edition editor
  syn keyword bstField		howpublished institution journal key month
  syn keyword bstField		note number
  syn keyword bstField		organization
  syn keyword bstField		pages publisher
  syn keyword bstField		school series
  syn keyword bstField		title type
  syn keyword bstField		volume year
  

  syn case match



if !exists("did_bst_syntax_inits")
  let did_bst_syntax_inits = 1

" hi link bstDivider		PreProc
" hi link bstSection		Type
  hi link bstComment		Comment
  hi link bstString		String
  hi link bstCommand		PreProc
  hi link bstBuiltIn		Statement
  hi link bstField		Special
  hi link bstNumber		Number
  hi link bstType		Type
  hi link bstIdentifier		Identifier
  "Type Statement

  " My default-color overrides:



endif

let b:current_syntax = "BST"

" vim: ts=8
