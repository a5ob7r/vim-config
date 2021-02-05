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
nnoremap <F2> :source $MYVIMRC<CR>
nnoremap <leader><F2> :edit $MYVIMRC<CR>
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

command! -range SubstJPuncts silent! <line1>,<line2>call SubstituteJapanesePunctuationsInRange()

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

" t-takata/minpac {{{
silent! packadd minpac

if !exists('g:loaded_minpac')
  finish
endif

function! PackInit() abort
  call minpac#init()

  call minpac#add('t-takata/minpac', { 'type': 'opt' })

  call minpac#add('KeitaNakamura/neodark.vim')
  call minpac#add('SirVer/ultisnips')
  call minpac#add('airblade/vim-gitgutter')
  call minpac#add('bronson/vim-trailing-whitespace')
  call minpac#add('editorconfig/editorconfig-vim')
  call minpac#add('honza/vim-snippets')
  call minpac#add('itchyny/lightline.vim')
  call minpac#add('itchyny/vim-gitbranch')
  call minpac#add('kannokanno/previm')
  call minpac#add('liuchengxu/vista.vim')
  call minpac#add('mattn/emmet-vim')
  call minpac#add('mattn/vim-lexiv')
  call minpac#add('mattn/vim-lsp-settings')
  call minpac#add('mechatroner/rainbow_csv')
  call minpac#add('prabirshrestha/async.vim')
  call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
  call minpac#add('prabirshrestha/asyncomplete-ultisnips.vim')
  call minpac#add('prabirshrestha/asyncomplete.vim')
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('rhysd/git-messenger.vim')
  call minpac#add('sheerun/vim-polyglot')
  call minpac#add('thinca/vim-localrc')
  call minpac#add('tpope/vim-commentary')
  call minpac#add('tpope/vim-endwise')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('w0rp/ale')

  call minpac#add('ctrlpvim/ctrlp.vim')
  call minpac#add('mattn/ctrlp-matchfuzzy')
endfunction

command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
command! PackStatus call minpac#status()
" }}}

" KeitaNakamura/neodark.vim {{{
let g:neodark#background='#202020'
colorscheme neodark
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
      \       [ 'gitbranch', 'readonly', 'relativepath', 'modified' ],
      \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
      \       [ 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok' ]
      \     ]
      \   },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
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
      \ },
      \ 'colorscheme': 'neodark'
      \ }
" }}}

" liuchengxu/vista.vim {{{
let g:vista_sidebar_width = 50
nnoremap <leader>v :Vista!!<CR>
" }}}

" prabirshrestha/vim-lsp {{{
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader>r <plug>(lsp-rename)
  nmap <buffer> <leader><Space> <plug>(lsp-hover)
  nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
  nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)

  nmap <buffer> <leader>lf <plug>(lsp-document-format)
  nmap <buffer> <leader>la <plug>(lsp-code-action)

  ALEDisableBuffer
endfunction

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_delay = 200
let g:lsp_highlight_references_enabled = 1
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
let g:polyglot_disabled = ['sensible']
" }}}

" w0rp/ale {{{
highlight ALEErrorSign ctermfg=9 guifg=#C30500
highlight ALEWarningSign ctermfg=11 guifg=#ED6237
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0
let g:ale_linters = {
      \ 'zsh': ['shellcheck']
      \}
let g:ale_python_auto_pipenv = 1
let g:ale_disable_lsp = 1

nmap <silent> <C-p> <Plug>(ale_previous_wrap)
nmap <silent> <C-n> <Plug>(ale_next_wrap)
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
let g:ctrlp_show_hidden = 1

if executable('rg')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = "rg --files --hidden --glob='!.git'"
endif
" }}}

" mattn/ctrlp-matchfuzzy {{{
let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
" }}}

packloadall

" After plugin loaded {{{
" prabirshrestha/asyncomplete-ultisnips.vim {{{
call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
      \ 'name': 'ultisnips',
      \ 'whitelist': ['*'],
      \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
      \ }))
" }}}
" }}}
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
