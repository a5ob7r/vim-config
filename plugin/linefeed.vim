function! s:indent_spaces(n) abort
  let l:tab = '	'
  let l:space = ' '

  if &expandtab
    let l:tabs = 0
    let l:spaces = a:n
  else
    let l:tabs = a:n / &tabstop
    let l:spaces = a:n % &tabstop
  endif

  return repeat(l:tab, l:tabs) . repeat(l:space, l:spaces)
endfunction

function! s:indent_spaces_helper(n)
  let l:line = s:indent_spaces(a:n)

  if type(l:line) == 1
    return l:line
  else
    return ''
  endif
endfunction

function! s:linefeed()
  let l:n = getcurpos()[4] - 1

  return "\<CR> \<C-U>" . s:indent_spaces_helper(l:n)
endfunction

" Emulate linefeed without carrige return.
"
" Example:
" | indicates cursor position. It is zero width in fact.
"
" From
" aaa|bbb
"
" To
" aaa
"    |bbb
"
inoremap <silent> <Plug>(linefeed) <C-R>=<SID>linefeed()<CR>
