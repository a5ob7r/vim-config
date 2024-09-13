" Whether or not the buffer is the same as a new, unnamed and empty buffer.
" This function returns "0" if the buffer id is invalid.
function! s:is_empty_buffer(buffer_id) abort
  if a:buffer_id == bufnr('%')
    return empty(bufname('%'))
      \ && line('$') <= 1
      \ && empty(getbufline(a:buffer_id, 1)[0])
      \ && !getbufvar(a:buffer_id, '&modified')
  elseif exists('?getbufinfo')
    try
      let l:bufinfo = getbufinfo(a:buffer_id)[0]
    catch /^Vim\%((\a\+)\)\=:E684:/
      " If buffer_id is invalid.
      return 0
    endtry

    return empty(l:bufinfo['name'])
      \ && l:bufinfo['lnum'] <= 1
      \ && empty(getbufline(a:buffer_id, 1)[0])
      \ && !l:bufinfo['changed']
  else
    return empty(bufname(a:buffer_id))
      \ && getbufline(a:buffer_id, 1, '$') == ['']
      \ && !getbufvar(a:buffer_id, '&modified')
  endif
endfunction

" Execute ":bdelete" only if the current buffer isn't the last normal buffer.
" Normal buffers are just for editing files and not terminal or unlisted (i.e.
" help) buffers.
function! s:bdelete(bang) abort
  let l:bufid = bufnr('%')
  " Ignore non normal buffers.
  let l:buffers = filter(tabpagebuflist(), "empty(getbufvar(v:val, '&buftype'))")

  " Create a new empty buffer at the current buffer to keep the current
  " tabpage if the current buffer is the last one in the current tabpage.
  if len(l:buffers) < 2
    if s:is_empty_buffer(l:bufid) && tabpagenr('$') > 1
      " No need to do anything if the last buffer on the current tab is just
      " an empty buffer.
      return
    else
      " This does nothing if the current buffer is already an new empty
      " buffer.
      execute printf('enew%s', a:bang)
    endif
  else
    execute printf('bdelete%s %s', a:bang, l:bufid)
  endif
endfunction

function! s:delete_empty_buffers(bang, line1, line2) abort
  let l:buffers = {}

  for l:tn in range(1, tabpagenr('$'))
    for l:bn in tabpagebuflist(l:tn)
      let l:buffers[l:bn] = 1
    endfor
  endfor

  for l:bn in range(a:line1, a:line2)
    if buflisted(l:bn) && s:is_empty_buffer(l:bn) && !get(l:buffers, l:bn, 0)
      execute printf('bdelete%s', a:bang) l:bn
    endif
  endfor
endfunction

command! -bang -bar Bdelete call s:bdelete(<q-bang>)

command! -bang -bar -range=% -addr=loaded_buffers DeleteEmptyBuffers
  \ call s:delete_empty_buffers(<q-bang>, <line1>, <line2>)
