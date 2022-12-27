" A backward compatible "virtcol()".
function! s:virtcol(expr, ...) abort
  if has('patch-8.2.5019')
    return call('virtcol', [a:expr] + a:000)
  elseif get(a:000, 0, 0)
    let l:line = getline(a:expr)
    let l:idx = col(a:expr)

    let l:start = strdisplaywidth(l:line[: l:idx - 2], 0) + 1
    let l:end = virtcol(a:expr)

    return [l:start, l:end]
  else
    return virtcol(a:expr)
  endif
endfunction

function! s:indent_spaces(n) abort
  let l:tabs = &expandtab ? 0 : a:n / &tabstop
  let l:spaces = &expandtab ? a:n : a:n % &tabstop

  return repeat("\<Tab>", l:tabs) . repeat(' ', l:spaces)
endfunction

function! s:linefeed() abort
  " The screen column number just before the current cursor.
  let l:n = max([0, s:virtcol('.', 1)[0] - 1])

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
