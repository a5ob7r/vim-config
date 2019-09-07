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

if executable("rg")
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  set grepprg=rg\ --vimgrep\ --no-heading
endif

if has("osxdarwin")
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif
