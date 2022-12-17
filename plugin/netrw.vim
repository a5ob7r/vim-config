function! s:toggle_newrw() abort
  let l:cwd = getcwd()

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
command! ToggleNetrw call s:toggle_newrw()
