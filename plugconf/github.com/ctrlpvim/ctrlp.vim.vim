" NOTE: <Nul> is sent when Ctrl and Space are typed.
let g:ctrlp_map = '<Nul>'
let g:ctrlp_show_hidden = 1
let g:ctrlp_lazy_update = 150
let g:ctrlp_reuse_window = '.*'
let g:ctrlp_use_caching = 0

let g:ctrlp_user_command = {}
let g:ctrlp_user_command['types'] = {}

if executable('git')
  let g:ctrlp_user_command['types'][1] = ['.git', 'git -C %s ls-files -co --exclude-standard']
endif

if executable('fd')
  let g:ctrlp_user_command['fallback'] = 'fd --type=file --type=symlink --hidden . %s'
elseif executable('find')
  let g:ctrlp_user_command['fallback'] = 'find %s -type f'
else
  let g:ctrlp_use_caching = 1
  let g:ctrlp_cmd = 'CtrlPp'
endif

function! s:ctrlp_proxy(bang, ...) abort
  let l:bang = empty(a:bang) ? '' : '!'
  let l:dir = a:0 ? a:1 : getcwd()

  let l:home = expand('~')

  " Make vim heavy or freeze to run CtrlP to search many files. For example
  " this is caused when run `CtrlP` on home directory or edit a file on home
  " directory.
  if empty(l:bang) && l:home ==# l:dir
    throw 'Forbidden to run CtrlP on home directory'
  endif

  CtrlP l:dir
endfunction

command! -bang -nargs=? -complete=dir CtrlPp call s:ctrlp_proxy(<q-bang>, <f-args>)

nnoremap <silent> <leader>b :<C-U>CtrlPBuffer<CR>
