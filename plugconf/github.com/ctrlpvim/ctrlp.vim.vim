let g:ctrlp_map = '<leader><Space>'
let g:ctrlp_cmd = 'CtrlPp'
let g:ctrlp_show_hidden = 1

if executable('git')
  let g:ctrlp_user_command = ['.git', 'git -C %s ls-files -co --exclude-standard']
endif

function! s:ctrlp_proxy() abort
  let l:home = expand('~')
  let l:cwd = getcwd()
  " Dirname of current file name.
  let l:cdn = expand('%:p:h')

  " Make vim heavy or freeze to run CtrlP to search many files. For example
  " this is caused when run `CtrlP` on home directory or edit a file on home
  " directory.
  if l:home ==# l:cwd || l:home ==# l:cdn
    throw 'Forbidden to run CtrlP on home directory'
  endif

  CtrlP
endfunction

command! CtrlPp call s:ctrlp_proxy()

nnoremap <leader>b :CtrlPBuffer<CR>
