" p/P on normal mode, but also handles "E353: Nothing in register +" caused by
" the X11 server disconnection. For example, this problem is caused when runs
" Vim on the tools which have attach/detach functionality such as Scree/Tmux,
" dtach and so on and kills the current X11 server and reattachs to the
" instance on a console or a new X11 server.
function! s:put(bang, reg, count) abort
  let l:reg = a:reg

  " TODO: This may be not an accurate detection for the problem. Is there an
  " appropriate way to do it?
  " TODO: The real thing I want to do is catching every register error about
  " X11 connection and restoring it immediately at just once.
  if l:reg == '+' && empty(getreginfo('+'))
    if exists(':xrestore') == 2
      silent xrestore

      " Fallback to the unnamed register if fails to restore a connection.
      if empty(getreginfo('+'))
        let l:reg = '"'
      endif
    else
      let l:reg = '"'
    endif
  endif

  " NOTE: Normalize non number value to 1.
  let l:count = a:count - 0 > 0 ? a:count : 1

  let l:put = empty(a:bang) ? 'p' : 'P'

  execute printf('normal! %s"%s%s', l:count, l:reg, l:put)
endfunction

noremap <Plug>(put) :<C-U>call <SID>put('', v:register, v:count1)<CR>
noremap <Plug>(Put) :<C-U>call <SID>put('!', v:register, v:count1)<CR>
