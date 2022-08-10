function! s:readonly(bang, mods, ...)
  if !empty(a:0)
    if empty(a:bang)
      let l:open_cmd = 'edit'
    else
      let l:open_cmd = 'split'
    endif

    execute a:mods l:open_cmd a:1
  endif

  setlocal readonly nomodifiable noswapfile
endfunction

" Open a file in readonly mode, or set readonly mode into the current buffer.
command! -bang -nargs=? -complete=file Readonly
      \ call s:readonly(<q-bang>, <q-mods>, <q-args>)
