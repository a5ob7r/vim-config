if !has('terminal')
  finish
endif

" Open a single window terminal on a new tabpage.
function! s:open_terminal_on_newtab(count, dir) abort
  " -1 is supplied if no range is specified with a command with "-range"
  " attribute and "-addr=tabs" one.
  let l:count = a:count > -1 ? string(a:count) : ''

  " The directory path where we want to open a new tabpage.
  let l:dir = fnameescape(a:dir)

  " The original tabpage number.
  let l:tabpagenum = tabpagenr()

  try
    execute printf('%stabnew', l:count)
    execute 'tcd' l:dir
    terminal ++curwin
  catch /^Vim(tcd):/
    " Cleanup an empty tabpage.
    tabclose
    " Go to a previous tabpage.
    execute 'tabnext' l:tabpagenum

    " Show the exception instead of rethrowing it because doing it isn't
    " permitted by Vim.
    echoerr v:exception
  endtry
endfunction

command! -range -addr=tabs -nargs=? -complete=dir Terminal
  \ call s:open_terminal_on_newtab(<count>, <q-args>)
