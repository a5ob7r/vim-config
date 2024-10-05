vim9script

# Whether or not the buffer is the same as a new, unnamed and empty buffer.
# This function returns "0" if the buffer id is invalid.
def IsEmptyBuffer(buffer_id: number): bool
  const bufinfo = getbufinfo(buffer_id)->get(0, {})

  return !empty(bufinfo)
    && empty(bufinfo['name'])
    && bufinfo['lnum'] <= 1
    && empty(getbufline(buffer_id, 1)[0])
    && !bufinfo['changed']
enddef

# Execute ":bdelete", but this command try to keep at least one window or a
# normal buffer in the current tabpage.
def Bdelete(bang: string)
  const current_bufnr = bufnr()
  const normal_buffers = tabpagebuflist()->filter((i, v) => getbufvar(v, '&buftype')->empty())

  if empty(&buftype) ? len(normal_buffers) <= 1 : winnr('$') <= 1
    execute $'enew{bang}'
  endif

  execute $'bdelete{bang} {current_bufnr}'
enddef

def DeleteEmptyBuffers(bang: string, line1: number, line2: number)
  var buffers = {}

  range(1, tabpagenr('$'))
    ->map((i, v) => tabpagebuflist(v))
    ->flattennew()
    ->foreach((i, v) => {
      buffers[v] = 1
    })

  range(line1, line2)
    ->filter((i, v) => buflisted(v) && IsEmptyBuffer(v) && !get(buffers, v))
    ->foreach((i, v) => {
      execute $'bdelete{bang} {v}'
    })
enddef

command! -bang -bar Bdelete {
  Bdelete(<q-bang>)
}

command! -bang -bar -range=% -addr=loaded_buffers DeleteEmptyBuffers {
  DeleteEmptyBuffers(<q-bang>, <line1>, <line2>)
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
