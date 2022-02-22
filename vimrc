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
syntax on
" }}}

" Functions {{{
function! s:yank_comments(reg) abort range
  let l:reg = a:reg

  let l:lines = getline(a:firstline, a:lastline)
  let l:lines = map(l:lines, 'utils#extract_comment(v:val)')

  call setreg(l:reg, join(l:lines))
endfunction

" Toggle netrw window
function! s:toggle_newrw() abort
  if &filetype ==# 'netrw'
    " NOTE: To ignore warning "warning (netrw) win#n not a former netrw
    " window".
    try
      Rexplore
    endtry
  else
    Explore .
  endif
endfunction

" Run :update, but instead :write if no current buffer's file exists because
" :update doesn't write to a new file, which the corresponding buffer is empty
" and is no modified.
function! s:update() abort
  if filewritable(expand('%'))
    update
  else
    write
  endif
endfunction

" Create parent directories for current buffer's file.
function! s:make_parent() abort
  let l:parent = expand('%:h')

  if ! isdirectory(l:parent)
    call mkdir(l:parent, 'p')
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
function! s:environments(bang, ...)
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

function! s:readonly(bang, mods, ...)
  if !empty(a:0)
    if empty(a:bang)
      let l:open_cmd = 'edit'
    else
      let l:open_cmd = 'split'
    endif

    execute a:mods l:open_cmd a:1
  endif

  setlocal readonly nomodifiable noswapfile
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

if utils#is_direct_color_enablable()
  " To use truecolor on not xterm* terminal type
  set termguicolors
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

" From vim/runtime/mswin.vim
" Save with Ctrl + s on normal mode and insert mode.
"
" I usually save to file per every line editing by doing to go to normal mode
" and run ":w". But doing this by hand per every editing is a little
" borthersome.
nnoremap <silent> <C-s> :<C-U>Update<CR>
inoremap <silent> <C-s> <Esc>:Update<CR>gi

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

" Emulate linefeed without carrige return.
"
" Example:
" | indicates cursor position. It is zero width in fact.
"
" From
" aaa|bbb
"
" To
" aaa
"    |bbb
"
" TODO: Try to do this without global variable.
" TODO: Indent style with tab char.
" TODO: No <Cmd>...<CR> version.
if has('patch-8.2.1978')
  inoremap <C-L> <Cmd>let g:previous_cursor_column = getcurpos()[4]<CR>
        \<Cmd>set paste<CR>
        \<CR>
        \<Cmd>call setline('.', repeat(' ', g:previous_cursor_column - 1) . getline('.'))<CR>
        \<Cmd>call setcursorcharpos('.', g:previous_cursor_column)<CR>
        \<Cmd>unlet g:previous_cursor_column<CR>
        \<Cmd>set nopaste<CR>
endif
" }}}

" Commands {{{
command! -range YankComments <line1>,<line2>call s:yank_comments(v:register)
command! -bang -nargs=? -complete=file Readonly
      \ call s:readonly(<q-bang>, <q-mods>, <q-args>)
command! -range -addr=tabs -nargs=? -complete=dir Terminal
      \ call s:open_terminal_on_newtab(<count>, <f-args>)
command! Runtimepath echo substitute(&runtimepath, ',', "\n", 'g')
command! Update call s:update()
command! ToggleNetrw call s:toggle_newrw()
command! -bang -nargs=* Environments call s:environments(<q-bang>, <q-args>)
command! Vimrc edit $MYVIMRC
command! ReloadVimrc source $MYVIMRC
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

Autocmd BufWritePre * call s:make_parent()

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
while ! minpac#extra#setup()
  if ! exists('g:install_minpac')
    finish
  endif

  call minpac#extra#install()
  unlet g:install_minpac

  Autocmd VimEnter * call minpac#extra#install_and_load_plugins()
endwhile

" NOTE: Call this ASAP!
" NOTE: Maybe `+clientserver` is disabled on macOS even if a Vim is compiled
" with `--with-features=huge`.
if has('clientserver')
  call minpac#extra#add('thinca/vim-singleton')
endif

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

" Snippet
call minpac#extra#add('hrsh7th/vim-vsnip')
call minpac#extra#add('hrsh7th/vim-vsnip-integ')
call minpac#extra#add('rafamadriz/friendly-snippets')

" Operator
call minpac#extra#add('kana/vim-operator-user')
call minpac#extra#add('kana/vim-operator-replace')

" Misc
call minpac#extra#add('a5ob7r/shellcheckrc.vim')
call minpac#extra#add('a5ob7r/tig.vim')
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
