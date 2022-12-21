function! s:indent_spaces(n) abort
  let l:tabs = &expandtab ? 0 : a:n / &tabstop
  let l:spaces = &expandtab ? a:n : a:n % &tabstop

  return repeat("\<Tab>", l:tabs) . repeat(' ', l:spaces)
endfunction

function! s:linefeed() abort
  " The screen column number just before the current cursor.
  let l:n = max([0, virtcol('.', 1)[0] - 1])

  " Remove all of automatic indentation before inserting a calculated one like
  " a linefeed.
  return "\<CR> \<C-U>" . s:indent_spaces(l:n)
endfunction

" Emulate a linefeed without a carrige return.
"
" Example:
" '|' indicates the current cursor position. It has zero width in fact.
"
" From
" aaa|bbb
"
" To
" aaa
"    |bbb
"
inoremap <silent> <Plug>(linefeed) <C-R>=<SID>linefeed()<CR>
