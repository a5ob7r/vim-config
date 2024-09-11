vim9script

# Read/Write the binary format, but are these configurations really
# comfortable? Maybe we should use a binary editor insated.

def SetAutocmds()
  augroup vimrc:xxd
    autocmd! * <buffer>

    autocmd BufReadPost <buffer> {
      execute 'silent :%!xxd -g 1'
      set filetype=xxd
    }
    autocmd BufWritePre <buffer> {
      b:cursorpos = getcurpos()
      execute ':%!xxd -r'
    }
    autocmd BufWritePost <buffer> {
      execute 'silent :%!xxd -g 1'
      set nomodified
      cursor(b:cursorpos[1], b:cursorpos[2], b:cursorpos[3])
      unlet b:cursorpos
    }
  augroup END
enddef

def UnsetAutocmds()
  augroup vimrc:xxd
    autocmd! * <buffer>
  augroup END
enddef

augroup vimrc:binary
  autocmd!
  autocmd OptionSet binary {
    if v:option_new ==# '1'
      SetAutocmds()
    else
      UnsetAutocmds()
    endif
  }
augroup END

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
