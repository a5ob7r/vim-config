if has('gui_macvim')
  set guifont=Cica-Regular:h14
  set transparency=10
  " set blurradius=20
else
  set guifont=monospace
endif

" {{{ window size
set columns=120
set lines=40
" }}}

" {{{ hide GUI interface
set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=l
set guioptions-=b
" }}}
