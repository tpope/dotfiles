" flagship.vim
" Author: Tim Pope <http://tpo.pe/>

if exists('g:loaded_flagship')
  finish
endif
let g:loaded_flagship = 1

if !exists('g:flagship_cwd')
  let g:flagship_cwd = getcwd()
endif

augroup flagship
  autocmd!
  autocmd WinEnter,VimEnter * call flagship#enter()
augroup END
