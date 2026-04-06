vim9script

# A lock to avoid nested ":Capture" executions.
var is_execution_locked = false

def IsExecutionLocked(): bool
  return is_execution_locked
enddef

def LockExecution()
  is_execution_locked = true
enddef

def UnlockExecution()
  is_execution_locked = false
enddef

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

  if IsExecutionLocked()
    throw ':Capture does not capture itself.'
  endif

  if empty(command)
    throw 'Not found a capturable command. Run with arguments or run a command which you want to capture before run :Capture.'
  endif

  try
    LockExecution()

    const lines = Redirect(command, raw)

    execute mods 'new'
    MakeBufferScratch()

    setline('.', lines)

    MakeBufferReadonly()
  finally
    # TODO: Switch to ":defer".
    UnlockExecution()
  endtry
enddef

# Capture Ex command outputs and write it to a new scratch buffer.
command! -bang -nargs=* -complete=command Capture {
  Capture(<q-args> ?? @:, { mods: <q-mods>, raw: <bang>false })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
