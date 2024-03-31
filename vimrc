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
" This is for the internal encoding for Vim itself, not for file encoding
" detection.
set encoding=utf-8
" Following lines are interpreted as if they are encoded by "utf-8".
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

set colorcolumn=81,101,121
set cursorline

" Show characters to fill the screen as much as possible when some characters
" are out of the screen.
set display=lastline

" Maybe SKK dictionaries are encoded by "enc-jp".
" NOTE: "usc-bom" must precede "utf-8" to recognize BOM.
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1

" Prefer "<NL>" as "<EOL>" even if it is on Windows.
set fileformats=unix,dos,mac

" Automatically reload the file which is changed outside of Vim. For example
" this is useful when discarding modifications using VCS such as git.
set autoread

" Allow to hide buffers even if they are still modified.
set hidden

" The number of history of commands (":") and previous search patterns ("/").
"
" 10000 is the maximum value.
set history=10000

set hlsearch
set incsearch

" Render "statusline" for all of windows, to show window statuses not to
" separate windows.
set laststatus=2

" This option has no effect when "statusline" is not empty.
set ruler

" The cursor offset value around both of window edges.
set scrolloff=5

" Show the search count message, such as "[1/24]", when using search commands
" such as "/" and "n". This is enabled on "8.1.1270".
set shortmess-=S

set showcmd
set showmatch
set virtualedit=block

" When type the "wildchar" key that the default value is "<Tab>" in Vim,
" complete the longest match part and start "wildmenu" at the same time. And
" then complete the next item when type the key again.
set wildmode=longest:full,full

" A command mode with an enhanced completion.
set wildmenu

if has('patch-8.2.4325')
  set wildoptions+=pum
endif

if has('patch-8.2.4463')
  set wildoptions+=fuzzy
endif

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

" Strings that start with '>' isn't compatible with the block quotation syntax
" of markdown.
set showbreak=+++\ 

if exists('+breakindent')
  set breakindent
  set breakindentopt=shift:2,sbr
endif

" "smartcase" works only if "ignorecase" is on.
set ignorecase smartcase

set pastetoggle=<F12>

set completeopt=menuone,longest

if has('patch-8.1.1880')
  set completeopt+=popup
endif

