vim9script

# ":close" but doesn't close the last window on the current tabpage.
def Close(bang: string, count: string)
  if tabpagewinnr(tabpagenr(), '$') <= 1
    echohl ErrorMsg
    echo "[Close] Can't close the last window on the current tabpage."
    echohl None
    return
  endif

  const window_number = count ==# '0' ? '' : count

  execute $':{window_number}close{bang}'
enddef

command! -bang -bar -count -addr=windows Close {
  Close(<q-bang>, <q-count>)
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
