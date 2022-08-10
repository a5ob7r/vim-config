" A wrapper for "execute()".
function! s:redirect(bang, command) abort
  let l:bang = empty(a:bang) ? '' : '!'

  return split(execute(a:command, printf('silent%s', l:bang)), '\n')
endfunction

function! s:capture(bang, mods, command) abort
  let l:command = empty(a:command) ? @: : a:command
  let l:words = split(l:command)

  if empty(l:words)
    echoerr 'Not found a capturable command. Run a command which you want to capture before run :Capture.'
    return
  elseif fullcommand(l:words[0]) ==# 'Capture'
    echoerr ':Capture does not capture itself.'
    return
  endif

  let l:bufs = s:redirect(a:bang, l:command)

  execute a:mods 'new'
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  call setline('.', l:bufs)

  setlocal readonly
  setlocal nomodifiable
endfunction

" Capture Ex command outputs and redirect it to a new empty buffer.
command! -nargs=* -complete=command -bang Capture
      \ call s:capture(<q-bang>, <q-mods>, <q-args>)
