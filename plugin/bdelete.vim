vim9script

# Whether or not the buffer is the same as a new, unnamed and empty buffer.
# This function returns "0" if the buffer id is invalid.
def IsEmptyBuffer(buffer_id: number): bool
  if buffer_id == bufnr('%')
    return empty(bufname('%'))
      && line('$') <= 1
      && empty(getbufline(buffer_id, 1)[0])
      && !getbufvar(buffer_id, '&modified')
  elseif exists('?getbufinfo')
    const bufinfo = getbufinfo(buffer_id)->get(0, {})

    return !empty(bufinfo)
      && empty(bufinfo['name'])
      && bufinfo['lnum'] <= 1
      && empty(getbufline(buffer_id, 1)[0])
      && !bufinfo['changed']
  else
    return empty(bufname(buffer_id))
      && getbufline(buffer_id, 1, '$') == ['']
      && !getbufvar(buffer_id, '&modified')
  endif
enddef

# Execute ":bdelete" only if the current buffer isn't the last normal buffer.
# Normal buffers are just for editing files and not terminal or unlisted (i.e.
# help) buffers.
def Bdelete(bang: string)
  const bufid = bufnr('%')
  # Ignore non normal buffers.
  const buffers = filter(tabpagebuflist(), "empty(getbufvar(v:val, '&buftype'))")

  # Create a new empty buffer at the current buffer to keep the current
  # tabpage if the current buffer is the last one in the current tabpage.
  if len(buffers) < 2
    if IsEmptyBuffer(bufid) && tabpagenr('$') > 1
      # No need to do anything if the last buffer on the current tab is just
      # an empty buffer.
      return
    else
      # This does nothing if the current buffer is already an new empty
      # buffer.
      execute printf('enew%s', bang)
    endif
  else
    execute printf('bdelete%s %s', bang, bufid)
  endif
enddef

def DeleteEmptyBuffers(bang: string, line1: number, line2: number)
  var buffers = {}

  for tn in range(1, tabpagenr('$'))
    for bn in tabpagebuflist(tn)
      buffers[bn] = 1
    endfor
  endfor

  for bn in range(line1, line2)
    if buflisted(bn) && IsEmptyBuffer(bn) && !get(buffers, bn, 0)
      execute printf('bdelete%s', bang) bn
    endif
  endfor
enddef

command! -bang -bar Bdelete {
  Bdelete(<q-bang>)
}

command! -bang -bar -range=% -addr=loaded_buffers DeleteEmptyBuffers {
  DeleteEmptyBuffers(<q-bang>, <line1>, <line2>)
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
