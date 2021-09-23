"
" vimrc
"

" Encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}

" Functions {{{
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

" Write a buffer to a file whether or not parent directories.
function! s:write_parent() abort
  let l:cdn = expand('%:h')
  call mkdir(l:cdn, 'p')
  write
endfunction

function! SubstituteStringsWith(dict, line) abort
  let l:repl = a:line
  for [l:k, l:v] in items(a:dict)
    let l:repl = substitute(l:repl, l:k, l:v, 'g')
  endfor
  return l:repl
endfunction

function! SubstituteJapanesePunctuations(line) abort
  let l:dict = {
        \ '。':  '．',
        \ '、':  '，'
        \ }
  return SubstituteStringsWith(l:dict, a:line)
endfunction

function! SubstituteJapanesePunctuationsInRange() abort range
  let l:lines = getline(a:firstline, a:lastline)
  let l:repls = map(l:lines, 'SubstituteJapanesePunctuations(v:val)')
  call setline(a:firstline, l:repls)
endfunction

function! s:is_linux_console() abort
  return $TERM ==# 'linux'
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

if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $TERM ==# 'st-256color')
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
nnoremap <leader>k :call SearchUnderCursorEnglishWord()<CR>
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
nnoremap <C-s> :update<CR>
inoremap <C-s> <Esc>:update<CR>gi

" Tmux like window(pane) splitting. In this case assume the prefix key is
" Ctrl-Q.
nnoremap <C-Q>" :terminal<CR>
nnoremap <C-Q>% :vertical terminal<CR>

nnoremap <silent> <leader>t :tabnew<CR>
" }}}

" Commands {{{
command! -range SubstJPuncts silent! <line1>,<line2>call SubstituteJapanesePunctuationsInRange()

command! WriteP call s:write_parent()
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

" NOTE: If set hotkeys to escape key or ctrl+[ on fcitx(5), it catches the key
" sequence without passing through it to applications.
augroup AUTO_INACTIVATE_IME
  autocmd!

  if executable('fcitx-remote')
    autocmd InsertLeave * :call system('pgrep fcitx5 >/dev/null 2>&1 && fcitx-remote -c')
    autocmd CmdlineLeave * :call system('pgrep fcitx5 >/dev/null 2>&1 && fcitx-remote -c')
  endif

  if executable('fcitx5-remote')
    autocmd InsertLeave * :call system('pgrep fcitx5 >/dev/null 2>&1 && fcitx5-remote -c')
    autocmd CmdlineLeave * :call system('pgrep fcitx5 >/dev/null 2>&1 && fcitx5-remote -c')
  endif
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

" KeitaNakamura/neodark.vim {{{
let g:neodark#background='#202020'

function! s:enable_colorscheme()
  if ! minpac#extra#exists('KeitaNakamura/neodark.vim') || s:is_linux_console()
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
" }}}

" SirVer/ultisnips {{{
augroup USE_RSPEC_AS_RUBY
  au!
  autocmd Filetype rspec UltiSnipsAddFiletypes ruby
augroup end
" }}}

" airblade/vim-gitgutter {{{
let g:gitgutter_sign_added = 'A'
let g:gitgutter_sign_modified = 'M'
let g:gitgutter_sign_removed = 'D'
let g:gitgutter_sign_removed_first_line = 'd'
let g:gitgutter_sign_modified_removed = 'm'
" }}}

" itchyny/lightline.vim {{{
let g:lightline = {
      \ 'active': {
      \   'left': [
      \       [ 'mode', 'paste' ],
      \       [ 'readonly', 'relativepath', 'modified' ],
      \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
      \       [ 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok' ]
      \     ]
      \   },
      \ 'component_expand': {
      \   'lsp_errors': 'LspErrorCount',
      \   'lsp_warnings': 'LspWarningCount',
      \   'lsp_informations': 'LspInformationCount',
      \   'lsp_hints': 'LspHintCount',
      \   'lsp_ok': 'LspOk'
      \ },
      \ 'component_type': {
      \   'linter_checking': 'left',
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \   'linter_ok': 'left',
      \   'lsp_errors': 'error',
      \   'lsp_warnings': 'warning',
      \   'lsp_informations': 'left',
      \   'lsp_hints': 'left',
      \   'lsp_ok': 'left'
      \ }
      \ }

function! s:update_lightline()
  if ! exists('g:loaded_lightline')
    return
  endif

  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

augroup update_lightline_colorscheme
  autocmd!
  autocmd ColorScheme * call s:update_lightline()
augroup END
" }}}

" prabirshrestha/vim-lsp {{{
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader>r <plug>(lsp-rename)
  nmap <buffer> <leader>h <plug>(lsp-hover)
  nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
  nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)

  nmap <buffer> <leader>lf <plug>(lsp-document-format)
  nmap <buffer> <leader>la <plug>(lsp-code-action)
  nmap <buffer> <leader>ll <plug>(lsp-code-lens)
  nmap <buffer> <leader>lr <plug>(lsp-references)

  ALEDisableBuffer

  augroup LSP_AUTO_FORMAT
    autocmd!
    autocmd! BufWritePre *.hs call execute('LspDocumentFormatSync')
  augroup END
endfunction

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_delay = 200
let g:lsp_semantic_enabled = 1

augroup LSP_INSTALL
  au!
  au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup end

augroup OnLSP
  au!
  au User lsp_diagnostics_updated call lightline#update()
augroup end

function! LspErrorCount() abort
  let l:errors = lsp#get_buffer_diagnostics_counts().error
  if l:errors == 0 | return '' | endif
  return 'E: ' . l:errors
endfunction

function LspWarningCount() abort
  let l:warnings = lsp#get_buffer_diagnostics_counts().warning
  if l:warnings == 0 | return '' | endif
  return 'W: ' . l:warnings
