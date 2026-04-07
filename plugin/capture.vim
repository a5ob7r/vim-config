vim9script

class WithLocker
  var lock = false

  def Call(Proc: func, args: list<any>): any
    if this._IsLocked()
      throw "WithLocker.Call(): Cannot get a lock."
    endif

    defer this._Unlock()

    this._Lock()

    return call(Proc, args)
  enddef

  def _IsLocked(): bool
    return this.lock
  enddef

  def _Lock()
    this.lock = true
  enddef

  def _Unlock()
    this.lock = false
  enddef
endclass

const capture_with_locker = WithLocker.new()

def MakeBufferScratch()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
enddef

def MakeBufferReadonly()
  setlocal readonly
  setlocal nomodifiable
enddef

# A wrapper for "execute()".
def Redirect(command: string, raw: bool): list<string>
  if !raw
    defer (v) => {
      &l:list = v
    }(&l:list)

    # Do not output extra characters displayed by the "list" option.
    noautocmd setlocal nolist
  endif

  return execute(command)->split('\n')
enddef

def Capture(command: string, opts = {})
  const mods = get(opts, 'mods', '')
  const raw = get(opts, 'raw', false)

  if empty(command)
    throw 'Not found a capturable command. Run with arguments or run a command which you want to capture before run :Capture.'
  endif

  capture_with_locker.Call(
    () => {
      const lines = Redirect(command, raw)

      execute mods 'new'
      MakeBufferScratch()

      setline('.', lines)

      MakeBufferReadonly()
    },
    []
  )
enddef

# Capture Ex command outputs and write it to a new scratch buffer.
command! -bang -nargs=* -complete=command Capture {
  Capture(<q-args> ?? @:, { mods: <q-mods>, raw: <bang>false })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
