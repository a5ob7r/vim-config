setlocal expandtab&
setlocal list&
setlocal tabstop&

nnoremap <buffer> <silent> q <Cmd>close<CR>

let b:undo_ftplugin ..= '| setlocal expandtab< list< tabstop< | nunmap <buffer> q'

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
