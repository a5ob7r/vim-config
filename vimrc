"
" vimrc
"

" Boilerplate {{{
set encoding=utf-8
scriptencoding utf-8

" NOTE: No need this basically in user vimrc because "compatible" option turns
" into off automatically when vim find user "vimrc" or "gvimrc", but it is
" said that system vimrc on some distributions contains "set compatible".
if &compatible
  set nocompatible
endif

filetype plugin indent on
syntax enable
" }}}

" Functions {{{
" Toggle netrw window
function! s:toggle_newrw() abort
  let l:cwd = getcwd()

  " Prefer the current working directory.
  if get(b:, 'netrw_curdir', '') !=# l:cwd
    execute 'Explore' l:cwd
  elseif exists(':Rexplore') && exists('w:netrw_rexlocal')
    Rexplore
  else
    Explore
  endif
endfunction

" A backward comaptible "mkdir" for patch-8.0.1708, that "mkdir" with "p" flag
" throws no error even if the directory already exists.
function! s:mkdir(name, ...) abort
  let l:name = a:name
  let l:path = get(a:, '1', '')
  let l:prot = get(a:, '2', '0o755')

  if !(l:path =~# 'p' && isdirectory(l:name))
    call mkdir(l:name, l:path, l:prot)
  endif
endfunction

" Open single window terminal on new tabpage.
function! s:open_terminal_on_newtab(count, ...) abort
  let l:dir = get(a:, 1, $HOME)

  execute 'Autocmd TabNew * ++once tcd' l:dir

  " NOTE: -1 is supplied if no range is specified on a command with "-range"
  " attr.
  if a:count > -1
    execute printf('%dtab terminal', a:count)
  else
    tab terminal
  endif
endfunction

" Like 'export' which is shell's builtin command with filter.
function! s:environments(bang, ...) abort
  let l:env = environ()
  let l:keys = sort(keys(l:env))

  let l:regex = a:0 > 0 ? a:1 : ''

  for l:k in l:keys
    if empty(a:bang)
      if l:k !~# l:regex
        continue
      endif
    else
      if l:k !~? l:regex
        continue
      endif
    endif

    let l:v = l:env[l:k]

    if l:v =~# "'"
      if l:v =~# '"'
        let l:v = substitute(l:v, '"', '\\"', 'g')
      endif

      echo printf('%s="%s"', l:k, l:v)
    elseif l:v =~# '\m\(\s\|\r\|\n\|["!#\^\$\&|=?\\\*\[\]\{\}()<>]\)'
      echo printf("%s='%s'", l:k, l:v)
    else
      echo printf('%s=%s', l:k, l:v)
    endif
  endfor
endfunction

function! s:autocmd(group, autocmd) abort
  let l:group = a:group

  let l:once = 0
  let l:nested = 0
  let l:attrs = []

  let l:idx = match(a:autocmd, '^\s*\S\+\s\+\%(\\ \|[^[:space:]]\)\+\s\+\zs')
  " Events and patterns.
  let l:left = slice(a:autocmd, 0, l:idx)
  " Attribute arguments(++once, ++nested) and commands.
  let l:right = slice(a:autocmd, l:idx)

  let l:idx = match(l:right, '^\s*\%(\%(\%(++\)\=nested\|++once\)\s\+\)\+\zs')
  if l:idx >= 0
    let l:attrs = split(slice(l:right, 0, l:idx))
    " Commands only.
    let l:right = slice(l:right, l:idx)
  endif

  let l:once = index(l:attrs, '++once') >= 0
  let l:nested = match(l:attrs, '^\%(++\)\=nested$') >= 0

  if has('patch-8.1.1113')
    let l:nested_arg = l:nested ? '++nested' : ''
    let l:once_arg = l:once ? '++once' : ''

    execute printf('autocmd %s %s %s %s %s', l:group, l:left, l:nested_arg, l:once_arg, l:right)
  else
    let l:nested_arg = l:nested ? 'nested' : ''

    if l:once
      let l:group = printf('vimrc_autocmd_once_%s', rand())

      execute 'augroup' l:group
        autocmd!
        execute 'autocmd' l:left l:nested_arg l:right
        execute 'autocmd' l:left 'autocmd!' l:group l:left
      augroup END
    else
      execute 'autocmd' l:left l:nested_arg l:right
    endif
  endif
endfunction

" p/P on normal mode, but also handles "E353: Nothing in register +" caused by
" the X11 server disconnection. For example, this problem is caused when runs
" Vim on the tools which have attach/detach functionality such as Scree/Tmux,
" dtach and so on and kills the current X11 server and reattachs to the
" instance on a console or a new X11 server.
function! s:put(bang, reg, count) abort
  let l:reg = a:reg

  " TODO: This may be not an accurate detection for the problem. Is there an
  " appropriate way to do it?
  " TODO: The real thing I want to do is catching every register error about
  " X11 connection and restoring it immediately at just once.
  if l:reg == '+' && empty(getreginfo('+'))
    if exists(':xrestore') == 2
      silent xrestore

      " Fallback to the unnamed register if fails to restore a connection.
      if empty(getreginfo('+'))
        let l:reg = '"'
      endif
    else
      let l:reg = '"'
    endif
  endif

  " NOTE: Normalize non number value to 1.
  let l:count = a:count - 0 > 0 ? a:count : 1

  let l:put = empty(a:bang) ? 'p' : 'P'

  execute printf('normal! %s"%s%s', l:count, l:reg, l:put)
endfunction

function! s:capable_truecolor() abort
  let l:terms = [
    \ 'xterm',
    \ 'st-256color',
    \ ]

  return $COLORTERM ==# 'truecolor' || index(l:terms, $TERM) > -1
endfunction

function! s:install_minpac() abort
  " A root directory path of vim packages.
  let l:packhome = split(&packpath, ',')[0] . '/pack'

  let l:minpac_path = l:packhome . '/minpac/opt/minpac'
  let l:minpac_url = 'https://github.com/k-takata/minpac.git'

  if isdirectory(l:minpac_path) || ! executable('git')
    return
  endif

  let l:command = printf('git clone %s %s', l:minpac_url, l:minpac_path)

  if has('terminal')
    execute 'terminal' l:command
  else
    call system(l:command)
  endif
endfunction
" }}}

" Options {{{
set backspace=indent,eol,start
set colorcolumn=81,101,121
set cursorline
set display=lastline

" Maybe SKK dictionaries are encoded by "enc-jp".
" NOTE: "usc-bom" must precede "utf-8" to recognize BOM.
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1

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

if has('patch-8.2.4325')
  set wildoptions+=pum
endif

if has('patch-8.2.4463')
  set wildoptions+=fuzzy
endif

set nojoinspaces
set nowrapscan

" Indent {{{
" This should be on when "smartindent" is on accoding to manual. Why?
set autoindent

" NOTE: This has no effect when "cindent" is on or "indentexpr" is set.
set smartindent

set cindent
" }}}

" Invisible chars {{{
set list
set listchars&

if has('patch-8.1.0759')
  set listchars+=tab:>\ \|,extends:>,precedes:<
else
  set listchars+=tab:>\ ,extends:>,precedes:<
endif
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

if has('termguicolors') && s:capable_truecolor()
  set termguicolors

  " Vim sets these configs below only if the value of `$TERM` is `xterm`.
  " Otherwise we manually need to set them to work true color well.
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if has('osxdarwin')
  set clipboard=unnamed
else
  set clipboard=exclude:cons\|linux

  if has('unnamedplus')
    set clipboard^=unnamedplus
  endif
endif

" Create temporary files(backup, swap, undo) under secure locations to avoid
" CVE-2017-1000382.
"
" https://github.com/archlinux/svntogit-packages/blob/68635a69f0c5525210adca6ff277dc13c590399b/trunk/archlinux.vim#L22
let s:directory = get(environ(), 'XDG_CACHE_HOME', expand('~/.cache'))

let &g:backupdir = s:directory . '/vim/backup//'
let &g:directory = s:directory . '/vim/swap//'
let &g:undodir = s:directory . '/vim/undo//'

silent call s:mkdir(expand(&g:backupdir), 'p', 0700)
silent call s:mkdir(expand(&g:directory), 'p', 0700)
silent call s:mkdir(expand(&g:undodir), 'p', 0700)
" }}}

" Key mappings {{{
let g:mapleader=' '

" Use "Q" as typed key recording starter and terminator instead of "q".
noremap Q q
map q <Nop>

map <F1> <Nop>
map! <F1> <Nop>

nnoremap j gj
nnoremap k gk

" Reset screen.
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>:redraw!<CR><Esc>

noremap Y y$

nnoremap <leader><Enter> o<Esc>

noremap <silent> p :<C-U>call <SID>put('', v:register, v:count1)<CR>
noremap <silent> P :<C-U>call <SID>put('!', v:register, v:count1)<CR>

nnoremap <silent> <leader>n :<C-U>ToggleNetrw<CR>
nnoremap <silent> <F2> :<C-U>ReloadVimrc<CR>
nnoremap <silent> <leader><F2> :<C-U>Vimrc<CR>

nnoremap <silent> <leader>f :<C-U>Rg<CR>
vnoremap <silent> <leader>f :Rgv<CR>

" From $VIMRUNTIME/mswin.vim
" Save with "CTRL-S" on normal mode and insert mode.
"
" I usually save buffers to files every line editing by switching to the
" normal mode and typing ":w". However doing them every editing is a little
" bit bothersome. So I want to use these shortcuts which are often used to
" save files by GUI editros.
nnoremap <silent> <C-s> :<C-U>Update<CR>
if has('patch-8.2.1978')
  inoremap <silent> <C-s> <Cmd>Update<CR>
else
  inoremap <silent> <C-s> <Esc>:Update<CR>gi
endif

nnoremap <silent> <leader>t :<C-U>tabnew<CR>

" Like default configurations of Tmux.
nnoremap <silent> <leader>" :<C-U>terminal<CR>
nnoremap <silent> <leader>% :<C-U>vertical terminal<CR>
nnoremap <silent> <leader>c :<C-U>Terminal<CR>

tnoremap <silent> <C-W>" <C-W>:terminal<CR>
tnoremap <silent> <C-W>% <C-W>:vertical terminal<CR>
tnoremap <silent> <C-W>c <C-W>:Terminal<CR>

nnoremap <silent> <leader>y :YankComments<CR>
vnoremap <silent> <leader>y :YankComments<CR>

inoremap <silent> <C-L> <Plug>(linefeed)
" }}}

" Commands {{{
command! -range -addr=tabs -nargs=? -complete=dir Terminal
      \ call s:open_terminal_on_newtab(<count>, <f-args>)
command! Runtimepath echo substitute(&runtimepath, ',', "\n", 'g')

" ":update" with new empty file creations for the current buffer.
"
" Run ":update" if the file which the current buffer is corresponding exists,
" otherwise run ":write" instead. This is because ":update" doesn't create a
" new empty file if the corresponding buffer is empty and unmodified.
"
" This is an auxiliary command for keyboard shortcuts.
command! -bang -bar -range=% Update
  \ execute printf('<mods> <line1>,<line2>%s<bang>', filewritable(expand('%')) ? 'update' : 'write')

command! ToggleNetrw call s:toggle_newrw()
command! -bang -nargs=* Environments call s:environments(<q-bang>, <q-args>)

" A helper command to open a file in a split window, or the current one (if it
" is invoked with a bang mark).
command! -bang -bar -nargs=1 -complete=file Open execute <q-mods> (empty(<q-bang>) ? 'split' : 'edit') <q-args>

command! -bang -bar Vimrc <mods> Open<bang> $MYVIMRC
command! ReloadVimrc source $MYVIMRC

command! InstallMinpac call s:install_minpac()
" }}}

" Auto commands {{{
" An attribute(++once, ++nested) compatible :autocmd helper.
"
" :Autocmd TabNew * tcd ~
" :Autocmd TabNew * nested tcd ~
" :Autocmd TabNew * ++nested tcd ~
" :Autocmd TabNew * ++once tcd ~
" :Autocmd TabNew * ++once nested tcd ~
" :Autocmd TabNew * ++once ++nested tcd ~
command! -nargs=+ Autocmd call s:autocmd('vimrc', <q-args>)

augroup vimrc
  autocmd!
augroup END

Autocmd QuickFixCmdPost *grep* cwindow

" Make parent directories of the file which the written buffer is corresponing
" if these directories are missing.
Autocmd BufWritePre * silent call s:mkdir(expand('<afile>:p:h'), 'p')

" Hide extras on normal mode of terminal.
Autocmd TerminalOpen * setlocal nolist nonumber colorcolumn=

if has('persistent_undo')
  Autocmd BufReadPre ~/* setlocal undofile
endif

" From vim/runtime/defaults.vim
" Jump cursor to last editting line.
Autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

Autocmd BufReadPost * if &binary | silent %!xxd -g 1
Autocmd BufReadPost * set filetype=xxd | endif
Autocmd BufWritePre * if &binary | %!xxd -r
Autocmd BufWritePre * endif
Autocmd BufWritePost * if &binary | silent %!xxd -g 1
Autocmd BufWritePost * set nomod | endif
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
Autocmd BufEnter * let b:match_ignorecase = 1
" }}}
" }}}

" Plugins {{{
if !maxpac#begin()
  finish
endif

let s:singleton = maxpac#plugconf('thinca/vim-singleton')

function! s:singleton.post() abort
  call singleton#enable()
endfunction

" NOTE: Call this ASAP!
" NOTE: Maybe `+clientserver` is disabled on macOS even if a Vim is compiled
" with `--with-features=huge`.
if has('clientserver')
  " call maxpac#add(s:singleton)
endif

let s:minpac = maxpac#plugconf('k-takata/minpac')

function! s:minpac.post() abort
  command! PackInit call minpac#init()
  command! PackUpdate call minpac#update()
  command! PackInstall PackUpdate
  command! PackClean call minpac#clean()
  command! PackStatus call minpac#status()
endfunction

call maxpac#add(s:minpac)

let s:neodark = maxpac#plugconf('KeitaNakamura/neodark.vim')

function! s:neodark.pre() abort
  let g:neodark#background='#202020'
endfunction

function! s:neodark.post() abort
  function! s:enable_colorscheme(bang)
    let l:bang = empty(a:bang) ? '' : '!'

    " Linux console only works with a very few colors.
    if empty(l:bang) && $TERM ==# 'linux'
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

  command! -bang Neodark call s:enable_colorscheme(<q-bang>)

  Autocmd VimEnter * ++nested Neodark
endfunction

call maxpac#add(s:neodark)

let s:lightline = maxpac#plugconf('itchyny/lightline.vim')

function! s:lightline.pre() abort
  let g:lightline = {
    \ 'active': {
    \   'left': [
    \     [ 'mode', 'paste' ],
    \     [ 'readonly', 'relativepath', 'modified' ],
    \     [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
    \     [ 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok' ]
    \   ]
    \ },
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

  Autocmd ColorScheme * call s:update_lightline()
endfunction

call maxpac#add(s:lightline)

let s:gitgutter = maxpac#plugconf('airblade/vim-gitgutter')

function! s:gitgutter.pre() abort
  let g:gitgutter_sign_added = 'A'
  let g:gitgutter_sign_modified = 'M'
  let g:gitgutter_sign_removed = 'D'
  let g:gitgutter_sign_removed_first_line = 'd'
  let g:gitgutter_sign_modified_removed = 'm'
endfunction

call maxpac#add(s:gitgutter)

let s:gina = maxpac#plugconf('lambdalisue/gina.vim')

function! s:gina.post() abort
  nmap <silent> <leader>gl :<C-U>Gina log --graph --all<CR>
  nmap <silent> <leader>gs :<C-U>Gina status<CR>
  nmap <silent> <leader>gc :<C-U>Gina commit<CR>

  call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'yy', '<Plug>(gina-yank-path)', { 'silent': 1 })
endfunction

call maxpac#add(s:gina)

let s:git_messenger = maxpac#plugconf('rhysd/git-messenger.vim')

function! s:git_messenger.post() abort
  let g:git_messenger_include_diff = 'all'
  let g:git_messenger_always_into_popup = v:true
  let g:git_messenger_max_popup_height = 15
endfunction

call maxpac#add(s:git_messenger)

let s:ctrlp = maxpac#plugconf('ctrlpvim/ctrlp.vim')

function! s:ctrlp.pre() abort
  " NOTE: <Nul> is sent when Ctrl and Space are typed.
  let g:ctrlp_map = '<Nul>'
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_lazy_update = 150
  let g:ctrlp_reuse_window = '.*'
  let g:ctrlp_use_caching = 0

  let g:ctrlp_user_command = {}
  let g:ctrlp_user_command['types'] = {}

  if executable('git')
    let g:ctrlp_user_command['types'][1] = ['.git', 'git -C %s ls-files -co --exclude-standard']
  endif

  if executable('fd')
    let g:ctrlp_user_command['fallback'] = 'fd --type=file --type=symlink --hidden . %s'
  elseif executable('find')
    let g:ctrlp_user_command['fallback'] = 'find %s -type f'
  else
    let g:ctrlp_use_caching = 1
    let g:ctrlp_cmd = 'CtrlPp'
  endif

  function! s:ctrlp_proxy(bang, ...) abort
    let l:bang = empty(a:bang) ? '' : '!'
    let l:dir = a:0 ? a:1 : getcwd()

    let l:home = expand('~')

    " Make vim heavy or freeze to run CtrlP to search many files. For example
    " this is caused when run `CtrlP` on home directory or edit a file on home
    " directory.
    if empty(l:bang) && l:home ==# l:dir
      throw 'Forbidden to run CtrlP on home directory'
    endif

    CtrlP l:dir
  endfunction

  command! -bang -nargs=? -complete=dir CtrlPp call s:ctrlp_proxy(<q-bang>, <f-args>)

  nnoremap <silent> <leader>b :<C-U>CtrlPBuffer<CR>
endfunction

call maxpac#add(s:ctrlp)

let s:ctrlp_matchfuzzy = maxpac#plugconf('mattn/ctrlp-matchfuzzy')

function! s:ctrlp_matchfuzzy.post() abort
  let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
endfunction

call maxpac#add(s:ctrlp_matchfuzzy)

let s:ctrlp_ghq = maxpac#plugconf('mattn/ctrlp-ghq')

function! s:ctrlp_ghq.post() abort
  nnoremap <silent> <leader>gq :CtrlPGhq<CR>
endfunction

call maxpac#add(s:ctrlp_ghq)

let s:ctrlp_man = maxpac#plugconf('a5ob7r/ctrlp-man')

function! s:ctrlp_man.post() abort
  function! s:lookup_manual() abort
    let l:q = input('keyword> ', '', 'shellcmd')

    if empty(l:q)
      return
    endif

    execute 'CtrlPMan' l:q
  endfunction

  command! LookupManual call s:lookup_manual()

  nnoremap <silent> <leader>m :LookupManual<CR>
endfunction

call maxpac#add(s:ctrlp_man)

let s:vim_lsp = maxpac#plugconf('prabirshrestha/vim-lsp')

function! s:vim_lsp.pre() abort
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_float_delay = 200
  let g:lsp_semantic_enabled = 1

  let g:lsp_experimental_workspace_folders = 1

  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gD <plug>(lsp-implementation)
    nmap <buffer> <leader>r <plug>(lsp-rename)
    nmap <buffer> <leader>h <plug>(lsp-hover)
    nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
    nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)

    nmap <buffer> <leader>lf <plug>(lsp-document-format)
    nmap <buffer> <leader>la <plug>(lsp-code-action)
    nmap <buffer> <leader>ll <plug>(lsp-code-lens)
    nmap <buffer> <leader>lr <plug>(lsp-references)

    nnoremap <silent><buffer><expr> <C-j> lsp#scroll(+1)
    nnoremap <silent><buffer><expr> <C-k> lsp#scroll(-1)

    let b:vim_lsp_enabled = 1
  endfunction

  Autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

  Autocmd User lsp_diagnostics_updated call lightline#update()

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
    if !get(b:, 'vim_lsp_enabled', 0)
      return ''
    endif

    let l:counts = lsp#get_buffer_diagnostics_counts()
    let l:not_zero_counts = filter(l:counts, 'v:val != 0')
    let l:ok = len(l:not_zero_counts) == 0
    if l:ok | return 'OK' | endif
    return ''
  endfunction

  function! s:lsp_log_file()
    return get(g:, 'lsp_log_file', '')
  endfunction

  command! CurrentLspLogging echo s:lsp_log_file()
  command! -nargs=* -complete=file EnableLspLogging
        \ let g:lsp_log_file = empty(<q-args>) ? expand('~/vim-lsp.log') : <q-args>
  command! DisableLspLogging let g:lsp_log_file = ''

  function! s:view_lsp_log()
    let l:log = s:lsp_log_file()

    if filereadable(l:log)
      call term_start(
        \ printf('less %s', l:log),
        \ {
        \   'env': { 'LESS': '' },
        \   'term_finish': 'close',
        \ })
    endif
  endfunction

  command! ViewLspLog call s:view_lsp_log()

  function! s:clear_lsp_log()
    let l:log = s:lsp_log_file()

    if filewritable(l:log)
      call writefile([], l:log)
    endif
  endfunction

  command! ClearLspLog call s:clear_lsp_log()
endfunction

call maxpac#add(s:vim_lsp)

let s:vim_lsp_settings = maxpac#plugconf('mattn/vim-lsp-settings')

function! s:vim_lsp_settings.pre() abort
  let g:lsp_settings_enable_suggestions = 0

  let g:lsp_settings = get(g:, 'lsp_settings', {})
  let g:lsp_settings['texlab'] = {
    \ 'workspace_config': {
    \   'latex': {
    \     'build': {
    \       'args': ['%f'],
    \       'onSave': v:true,
    \       'forwardSearchAfter': v:true
    \       },
    \     'forwardSearch': {
    \       'executable': 'zathura',
    \       'args': ['--synctex-forward', '%l:1:%f', '%p']
    \       }
    \     }
    \   }
    \ }
endfunction

call maxpac#add(s:vim_lsp_settings)

let s:vsnip = maxpac#plugconf('hrsh7th/vim-vsnip')

function! s:vsnip.pre() abort
  let g:vsnip_snippet_dir = expand('~/.vim/vsnip')
endfunction

function! s:vsnip.post() abort
  imap <expr> <Tab> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
endfunction

call maxpac#add(s:vsnip)

call maxpac#add('hrsh7th/vim-vsnip-integ')
call maxpac#add('rafamadriz/friendly-snippets')

call maxpac#add('kana/vim-operator-user')

let s:replace = maxpac#plugconf('kana/vim-operator-replace')

function! s:replace.post() abort
  map _ <Plug>(operator-replace)
endfunction

call maxpac#add(s:replace)

call maxpac#add('LumaKernel/coqpit.vim')

let s:shellcheckrc = maxpac#plugconf('a5ob7r/shellcheckrc.vim')

function! s:shellcheckrc.pre() abort
  let g:shellcheck_directive_highlight = 1
endfunction

call maxpac#add(s:shellcheckrc)

call maxpac#add('a5ob7r/tig.vim')
call maxpac#add('aliou/bats.vim')
call maxpac#add('bronson/vim-trailing-whitespace')
call maxpac#add('editorconfig/editorconfig-vim')
call maxpac#add('fladson/vim-kitty')
call maxpac#add('junegunn/vader.vim')
call maxpac#add('kannokanno/previm')
call maxpac#add('machakann/vim-highlightedyank')
call maxpac#add('machakann/vim-swap')

let s:markdown = maxpac#plugconf('preservim/vim-markdown')

function! s:markdown.pre() abort
  let g:vim_markdown_folding_disabled = 1
endfunction

call maxpac#add(s:markdown)

let s:polyglot = maxpac#plugconf('sheerun/vim-polyglot')

function! s:polyglot.pre() abort
  " Disable polyglot's ftdetect to use my ftdetect.
  let g:polyglot_disabled = ['ftdetect', 'sensible', 'markdown']
endfunction

call maxpac#add(s:polyglot)

call maxpac#add('thinca/vim-localrc')
call maxpac#add('thinca/vim-prettyprint')
call maxpac#add('thinca/vim-themis')
call maxpac#add('tpope/vim-commentary')
call maxpac#add('tpope/vim-endwise')
call maxpac#add('tpope/vim-repeat')
call maxpac#add('tpope/vim-surround')

let s:eskk = maxpac#plugconf('tyru/eskk.vim')

function! s:eskk.pre() abort
  let g:eskk#large_dictionary = {
    \ 'path': '/usr/share/skk/SKK-JISYO.L',
    \ 'sorted': 1,
    \ 'encoding': 'euc-jp',
    \ }
endfunction

call maxpac#add(s:eskk)

let s:open_browser = maxpac#plugconf('tyru/open-browser.vim')

function! s:open_browser.post() abort
  nmap <leader>K <Plug>(openbrowser-smart-search)
  nnoremap <leader>k :call SearchUnderCursorEnglishWord()<CR>

  function! SearchEnglishWord(word) abort
    let l:searchUrl = 'https://dictionary.cambridge.org/dictionary/english/'
    let l:url = l:searchUrl . a:word
    call openbrowser#open(l:url)
  endfunction

  function! SearchUnderCursorEnglishWord() abort
    let l:word = expand('<cword>')
    call SearchEnglishWord(l:word)
  endfunction
endfunction

call maxpac#add(s:open_browser)

call maxpac#add('vim-jp/vital.vim')

let s:ale = maxpac#plugconf('w0rp/ale')

function! s:ale.pre() abort
  highlight ALEErrorSign ctermfg=9 guifg=#C30500
  highlight ALEWarningSign ctermfg=11 guifg=#ED6237
  let g:ale_lint_on_insert_leave = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_lint_on_enter = 0
  let g:ale_python_auto_pipenv = 1
  let g:ale_disable_lsp = 1

  nmap <silent> <C-p> <Plug>(ale_previous_wrap)
  nmap <silent> <C-n> <Plug>(ale_next_wrap)

  Autocmd User lsp_buffer_enabled ALEDisableBuffer
endfunction

call maxpac#add(s:ale)

call maxpac#add('yasuhiroki/github-actions-yaml.vim')

let s:fern = maxpac#plugconf('lambdalisue/fern.vim')

function! s:fern.pre() abort
  let g:fern#default_hidden = 1
  let g:fern#default_exclude = '.*\~$'

  command! CurrentFernLogging echo get(g:, 'fern#logfile', v:null)
  command! -nargs=* -complete=file EnableFernLogging
        \ let g:fern#logfile = empty(<q-args>) ? '~/fern.tsv' : <q-args>
  command! DisableFernLogging let g:fern#logfile = v:null
  command! FernLogDebug let g:fern#loglevel = g:fern#DEBUG
  command! FernLogInfo let g:fern#loglevel = g:fern#INFO
  command! FernLogWARN let g:fern#loglevel = g:fern#WARN
  command! FernLogError let g:fern#loglevel = g:fern#Error
endfunction

call maxpac#add(s:fern)

call maxpac#add('lambdalisue/fern-git-status.vim')

call maxpac#add('a5ob7r/fern-renderer-lsflavor.vim')

let s:lsflavor = maxpac#plugconf('a5ob7r/fern-renderer-lsflavor.vim')

function! s:lsflavor.pre() abort
  let g:fern#renderer = 'lsflavor'
endfunction

call maxpac#add(s:lsflavor)

call maxpac#end()
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
