let g:mapleader=' '

nnoremap j gj
nnoremap k gk
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" Insert newline without entering insert mode.
nnoremap <leader><Enter> o<Esc>
nnoremap <leader><S-Enter> O<Esc>

nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" Don't use Ex mode, ignore Q.
" ref. $VIMRUNTIME/defaults.vim
map Q ''
