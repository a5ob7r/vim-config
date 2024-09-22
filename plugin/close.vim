vim9script

# ":close" with some exception.
#
# - Do not close the last window on the current tabpage.
# - "0" (by default) of "[count]" means the current window number.
def Close(bang: string, count: string)
  if tabpagewinnr(tabpagenr(), '$') <= 1
    echohl WarningMsg
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
