" Strip comment prefix (and suffix if it exists).
"
" NOTE: Optional argument with default value is introduced on patch-8.1.1310.
function! s:extract_comment(line, ...)
  let l:commentstring = get(a:, 1, &commentstring)
  let l:commentstring = utils#strip_whitespaces(l:commentstring)
  let l:line = utils#strip_whitespaces(a:line)

  " Accept a string which contains one '%s' only and has comment prefix at
  " least.
  "
  " Valid string.
  " - '" %s'
  " - '/*%s*/'
  "
  " Invalid string.
  " - ''
  " - ' %s '
  " - '%s %s'
  if ! (l:commentstring =~# '^\S\+\s*%s' && count(l:commentstring, '%s') == 1)
    return l:line
  endif

  let l:arr = split(l:commentstring, '%s')
  let l:prefix = utils#strip_whitespaces(get(l:arr, 0, ''))
  let l:suffix = utils#strip_whitespaces(get(l:arr, 1, ''))

  " NOTE: Don't use regex to remove comment prefix or suffix because they may
  " contain special characters for regex. If so, maybe cause unexpected
  " behavior.
  let l:prefix_len = len(l:prefix)
  if l:prefix_len > 0 && l:line[:l:prefix_len-1] ==# l:prefix
    let l:line = utils#strip_whitespaces(l:line[l:prefix_len:])
  endif
  let l:suffix_len = len(l:suffix)
  if l:suffix_len > 0 && l:line[-l:suffix_len:] ==# l:suffix
    let l:line = utils#strip_whitespaces(l:line[:-1-l:suffix_len])
  endif

  return l:line
endfunction

function! s:yank_comments(reg) abort range
  let l:reg = a:reg

  let l:lines = getline(a:firstline, a:lastline)
  let l:lines = map(l:lines, 's:extract_comment(v:val)')

  let l:prev = v:null
  let l:s = ''
  for l:line in l:lines
    if empty(l:line)
      let l:s .= "\n"
    elseif empty(l:prev)
      let l:s .= l:line
    else
      let l:s .= ' ' . l:line
    endif

    let l:prev = l:line
  endfor
  call setreg(l:reg, l:s)
endfunction

command! -range YankComments <line1>,<line2>call s:yank_comments(v:register)
