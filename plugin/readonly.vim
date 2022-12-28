function! s:readonly(bang, mods, ...) abort
  if !empty(a:0)
    let l:opener = empty(a:bang) ? 'edit' : 'split'

    execute a:mods l:opener a:1
  endif

  setlocal readonly nomodifiable noswapfile
endfunction

" Open a file in readonly mode, or set readonly mode into the current buffer.
command! -bang -bar -nargs=? -complete=file Readonly
  \ call s:readonly(<q-bang>, <q-mods>, <q-args>)
