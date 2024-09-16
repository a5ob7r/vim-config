vim9script

#
# gvimrc
#

set guioptions-=L
set guioptions-=T
set guioptions-=a
set guioptions-=e
set guioptions-=m
set guioptions-=r

if has('win32')
  set guifont=Cascadia\ Mono:h16
elseif has('osxdarwin')
  # Do not anything.
else
  set guifont=monospace
endif

# vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
