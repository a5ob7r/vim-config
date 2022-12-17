"
" vimrc
"
" - WIP: The minimal requirement version is 7.4.0000.
" - Work well even if a tiny version.
" - Work well even if no (non-default) plugin is installed.
" - Work well with plugins since 8.0.0050.
" - Support Unix and Windows.
" - No support Neovim.
"

" =============================================================================
"
" For the tiny version.
"

" Options {{{
set encoding=utf-8
scriptencoding utf-8

" NOTE: No need this basically in user vimrc because "compatible" option turns
" into off automatically if vim finds user "vimrc" or "gvimrc", but it is said
" that system vimrcs on some distributions contains "set compatible".
if &compatible
  set nocompatible
endif

" Use a Vim as a Vi Improved not a Vi-compatible even if no "+eval" feature
" such as a tiny version.
silent! while 0
  set nocompatible
silent! endwhile

" Allow to delete everything in Insert Mode.
set backspace=indent,eol,start

if has('syntax')
  set colorcolumn=81,101,121
  set cursorline
endif

" Show characters to fill the screen as much as possible when some characters
" are out of the screen.
set display=lastline

" Maybe SKK dictionaries are encoded by "enc-jp".
" NOTE: "usc-bom" must precede "utf-8" to recognize BOM.
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1

" Prefer "<NL>" as "<EOL>" even if it is on Windows.
set fileformats=unix,dos,mac

" Allow to hide buffers even if they are still modified.
set hidden

" The number of history of commands (":") and previous search patterns ("/").
"
" 10000 is the maximum value.
set history=10000

if has('extra_search')
  set hlsearch
  set incsearch
endif

" Render "statusline" for all of windows, to show window statuses not to
" separate windows.
set laststatus=2

" This option has no effect when "statusline" is not empty.
set ruler

" The cursor offset value around both of window edges.
set scrolloff=5

set showcmd
set showmatch
set virtualedit=block

" A command mode with an enhanced completion.
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

" "smartindent" isn't a super option for "autoindent", and the two of options
" work in a complement way for each other. So these options should be on at
" the same time. This is recommended in the help too.
set autoindent smartindent

" List mode, which renders alternative characters instead of invisible
" (non-printable, out of screen or concealed) them.
"
" "extends" is only used when "wrap" is off.
set list
set listchars+=tab:>\ ,extends:>,precedes:<

if has('patch-8.1.0759')
  set listchars+=tab:>\ \|
endif

if has('linebreak')
  " Strings that start with '>' isn't compatible with the block quotation
  " syntax of markdown.
  set showbreak=+++\ 

  if has('patch-7.4.338')
    set breakindent
    set breakindentopt=shift:2,sbr
  endif
endif

" "smartcase" works only if "ignorecase" is on.
set ignorecase smartcase

