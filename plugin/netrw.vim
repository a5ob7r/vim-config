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

" Toggle the netrw window.
command! -bar -bang ToggleNetrw call s:toggle_newrw(<q-bang>)
