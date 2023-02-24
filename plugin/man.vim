" Enable :Man command.
"
" NOTE: An recommended way to enable :Man command on vim help page is to
" source default ftplugin for man by "runtime ftplugin/man.vim" in vimrc. But
" maybe it sources another file if another fplugin/man.vim file on
" runtimepath's directories. So specify default ftplugin for man explicitly.
if exists(':Man') != 2
  try
    source $VIMRUNTIME/ftplugin/man.vim
  catch
    echoerr v:exception
    finish
  endtry
endif

" An enhanced completion for ":Man" using "apropos(1)".
"
" :M
" :M l
" :M 1 ls
function! s:man_complete(arg_lead, cmd_line, cursor_pos) abort
  " Words on the command line.
  let l:words = split(a:cmd_line, '[[:space:]]')

  " Trim command modifiers.
  let l:words = l:words[match(l:words, '^\u') :]

  " Trim a incomplate word.
  if !empty(a:arg_lead) && len(l:words) >= 2
    let l:words = l:words[:-2]
  endif

  " Default section number is 1.
  let l:section = '1'

  " Maybe section number is provided as first argument.
  if len(l:words) >= 2
    let l:section = l:words[1]
  endif

  " A man entry lookup command.
  let l:cmd = ['apropos']

  " Specify a section number.
  let l:args = ['-s', l:section, '.']

  let l:candidates = split(system(join(l:cmd + l:args)), '\n')

  " Fallback to a no option lookup if `-s` option isn't provided.
  " NOTE: This may be slow due to full search.
  if v:shell_error
    let l:args = [printf("'(%s)'", l:section)]

    let l:candidates = split(system(join(l:cmd + l:args)), '\n')
  endif

  let l:candidates = map(l:candidates, printf("matchstr(v:val, '%s')", '[[:alnum:]\.:_-]\+'))

  if !empty(a:arg_lead)
    let l:candidates = filter(l:candidates, printf("v:val[:%d] ==# '%s'", strlen(a:arg_lead) - 1, a:arg_lead))
  endif

  return l:candidates
endfunction

function! s:man(bang, mods, count, ...)
  let l:section = a:count
  let l:name = ''

  if a:0 == 1
    let l:name = a:1
  elseif a:0 >= 2
    let l:section = a:1
    let l:name = a:2
  endif

  if !empty(a:bang)
    enew
    setlocal filetype=man
  endif

  if empty(l:section)
    execute a:mods 'Man' l:name
  else
    execute a:mods 'Man' l:section l:name
  endif
endfunction

" Define completion enhanced :Man.
"
" Open the manual page at the current window when with a bang.
command! -bang -nargs=+ -complete=customlist,s:man_complete M
  \ call s:man(<q-bang>, <q-mods>, '', <f-args>)

if has('patch-7.4.1833')
  set keywordprg=:Man
endif
