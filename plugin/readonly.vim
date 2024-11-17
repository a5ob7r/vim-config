function! s:readonly(bang, mods, args) abort
  if !empty(a:args)
    execute printf('%s OpenHelper%s %s', a:mods, a:bang, a:args)
  endif

  Unwritable
endfunction

" Open a file in readonly mode, or set readonly mode into the current buffer.
command! -bang -bar -nargs=? -complete=file Readonly call s:readonly(<q-bang>, <q-mods>, <q-args>)
command! -bang -bar -nargs=? -complete=file RO <mods> Readonly<bang> <args>

command! -bar Writable setlocal noreadonly modifiable swapfile
command! -bar Unwritable setlocal readonly nomodifiable noswapfile
