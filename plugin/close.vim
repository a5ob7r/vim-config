" ":close" but doesn't close the last window on the current tab.
function! s:close(bang, count) abort
  let l:bang = empty(a:bang) ? '' : '!'
  let l:count = a:count ==# 0 ? '' : a:count

  if tabpagewinnr('', '$') <= 1
    echohl ErrorMsg
    echo "[Close] Can't close the last window on the current tab."
    echohl None
    return
  endif

  execute printf('%sclose%s', l:count, l:bang)
endfunction

command! -bang -bar -count -addr=windows Close call s:close(<q-bang>, <count>)