" Xterm and st (simple terminal) also support true (or direct) colors.
if exists('+termguicolors') && ($COLORTERM ==# 'truecolor' || index(['xterm', 'st-256color'], $TERM) > -1)
  set termguicolors

  " No longer need these configurations below since "patch-9.0.1111" because
  " Vim set them automatically if compiled with the "+termguicolors" feature.
  if !has('patch-9.0.1111')
    " Vim sets these configurations below only if the value of `$TERM` is
    " `xterm`. Otherwise we manually need to set them to work true color well.
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

    if exists('+t_8u')
      let &t_8u = "\<Esc>[58;2;%lu;%lu;%lum"
    endif
  endif
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

if exists('+smoothscroll')
  " Screen line oriented scrolling.
  set smoothscroll
endif

if exists('+cdhome')
  " Behave ":cd", ":tcd" and ":lcd" like in UNIX even if in MS-Windows.
  set cdhome
endif

" "modeline" is on only if Vim can validate the values.
"
" https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-1248
set nomodeline

if has('patch-8.0.0056')
  set modeline
endif

if has('gui_running')
  " Add a "M" to the "guioptions" before executing ":syntax enable" or
  " ":filetype on" to avoid sourcing the "menu.vim".
  set guioptions=M
endif

" Keep other window sizes when opening/closing new windows.
set noequalalways

" Prefer single space rather than double them for text joining.
set nojoinspaces

" Stop at a TOP or BOTTOM match even if hitting "n" or "N" repeatedly.
set nowrapscan
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

" A shortcut to complete filenames.
inoremap <C-F> <C-X><C-F>

" Quit Visual mode.
vnoremap <C-L> <Esc>

" A newline version of "i_CTRL-G_k" and "i_CTRL-G_j".
inoremap <C-G><CR> <End><CR>
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
function! s:get_visual_selection() abort
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

" Get syntax item information at a position.
"
" https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function! s:syntax_item_attribute(line, column) abort
  let l:item_id = synID(a:line, a:column, 1)
  let l:trans_item_id = synID(a:line, a:column, 0)

  return printf(
    \ 'hi<%s> trans<%s> lo<%s>',
    \ synIDattr(l:item_id, 'name'),
    \ synIDattr(l:trans_item_id, 'name'),
    \ synIDattr(synIDtrans(l:item_id), 'name')
    \ )
endfunction

" Join and normalize filepaths.
function! s:pathjoin(...) abort
  let l:sep = has('win32') ? '\\' : '/'
  return substitute(simplify(join(a:000, l:sep)), printf('^\.%s', l:sep), '', '')
endfunction

function! s:terminal(...) abort
  let l:bang = get(a:000, 0, '')
  let l:mods = get(a:000, 1, '')

  " If the current buffer is for normal exsisting file editing.
  let l:cwd = empty(&buftype) && !empty(expand('%')) ? expand('%:p:h') : getcwd()
  let l:opts = { 'curwin': !empty(l:bang), 'cwd': l:cwd, 'term_finish': 'close' }

  execute l:mods 'call term_start(&shell, l:opts)'
endfunction
" }}}

" Variables {{{
let $VIMHOME = expand('<sfile>:p:h')
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

" Smart linewise upward/downward cursor movements in Vitual mode.
"
" Move the cursor line by line phycically not logically(screen) if Visual mode
" is linewise, otherwise character by character.
vnoremap <silent><expr> j mode() ==# 'V' ? 'j' : 'gj'
vnoremap <silent><expr> k mode() ==# 'V' ? 'k' : 'gk'

" Switch buffers. These are similar to "gt" and "gT" for tabs, but for
" buffers.
nnoremap <silent> gb :bNext<CR>
nnoremap <silent> gB :bprevious<CR>

" Browse quickfix/location lists by "<C-N>" and "<C-P>".
nnoremap <silent> <C-N> :<C-U>execute printf('%dcnext', v:count1)<CR>
nnoremap <silent> <C-P> :<C-U>execute printf('%dcprevious', v:count1)<CR>
nnoremap <silent> g<C-N> :<C-U>execute printf('%dlnext', v:count1)<CR>
nnoremap <silent> g<C-P> :<C-U>execute printf('%dlprevious', v:count1)<CR>
nnoremap <silent> <C-G><C-N> :<C-U>execute printf('%dlnext', v:count1)<CR>
nnoremap <silent> <C-G><C-P> :<C-U>execute printf('%dlprevious', v:count1)<CR>

" Clear the highlightings for pattern searching and run a command to refresh
" something.
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR>:Refresh<CR>

nnoremap <Leader><CR> o<Esc>

map <silent> p <Plug>(put)
map <silent> P <Plug>(Put)

nnoremap <silent> <F10> :<C-U>echo <SID>syntax_item_attribute(line('.'), col('.'))<CR>

nnoremap <silent> <Leader>n :<C-U>ToggleNetrw<CR>
nnoremap <silent> <Leader>N :<C-U>ToggleNetrw!<CR>
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
  nnoremap <silent> <Leader>' :<C-U>call <SID>terminal()<CR>
  nnoremap <silent> <Leader>% :<C-U>vertical terminal<CR>
  nnoremap <silent> <Leader>5 :<C-U>call <SID>terminal('', 'vertical')<CR>
  nnoremap <silent> <Leader>c :<C-U>Terminal<CR>

  tnoremap <silent> <C-W><Leader>" <C-W>:terminal<CR>
  tnoremap <silent> <C-W><Leader>' <C-W>:call <SID>terminal()<CR>
  tnoremap <silent> <C-W><Leader>% <C-W>:vertical terminal<CR>
  tnoremap <silent> <C-W><Leader>5 <C-W>:call <SID>terminal('', 'vertical')<CR>
  tnoremap <silent> <C-W><Leader>c <C-W>:Terminal<CR>
endif

nnoremap <silent> <Leader>y :YankComments<CR>
vnoremap <silent> <Leader>y :YankComments<CR>

if has('terminal')
  " Delete finished terminal buffers by "<CR>", this behavior is similar to
  " Neovim's builtin terminal.
  tnoremap <silent><expr> <CR>
    \ job_status(term_getjob(bufnr())) ==# 'dead'
    \ ? "<C-W>:bdelete<CR>"
    \ : "<CR>"
endif

" This is required for "term_start()" without "{ 'term_finish': 'close' }".
nmap <silent><expr> <CR>
  \ &buftype ==# 'terminal' && job_status(term_getjob(bufnr())) ==# 'dead'
  \ ? ":<C-U>bdelete<CR>"
  \ : "<Plug>(newline)"

" Maximize or minimize the current window.
nnoremap <silent> <C-W>m :<C-U>resize 0<CR>
nnoremap <silent> <C-W>Vm :<C-U>vertical resize 0<CR>
nmap <silent> <C-W>gm <Plug>(xminimize)

nnoremap <silent> <C-W>M :<C-U>resize<CR>
nnoremap <silent> <C-W>VM :<C-U>vertical resize<CR>

if has('terminal')
  tnoremap <silent> <C-W>m <C-W>:resize 0<CR>
  tnoremap <silent> <C-W>Vm <C-W>:vertical resize 0<CR>
  tmap <silent> <C-W>gm <Plug>(xminimize)

  tnoremap <silent> <C-W>M <C-W>:resize<CR>
  tnoremap <silent> <C-W>VM <C-W>:vertical resize<CR>
endif
" }}}

" Commands {{{
command! Runtimepath echo substitute(&runtimepath, ',', "\n", 'g')
command! Packpath echo substitute(&packpath, ',', '\n', 'g')

" Toggle the syntax highlighting.
command! -bang -bar Syntax
  \ if exists('g:syntax_on')
  \ |   syntax off
  \ | elseif <bang>1
  \ |   syntax enable
  \ | else
  \ |   syntax on
  \ | endif

" A modified version of ":DiffOrig", which is from "defaults.vim".
command! -nargs=? -complete=buffer Diff
  \   vertical new
  \ | set buftype=nofile
  \ | execute 'read ++edit' empty(<q-args>) ? '#' : <q-args>
  \ | 0delete _
  \ | diffthis
  \ | wincmd p
  \ | diffthis

" Toggle the "paste" mode.
command! -bar Paste set paste!

" Toggle the "binary" mode locally.
command! -bar Binary setlocal binary!

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
command! -bang -bar -nargs=1 -complete=file Open execute <q-mods> (<bang>1 ? 'split' : 'edit') <q-args>

command! -bang -bar Vimrc <mods> Open<bang> $MYVIMRC
command! ReloadVimrc source $MYVIMRC

" Run commands to refresh something. Use ":OnRefresh" to register a command.
command! Refresh doautocmd <nomodeline> User Refresh

command! Hitest source $VIMRUNTIME/syntax/hitest.vim

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

" Register a command to refresh something.
command! -bar -nargs=+ OnRefresh autocmd refresh User Refresh <args>

augroup refresh
  autocmd!
augroup END

OnRefresh redraw
" }}}

" Standard plugins {{{
" newrw {{{
" WIP: Must match to line not but filename when `g:netrw_liststyle = 1`, on
" the commit hash of vim/vim: a452b808b4da2d272ca4a50865eb8ca89a58f239
let g:netrw_list_hide = '^\..*\~ *'
let g:netrw_sizestyle = 'H'
" }}}

" These two plugins provide plugin management, but they are already obsolete.
let g:loaded_getscriptPlugin = 1
let g:loaded_vimballPlugin = 1
" }}}

" =============================================================================

" Plugins {{{
call maxpac#begin()

" =============================================================================

" thinca/vim-singleton {{{
let s:singleton = maxpac#plugconf('thinca/vim-singleton')

function! s:singleton.post() abort
  call singleton#enable()
endfunction

" NOTE: Call this as soon as possible!
" NOTE: Maybe "+clientserver" is disabled in macOS even if a Vim is compiled
" with "--with-features=huge".
if has('clientserver')
  call maxpac#add(s:singleton)
endif
" }}}

" k-takata/minpac {{{
let s:minpac = maxpac#add('k-takata/minpac')

function! s:minpac.post() abort
  function! s:pack_complete(...) abort
    return join(sort(keys(minpac#getpluglist())), "\n")
  endfunction

  command! -bar -nargs=? PackInstall
    \   if empty(<q-args>)
    \ |   call minpac#update()
    \ | else
    \ |   call minpac#add(<q-args>, { 'type': 'opt' })
    \ |   call minpac#update(maxpac#plugname(<q-args>), { 'do': printf('packadd %s', maxpac#plugname(<q-args>)) })
    \ | endif

  command! -bar -nargs=? -complete=custom,s:pack_complete PackUpdate
    \   if empty(<q-args>)
    \ |   call minpac#update()
    \ | else
    \ |   call minpac#update(maxpac#plugname(<q-args>))
    \ | endif

  command! -bar -nargs=? -complete=custom,s:pack_complete PackClean
    \   if empty(<q-args>)
    \ |   call minpac#clean()
    \ | else
    \ |   call minpac#clean(maxpac#plugname(<q-args>))
    \ | endif

  " This command is from the minpac help file.
  command! -nargs=1 -complete=custom,s:pack_complete PackOpenDir
    \ call term_start(&shell, {
    \   'cwd': minpac#getpluginfo(maxpac#plugname(<q-args>))['dir'],
    \   'term_finish': 'close',
    \ })
endfunction
" }}}

" =============================================================================

" KeitaNakamura/neodark.vim {{{
let s:neodark = maxpac#add('KeitaNakamura/neodark.vim')

function! s:neodark.post() abort
  " Prefer a near black background color.
  let g:neodark#background = '#202020'

  function! s:apply_neodark(bang) abort
    " Neodark requires 256 colors at least. For example Linux console supports
    " only 8 colors.
    if empty(a:bang) && &t_Co < 256
      return
    endif

    colorscheme neodark

    if has('terminal')
      " Cyan, but the default is orange in a strange way.
      let g:terminal_ansi_colors[6] = '#72c7d1'
      " Light black
      " Adjust the autosuggested text color for zsh.
      let g:terminal_ansi_colors[8] = '#5f5f5f'
    endif
  endfunction

  command! -bang -bar Neodark call s:apply_neodark(<q-bang>)

  Autocmd VimEnter * ++nested Neodark
endfunction
" }}}

" itchyny/lightline.vim {{{
let s:lightline = maxpac#add('itchyny/lightline.vim')

function! s:lightline.pre() abort
  let g:lightline = {
    \ 'active': {
    \   'left': [
    \     [ 'mode', 'binary', 'paste' ],
    \     [ 'readonly', 'relativepath', 'modified' ],
    \     [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \     [ 'lsp_checking', 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok', 'lsp_progress' ]
    \   ]
    \ },
    \ 'component': {
    \   'binary': '%{&binary ? "BINARY" : ""}'
    \ },
    \ 'component_visible_condition': {
    \   'binary': '&binary'
    \ },
    \ 'component_expand': {
    \   'linter_checking': 'lightline#ale#checking',
    \   'linter_errors': 'lightline#ale#errors',
    \   'linter_warnings': 'lightline#ale#warnings',
    \   'linter_infos': 'lightline#ale#infos',
    \   'linter_ok': 'lightline#ale#ok',
    \   'lsp_checking': 'lightline#lsp#checking',
    \   'lsp_errors': 'lightline#lsp#error',
    \   'lsp_warnings': 'lightline#lsp#warning',
    \   'lsp_informations': 'lightline#lsp#information',
    \   'lsp_hints': 'lightline#lsp#hint',
    \   'lsp_ok': 'lightline#lsp#ok',
    \   'lsp_progress': 'lightline_lsp_progress#progress'
    \ },
    \ 'component_type': {
    \   'linter_checking': 'left',
    \   'linter_errors': 'error',
    \   'linter_warnings': 'warning',
    \   'linter_infos': 'left',
    \   'linter_ok': 'left',
    \   'lsp_checking': 'left',
    \   'lsp_errors': 'error',
    \   'lsp_warnings': 'warning',
    \   'lsp_informations': 'left',
    \   'lsp_hints': 'left',
    \   'lsp_ok': 'left',
    \   'lsp_progress': 'left'
    \ }
    \ }

  function! s:set_lightline_colorscheme(colorscheme) abort
    let g:lightline = get(g:, 'lightline', {})
    let g:lightline['colorscheme'] = a:colorscheme
  endfunction

  function! s:has_lightline_colorscheme(colorscheme) abort
    return !empty(globpath(&runtimepath, printf('autoload/lightline/colorscheme/%s.vim', a:colorscheme), 1))
  endfunction

  function! s:update_lightline() abort
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
  endfunction

  function! s:change_lightline_colorscheme() abort
    if !get(g:, 'lightline_colorscheme_change_on_the_fly', 1)
      return
    endif

    let l:colorscheme =
      \ !exists('g:lightline_colorscheme_mapping') ? g:colors_name
      \ : type(g:lightline_colorscheme_mapping) == type('') ? call(g:lightline_colorscheme_mapping, [g:colors_name])
      \ : type(g:lightline_colorscheme_mapping) == type(function('tr')) ? g:lightline_colorscheme_mapping(g:colors_name)
      \ : type(g:lightline_colorscheme_mapping) == type({}) ? get(g:lightline_colorscheme_mapping, g:colors_name, g:colors_name)
      \ : g:colors_name

    if s:has_lightline_colorscheme(l:colorscheme)
      call s:set_lightline_colorscheme(l:colorscheme)
    endif
  endfunction

  function! s:lightline_colorschemes(...) abort
    return join(map(globpath(&runtimepath, 'autoload/lightline/colorscheme/*.vim', 1, 1), "fnamemodify(v:val, ':t:r')"), "\n")
  endfunction

  " The original version is from the help file of "lightline".
  command! -bar -nargs=1 -complete=custom,s:lightline_colorschemes LightlineColorscheme
    \   if exists('g:loaded_lightline')
    \ |   call s:set_lightline_colorscheme(<q-args>)
    \ |   call s:update_lightline()
    \ | endif

  " Synchronous lightline's colorscheme with Vim's one on the fly.
  Autocmd ColorScheme *
    \   if exists('g:loaded_lightline')
    \ |   call s:change_lightline_colorscheme()
    \ |   call s:update_lightline()
    \ | endif

  OnRefresh call lightline#update()
endfunction
" }}}

" =============================================================================

" airblade/vim-gitgutter {{{
let s:gitgutter = maxpac#add('airblade/vim-gitgutter')

function! s:gitgutter.pre() abort
  let g:gitgutter_sign_added = 'A'
  let g:gitgutter_sign_modified = 'M'
  let g:gitgutter_sign_removed = 'D'
  let g:gitgutter_sign_removed_first_line = 'd'
  let g:gitgutter_sign_modified_removed = 'm'
endfunction
" }}}

" lambdalisue/gina.vim {{{
let s:gina = maxpac#add('lambdalisue/gina.vim')

function! s:gina.post() abort
  nmap <silent> <Leader>gl :<C-U>Gina log --graph --all<CR>
  nmap <silent> <Leader>gs :<C-U>Gina status<CR>
  nmap <silent> <Leader>gc :<C-U>Gina commit<CR>

  call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('log', 'yy', '<Plug>(gina-yank-rev)', { 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap('status', 'yy', '<Plug>(gina-yank-path)', { 'silent': 1 })
endfunction
" }}}

" rhysd/git-messenger.vim {{{
let s:git_messenger = maxpac#add('rhysd/git-messenger.vim')

function! s:git_messenger.post() abort
  let g:git_messenger_include_diff = 'all'
  let g:git_messenger_always_into_popup = v:true
  let g:git_messenger_max_popup_height = 15
endfunction
" }}}

" =============================================================================

" ctrlpvim/ctrlp.vim {{{
let s:ctrlp = maxpac#add('ctrlpvim/ctrlp.vim')

function! s:ctrlp.pre() abort
  " "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and the
  " "SPACE" one as once if in some terminal emulators.
  let g:ctrlp_map = has('gui_running') || index(['xterm', 'xterm-kitty'], &term) >= 0 ? '<C-Space>' : '<Nul>'

  let g:ctrlp_show_hidden = 1
  let g:ctrlp_lazy_update = 150
  let g:ctrlp_reuse_window = '.*'
  let g:ctrlp_use_caching = 0
  let g:ctrlp_compare_lim = 5000

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
" }}}

" mattn/ctrlp-matchfuzzy {{{
let s:ctrlp_matchfuzzy = maxpac#add('mattn/ctrlp-matchfuzzy')

function! s:ctrlp_matchfuzzy.post() abort
  let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
endfunction
" }}}

" mattn/ctrlp-ghq {{{
let s:ctrlp_ghq = maxpac#add('mattn/ctrlp-ghq')

function! s:ctrlp_ghq.post() abort
  let g:ctrlp_ghq_actions = [
    \ { 'label': 'edit', 'action': 'edit', 'path': 1 },
    \ { 'label': 'tabnew', 'action': 'tabnew', 'path': 1 }
    \ ]

  nnoremap <silent> <Leader>gq :<C-U>CtrlPGhq<CR>
endfunction
" }}}

" a5ob7r/ctrlp-man {{{
let s:ctrlp_man = maxpac#add('a5ob7r/ctrlp-man')

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
" }}}

" =============================================================================

" prabirshrestha/vim-lsp {{{
let s:vim_lsp = maxpac#add('prabirshrestha/vim-lsp')

function! s:vim_lsp.pre() abort
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_float_delay = 200

  let g:lsp_semantic_enabled = 1
  let g:lsp_inlay_hints_enabled = 1
  " FIXME: HLS (haskell-language-server) v1.8+ (and maybe early versions too)
  " throws such a string, "Error | Failed to parse message header:" if the
  " native client is on. And the client logs "waiting for lsp server to
  " initialize". This means we can't use the native client with HLSs
  " unfortunately at this time, although I want to use the client. The client
  " is off by default, but I make it off explicitly for this documentation
  " about why we have to disable it.
  let g:lsp_use_native_client = 0

  let g:lsp_async_completion = 1

  let g:lsp_experimental_workspace_folders = 1

  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    nmap <buffer> gd <Plug>(lsp-definition)
    nmap <buffer> gD <Plug>(lsp-implementation)
    nmap <buffer> <Leader>r <Plug>(lsp-rename)
    nmap <buffer> <Leader>h <Plug>(lsp-hover)

    nmap <buffer> <Leader>lf <Plug>(lsp-document-format)
    nmap <buffer> <Leader>la <Plug>(lsp-code-action)
    nmap <buffer> <Leader>ll <Plug>(lsp-code-lens)
    nmap <buffer> <Leader>lr <Plug>(lsp-references)

    nnoremap <silent><buffer><expr> <C-J> lsp#scroll(+1)
    nnoremap <silent><buffer><expr> <C-K> lsp#scroll(-1)
  endfunction

  Autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()

  function! s:lsp_log_file() abort
    return get(g:, 'lsp_log_file', '')
  endfunction

  command! CurrentLspLogging echo s:lsp_log_file()
  command! -nargs=* -complete=file EnableLspLogging
    \ let g:lsp_log_file = empty(<q-args>) ? expand('$VIMHOME/tmp/vim-lsp.log') : <q-args>
  command! DisableLspLogging let g:lsp_log_file = ''

  function! s:view_lsp_log() abort
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

  function! s:run_with_lsp_log(template) abort
    let l:log = s:lsp_log_file()

    if filereadable(l:log)
      call term_start([&shell, &shellcmdflag, printf(a:template, l:log)], { 'term_finish': 'close' })
    endif
  endfunction

  command! -nargs=+ -complete=shellcmd RunWithLspLog call s:run_with_lsp_log(<q-args>)

  function! s:clear_lsp_log() abort
    let l:log = s:lsp_log_file()

    if filewritable(l:log)
      call writefile([], l:log)
    endif
  endfunction

  command! ClearLspLog call s:clear_lsp_log()
endfunction
" }}}

" mattn/vim-lsp-settings {{{
let s:vim_lsp_settings = maxpac#add('mattn/vim-lsp-settings')

function! s:vim_lsp_settings.pre() abort
  " Use this only as a preset configuration for LSP, not a installer.
  let g:lsp_settings_enable_suggestions = 0

  let g:lsp_settings = get(g:, 'lsp_settings', {})
  " Prefer Vim + latexmk than texlab for now.
  let g:lsp_settings['texlab'] = {
    \ 'disabled': 1,
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
" }}}

call maxpac#add('tsuyoshicho/lightline-lsp')
call maxpac#add('micchy326/lightline-lsp-progress')

" =============================================================================

" hrsh7th/vim-vsnip {{{
let s:vsnip = maxpac#add('hrsh7th/vim-vsnip')

function! s:vsnip.pre() abort
  let g:vsnip_snippet_dir = expand('$VIMHOME/vsnip')
endfunction

function! s:vsnip.post() abort
  imap <expr> <Tab>
    \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
    \ vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
  smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
  smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
endfunction
" }}}

call maxpac#add('hrsh7th/vim-vsnip-integ')
call maxpac#add('rafamadriz/friendly-snippets')

" =============================================================================

call maxpac#add('kana/vim-operator-user')

" kana/vim-operator-replace {{{
let s:replace = maxpac#add('kana/vim-operator-replace')

function! s:replace.post() abort
  map _ <Plug>(operator-replace)
endfunction
" }}}

" =============================================================================

" a5ob7r/shellcheckrc.vim {{{
let s:shellcheckrc = maxpac#add('a5ob7r/shellcheckrc.vim')

function! s:shellcheckrc.pre() abort
  let g:shellcheck_directive_highlight = 1
endfunction
" }}}

" preservim/vim-markdown {{{
let s:markdown = maxpac#add('preservim/vim-markdown')

function! s:markdown.pre() abort
  " No need to insert any indent preceding a new list item after inserting a
  " newline.
  let g:vim_markdown_new_list_item_indent = 0

  let g:vim_markdown_folding_disabled = 1
endfunction
" }}}

" tyru/open-browser.vim {{{
let s:open_browser = maxpac#add('tyru/open-browser.vim')

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
" }}}

" w0rp/ale {{{
let s:ale = maxpac#add('w0rp/ale')

function! s:ale.pre() abort
  " Use ALE only as a linter engine.
  let g:ale_disable_lsp = 1

  let g:ale_python_auto_pipenv = 1
  let g:ale_python_auto_poetry = 1

  Autocmd User lsp_buffer_enabled ALEDisableBuffer
endfunction
" }}}

" kyoh86/vim-ripgrep {{{
let s:ripgrep = maxpac#add('kyoh86/vim-ripgrep')

function! s:ripgrep.post() abort
  function! RipgrepContextObserver(message) abort
    if a:message['type'] !=# 'context'
      return
    endif

    let l:data = a:message['data']

    let l:item = {
      \ 'filename': l:data['path']['text'],
      \ 'lnum': l:data['line_number'],
      \ 'text': l:data['lines']['text'],
      \ }

    call setqflist([l:item], 'a')
  endfunction

  call ripgrep#observe#add_observer(g:ripgrep#event#other, 'RipgrepContextObserver')

  command! -bang -count -nargs=+ -complete=file Rg call s:ripgrep(['-C<count>', <q-args>], { 'case': <bang>1, 'escape': <bang>1 })

  function! s:ripgrep(args, ...) abort
    let l:opts = get(a:000, 0, {})
    let l:o_case = get(l:opts, 'case')
    let l:o_escape = get(l:opts, 'escape')

    let l:args = []

    if l:o_case
      let l:args += [&ignorecase ? &smartcase ? '--smart-case' : '--ignore-case' : '--case-sensitive']
    endif

    if l:o_escape
      " Change the "<q-args>" to the "{command}" argument for "job_start()" literally.
      let l:args += map(copy(a:args), 's:job_argumentalize_escape(v:val)')
    else
      let l:args += a:args
    endif

    call ripgrep#search(join(l:args))
  endfunction

  " Escape backslashes without them escaping a double quote or a space.
  "
  " :Rg \bvim\b -> call job_start('rg \\bvim\\b')
  " :Rg \"\ vim\b -> call job_start('rg \"\ vim\\b')
  "
  function! s:job_argumentalize_escape(s) abort
    let l:tokens = []
    let l:s = a:s

    while 1
      let [l:matched, l:start, l:end] = matchstrpos(l:s, '\%(\%(\\\\\)*\)\@<=\\[" ]')

      if l:start + 1
        let l:tokens += (l:start ? [escape(l:s[0 : l:start - 1], '\')] : []) + [l:matched]
        let l:s = l:s[l:end :]
      else
        let l:tokens += [escape(l:s, '\')]
        return join(l:tokens, '')
      endif
    endwhile
  endfunction

  map <Leader>f <Plug>(operator-ripgrep-g)
  map g<Leader>f <Plug>(operator-ripgrep)

  call operator#user#define('ripgrep', 'Op_ripgrep')
  call operator#user#define('ripgrep-g', 'Op_ripgrep_g')

  function! Op_ripgrep(motion_wiseness) abort
    call s:operator_ripgrep(a:motion_wiseness, { 'boundaries': 0, 'push_history_entry': 1, 'highlight': 1 })
  endfunction

  function! Op_ripgrep_g(motion_wiseness) abort
    call s:operator_ripgrep(a:motion_wiseness, { 'boundaries': 1, 'push_history_entry': 1, 'highlight': 1 })
  endfunction

  " TODO: Consider ideal linewise and blockwise operations.
  function! s:operator_ripgrep(motion_wiseness, ...) abort
    let l:opts = get(a:000, 0, {})
    let l:o_boundaries = get(l:opts, 'boundaries')
    let l:o_push_history_entry = get(l:opts, 'push_history_entry')
    let l:o_highlight = get(l:opts, 'highlight')

    let l:words = ['Rg', '-F']

    if l:o_boundaries
      let l:words += ['-w']
    endif

    let [l:_, l:l_lnum, l:l_col, l:_] = getpos("'[")
    let [l:_, l:r_lnum, l:r_col, l:_] = getpos("']")

    let l:l_col_idx = l:l_col - 1
    let l:r_col_idx = l:r_col - (&selection ==# 'inclusive' ? 1 : 2)

    let l:buflines =
          \ a:motion_wiseness ==# 'block' ? map(getbufline(bufname('%'), l:l_lnum, l:r_lnum), 'v:val[l:l_col_idx : l:r_col_idx]') :
          \ a:motion_wiseness ==# 'line' ? getbufline(bufname('%'), l:l_lnum, l:r_lnum) :
          \ map(getbufline(bufname('%'), l:l_lnum), 'v:val[l:l_col_idx : l:r_col_idx]')

    let l:words += match(l:buflines, '^\s*-') + 1 ? ['--'] : []
    let l:words += match(l:buflines, ' ') + 1 ? [printf('"%s"', join(map(copy(l:buflines), 's:command_line_argumentalize_escape(v:val)'), "\n"))] : [join(map(copy(l:buflines), 's:command_line_argumentalize_escape(v:val)'), "\n")]

    let l:command = join(l:words)

    execute l:command

    if l:o_highlight && a:motion_wiseness ==# 'char'
      let @/ = l:o_boundaries ? printf('\V\<%s\>', escape(l:buflines[0], '\/')) : printf('\V%s', escape(l:buflines[0], '\/'))
    endif

    if l:o_push_history_entry
      call s:smart_ripgrep_command_history_push(l:command)
    endif
  endfunction

  " Escape command line special characters ("cmdline-special"), any
  " double-quotes and any backslashes preceding spaces.
  function! s:command_line_argumentalize_escape(s) abort
    let l:tokens = []
    let l:s = a:s

    while 1
      let [l:matched, l:start, l:end] = matchstrpos(l:s, '\C<\(cword\|cWORD\|cexpr\|cfile\|afile\|abuf\|amatch\|sfile\|stack\|script\|slnum\|sflnum\|client\)>\|\\ ')

      if l:start + 1
        let l:tokens += (l:start ? [escape(l:s[0 : l:start - 1], '"%#')] : []) + [escape(l:matched, '<\')]
        let l:s = l:s[l:end : ]
      else
        let l:tokens += [escape(l:s, '"%#')]
        return join(l:tokens, '')
      endif
    endwhile
  endfunction

  function! s:smart_ripgrep_command_history_push(command) abort
    let l:history_entry = a:command
    let l:latest_history_entry = histget('cmd', -1)

    if l:history_entry !=# l:latest_history_entry
      call histadd('cmd', l:history_entry)
    endif
  endfunction
endfunction
" }}}

" haya14busa/vim-asterisk {{{
let s:asterisk = maxpac#add('haya14busa/vim-asterisk')

function! s:asterisk.post() abort
  " Keep the cursor offset while searching. See "search-offset".
  let g:asterisk#keeppos = 1

  map * <Plug>(asterisk-z*)
  map # <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
  map z* <Plug>(asterisk-*)
  map z# <Plug>(asterisk-#)
  map gz* <Plug>(asterisk-g*)
  map gz# <Plug>(asterisk-g#)
endfunction
" }}}

" monaqa/modesearch.vim {{{
let s:modesearch = maxpac#add('monaqa/modesearch.vim')

function! s:modesearch.post() abort
  nmap <silent> g/ <Plug>(modesearch-slash-rawstr)
  nmap <silent> g? <Plug>(modesearch-question-regexp)
  cmap <silent> <C-x> <Plug>(modesearch-toggle-mode)
endfunction
" }}}

" thinca/vim-localrc {{{
let s:localrc = maxpac#add('thinca/vim-localrc')

function! s:localrc.post() abort
  function! s:open_localrc(bang, mods, dir) abort
    let l:filename = get(g:, 'localrc_filename', '.local.vimrc')
    let l:localrc = s:pathjoin(a:dir, fnameescape(l:filename))

    execute printf('%s Open%s %s', a:mods, a:bang, l:localrc)
  endfunction

  command! -bang -bar VimrcLocal
    \ call s:open_localrc(<q-bang>, <q-mods>, expand('~'))
  command! -bang -bar -nargs=? -complete=dir OpenLocalrc
    \ call s:open_localrc(<q-bang>, <q-mods>, empty(<q-args>) ? expand('%:p:h') : <q-args>)
endfunction
" }}}

" andymass/vim-matchup {{{
let s:matchup = maxpac#add('andymass/vim-matchup')

function! s:matchup.fallback() abort
  " The enhanced "%", to find many extra matchings and jump the cursor to them.
  "
  " NOTE: "matchit" isn't a standard plugin, but it's bundled in Vim by default.
  if has('patch-7.4.1486')
    packadd! matchit
  else
    source $VIMRUNTIME/macros/matchit.vim
  endif
endfunction
" }}}

" Eliot00/git-lens.vim {{{
if has('vim9script')
  let s:gitlens = maxpac#add('Eliot00/git-lens.vim')

  function! s:gitlens.post() abort
    command! -bar ToggleGitLens call ToggleGitLens()
  endfunction
endif
" }}}

" a5ob7r/linefeed.vim {{{
let s:linefeed = maxpac#add('a5ob7r/linefeed.vim')

function! s:linefeed.post() abort
  " TODO: These keymappings override some default them and conflict with other
  " plugin's default one.
  " imap <silent> <C-K> <Plug>(linefeed-goup)
  " imap <silent> <C-G>k <Plug>(linefeed-up)
  " imap <silent> <C-G><C-K> <Plug>(linefeed-up)
  " imap <silent> <C-G><C-K> <Plug>(linefeed-up)
  " imap <silent> <C-J> <Plug>(linefeed-godown)
  " imap <silent> <C-G>j <Plug>(linefeed-down)
  " imap <silent> <C-G><C-J> <Plug>(linefeed-down)
endfunction
" }}}

" vim-utils/vim-man {{{
let s:man = maxpac#add('vim-utils/vim-man')

function! s:man.post() abort
  command! -nargs=* -bar -complete=customlist,man#completion#run M Man <args>

  call s:man.common()
endfunction

function! s:man.fallback() abort
  " NOTE: An recommended way to enable :Man command on vim help page is to
  " source default ftplugin for man by "runtime ftplugin/man.vim" in vimrc.
  " But maybe it sources another file if another fplugin/man.vim file on
  " runtimepath's directories. So specify default ftplugin for man explicitly.
  try
    source $VIMRUNTIME/ftplugin/man.vim
  catch
    echoerr v:exception
    return
  endtry

  command! -nargs=+ -complete=shellcmd M <mods> Man <args>

  call s:man.common()
endfunction

function! s:man.common() abort
  if has('patch-7.4.1833')
    set keywordprg=:Man
  endif
endfunction
" }}}

" =============================================================================

" lambdalisue/fern.vim {{{
let s:fern = maxpac#add('lambdalisue/fern.vim')

function! s:fern.pre() abort
  let g:fern#default_hidden = 1
  let g:fern#default_exclude = '.*\~$'

  " Toggle a fern buffer to keep the cursor position. A tab should only have
  " one fern buffer.
  function! s:toggle_fern() abort
    if &filetype ==# 'fern'
      if exists('t:non_fern_buffer_id')
        execute 'buffer' t:non_fern_buffer_id
      else
        echohl WarningMsg
        echo 'No non fern buffer exists'
        echohl None
      endif
    else
      if exists('t:fern_buffer_id')
        execute 'buffer' t:fern_buffer_id
      else
        Fern .
      endif
    endif
  endfunction

  command! -bar ToggleFern call s:toggle_fern()

  Autocmd Filetype fern let t:fern_buffer_id = bufnr()
  Autocmd BufLeave * if &ft !=# 'fern' | let t:non_fern_buffer_id = bufnr() | endif
  Autocmd DirChanged * unlet! t:fern_buffer_id

  function! s:fern_log_file() abort
    return get(g:, 'fern#logfile', v:null)
  endfunction

  command! CurrentFernLogging echo s:fern_log_file()
  command! -nargs=* -complete=file EnableFernLogging
    \ let g:fern#logfile = empty(<q-args>) ? '$VIMHOME/tmp/fern.tsv' : <q-args>
  command! DisableFernLogging let g:fern#logfile = v:null
  command! FernLogDebug let g:fern#loglevel = g:fern#DEBUG
  command! FernLogInfo let g:fern#loglevel = g:fern#INFO
  command! FernLogWARN let g:fern#loglevel = g:fern#WARN
  command! FernLogError let g:fern#loglevel = g:fern#Error

  function! s:run_with_fern_log(template) abort
    let l:log = s:fern_log_file()

    if filereadable(l:log)
      call term_start([&shell, &shellcmdflag, printf(a:template, l:log)], { 'term_finish': 'close' })
    endif
  endfunction

  command! -nargs=+ -complete=shellcmd RunWithFernLog call s:run_with_fern_log(<q-args>)
endfunction
" }}}

call maxpac#add('lambdalisue/fern-git-status.vim')

" a5ob7r/fern-renderer-lsflavor.vim {{{
let s:lsflavor = maxpac#add('a5ob7r/fern-renderer-lsflavor.vim')

function! s:lsflavor.pre() abort
  let g:fern#renderer = 'lsflavor'
endfunction
" }}}

"==============================================================================

" prabirshrestha/asyncomplete.vim {{{
let s:asyncomplete = maxpac#add('prabirshrestha/asyncomplete.vim')

function! s:asyncomplete.pre() abort
  let g:asyncomplete_enable_for_all = 0

  function! s:toggle_asyncomplete(...) abort
    let l:asyncomplete_enable = get(a:000, 0, get(b:, 'asyncomplete_enable', 0))

    if l:asyncomplete_enable
      call asyncomplete#disable_for_buffer()

      execute printf('augroup toggle_asyncomplete_%s', bufnr('%'))
        autocmd!
      augroup END
    else
      let l:bufname = fnameescape(bufname('%'))

      execute printf('augroup toggle_asyncomplete_%s', bufnr('%'))
        autocmd!
        execute printf('autocmd BufEnter %s set completeopt=menuone,noinsert,noselect', l:bufname)
        execute printf('autocmd BufLeave %s set completeopt=%s', l:bufname, &completeopt)
        execute printf('autocmd BufWipeout %s set completeopt=%s', l:bufname, &completeopt)
      augroup END

      call asyncomplete#enable_for_buffer()
    endif
  endfunction

  command! ToggleAsyncomplete call s:toggle_asyncomplete()
  command! EnableAsyncomplete call s:toggle_asyncomplete(0)
  command! DisableAsyncomplete call s:toggle_asyncomplete(1)
endfunction
" }}}

call maxpac#add('prabirshrestha/asyncomplete-lsp.vim')

" =============================================================================

" Text object.
call maxpac#add('kana/vim-textobj-user')

call maxpac#add('D4KU/vim-textobj-chainmember')
call maxpac#add('Julian/vim-textobj-variable-segment')
call maxpac#add('deris/vim-textobj-enclosedsyntax')
call maxpac#add('kana/vim-textobj-datetime')
call maxpac#add('kana/vim-textobj-entire')
call maxpac#add('kana/vim-textobj-indent')
call maxpac#add('kana/vim-textobj-line')
call maxpac#add('kana/vim-textobj-syntax')
call maxpac#add('mattn/vim-textobj-url')
call maxpac#add('osyo-manga/vim-textobj-blockwise')
call maxpac#add('saaguero/vim-textobj-pastedtext')
call maxpac#add('sgur/vim-textobj-parameter')
call maxpac#add('thinca/vim-textobj-comment')

call maxpac#add('machakann/vim-textobj-delimited')
call maxpac#add('machakann/vim-textobj-functioncall')

" Misc.
call maxpac#add('LumaKernel/coqpit.vim')
call maxpac#add('a5ob7r/chmod.vim')
call maxpac#add('a5ob7r/rspec-daemon.vim')
call maxpac#add('a5ob7r/tig.vim')
call maxpac#add('aliou/bats.vim')
call maxpac#add('azabiong/vim-highlighter')
call maxpac#add('bronson/vim-trailing-whitespace')
call maxpac#add('editorconfig/editorconfig-vim')
call maxpac#add('fladson/vim-kitty')
call maxpac#add('gpanders/vim-oldfiles')
call maxpac#add('junegunn/goyo.vim')
call maxpac#add('junegunn/vader.vim')
call maxpac#add('junegunn/vim-easy-align')
call maxpac#add('kannokanno/previm')
call maxpac#add('keith/rspec.vim')
call maxpac#add('machakann/vim-highlightedyank')
call maxpac#add('machakann/vim-sandwich')
call maxpac#add('machakann/vim-swap')
call maxpac#add('maximbaz/lightline-ale')
call maxpac#add('neovimhaskell/haskell-vim')
call maxpac#add('pocke/rbs.vim')
call maxpac#add('thinca/vim-prettyprint')
call maxpac#add('thinca/vim-themis')
call maxpac#add('tpope/vim-commentary')
call maxpac#add('tpope/vim-endwise')
call maxpac#add('tyru/eskk.vim')
call maxpac#add('vim-jp/vital.vim')
call maxpac#add('yasuhiroki/github-actions-yaml.vim')

" =============================================================================

call maxpac#end()
" }}}

" Filetypes {{{
filetype off
filetype plugin indent off
filetype plugin indent on
" }}}

" Syntax {{{
syntax off
syntax enable
" }}}

endif

" =============================================================================

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
