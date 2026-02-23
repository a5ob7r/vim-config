vim9script

def ToggleNetrw(opts = {})
  const bang = get(opts, 'bang', '')

  const cwd = empty(bang) ? getcwd() : expand('%:p:h')

  if get(b:, 'netrw_curdir', '') !=# cwd
    execute 'Explore' cwd
  elseif exists(':Rexplore') == 2 && exists('w:netrw_rexlocal')
    execute 'Rexplore'
  else
    execute 'Explore'
  endif
enddef

# Toggle the netrw window.
command! -bar -bang ToggleNetrw {
  ToggleNetrw({ bang: <q-bang> })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
