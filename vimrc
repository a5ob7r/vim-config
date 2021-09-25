"
" vimrc
"

" Encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}

" Functions {{{
function! s:yank_comments() abort range
  let l:lines = getline(a:firstline, a:lastline)
  let l:lines = map(l:lines, 'utils#extract_comment(v:val)')

  call setreg(utils#clipboard_register(), join(l:lines))
endfunction

" Toggle netrw window
function! s:toggle_newrw() abort
  " Capture Ex command output into a variable.
  redir => l:bufs
  silent! buffers %a
  redir END

  if empty(l:bufs)
    edit .
  elseif &filetype ==# 'netrw'
    " NOTE: To ignore warning "warning (netrw) win#n not a former netrw
    " window".
    try
      Rexplore
    endtry
  else
    Explore
  endif
endfunction

" The name is from 'all right' and 'write'. Write a buffer to a file whether
" or not parent directories exist. This means that create parent directories
" if there are no them.
function! s:alwrite() abort
  let l:parent = expand('%:h')

  if empty(glob(l:parent))
    call mkdir(l:parent, 'p')
  endif

  " NOTE: Execute :write if writes to a new file instead of :update because it
  " does not write to a new file, which the corresponding buffer is empty and
  " is no modified.
  if empty(glob(expand('%')))
    write
  else
    update
  endif
endfunction
" }}}

" Options {{{
set backspace=indent,eol,start
set cindent
set colorcolumn=81,101,121
set cursorline
set display=lastline
set fileencodings=utf-8,sjis,shift_jis,iso-2022-jp,euc-jp,cp932,ucs-bom
set hidden
set history=10000
set hlsearch
set incsearch
set laststatus=2
set ruler
set scrolloff=5
set showcmd
set showmatch
set virtualedit=block
set wildmenu
set wildmode=longest:full,full

set nowrapscan

" Invisible chars {{{
set list
set listchars&
set listchars+=tab:>\ \|,extends:>,precedes:<
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

if utils#is_direct_color_enablable()
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
" }}}

" Key mappings {{{
let g:mapleader=' '

map Q <Nop>

nnoremap j gj
nnoremap k gk
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

noremap Y y$

nnoremap <leader><Enter> o<Esc>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <leader>n :ToggleNetrw<CR>
nnoremap <F2> :source $MYVIMRC<CR>
nnoremap <leader><F2> :edit $MYVIMRC<CR>

nnoremap <leader>f :Rg<CR>
vnoremap <leader>f :Rgv<CR>

" From vim/runtime/mswin.vim
" Save with Ctrl + s on normal mode and insert mode.
"
" I usually save to file per every line editing by doing to go to normal mode
" and run ":w". But doing this by hand per every editing is a little
" borthersome.
nnoremap <C-s> :Update<CR>
inoremap <C-s> <Esc>:Update<CR>gi

" Tmux like window(pane) splitting. In this case assume the prefix key is
" Ctrl-Q.
nnoremap <C-Q>" :terminal<CR>
nnoremap <C-Q>% :vertical terminal<CR>

nnoremap <silent> <leader>t :tabnew<CR>

nnoremap <silent> <leader>y :YankComments<CR>
vnoremap <silent> <leader>y :YankComments<CR>
" }}}

" Commands {{{
command! -range YankComments <line1>,<line2>call s:yank_comments()

command! Update call s:alwrite()
command! ToggleNetrw call s:toggle_newrw()

" Tig
command! -nargs=* Tig terminal ++close tig <args>
command! -nargs=* Tiga Tig <args> --all
" }}}

" Auto commands {{{
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

augroup vimStartup
  autocmd!

  " From vim/runtime/defaults.vim
  " Jump cursor to last editting line.
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END

augroup EditBinary
  autocmd!
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set filetype=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r
  autocmd BufWritePre * endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END
" }}}

" Others {{{
filetype plugin indent on
syntax on
" }}}

" Default plugins {{{
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

" rust {{{
let g:rustfmt_autosave = 1
" }}}
" }}}

" Plugins {{{
while ! minpac#extra#setup()
  if ! exists('g:install_minpac')
    finish
  endif

  call minpac#extra#install()
  unlet g:install_minpac

  augroup install_plugins_with_minpac
    autocmd!
    autocmd VimEnter * call minpac#extra#install_and_load_plugins()
  augroup END
endwhile

" UI
call minpac#extra#add('KeitaNakamura/neodark.vim')
call minpac#extra#add('itchyny/lightline.vim')

" Git
call minpac#extra#add('airblade/vim-gitgutter')
call minpac#extra#add('lambdalisue/gina.vim')
call minpac#extra#add('rhysd/git-messenger.vim')

" CtrlP
call minpac#extra#add('ctrlpvim/ctrlp.vim')
call minpac#extra#add('mattn/ctrlp-matchfuzzy')
call minpac#extra#add('mattn/ctrlp-ghq')
call minpac#extra#add('a5ob7r/ctrlp-man')

" LSP
call minpac#extra#add('prabirshrestha/vim-lsp')
call minpac#extra#add('mattn/vim-lsp-settings')

if has('python3')
  " Snippet
  call minpac#extra#add('SirVer/ultisnips')
  call minpac#extra#add('honza/vim-snippets')
endif

" Misc
call minpac#extra#add('bronson/vim-trailing-whitespace')
call minpac#extra#add('editorconfig/editorconfig-vim')
call minpac#extra#add('kannokanno/previm')
call minpac#extra#add('sheerun/vim-polyglot')
call minpac#extra#add('t-takata/minpac')
call minpac#extra#add('thinca/vim-localrc')
call minpac#extra#add('tpope/vim-commentary')
call minpac#extra#add('tpope/vim-endwise')
call minpac#extra#add('tpope/vim-surround')
call minpac#extra#add('tyru/eskk.vim')
call minpac#extra#add('tyru/open-browser.vim')
call minpac#extra#add('w0rp/ale')
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
