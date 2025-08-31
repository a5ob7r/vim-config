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

def SetOption(name: string, value: any)
  execute $'&{name} = {value}'
enddef

# A wrapper for "execute()".
def Redirect(command: string): list<string>
  defer SetOption('list', &list)

  # Do not output extra characters displayed by the "list" option.
  set nolist

  return execute(command)->split('\n')
enddef

def Capture(command: string, opts = {})
  const mods = get(opts, 'mods', '')

  if IsExecutionLocked()
    throw ':Capture does not capture itself.'
  endif

  if empty(command)
    throw 'Not found a capturable command. Run with arguments or run a command which you want to capture before run :Capture.'
  endif

  try
    LockExecution()

    const lines = Redirect(command)

    execute mods 'new'
    MakeBufferScratch()

    call setline('.', lines)

    MakeBufferReadonly()
  finally
    # TODO: Switch to ":defer".
    UnlockExecution()
  endtry
enddef

# Capture Ex command outputs and write it to a new scratch buffer.
command! -nargs=* -complete=command Capture {
  Capture(<q-args> ?? @:, { mods: <q-mods> })
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
