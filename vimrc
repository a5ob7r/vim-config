set encoding=utf-8
scriptencoding utf-8

let g:mapleader=' '

filetype indent plugin on
syntax on

set background=light
set backspace=indent,eol,start
set breakindent
set breakindentopt=shift:2,sbr
set cindent
set colorcolumn=81,101,121
set cursorline
set display=lastline
set fileencodings=utf-8,sjis,shift_jis,iso-2022-jp,euc-jp,cp932,ucs-bom
set hidden
set history=10000
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set list
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮
set modeline
set scrolloff=4
set showbreak=>>
set showmatch
set smartcase
set ttyfast
set updatetime=100
set virtualedit+=onemore
set visualbell
set wildmenu
set wildmode=longest:full,full
set wrapscan

" To use truecolor on not xterm* terminal type
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" {{{ Tab char
set expandtab
set tabstop=2
set shiftwidth=2
" }}}

runtime macros/matchit.vim
let b:match_ignorecase = 1
let g:netrw_liststyle = 1
let g:netrw_sizestyle = 'H'

" Toggle netrw window
function! ToggleNetrw()
  if &filetype == 'netrw'
    Rexplore
  else
    Explore
  endif
endfunction

nnoremap <leader>n :call ToggleNetrw()<CR>

if executable('rg')
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  set grepprg=rg\ --vimgrep\ --no-heading
endif

if has('osxdarwin')
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif

nnoremap j gj
nnoremap k gk
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

nnoremap <leader><Enter> o<Esc>

nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Don't use Ex mode, ignore Q.
" ref. $VIMRUNTIME/defaults.vim
map Q <Nop>


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


" {{{ Restore last cursor position
" This is from vim help, *restore-cursor* *last-position-jump*
augroup KeepLastPosition
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") >= 1
        \   && line("'\"") <= line("$")
        \   && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif
augroup END
" }}}

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