endfunction

function! LspInformationCount() abort
  let l:informations = lsp#get_buffer_diagnostics_counts().information
  if l:informations == 0 | return '' | endif
  return 'I: ' . l:informations
endfunction

function! LspHintCount() abort
  let l:hints = lsp#get_buffer_diagnostics_counts().hint
  if l:hints == 0 | return '' | endif
  return 'H: ' . l:hints
endfunction

function! LspOk() abort
  let l:counts = lsp#get_buffer_diagnostics_counts()
  let l:not_zero_counts = filter(l:counts, 'v:val != 0')
  let l:ok = len(l:not_zero_counts) == 0
  if l:ok | return 'OK' | endif
  return ''
endfunction
" }}}

" rhysd/git-messenger.vim {{{
let g:git_messenger_include_diff = 'all'
let g:git_messenger_always_into_popup = v:true
let g:git_messenger_max_popup_height = 15
" }}}

" sheerun/vim-polyglot {{{
" Disable polyglot's ftdetect to use my ftdetect.
let g:polyglot_disabled = ['ftdetect', 'sensible']
" }}}

" w0rp/ale {{{
highlight ALEErrorSign ctermfg=9 guifg=#C30500
highlight ALEWarningSign ctermfg=11 guifg=#ED6237
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0
let g:ale_python_auto_pipenv = 1
let g:ale_disable_lsp = 1

nmap <silent> <C-p> <Plug>(ale_previous_wrap)
nmap <silent> <C-n> <Plug>(ale_next_wrap)
" }}}

" lambdalisue/gina.vim {{{
nmap <leader>gl :Gina log --graph --all<CR>
nmap <leader>gs :Gina status<CR>
nmap <leader>gc :Gina commit<CR>

call minpac#extra#add('lambdalisue/gina.vim')

call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
" }}}

" mattn/vim-lsp-settings {{{
let g:lsp_settings_enable_suggestions = 0
let g:lsp_settings = {
      \ 'texlab': {
      \   'workspace_config': {
      \     'latex': {
      \       'build': {
      \         'args': ['%f'],
      \         'onSave': v:true,
      \         'forwardSearchAfter': v:true
      \         },
      \       'forwardSearch': {
      \         'executable': 'zathura',
      \         'args': ['--synctex-forward', '%l:1:%f', '%p']
      \         }
      \       }
      \     }
      \   }
      \ }
" }}}

" ctrlpvim/ctrlp.vim {{{
let g:ctrlp_map = '<leader><Space>'
let g:ctrlp_cmd = 'CtrlPp'
let g:ctrlp_show_hidden = 1

if executable('rg')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = "rg --files --hidden --glob='!.git'"
endif

function! s:ctrlp_proxy() abort
  let l:home = expand('~')
  let l:cwd = getcwd()
  " Dirname of current file name.
  let l:cdn = expand('%:p:h')

  " Make vim heavy or freeze to run CtrlP to search many files. For example
  " this is caused when run `CtrlP` on home directory or edit a file on home
  " directory.
  if l:home ==# l:cwd || l:home ==# l:cdn
    throw 'Forbidden to run CtrlP on home directory'
  endif

  CtrlP
endfunction

command! CtrlPp call s:ctrlp_proxy()

nnoremap <leader>b :CtrlPBuffer<CR>
" }}}

" mattn/ctrlp-matchfuzzy {{{
let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
" }}}

" mattn/ctrlp-ghq {{{
nnoremap <silent> <leader>gq :CtrlPGhq<CR>
" }}}

" tyru/open-browser.vim {{{
nmap <leader>K <Plug>(openbrowser-smart-search)

function! SearchEnglishWord(word) abort
  let l:searchUrl = 'https://dictionary.cambridge.org/dictionary/english/'
  let l:url = l:searchUrl . a:word
  call openbrowser#open(l:url)
endfunction

function! SearchUnderCursorEnglishWord() abort
  let l:word = expand('<cword>')
  call SearchEnglishWord(l:word)
endfunction
" }}}

" tyru/eskk.vim {{{
let g:eskk#large_dictionary = {
      \ 'path': '/usr/share/skk/SKK-JISYO.L',
      \ 'sorted': 1,
      \ 'encoding': 'euc-jp',
      \ }
" }}}

call minpac#extra#add('t-takata/minpac')
call minpac#extra#add('KeitaNakamura/neodark.vim')
call minpac#extra#add('airblade/vim-gitgutter')
call minpac#extra#add('bronson/vim-trailing-whitespace')
call minpac#extra#add('editorconfig/editorconfig-vim')
call minpac#extra#add('itchyny/lightline.vim')
call minpac#extra#add('kannokanno/previm')
call minpac#extra#add('mattn/vim-lsp-settings')
call minpac#extra#add('prabirshrestha/vim-lsp')
call minpac#extra#add('rhysd/git-messenger.vim')
call minpac#extra#add('sheerun/vim-polyglot')
call minpac#extra#add('thinca/vim-localrc')
call minpac#extra#add('tpope/vim-commentary')
call minpac#extra#add('tpope/vim-endwise')
call minpac#extra#add('tpope/vim-surround')
call minpac#extra#add('tyru/eskk.vim')
call minpac#extra#add('tyru/open-browser.vim')
call minpac#extra#add('w0rp/ale')

call minpac#extra#add('ctrlpvim/ctrlp.vim')
call minpac#extra#add('mattn/ctrlp-matchfuzzy')
call minpac#extra#add('mattn/ctrlp-ghq')
call minpac#extra#add('a5ob7r/ctrlp-man')

if has('python3')
  call minpac#extra#add('SirVer/ultisnips')
  call minpac#extra#add('honza/vim-snippets')
endif
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
