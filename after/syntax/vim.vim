" Also highlight ":Autocmd" like ":autocmd", which is a helper command defined
" in my vimrc.
"
" TODO: This should only be enabled in my vimrc using "autocommand".
syntax keyword vimAutoCmd Autocmd skipwhite nextgroup=vimAutoEventList

" Highlight user defined commands even if in a function body.
syntax cluster vimFuncBodyList add=vimUserCmd remove=vimUserCommand
