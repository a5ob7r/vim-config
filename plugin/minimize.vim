function! s:divmod(a, b) abort
  const l:q = a:a / a:b
  const l:r = a:a % a:b

  return (l:q, l:r)
endfunction

" Minimize the current window and distribute the window's height equally to
" other windows.
"
" FIXME: Resize complicated layouts well.
function! s:xwinminimize() abort
  let l:cur_winid = win_getid()

  const l:heights = getwininfo()
    \ ->filter({ _, v -> v['tabnr'] == tabpagenr() })
    \ ->reduce({ acc, v -> extend(acc, { v['winid']: v['height'] }) }, {})

  let l:stack = [[winlayout(), winheight(0) - &winminheight]]

  " First, minimize the current window.
  resize 0

  " TODO: Atomic window resizing.
  while !empty(l:stack)
    let [l:layout, l:diffheight] = remove(l:stack, 0)

    if l:layout[0] ==# 'col'
      let l:len = len(l:layout[1])
      let [l:height, l:height_remain] = s:divmod(l:diffheight, l:len - 1)

      " If the window height fraction exists, distribute it to each of lower
      " windows in order.
      for l:i in reverse(range(l:len))
        let l:delta = l:height_remain > 0 && l:layout[1][l:i] != ['leaf', l:cur_winid]
        let l:height_remain -= l:delta
        let l:layout[1][l:i] = [l:layout[1][l:i], l:height + l:delta]
      endfor

      let l:stack += l:layout[1]
    elseif l:layout[0] ==# 'row'
      if index(l:layout[1], ['leaf', l:cur_winid]) >= 0
        continue
      endif

      let l:stack += map(l:layout[1], '[v:val, l:diffheight]')
    elseif l:layout[0] ==# 'leaf'
      let l:wid = l:layout[1]

      if l:wid == l:cur_winid
        continue
      endif

      call win_execute(l:wid, printf('resize %s', l:heights[l:wid] + l:diffheight))
    else
      throw 'xwinminimize(): An unknown item.'
    endif
  endwhile
endfunction

function! s:xminimize() abort
  let l:save_lz = &lazyredraw

  " Suppress view flickering caused by window resizing.
  set lazyredraw

  " NOTE: I'm not sure that why calling this in "s:xwinminimize()" does
  " nothing.
  wincmd =
  call s:xwinminimize()

  let &lazyredraw = l:save_lz
endfunction

" Minimize the current window, and make other window's height equally.
nnoremap <Plug>(xminimize) <ScriptCmd>call s:xminimize()<CR>
tnoremap <Plug>(xminimize) <ScriptCmd>call s:xminimize()<CR>

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