if has('termguicolors') && ($COLORTERM ==# 'truecolor' || index(['xterm', 'st-256color'], $TERM) > -1)
  set termguicolors

  " Vim sets these configs below only if the value of `$TERM` is `xterm`.
  " Otherwise we manually need to set them to work true color well.
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if has('win32') || has('osxdarwin')
  " Use the "*" register as a default one, for yank, delete, change and put
  " operations instead of the '"' unnamed one. The contents of the "*"
  " register is synchronous with the system clipboard's them.
  set clipboard=unnamed
else
  " No connection to the X server if in a console.
  set clipboard=exclude:cons\|linux

  if has('unnamedplus')
    " This is similar to "unnamed", but use the "+" register instead. The
    " register is used for reading and writing of the CLIPBOARD selection but
    " not the PRIMARY one.
    set clipboard^=unnamedplus
  endif
endif

if has('gui_running')
  " Add a "M" to the "guioptions" before executing ":syntax enable" or
  " ":filetype on" to avoid sourcing the "menu.vim".
  set guioptions=M
endif
" }}}

" Key mappings {{{
" Use "Q" as the typed key recording starter and the terminator instead of
" "q".
noremap Q q
map q <Nop>

" Do not anything even if type "<F1>". I sometimes mistype it instead of
" typing "<ESC>".
map <F1> <Nop>
map! <F1> <Nop>

" Swap keybingings of 'j/k' and 'gj/gk' with each other.
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" By default, "Y" is a synonym of "yy" for Vi-compatibilities.
noremap Y y$

" Change the current window height instantly.
nnoremap + <C-W>+
nnoremap - <C-W>-

" Quit Visual mode.
vnoremap <C-L> <Esc>
" }}}

" =============================================================================
"
" For the normal+ version.
"

" Following lines are evaluated only if "+eval" feature is on. Maybe no
" ":finish" is enabled on some environments, but ":if" and ":endif" is always
" enabled even if "+eval" is not on.
if 1

" Functions {{{
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

function! s:autocmd(group, autocmd) abort
  let l:group = a:group

  let l:once = 0
  let l:nested = 0
  let l:attrs = []

  let l:idx = match(a:autocmd, '^\s*\S\+\s\+\%(\\ \|[^[:space:]]\)\+\s\+\zs')
  " Events and patterns.
  let l:left = a:autocmd[0:l:idx][0:-2]
  " Attribute arguments(++once, ++nested) and commands.
  let l:right = a:autocmd[l:idx :]

  let l:idx = match(l:right, '^\s*\%(\%(\%(++\)\=nested\|++once\)\s\+\)\+\zs')
  if l:idx >= 0
    let l:attrs = split(l:right[0:l:idx][0:-2])
    " Commands only.
    let l:right = l:right[l:idx :]
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

" https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! s:get_visual_selection()
  let [l:line_start, l:column_start] = getpos("'<")[1:2]
  let [l:line_end, l:column_end] = getpos("'>")[1:2]
  let l:lines = getline(l:line_start, l:line_end)
  if len(l:lines) == 0
    return ''
  endif
  let l:lines[-1] = l:lines[-1][: l:column_end - (&selection ==# 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:column_start - 1:]
  return join(l:lines, "\n")
endfunction
" }}}

" Options {{{
" Create temporary files(backup, swap, undo) under secure locations to avoid
" CVE-2017-1000382.
"
" https://github.com/archlinux/svntogit-packages/blob/68635a69f0c5525210adca6ff277dc13c590399b/trunk/archlinux.vim#L22
let s:directory = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : expand('~/.cache')

let &g:backupdir = s:directory . '/vim/backup//'
let &g:directory = s:directory . '/vim/swap//'
let &g:undodir = s:directory . '/vim/undo//'

silent call s:mkdir(expand(&g:backupdir), 'p', 0700)
silent call s:mkdir(expand(&g:directory), 'p', 0700)
silent call s:mkdir(expand(&g:undodir), 'p', 0700)
" }}}

" Key mappings {{{
" "<Leader>" is replaced with the value of "g:mapleader" when define a
" keymapping, so we must define this variable before the mapping definition.
let g:mapleader = ' '

" Clear the highlightings for pattern searching.
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR>

nnoremap <Leader><CR> o<Esc>

noremap <silent> p :<C-U>call <SID>put('', v:register, v:count1)<CR>
noremap <silent> P :<C-U>call <SID>put('!', v:register, v:count1)<CR>

nnoremap <silent> <Leader>n :<C-U>ToggleNetrw<CR>
nnoremap <silent> <F2> :<C-U>ReloadVimrc<CR>
nnoremap <silent> <Leader><F2> :<C-U>Vimrc<CR>

" From $VIMRUNTIME/mswin.vim
" Save with "CTRL-S" on normal mode and insert mode.
"
" I usually save buffers to files every line editing by switching to the
" normal mode and typing ":w". However doing them every editing is a little
" bit bothersome. So I want to use these shortcuts which are often used to
" save files by GUI editros.
nnoremap <silent> <C-S> :<C-U>Update<CR>
if has('patch-8.2.1978')
  inoremap <silent> <C-S> <Cmd>Update<CR>
else
  inoremap <silent> <C-S> <Esc>:Update<CR>gi
endif

nnoremap <silent> <Leader>t :<C-U>tabnew<CR>

if has('terminal')
  " Like default configurations of Tmux.
  nnoremap <silent> <Leader>" :<C-U>terminal<CR>
  nnoremap <silent> <Leader>% :<C-U>vertical terminal<CR>
  nnoremap <silent> <Leader>c :<C-U>Terminal<CR>

  tnoremap <silent> <C-W>" <C-W>:terminal<CR>
  tnoremap <silent> <C-W>% <C-W>:vertical terminal<CR>
  tnoremap <silent> <C-W>c <C-W>:Terminal<CR>
endif

nnoremap <silent> <Leader>y :YankComments<CR>
vnoremap <silent> <Leader>y :YankComments<CR>

nnoremap <silent> <CR> <Plug>(newline)

inoremap <silent> <C-L> <Plug>(linefeed)
" }}}

" Commands {{{
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
  " This throws "E216" if no such a autocmd group, so first of all we need to
  " define it using ":augroup".
  autocmd!
augroup END

Autocmd QuickFixCmdPost *grep* cwindow

" Make parent directories of the file which the written buffer is corresponing
" if these directories are missing.
Autocmd BufWritePre * silent call s:mkdir(expand('<afile>:p:h'), 'p')

if has('terminal')
  " Hide extras on normal mode of terminal.
  Autocmd TerminalOpen * setlocal nolist nonumber colorcolumn=
endif

if has('persistent_undo')
  Autocmd BufReadPre ~/* setlocal undofile
endif

" From vim/runtime/defaults.vim
" Jump cursor to last editting line.
Autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" Read/Write the binary format, but are these configurations really
" comfortable? Maybe we should use a binary editor insated.
Autocmd BufReadPost *
  \ if &binary
  \ |   execute 'silent %!xxd -g 1'
  \ |   set filetype=xxd
  \ | endif
Autocmd BufWritePre *
  \ if &binary
  \ |   let b:cursorpos = getcurpos()
  \ |   execute '%!xxd -r'
  \ | endif
Autocmd BufWritePost *
  \ if &binary
  \ |   execute 'silent %!xxd -g 1'
  \ |   set nomodified
  \ |   call cursor(b:cursorpos[1], b:cursorpos[2], b:cursorpos[3])
  \ |   unlet b:cursorpos
  \ | endif
" }}}

" Filetypes {{{
filetype plugin indent on
" }}}

" Syntax {{{
syntax enable
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

" The enhanced "%", to find many extra matchings and jump the cursor to them.
if has('patch-7.4.1486')
  packadd! matchit
else
  source $VIMRUNTIME/macros/matchit.vim
endif
" }}}

" =============================================================================

" At least "maxpac" (and "minpac") requires Vim 8.0.0050+.
if !has('patch-8.0.0050')
  finish
endif

" Plugins {{{
call maxpac#begin()

" =============================================================================

" thinca/vim-singleton {{{
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
" }}}

" k-takata/minpac {{{
let s:minpac = maxpac#plugconf('k-takata/minpac')

function! s:minpac.post() abort
  command! PackInit call minpac#init()
  command! PackUpdate call minpac#update()
  command! PackInstall PackUpdate
  command! PackClean call minpac#clean()
  command! PackStatus call minpac#status()
endfunction

call maxpac#add(s:minpac)
" }}}

" =============================================================================

" KeitaNakamura/neodark.vim {{{
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
" }}}

" itchyny/lightline.vim {{{
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
" }}}

" =============================================================================

" airblade/vim-gitgutter {{{
let s:gitgutter = maxpac#plugconf('airblade/vim-gitgutter')

function! s:gitgutter.pre() abort
  let g:gitgutter_sign_added = 'A'
  let g:gitgutter_sign_modified = 'M'
  let g:gitgutter_sign_removed = 'D'
  let g:gitgutter_sign_removed_first_line = 'd'
  let g:gitgutter_sign_modified_removed = 'm'
endfunction

call maxpac#add(s:gitgutter)
" }}}

" lambdalisue/gina.vim {{{
let s:gina = maxpac#plugconf('lambdalisue/gina.vim')

function! s:gina.post() abort
  nmap <silent> <Leader>gl :<C-U>Gina log --graph --all<CR>
  nmap <silent> <Leader>gs :<C-U>Gina status<CR>
  nmap <silent> <Leader>gc :<C-U>Gina commit<CR>

  call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'yy', '<Plug>(gina-yank-path)', { 'silent': 1 })
endfunction

call maxpac#add(s:gina)
" }}}

" rhysd/git-messenger.vim {{{
let s:git_messenger = maxpac#plugconf('rhysd/git-messenger.vim')

function! s:git_messenger.post() abort
  let g:git_messenger_include_diff = 'all'
  let g:git_messenger_always_into_popup = v:true
  let g:git_messenger_max_popup_height = 15
endfunction

call maxpac#add(s:git_messenger)
" }}}

" =============================================================================

" ctrlpvim/ctrlp.vim {{{
let s:ctrlp = maxpac#plugconf('ctrlpvim/ctrlp.vim')

function! s:ctrlp.pre() abort
  " "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and the
  " "SPACE" one as once if in a terminal emulator or a console.
  let g:ctrlp_map = has('gui_running') ? '<C-Space>' : '<Nul>'

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

  nnoremap <silent> <Leader>b :<C-U>CtrlPBuffer<CR>
endfunction

call maxpac#add(s:ctrlp)
" }}}

" mattn/ctrlp-matchfuzzy {{{
let s:ctrlp_matchfuzzy = maxpac#plugconf('mattn/ctrlp-matchfuzzy')

function! s:ctrlp_matchfuzzy.post() abort
  let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
endfunction

call maxpac#add(s:ctrlp_matchfuzzy)
" }}}

" mattn/ctrlp-ghq {{{
let s:ctrlp_ghq = maxpac#plugconf('mattn/ctrlp-ghq')

function! s:ctrlp_ghq.post() abort
  nnoremap <silent> <Leader>gq :CtrlPGhq<CR>
endfunction

call maxpac#add(s:ctrlp_ghq)
" }}}

" a5ob7r/ctrlp-man {{{
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

  nnoremap <silent> <Leader>m :LookupManual<CR>
endfunction

call maxpac#add(s:ctrlp_man)
" }}}

" =============================================================================

" prabirshrestha/vim-lsp {{{
let s:vim_lsp = maxpac#plugconf('prabirshrestha/vim-lsp')

function! s:vim_lsp.pre() abort
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_float_delay = 200
  let g:lsp_semantic_enabled = 1

  let g:lsp_experimental_workspace_folders = 1

  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    nmap <buffer> gd <Plug>(lsp-definition)
    nmap <buffer> gD <Plug>(lsp-implementation)
    nmap <buffer> <Leader>r <Plug>(lsp-rename)
    nmap <buffer> <Leader>h <Plug>(lsp-hover)
    nmap <buffer> <C-P> <Plug>(lsp-previous-diagnostic)
    nmap <buffer> <C-N> <Plug>(lsp-next-diagnostic)

    nmap <buffer> <Leader>lf <Plug>(lsp-document-format)
    nmap <buffer> <Leader>la <Plug>(lsp-code-action)
    nmap <buffer> <Leader>ll <Plug>(lsp-code-lens)
    nmap <buffer> <Leader>lr <Plug>(lsp-references)

    nnoremap <silent><buffer><expr> <C-J> lsp#scroll(+1)
    nnoremap <silent><buffer><expr> <C-K> lsp#scroll(-1)

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
" }}}

" mattn/vim-lsp-settings {{{
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
" }}}

" =============================================================================

" hrsh7th/vim-vsnip {{{
let s:vsnip = maxpac#plugconf('hrsh7th/vim-vsnip')

function! s:vsnip.pre() abort
  let g:vsnip_snippet_dir = expand('~/.vim/vsnip')
endfunction

function! s:vsnip.post() abort
  imap <expr> <Tab> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
endfunction

call maxpac#add(s:vsnip)
" }}}

call maxpac#add('hrsh7th/vim-vsnip-integ')
call maxpac#add('rafamadriz/friendly-snippets')

" =============================================================================

call maxpac#add('kana/vim-operator-user')

" kana/vim-operator-replace {{{
let s:replace = maxpac#plugconf('kana/vim-operator-replace')

function! s:replace.post() abort
  map _ <Plug>(operator-replace)
endfunction

call maxpac#add(s:replace)
" }}}

" =============================================================================

" a5ob7r/shellcheckrc.vim {{{
let s:shellcheckrc = maxpac#plugconf('a5ob7r/shellcheckrc.vim')

function! s:shellcheckrc.pre() abort
  let g:shellcheck_directive_highlight = 1
endfunction

call maxpac#add(s:shellcheckrc)
" }}}

" preservim/vim-markdown {{{
let s:markdown = maxpac#plugconf('preservim/vim-markdown')

function! s:markdown.pre() abort
  " No need to insert any indent preceding a new list item after inserting a
  " newline.
  let g:vim_markdown_new_list_item_indent = 0

  let g:vim_markdown_folding_disabled = 1
endfunction

call maxpac#add(s:markdown)
" }}}

" sheerun/vim-polyglot {{{
let s:polyglot = maxpac#plugconf('sheerun/vim-polyglot')

function! s:polyglot.pre() abort
  " Disable polyglot's ftdetect to use my ftdetect.
  let g:polyglot_disabled = ['ftdetect', 'sensible', 'markdown']
endfunction

call maxpac#add(s:polyglot)
" }}}

" tyru/eskk.vim {{{
let s:eskk = maxpac#plugconf('tyru/eskk.vim')

function! s:eskk.pre() abort
  let g:eskk#large_dictionary = {
    \ 'path': '/usr/share/skk/SKK-JISYO.L',
    \ 'sorted': 1,
    \ 'encoding': 'euc-jp',
    \ }
endfunction

call maxpac#add(s:eskk)
" }}}

" tyru/open-browser.vim {{{
let s:open_browser = maxpac#plugconf('tyru/open-browser.vim')

function! s:open_browser.post() abort
  nmap <Leader>K <Plug>(openbrowser-smart-search)
  nnoremap <Leader>k :call SearchUnderCursorEnglishWord()<CR>

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
" }}}

" w0rp/ale {{{
let s:ale = maxpac#plugconf('w0rp/ale')

function! s:ale.pre() abort
  highlight ALEErrorSign ctermfg=9 guifg=#C30500
  highlight ALEWarningSign ctermfg=11 guifg=#ED6237
  let g:ale_lint_on_insert_leave = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_lint_on_enter = 0
  let g:ale_python_auto_pipenv = 1
  let g:ale_disable_lsp = 1

  nmap <silent> <C-P> <Plug>(ale_previous_wrap)
  nmap <silent> <C-N> <Plug>(ale_next_wrap)

  Autocmd User lsp_buffer_enabled ALEDisableBuffer
endfunction

call maxpac#add(s:ale)
" }}}

" kyoh86/vim-ripgrep {{{
let s:ripgrep = maxpac#plugconf('kyoh86/vim-ripgrep')

function! s:ripgrep.post() abort
  command! -nargs=+ -complete=file Rg call ripgrep#search(<q-args>)

  " This does not use any replacement text provided by "-range" attribute, but
  " we need it to update "'<" and "'>" marks to get a visual selected text.
  command! -range Rgv call ripgrep#search(s:get_visual_selection()->escape('"')->printf('"%s"'))

  nnoremap <silent> <Leader>f :<C-U>call ripgrep#search(expand('<cword>')->escape('"')->printf('"%s"'))<CR>
  vnoremap <silent> <Leader>f :Rgv<CR>
endfunction

call maxpac#add(s:ripgrep)
" }}}

" =============================================================================

" lambdalisue/fern.vim {{{
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
" }}}

call maxpac#add('lambdalisue/fern-git-status.vim')

" a5ob7r/fern-renderer-lsflavor.vim {{{
let s:lsflavor = maxpac#plugconf('a5ob7r/fern-renderer-lsflavor.vim')

function! s:lsflavor.pre() abort
  let g:fern#renderer = 'lsflavor'
endfunction

call maxpac#add(s:lsflavor)
" }}}

" =============================================================================

call maxpac#add('LumaKernel/coqpit.vim')
call maxpac#add('a5ob7r/tig.vim')
call maxpac#add('aliou/bats.vim')
call maxpac#add('andymass/vim-matchup')
call maxpac#add('bronson/vim-trailing-whitespace')
call maxpac#add('editorconfig/editorconfig-vim')
call maxpac#add('fladson/vim-kitty')
call maxpac#add('junegunn/vader.vim')
call maxpac#add('kannokanno/previm')
call maxpac#add('machakann/vim-highlightedyank')
call maxpac#add('machakann/vim-swap')
call maxpac#add('thinca/vim-localrc')
call maxpac#add('thinca/vim-prettyprint')
call maxpac#add('thinca/vim-themis')
call maxpac#add('tpope/vim-commentary')
call maxpac#add('tpope/vim-endwise')
call maxpac#add('tpope/vim-repeat')
call maxpac#add('tpope/vim-surround')
call maxpac#add('vim-jp/vital.vim')
call maxpac#add('yasuhiroki/github-actions-yaml.vim')

" =============================================================================

call maxpac#end()
" }}}

endif

" =============================================================================

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
