function! s:xnewline() abort
  " Work as just a "<CR>" if not on a normal window.
  if empty(&buftype)
    try
      " Merge undo sequences of multiple newline insertions which are caused
      " by sequential invocation of this function.
      if getreg('.') ==# "\n"
        undojoin
      endif
    catch /^Vim(undojoin):/
      " Ignore any error from ":undojoin" to allow this function invocation
      " even if it is right after undo/redo.
    endtry

    " Insert a newline.
    return "A\<CR>\<Esc>"
  else
    return "\<CR>"
  endif
endfunction

" Create a newline instantly even if in Normal mode, but work as just a "<CR>"
" if in a "command-line-window".
nnoremap <expr> <Plug>(newline) <SID>xnewline()
