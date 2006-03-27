" Vim syntax file
" Language:	VB.NET
" Maintainer:   Tim Pope <vim@rebelongto.us>
" Last Change:  2006 Mar 27
" Filenames:    *.vb
" URL:          http://www.sexygeek.us/cgi-bin/cvsweb/~checkout~/tpope/.vim/syntax/bst.vim
" $Id$

" 1.0 Keywords:
"|AddHandler    |AddressOf     |Alias         |And            |
"|AndAlso       |Ansi          |As            |Assembly       |
"|Auto          |Boolean       |ByRef         |Byte           |
"|ByVal         |Call          |Case          |Catch          |
"|CBool         |CByte         |CChar         |CDate          |
"|CDbl          |CDec          |Char          |CInt           |
"|Class         |CLng          |CObj          |Const          |
"|CShort        |CSng          |CStr          |CType          |
"|Date          |Decimal       |Declare       |Default        |
"|Delegate      |Dim           |DirectCast    |Do             |
"|Double        |Each          |Else          |ElseIf         |
"|End           |EndIf         |Enum          |Erase          |
"|Error         |Event         |Exit          |False          |
"|Finally       |For           |Friend        |Function       |
"|Get           |GetType       |GoSub         |GoTo           |
"|Handles       |If            |Implements    |Imports        |
"|In            |Inherits      |Integer       |Interface      |
"|Is            |Let           |Lib           |Like           |
"|Long          |Loop          |Me            |Mod            |
"|Module        |MustInherit   |MustOverride  |MyBase         |
"|MyClass       |Namespace     |New           |Next           |
"|Not           |Nothing       |NotInheritable|NotOverridable |
"|Object        |On            |Option        |Optional       |
"|Or            |OrElse        |Overloads     |Overridable    |
"|Overrides     |ParamArray    |Preserve      |Private        |
"|Property      |Protected     |Public        |RaiseEvent     |
"|ReadOnly      |ReDim         |REM           |RemoveHandler  |
"|Resume        |Return        |Select        |Set            |
"|Shadows       |Shared        |Short         |Single         |
"|Static        |Step          |Stop          |String         |
"|Structure     |Sub           |SyncLock      |Then           |
"|Throw         |To            |True          |Try            |
"|TypeOf        |Unicode       |Until         |Variant        |
"|Wend          |When          |While         |With           |
"|WithEvents    |WriteOnly     |Xor           |               |

" VB.net to C# cheat sheet:
" MustInherit, MustOverride = abstract
" NotInheritable, NotOverridable = sealed
" Overridable = virtual
" Delegate, AddressOf = delegate
" Friend = internal
" Shared = static
" TryCast(foo, bar) = foo as bar
" Of T = <T>

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

" VB.net is case insensitive
syn case ignore


syn keyword vbnetType		Boolean Byte Char Date Decimal Double Single Integer Long Object Short String
syn keyword vbnetCast		CBool CByte CChar CDate CDbl CDec Char CInt CLng CObj CShort CSng CStr CType DirectCast
syn match   vbnetTypeSpecifier	"[a-zA-Z0-9][\$%&#]"ms=s+1
syn match   vbnetTypeSpecifier	"[a-zA-Z0-9]!\([^a-zA-Z0-9]\|$\)"ms=s+1,me=s+2
syn keyword vbnetStorage	Delegate AddressOf
syn match   vbnetStorage	"\<\(End\s\+\)\=\(Class\|Enum\|Interface\|Namespace\|Structure\|Module\)\>"
syn keyword vbnetRepeat		For To Step Each In GoTo Next Return Loop Do Until Exit Stop
syn match   vbnetRepeat		"\<\(End\s\+\)\=While\>"
syn keyword vbnetConditional	If Then ElseIf Else Select
syn match   vbnetConditional	"\<End\s\+If\>"
syn match   vbnetConditional	"\<Select\(\s\+Case\)\>"
syn keyword vbnetLabel		Case
syn keyword vbnetArrayHandler	Erase Preserve ReDim
syn keyword vbnetAccessModifier	Friend Private Protected Public
syn keyword vbnetClassModifier	MustInherit NotInheritable Inherits Implements
" TODO: categorize
syn keyword vbnetModifier	MustOverride NotOverridable Overridable Overrides ReadOnly WriteOnly Shared Static Overloads Shadows Handles WithEvents Assembly Auto Unicode Ansi Default
syn keyword vbnetConstant	False Nothing True
syn keyword vbnetException	Catch When Finally Resume Throw
syn match   vbnetException	"\<\(On\s\+Error\|\(End\s\+\)\=Try\)\>"
syn keyword vbnetFunction       Call Declare Alias Lib Get Set
syn match   vbnetFunction	"\<\(End\s\+\)\=\(Sub\|Function\|Property\)\>"
syn keyword vbnetOperator	And Or Not Xor Mod In Is Imp Eqv Like AndAlso OrElse GetType TypeOf
syn keyword vbnetEvent		AddHandler RemoveHandler RaiseEvent Event

