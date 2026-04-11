vim9script

class Xnewline
  static const _NEWLINE_KEYSTROKES = () => {
    return map($'xnewline{rand()}', (_, c) => c .. "\<BS>") .. "\n"
  }()

  def Call(): string
    # Work as just a "<CR>" if not on a normal window.
    if !&buftype->empty()
      return "\<CR>"
    endif

    try
      # Merge undo sequences of multiple newline insertions which are caused by
      # sequential invocation of this function if the current line is blank and
      # no cursor movement since the last newline insersion.
      if getreg('.') ==# _NEWLINE_KEYSTROKES
          && getline('.') =~# '^\s*$'
          # A naive detection of whether or not the cursor moved since the last
          # Insert mode leaving.
          && getpos('.') == getpos("'^")
        undojoin
      endif
    catch /^Vim(undojoin):/
      # Ignore any error from ":undojoin" to allow this function invocation
      # even if it is right after undo/redo.
    endtry

    # Insert a newline.
    return $"A{_NEWLINE_KEYSTROKES}\<Esc>"
  enddef
endclass

# Create a newline instantly even if in Normal mode, but work as just a "<CR>"
# if in a "command-line-window".
nnoremap <expr> <Plug>(newline) Xnewline.new().Call()

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
