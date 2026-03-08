vim9script

def DictionarizedLsLine(line: string): dict<any>
  const matches = matchlist(line, '^\s*\([1-9]\d*\)\(.\{5}\) "\(.*\)" \s*line \(\d\+\)$')

  return {
    bufnr: matches[1]->str2nr(),
    indicators: matches[2],
    filename: matches[3],
    lnum: matches[4]->str2nr(),
  }
enddef

def QfLs(opts: dict<any>)
  const bang = get(opts, 'bang', '')
  const flags = get(opts, 'flags', '')

  const buffers = execute($'ls{bang} {flags}')->split('\n')->map((_, line) => DictionarizedLsLine(line))
  const max_bufnr_ndigits = mapnew(buffers, (_, buffer) => buffer['bufnr']->len())->insert(3)->max()

  setqflist([], ' ', {
    items: buffers,
    title: 'Buffer lists',
    quickfixtextfunc: (_info) => mapnew(buffers, (_, buffer) => {
      const bufnr = buffer['bufnr']
      const indicators = buffer['indicators']
      const filename = buffer['filename']
      const lnum = buffer['lnum']
      const text = getbufline(bufnr, lnum)->get(0, '')

      return printf($'%{max_bufnr_ndigits}d%s %-30S | {lnum} col 0 | %s', bufnr, indicators, $'"{filename}"', text)
    }),
  })
enddef

# "files", "buffers" and "ls", but view the outputs in a quickfix window.
command! -bang -bar -nargs=* Files {
  silent doautocmd QuickFixCmdPre Files
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Files
}
command! -bang -bar -nargs=* Buffers {
  silent doautocmd QuickFixCmdPre Buffers
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Buffers
}
command! -bang -bar -nargs=* Ls {
  silent doautocmd QuickFixCmdPre Ls
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Ls
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
