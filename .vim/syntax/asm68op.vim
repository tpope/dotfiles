" Vim syntax file
" Language:     68k Assembler Opcodes
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" Last Change:  2005 Dec 07

  syn case ignore

"Arithemetic Operations
  syn keyword asmOperator add adda addi addq addx
  syn keyword asmOperator asl asr
  syn keyword asmOperator divs divu
  syn keyword asmOperator sub suba subi subq subx
  syn keyword asmOperator muls mulu
  syn keyword asmOperator neg negx
"Conditional Branches
  syn keyword asmConditional bcc bchg bclr bcs beq bet bf bge bgt bhi ble bls blt bmi bne bpl bset bt btst bvc bvs
  syn keyword asmRepeat dbcc dbcs dbeq dbet dbf dbge dbgt dbhi dble dbls dblt dbmi dbne dbpl dbra dbt dbvc dbvs
  syn keyword asmStatement bra bsr jmp jsr
  syn keyword asmOpcode reset rte rtr rts
  syn keyword asmOpcode stop
"Tests
  syn keyword asmOpcode chk cmp cmpa cmpi cmpm
  syn keyword asmOpcode tst
"Register Operations
  syn keyword asmOpcode clr
  syn keyword asmOpcode ext
  syn keyword asmOpcode lea
  syn keyword asmOpcode move movea movem moveq
  syn keyword asmOpcode pea
  syn keyword asmOpcode swap
"Logical Operations
  syn keyword asmLogical and andi
  syn keyword asmLogical eor eori exg
  syn keyword asmLogical lsl lsr
  syn keyword asmLogical not
  syn keyword asmLogical or ori
  syn keyword asmLogical rol ror roxl roxr

  syn keyword asmData dc ds

  syn match asmSizeShrt '\.s'hs=s+1
  syn match asmSizeByte '\.b'hs=s+1
  syn match asmSizeWord '\.w'hs=s+1
  syn match asmSizeLong '\.l'hs=s+1


if !exists("did_a68op_syntax_inits")
  let did_a68op_syntax_inits = 1

  hi link asmData		asmOpcode
  hi link asmRepeat		Repeat
  hi link asmConditional	Conditional
  hi link asmLabel		Label
  hi link asmStatement		Statement
  hi link asmLogical		asmOperator
  hi link asmOperator		Operator
  hi link asmSizeShrt		Type
  hi link asmSizeByte		Type
  hi link asmSizeWord		Type
  hi link asmSizeLong		Type
" My default-color overrides:
  hi asmSizeShrt ctermfg=darkgreen guifg=#003000
  hi asmSizeByte ctermfg=darkgreen guifg=#006000
  hi asmSizeWord ctermfg=green guifg=#00A000
  hi asmSizeLong ctermfg=lightgreen guifg=#00E000

endif

" vim: ts=8
