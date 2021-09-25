let g:neodark#background='#202020'

function! s:enable_colorscheme()
  if ! minpac#extra#exists('KeitaNakamura/neodark.vim') || utils#is_linux_console()
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

augroup apply_colorscheme
  autocmd!
  autocmd VimEnter * ++nested call s:enable_colorscheme()
augroup END
