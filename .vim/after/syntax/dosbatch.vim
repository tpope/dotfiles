if version < 600
  set iskeyword=48-57,$,.,{,},:,A-Z,a-z,_
else
  setlocal iskeyword=48-57,$,.,{,},:,A-Z,a-z,_
endif

syn clear dosbatchIdentifier
syn clear dosbatchVariable
syn clear dosbatchSet
syn clear dosbatchSpecialChar

syn match dosbatchIdentifier    contained "\s\h\k*\>"
syn match dosbatchVariable	"%\h\k*%"
syn match dosbatchVariable	"%\h\k*:\*\=[^=]*=[^%]*%"
syn match dosbatchVariable	"%\h\k*:\~\d\+,\d\+%" contains=dosbatchInteger
syn match dosbatchSet		"\s\h\k*[+-]\==\{-1}" contains=dosbatchIdent