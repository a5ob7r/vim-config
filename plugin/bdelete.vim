vim9script

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

# Whether or not the buffer is the same as a new, unnamed and empty buffer.
def IsEmptyBuffer(bufinfo: dict<any>): bool
  return !empty(bufinfo)
    && empty(bufinfo.name)
    && bufinfo.lnum <= 1
    && empty(getbufline(bufinfo.bufnr, 1)[0])
    && !bufinfo.changed
enddef

def DeleteBuffers(args: list<string>, opts: dict<any>)
  const bang = get(opts, 'bang', '')
  const mods = get(opts, 'mods', '')
  const line1 = get(opts, 'line1', 1)
  const line2 = get(opts, 'line2', v:numbermax)

  const PREDICATES = {
    any: (_bufinfo) => true,
    displayed: (bufinfo) => !bufinfo.hidden,
    empty: (bufinfo) => IsEmptyBuffer(bufinfo),
    filled: (bufinfo) => !IsEmptyBuffer(bufinfo),
    hidden: (bufinfo) => bufinfo.hidden,
    listed: (bufinfo) => bufinfo.listed,
    normal: (bufinfo) => getbufvar(bufinfo.bufnr, '&buftype')->empty(),
    special: (bufinfo) => !getbufvar(bufinfo.bufnr, '&buftype')->empty(),
    unlisted: (bufinfo) => !bufinfo.listed,
  }

  const predicates =
    reduce(
      args,
      (acc, arg) => {
        const k = arg =~# '^--' ? arg[2 :] : arg

        if !PREDICATES->has_key(k)
          throw $':DeleteBuffers: ''{arg}'' is an invalid option.'
        endif

        return add(acc, PREDICATES[k])
      },
      []
    )

  getbufinfo({ bufloaded: true })->foreach((_i, bufinfo) => {
    if bufinfo.bufnr >= line1 && bufinfo.bufnr <= line2 && reduce(predicates, (acc, predicate) => acc && call(predicate, [bufinfo]), true)
      execute mods $'bdelete{bang}' bufinfo.bufnr
    endif
  })
enddef

def DeleteBuffersComplete(_A: string, _C: string, _P: number): list<string>
  return [
    '--any',
    '--displayed',
    '--empty',
    '--filled',
    '--hidden',
    '--listed',
    '--normal',
    '--special',
    '--unlisted',
  ]
enddef

command! -bang -bar Bdelete {
  Bdelete(<q-bang>)
}

# :DeleteBuffers --listed --hidden --normal
# :silent 1,10DeleteBuffers! --any
command! -bang -bar -nargs=+ -range=% -addr=loaded_buffers -complete=customlist,DeleteBuffersComplete DeleteBuffers {
  DeleteBuffers([<f-args>], { bang: <q-bang>, mods: <q-mods>, line1: <line1>, line2: <line2> })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
