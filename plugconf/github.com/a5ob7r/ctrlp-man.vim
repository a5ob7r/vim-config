function! s:lookup_manual() abort
  let l:q = input('keyword> ', '', 'shellcmd')

  if empty(l:q)
    return
  endif

  execute 'CtrlPMan' l:q
endfunction

command! LookupManual call s:lookup_manual()

nnoremap <silent> <leader>m :LookupManual<CR>
