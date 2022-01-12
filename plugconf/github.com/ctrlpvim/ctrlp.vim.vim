" NOTE: <Nul> is sent when Ctrl and Space are typed.
let g:ctrlp_map = '<Nul>'
let g:ctrlp_cmd = 'CtrlPp'
let g:ctrlp_show_hidden = 1
let g:ctrlp_lazy_update = 150

if executable('git')
  let g:ctrlp_user_command = ['.git', 'git -C %s ls-files -co --exclude-standard']
endif

function! s:ctrlp_proxy() abort
  let l:home = expand('~')
  let l:cwd = getcwd()

  " Make vim heavy or freeze to run CtrlP to search many files. For example
  " this is caused when run `CtrlP` on home directory or edit a file on home
  " directory.
  if l:home ==# l:cwd
    throw 'Forbidden to run CtrlP on home directory'
  endif

  CtrlP l:cwd
endfunction

command! CtrlPp call s:ctrlp_proxy()

nnoremap <leader>b :CtrlPBuffer<CR>
