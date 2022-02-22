" https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! utils#get_visual_selection()
  let [l:line_start, l:column_start] = getpos("'<")[1:2]
  let [l:line_end, l:column_end] = getpos("'>")[1:2]
  let l:lines = getline(l:line_start, l:line_end)
  if len(l:lines) == 0
    return ''
  endif
  let l:lines[-1] = l:lines[-1][: l:column_end - (&selection ==# 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:column_start - 1:]
  return join(l:lines, "\n")
endfunction

function! utils#is_packadded(name)
  return printf(',%s,', &runtimepath) =~# printf(',/[^,]*/%s,', a:name)
endfunction

function! utils#is_linux_console()
  return $TERM ==# 'linux'
endfunction

function! utils#is_direct_color_enablable()
  return has('termguicolors') && ($COLORTERM ==# 'truecolor' || $TERM ==# 'st-256color')
endfunction

function! utils#strip_whitespaces(line)
  " NOTE: '\S' preceding '\ze' is so important to prevent '.*' from consuming
  " trailing whitespaces. If does not match to this, it means all characters
  " are whitespaces and they should be stripped. In fact, return empty string
  " by nomatching instead of stripping.
  return matchstr(a:line, '^\s*\zs.*\S\ze\s*$')
endfunction

" Strip comment prefix (and suffix if it exists).
" NOTE: Optional argument with default value is introduced on patch-8.1.1310.
function! utils#extract_comment(line, ...)
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

function! utils#drop_while(predicate, list)
  for l:i in range(len(a:list))
    if !a:predicate(a:list[l:i])
      return a:list[l:i:]
    endif
  endfor

  return []
endfunction

" NOTE: This returns an empty string if causes out of index.
function! utils#strcharat(s, i) abort
  return strcharpart(a:s, a:i, 1)
endfunction

" Calculate Levenshtein distance.
function! utils#edit_distance(a, b) abort
  let l:insert_cost = 1
  let l:delete_cost = 1

  let l:len_a = strchars(a:a)
  let l:len_b = strchars(a:b)

  let l:d = [range(l:len_b + 1)]
  for l:i in range(1, l:len_a)
    let l:d += [[l:i] + map(range(l:len_b), 'v:null')]
  endfor

  for l:i in range(1, l:len_a)
    for l:j in range(1, l:len_b)
      let subst_cost = utils#strcharat(a:a , l:i - 1) ==# utils#strcharat(a:b, l:j - 1) ? 0 : 1
      let l:d[l:i][l:j] = min([
            \ d[l:i - 1][l:j] + l:delete_cost,
            \ d[l:i][l:j - 1] + l:insert_cost,
            \ d[l:i - 1][l:j - 1] + subst_cost
            \ ])
    endfor
  endfor

  return l:d[-1][-1]
endfunction
