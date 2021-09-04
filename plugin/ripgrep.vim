" This is true command I want.
command! -nargs=? -range Rg call ripgrep#run(<f-args>)

" This does not use any replacement text provided by `-range` attribute but
" needs it to update '< and '> marks to get visual selected text.
command! -range Rgv call ripgrep#visual()
