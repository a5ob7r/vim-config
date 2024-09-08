vim9script

def Gcd(query: string, bang: string, mods: string, cder = 'cd')
  # Use "systemlist()" to strip a trailing "^@" instead of "system()".
  const [directory] = systemlist($'ghq list --exact --full-path {shellescape(query)}')

  execute mods $'{cder}{bang}' fnameescape(directory)
enddef

def GcdComplete(_ArgLead: string, _CmdLine: string, _CursorPos: number): string
  return system('ghq list')
enddef

# ":cd" to a VCS repository managed by "ghq" using only the sub-path.
#
# ":Gcd vim-config"
command! -bang -nargs=1 -complete=custom,GcdComplete Gcd {
  Gcd(<q-args>, <q-bang>, <q-mods>)
}

# A ":tcd" version of ":Gcd".
command! -bang -nargs=1 -complete=custom,GcdComplete Gtcd {
  Gcd(<q-args>, <q-bang>, <q-mods>, 'tcd')
}

# A ":lcd" version of ":Gcd".
command! -bang -nargs=1 -complete=custom,GcdComplete Glcd {
  Gcd(<q-args>, <q-bang>, <q-mods>, 'lcd')
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
