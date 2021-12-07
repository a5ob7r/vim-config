" Enhanced completion for :Man.
"
" :M
" :M l
" :M 1 ls
function! s:man_complete(arg_lead, cmd_line, cursor_pos) abort
  " Words on the command line.
  let l:words = split(a:cmd_line, '[[:space:]]')

  " Trim command modifiers.
  let l:words = utils#drop_while({x -> x =~# '^[^A-Z]'}, l:words)

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

  let l:candidates = systemlist(join(l:cmd + l:args))

  " Fallback to a no option lookup if `-s` option isn't provided.
  " NOTE: This may be slow due to full search.
  if v:shell_error
    let l:args = [printf("'(%s)'", l:section)]

    let l:candidates = systemlist(join(l:cmd + l:args))
  endif

  let l:candidates = map(l:candidates, printf("matchstr(v:val, '%s')", '[[:alnum:]\.:_-]\+'))

  if !empty(a:arg_lead)
    let l:candidates = filter(l:candidates, printf("v:val[:%d] ==# '%s'", strlen(a:arg_lead) - 1, a:arg_lead))
  endif

  return l:candidates
endfunction

" Load :Man command.
source $VIMRUNTIME/ftplugin/man.vim

" Define completion enhanced :Man.
command! -nargs=+ -complete=customlist,s:man_complete M
      \ <mods> Man <args>
