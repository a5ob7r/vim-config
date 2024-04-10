function! s:toggle_newrw(bang) abort
  let l:cwd = empty(a:bang) ? getcwd() : expand('%:p:h')

  " Prefer the current working directory.
  if get(b:, 'netrw_curdir', '') !=# l:cwd
    execute 'Explore' l:cwd
  elseif exists(':Rexplore') && exists('w:netrw_rexlocal')
    Rexplore
  else
    Explore
  endif
endfunction

function! s:load_netrw() abort
  unlet g:loaded_netrwPlugin
  unlet g:loaded_netrw

  source $VIMRUNTIME/plugin/netrwPlugin.vim
  source $VIMRUNTIME/autoload/netrw.vim

  doautocmd <nomodeline> FileExplorer VimEnter
endfunction

" Toggle the netrw window.
command! -bar -bang ToggleNetrw call s:toggle_newrw(<q-bang>)

command! -bar LoadNetrw call s:load_netrw()

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
