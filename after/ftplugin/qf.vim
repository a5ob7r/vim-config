nnoremap <buffer> <silent> q <Cmd>close<CR>
nnoremap <buffer> <silent> <C-X> <C-W><CR>

" Reset the following key mappings.
nnoremap <buffer> j j
nnoremap <buffer> k k
nnoremap <buffer> gj gj
nnoremap <buffer> gk gk

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')

const s:undos =<< trim END
  nunmap <buffer> q
  nunmap <buffer> <C-X>
  nunmap <buffer> j
  nunmap <buffer> k
  nunmap <buffer> gj
  nunmap <buffer> gk
END

let b:undo_ftplugin = join([b:undo_ftplugin] + s:undos, "\n")

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
