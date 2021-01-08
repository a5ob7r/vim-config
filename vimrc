"
" vimrc
"

source $VIMRUNTIME/defaults.vim

" Encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}

" Options {{{
" Override some options on defaults.vim {{{
set display=lastline
set history=10000
set mouse=
" }}}

set cindent
set colorcolumn=81,101,121
set cursorline
set fileencodings=utf-8,sjis,shift_jis,iso-2022-jp,euc-jp,cp932,ucs-bom
set foldmethod=marker
set hidden
set hlsearch
set laststatus=2
set showmatch
set virtualedit=block
set wildmode=longest:full,full

set nowrapscan

" Invisible chars {{{
set list
set listchars&
set listchars+=tab:>\ \|,extends:>,precedes:<
" }}}

" Tab char {{{
set expandtab
set tabstop=2
set shiftwidth=2
" }}}

" Wrap {{{
set breakindent
set breakindentopt=shift:2,sbr
set showbreak=>>
" }}}

" Case {{{
set ignorecase
set smartcase
" }}}

if has('termguicolors')
  " To use truecolor on not xterm* terminal type
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if has('osxdarwin')
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif

if executable('rg')
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  set grepprg=rg\ --vimgrep\ --no-heading
endif

let g:mapleader=' '
" }}}

" Key mappings {{{
nnoremap j gj
nnoremap k gk
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

nnoremap <leader><Enter> o<Esc>

nnoremap <Left>  :vertical resize -1<CR>
nnoremap <Right> :vertical resize +1<CR>
nnoremap <Up>    :resize +1<CR>
nnoremap <Down>  :resize -1<CR>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <leader>n :call ToggleNetrw()<CR>
nnoremap <leader>k :call SearchUnderCursorEnglishWord()<CR>
nnoremap <leader>r :source $MYVIMRC<CR>
" }}}

" Others {{{
" Toggle netrw window
function! ToggleNetrw() abort
  if &filetype ==# 'netrw'
    Rexplore
  else
    Explore
  endif
endfunction

" Write a buffer to a file whether or not parent directories.
function! DrillWrite() abort
  let l:parentDirPathOfcurrentBuf = expand('%:h')
  call mkdir(l:parentDirPathOfcurrentBuf, 'p')
  write
endfunction

function! SearchEnglishWord(word) abort
  let l:searchUrl = 'https://dictionary.cambridge.org/dictionary/english/'
  let l:url = l:searchUrl . a:word
  call openbrowser#open(l:url)
endfunction

function! SearchUnderCursorEnglishWord() abort
  let l:word = expand('<cword>')
  call SearchEnglishWord(l:word)
endfunction

" Format Japanese text
"
" Before formatting
" 私は，日本人です．
" 好きな食べ物は，餃子です．
" どうぞ，よろしくおねがいします．
"
" After formatting
" 私は、日本人です。好きな食べ物は、餃子です。どうぞ、よろしくおねがいします。
command! -range FormatJapaneseText silent!
      \   '<,'>substitute/．/。/g
      \ | '<,'>substitute/，/、/g
      \ | '<,'>substitute/\n//g
      \ | nohlsearch

augroup QuickFixCmd
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
augroup end

" {{{ Save undo tree
if has('persistent_undo')
  augroup Undofile
    autocmd!
    autocmd BufReadPre ~/* setlocal undofile
  augroup END
endif
" }}}
" }}}

" Plugins {{{
" Disable some standard plugins which are not necessary. {{{
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1
" }}}

" newrw {{{
" WIP: Must match to line not but filename when `g:netrw_liststyle = 1`, on
" the commit hash of vim/vim: a452b808b4da2d272ca4a50865eb8ca89a58f239
let g:netrw_list_hide = '^\..*\~ *'
let g:netrw_sizestyle = 'H'
" }}}

" matchit {{{
packadd! matchit
let b:match_ignorecase = 1
" }}}

" minpac {{{
packadd minpac

if exists('g:loaded_minpac')
  runtime! plugins.vim
endif
" }}}
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
