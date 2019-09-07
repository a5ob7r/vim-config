" {{{ Restore last cursor position
" This is from vim help, *restore-cursor* *last-position-jump*
augroup KeepLastPosition
  autocmd BufReadPost *
        \ if line("'\"") >= 1
        \   && line("'\"") <= line("$")
        \   && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif
augroup END
" }}}

" {{{ Save undo tree
if has('persistent_undo')
  set undodir=./.vimundo,~/.cache/vim/undo
  augroup vimrc-undofile
    autocmd!
    autocmd BufReadPre ~/* setlocal undofile
  augroup END
endif
" }}}