syn keyword vbnetStatement	Me MyBase MyClass New ByVal ByRef Optional ParamArray Imports Dim Const As
syn match   vbnetStatement	"\<\(End\s\+\)\=\(With\|SyncLock\)\>"

syn keyword vbTodo contained TODO FIXME XXX NOTE
syn region vbnetComment start="\<REM\>" end="$" contains=vbnetTodo
syn region vbnetComment start="'" end="$" contains=vbnetTodo

syn keyword vbnetError		EndIf GoSub Let Variant Wend

syn region vbnetString		start=+"+ end=+"+ end=+$+ skip=+""+
syn match  vbnetCharacter	+"\([^"]\|""\)"c+

" TODO: Make these exhaustive and exclusive
syn match  vbnetDate		"1\=\d\=\([-/]\)[123]\=\d\1\d\{3,4\}" contained
syn match  vbnetDate		"\d\{1,2\}:\d\d\(:\d\d\)\=\([AP]M\)\=" contained
syn region vbnetDateTime	matchgroup=vbnetDate start=".#"ms=e end="#" contains=vbnetDate

"syn region	vbnetOption	start="^\s*Option\>.*$" skip="\<_$" end="$"
syn match	vbnetOption	"^\s*Option\s\+\(\(Explicit\|Strict\)\(\s\+On\|\s\+Off\)\=\|Compare\s\+\(Binary\|Text\)\)\s*$"
" TODO: can #Directives really cross line breaks with '_'?
syn region	vbnetPreCondit
    \ start="^\s*#\s*\(Const\|\|If\|ElseIf\|Else\|End\s\+If\)\>"
    \ skip="\<_$" end="$" contains=vbnetComment keepend
syn region	vbnetRegion matchgroup=vbnetPreCondit start="^\s*#\s*Region\>.*$" end="^\s*#\s*End\s\+Region\>.*$" fold contains=TOP

syn match   vbnetNumber		"[+-]\=\(&O[0-7]*\|&H\x\+\|\<\d\+\)[SIL]\=\>"
syn match   vbnetNumber		"[+-]\=\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[FRD]\=\>"
syn match   vbnetNumber		"[+-]\=\<\d\+[eE][-+]\=\d\+[FRD]\=\>"
syn match   vbnetNumber		"[+-]\=\<\d\+\([eE][-+]\=\d\+\)\=[FRD]\>"

"let vbnet_v1 = 1
if ! exists("vbnet_v1")
    syn keyword vbnetType		SByte UShort UInteger ULong
    syn keyword vbnetCast		CSByte CUShort CUInt CULng TryCast
    syn keyword vbnetRepeat		Continue
    syn match   vbnetFunction		"\<\(End\s\+\)\=Operator\>"
    syn keyword vbnetModifier		Widening Narrowing
    syn keyword vbnetOperator		IsNot
    syn keyword vbnetClassModifier	Partial
    syn keyword vbnetStatement		Of Global
    syn match   vbnetStatement		"\<\(End\s\+\)\=Using\>"
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_vbnet_syntax_inits")
	if version < 508
		let did_vbnet_syntax_inits = 1
		command -nargs=+ HiLink hi link <args>
	else
		command -nargs=+ HiLink hi def link <args>
	endif

	HiLink vbnetTypeSpecifier	vbnetType
	HiLink vbnetCast		vbnetType
	HiLink vbnetType		Type
	HiLink vbnetStorage		StorageClass
	HiLink vbnetRepeat		Repeat
	HiLink vbnetConditional		Conditional
	HiLink vbnetLabel		Label
	HiLink vbnetClassModifier	StorageClass
	HiLink vbnetAccessModifier	vbnetModifier
	HiLink vbnetModifier		Keyword
	HiLink vbnetConstant		Constant
	HiLink vbnetException		Exception
	HiLink vbnetEvent		Keyword
	HiLink vbnetStatement		Statement
	HiLink vbnetError		Error

	HiLink vbnetTodo		Todo
	HiLink vbnetComment		Comment

	HiLink vbnetString		String
	HiLink vbnetPreCondit		PreCondit
	HiLink vbnetOption		PreProc
	HiLink vbnetCharacter		Character
	HiLink vbnetNumber		Number
	HiLink vbnetDate		Constant

	HiLink vbnetFunction		Statement
	HiLink vbnetArrayHandler	Statement
	HiLink vbnetOperator		Operator

	delcommand HiLink
endif

let b:current_syntax = "vbnet"

" vim: ts=8 noet
