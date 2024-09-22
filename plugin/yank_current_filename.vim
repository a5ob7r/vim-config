vim9script

def SetClipboardRegisters(value: string)
  @" = value
  @* = value
  @+ = value
enddef

def YankCurrentFilename(opts = {})
  const filename = expand('%')

  if empty(filename)
    echohl WarningMsg
    echomsg 'No filename for the current buffer.'
    echohl None
    return
  endif

  const o_lineno = get(opts, 'lineno')

  if o_lineno
    const lineno = getpos('.')[1]
    SetClipboardRegisters($'{filename}:{lineno}')
  else
    SetClipboardRegisters(filename)
  endif
enddef

command! -bang YankCurrentFilename {
  YankCurrentFilename({ lineno: <bang>false })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
