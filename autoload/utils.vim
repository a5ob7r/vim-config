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
function! utils#extract_comment(line, commentstring = &commentstring)
  let l:commentstring = utils#strip_whitespaces(a:commentstring)
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

" Appropriate clipboard register.
function! utils#clipboard_register()
  if ! has('clipboard')
    return '"'
  endif

  let l:clipboard = printf(',%s,', &clipboard)

  if l:clipboard =~# ',unnamed,'
    return '*'
  elseif l:clipboard =~# ',unnamedplus,'
    return '+'
  else
    return '"'
  endif
endfunction
