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

function! utils#is_linux_console()
  return $TERM ==# 'linux'
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
