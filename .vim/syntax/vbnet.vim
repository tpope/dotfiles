" Vim syntax file
" Language:	VB.NET
" Maintainer:   Tim Pope <vim@rebelongto.us>
" Last Change:  2006 Mar 27
" Filenames:    *.vb
" $Id$

" Loosely modeled after cs.vim

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
syn keyword vbnetConditional	Then ElseIf Else
syn match   vbnetConditional	"\<\(End\s\+\)\=If\>"
syn match   vbnetConditional	"\<\(Select\(\s\+Case\)\|End\s\+Select\)\>"
syn keyword vbnetLabel		Case
syn keyword vbnetArrayHandler	Erase Preserve ReDim
syn keyword vbnetAccessModifier	Friend Private Protected Public
syn keyword vbnetClassModifier	MustInherit NotInheritable Inherits Implements
" TODO: categorize
syn keyword vbnetModifier	MustOverride NotOverridable Overridable Overrides ReadOnly WriteOnly Shared Static Overloads Shadows Handles WithEvents Assembly Auto Unicode Ansi Default
syn keyword vbnetBoolean	False True
syn keyword vbnetConstant	Nothing
syn keyword vbnetException	Catch When Finally Resume Throw
syn match   vbnetException	"\<\(On\s\+Error\|\(End\s\+\)\=Try\)\>"
syn keyword vbnetFunction       Call Declare Alias Lib
syn match   vbnetFunction	"\<\(End\s\+\)\=\(Sub\|Function\|Property\|Get\|Set\)\>"
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

" 2.4.6 Date literals
syn match  vbnetDate		"1\=\d\([-/]\)[123]\=\d\1\d\{3,4\}" contained
" For simplicity, require at least an hour and a minute in a time, and require
" minutes and seconds to be two digits
syn match  vbnetDate		"\<[12]\=\d:\d\d\(:\d\d\)\=\s*\([AP]M\)\=\>" contained
syn match  vbnetDate		"\<_$"
" Avoid matching #directives
syn region vbnetDateGroup	matchgroup=vbnetDate start="\(\S\s*\)\@<=#" skip="\<_$" end="\(\S\s*\)\@<=#" end="$" contains=vbnetDate

syn match	vbnetOption	"^\s*Option\s\+\(\(Explicit\|Strict\)\(\s\+On\|\s\+Off\)\=\|Compare\s\+\(Binary\|Text\)\)\s*$"
syn region	vbnetDefine	start="^\s*#\s*Const\>" skip="\<_$" end="$"
    \ contains=vbnetComment keepend
syn region	vbnetPreCondit
    \ start="^\s*#\s*\(If\|ElseIf\|Else\|End\s\+If\)\>" skip="\<_$" end="$"
    \ contains=vbnetComment keepend
"syn match	vbnetPreCondit "\(\s*#\s*\(Else\)\=If\>.*\)\@<=\<Then\>"
syn region	vbnetRegion matchgroup=vbnetPreProc start="^\s*#\s*Region\>" end="^\s*#\s*End\s\+Region\>" fold contains=TOP

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

    syn match   vbnetXmlCommentLeader	+'''+    contained
    syn match   vbnetXmlComment		+'''.*$+ contains=vbnetXmlCommentLeader,@vbnetXml
    syntax include @vbnetXml syntax/xml.vim
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
	HiLink vbnetBoolean		Boolean
	HiLink vbnetConstant		Constant
	HiLink vbnetException		Exception
	HiLink vbnetEvent		Keyword
	HiLink vbnetStatement		Statement
	HiLink vbnetError		Error

	HiLink vbnetTodo		Todo
	HiLink xmlRegion		vbnetXmlComment
	HiLink vbnetXmlCommentLeader	vbnetXmlComment
	HiLink vbnetXmlComment		vbnetComment
	HiLink vbnetComment		Comment

	HiLink vbnetString		String
	HiLink vbnetDefine		Define
	HiLink vbnetPreCondit		PreCondit
	HiLink vbnetOption		vbnetPreProc
	HiLink vbnetPreProc		PreProc
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
