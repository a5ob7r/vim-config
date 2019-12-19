filetype indent plugin on
syntax on

set background=light
set backspace=indent,eol,start
set breakindent
set breakindentopt=shift:2,sbr
set cindent
set cmdheight=2
set colorcolumn=81
set cursorline
set display=lastline
set encoding=utf-8
set expandtab
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
" set number
set scrolloff=4
set shiftwidth=2
set showbreak=>>
set showmatch
set smartcase
set softtabstop=2
set tabstop=2
set termguicolors
set ttyfast
set updatetime=100
set virtualedit+=onemore
set visualbell
set wildmenu
set wildmode=longest:full,full
set wrapscan

runtime macros/matchit.vim
let b:match_ignorecase = 1
let g:netrw_liststyle = 1
let g:netrw_sizestyle = 'H'

if executable("rg")
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  set grepprg=rg\ --vimgrep\ --no-heading
endif

if has("osxdarwin")
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif

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

" {{{ load local config files
if filereadable(expand($HOME . '/.vimrc.local'))
  source $HOME/.vimrc.local
endif
" }}}
