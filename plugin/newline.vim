vim9script

const MARKER = $'xnewline{rand()}'
const MARKER_KEYSTROKES = MARKER->map((_, c) => c .. "\<BS>")
const NEWLINE_KEYSTROKES = MARKER_KEYSTROKES .. "\n"

def Xnewline(): string
  # Work as just a "<CR>" if not on a normal window.
  if !&buftype->empty()
    return "\<CR>"
  endif

  try
    # Merge undo sequences of multiple newline insertions which are caused by
    # sequential invocation of this function if the current line is blank and
    # no cursor movement since the last newline insersion.
    if getreg('.') ==# NEWLINE_KEYSTROKES
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
  return $"A{NEWLINE_KEYSTROKES}\<Esc>"
enddef

# Create a newline instantly even if in Normal mode, but work as just a "<CR>"
# if in a "command-line-window".
nnoremap <expr> <Plug>(newline) <SID>Xnewline()

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
