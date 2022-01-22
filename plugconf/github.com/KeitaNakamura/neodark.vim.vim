let g:neodark#background='#202020'

function! s:enable_colorscheme(bang)
  let l:bang = empty(a:bang) ? '' : '!'

  if empty(l:bang) && utils#is_linux_console()
    return
  endif

  if exists('g:lightline')
    let g:lightline.colorscheme = 'neodark'
  endif

  colorscheme neodark

  " Cyan, but default is orange in a strange way.
  let g:terminal_ansi_colors[6] = '#72c7d1'
  " Light black
  " Adjust autosuggestioned text color for zsh.
  let g:terminal_ansi_colors[8] = '#5f5f5f'
endfunction

command! -bang Neodark call s:enable_colorscheme(<q-bang>)

Autocmd VimEnter * ++nested Neodark
