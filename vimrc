" {{{ load divideed config files
runtime! config/*.vim
" }}}

" {{{ load local config files
if filereadable(expand($HOME . '/.vimrc.local'))
  source $HOME/.vimrc.local
endif
" }}}
