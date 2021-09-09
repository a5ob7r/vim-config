if exists('g:loaded_ripgrep')
  finish
endif

let g:loaded_ripgrep = 1

" This is true command I want.
command! -nargs=? -bang Rg call ripgrep#run('<bang>', <f-args>)

" This does not use any replacement text provided by `-range` attribute but
" needs it to update '< and '> marks to get visual selected text.
command! -range Rgv call ripgrep#visual()
