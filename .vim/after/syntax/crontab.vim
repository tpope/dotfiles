if version >= 603
    syntax match  crontabMin     "\_^[0-9\-\/\,\.*]\{}\>"  nextgroup=crontabHr   skipwhite
    syntax match  crontabHr       "\<[0-9\-\/\,\.]\{}\>\|\*\/[0-9]*\>\|\*"  nextgroup=crontabDay   skipwhite contained
endif
syn match  crontabVariable "^ *\([bwglsav]:\)\=[a-zA-Z0-9.!@_%+,]*\ze="

if version >= 508 || !exists("did_crontab_after_syn_inits")
  if version < 508
    let did_crontab_after_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink crontabVariable Identifier

  delcommand HiLink
endif
