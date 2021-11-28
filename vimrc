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

  if has('patch-8.1.1113')
    execute 'autocmd TabNew * ++once tcd' l:dir
  else
    augroup open_terminal_on_newtab
      autocmd!
      execute 'autocmd TabNew * tcd' l:dir
      autocmd autocmd! open_terminal_on_newtab TabNew *
    augroup END
  endif

  " NOTE: -1 is supplied if no range is specified on a command with "-range"
  " attr.
  if a:count > -1
    execute printf('%dtab terminal', a:count)
  else
    tab terminal
  endif
endfunction

function! s:tig_complete(arg_lead, cmd_line, cursor_pos)
  let l:subcommands = [
        \ 'log',
        \ 'show',
        \ 'reflog',
        \ 'blame',
        \ 'grep',
        \ 'refs',
        \ 'stash',
        \ 'status',
        \ '<'
        \ ]

  let l:options = [
        \ '--',
        \ '--abbrev',
        \ '--abbrev-commit',
        \ '--after', '--since',
        \ '--all',
        \ '--all-match',
        \ '--ancestry-path',
        \ '--anchored',
        \ '--author',
        \ '--author-date-order',
        \ '--before', '--until',
        \ '--binary',
        \ '--bisect',
        \ '--boundary',
        \ '--branches',
        \ '--break-rewrites', '-B',
        \ '--cc', '-c',
        \ '--check',
        \ '--cherry',
        \ '--cherry-mark',
        \ '--cherry-pick',
        \ '--children',
        \ '--color',
        \ '--color-moved',
        \ '--color-moved-ws',
        \ '--color-words',
        \ '--committer',
        \ '--compact-summary',
        \ '--count',
        \ '--cumulative',
        \ '--date',
        \ '--date-order',
        \ '--decorate',
        \ '--decorate-refs',
        \ '--decorate-refs-exclude',
        \ '--default',
        \ '--dense',
        \ '--diff-algorithm',
        \ '--diff-filter',
        \ '--dirstat',
        \ '--dirstat-by-file',
        \ '--do-walk',
        \ '--dst-prefix',
        \ '--early-output', '--output',
        \ '--encoding',
        \ '--exclude',
        \ '--exit-code',
        \ '--ext-diff',
        \ '--extended-regexp', '-E',
        \ '--find-copies', '-C',
        \ '--find-copies-harder',
        \ '--find-object',
        \ '--find-renames', '-M',
        \ '--first-parent',
        \ '--fixed-strings', '-F',
        \ '--follow',
        \ '--format', '--pretty',
        \ '--full-diff',
        \ '--full-history',
        \ '--full-index',
        \ '-G',
        \ '--glob',
        \ '--graph',
        \ '--grep',
        \ '--grep-reflog',
        \ '-h',
        \ '--histogram',
        \ '--ignore-all-space', '-w',
        \ '--ignore-blank-lines',
        \ '--ignore-cr-at-eol',
        \ '--ignore-missing',
        \ '--ignore-space-at-eol',
        \ '--ignore-space-change', '-b',
        \ '--ignore-submodules',
        \ '--inter-hunk-context',
        \ '--invert-grep',
        \ '--irreversible-delete', '-D',
        \ '--ita-invisible-in-index',
        \ '-l',
        \ '-L',
        \ '--left-only',
        \ '--left-right',
        \ '--line-prefix',
        \ '--log-size',
        \ '--max-age',
        \ '--max-count', '-n',
        \ '--max-parents',
        \ '--merge',
        \ '--merges',
        \ '--min-age',
        \ '--minimal',
        \ '--min-parents',
        \ '--name-only',
        \ '--name-status',
        \ '--no-abbrev-commit', '--no-abbrev',
        \ '--no-color',
        \ '--no-color-moved-ws',
        \ '--no-decorate',
        \ '--no-ext-diff',
        \ '--no-follow',
        \ '--no-indent-heuristic',
        \ '--no-max-parents', '--no-min-parents',
        \ '--no-merges',
        \ '--no-notes',
        \ '--no-patch', '-s',
        \ '--no-prefix',
        \ '--no-renames',
        \ '--not',
        \ '--notes',
        \ '--no-textconv',
        \ '--no-walk',
        \ '--numstat',
        \ '-O',
        \ '--objects',
        \ '--objects-edge',
        \ '--oneline',
        \ '--output-indicator-context',
        \ '--output-indicator-new',
        \ '--output-indicator-old',
        \ '--parents',
        \ '--patch', '-u', '-p',
        \ '--patch-with-raw',
        \ '--patch-with-stat',
        \ '--patience',
        \ '--perl-regexp', '-P',
        \ '--pickaxe-all',
        \ '--pickaxe-regex',
        \ '-R',
        \ '--raw',
        \ '--reflog',
        \ '--regexp-ignore-case', '-i',
        \ '--relative',
        \ '--relative-date',
        \ '--remotes',
        \ '--remove-empty',
        \ '--rename-empty',
        \ '--reverse',
        \ '--right-only',
        \ '-S',
        \ '--shortstat',
        \ '--show-linear-break',
        \ '--show-signature',
        \ '--simplify-by-decoration',
        \ '--simplify-merges',
        \ '--single-worktree',
        \ '--skip',
        \ '--source',
        \ '--sparse',
        \ '--src-prefix',
        \ '--stat',
        \ '--stat-count',
        \ '--stat-graph-width',
        \ '--stat-width',
        \ '--stdin',
        \ '--submodule',
        \ '--summary',
        \ '--tags',
        \ '--text', '-a',
        \ '--textconv',
        \ '--topo-order',
        \ '--unified', '-U',
        \ '--use-mailmap',
        \ '--walk-reflogs', '-g',
        \ '--word-diff',
        \ '--word-diff-regex',
        \ '--ws-error-highlight',
        \ '-z'
        \ ]

  let l:branches = systemlist("git branch --all --format='%(refname:lstrip=2)'")
  if l:branches[0] =~# '(HEAD detached at [0-9a-f]\{8\})'
    let l:branches = l:branches[1:]
  endif
  let l:tags = systemlist('git tag')
  let l:hashes = systemlist('git rev-list --all --abbrev-commit')
  let l:files = map(split(globpath('.', a:arg_lead . '*'), '\n'), 'v:val[2:]')

  let l:lead_args = split(a:cmd_line)

  let l:candidates = []

  if index(l:lead_args, '--') > -1 && a:arg_lead !=# '--'
    let l:candidates = l:files
  elseif a:arg_lead =~# '^-'
    let l:candidates = l:options
  elseif len(l:lead_args) >= 3 || len(l:lead_args) == 2 && empty(a:arg_lead)
    let l:candidates = l:files + l:branches + l:tags + l:hashes
  else
    let l:candidates = l:subcommands + l:files + l:branches + l:tags + l:hashes
  endif

  return filter(l:candidates, printf("v:val =~# '^%s'", a:arg_lead))
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

" :M
" :M l
" :M 1 ls
function! s:man_complete(arg_lead, cmd_line, cursor_pos) abort
  " Words on the command line.
  let l:words = split(a:cmd_line, '[[:space:]]')

  " Trim a incomplate word.
  if !empty(a:arg_lead) && len(l:words) >= 2
    let l:words = l:words[:-2]
  endif

  " A man entry lookup command.
  let l:cmd = ['apropos', '.']

  let l:section = l:words[-1]

  " Default section number is 1.
  if l:section !~# '^\([[:digit:]]\|[013]p\|[ln]\)$'
    let l:section = '1'
  endif

  " Specify a section number.
  let l:cmd += ['-s', l:section]

  let l:candidates = map(systemlist(join(l:cmd)), printf("matchstr(v:val, '%s')", '[[:alnum:]\._-]\+'))

  if !empty(a:arg_lead)
    let l:candidates = filter(l:candidates, printf("v:val[:%d] ==# '%s'", strlen(a:arg_lead) - 1, a:arg_lead))
  endif

  return l:candidates
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
  set clipboard=unnamedplus
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

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <leader>n :ToggleNetrw<CR>
nnoremap <F2> :ReloadVimrc<CR>
nnoremap <leader><F2> :Vimrc<CR>

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

nnoremap <silent> <leader>t :tabnew<CR>

" Like default configurations of Tmux.
nnoremap <silent> <leader>" :terminal<CR>
nnoremap <silent> <leader>% :vertical terminal<CR>
nnoremap <silent> <leader>c :Terminal<CR>

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
command! -range YankComments <line1>,<line2>call s:yank_comments()
command! -nargs=1 -complete=file Readonly
      \ edit <args>
      \ | setlocal readonly nomodifiable noswapfile
command! -range -addr=tabs -nargs=? -complete=dir Terminal
      \ call s:open_terminal_on_newtab(<count>, <f-args>)
command! Runtimepath echo substitute(&runtimepath, ',', "\n", 'g')
command! Update call s:update()
command! ToggleNetrw call s:toggle_newrw()
command! -bang -nargs=* Environments call s:environments(<q-bang>, <q-args>)
command! Vimrc edit $MYVIMRC
command! ReloadVimrc source $MYVIMRC

command! -nargs=+ -complete=customlist,s:man_complete M
      \ <mods> Man <args>

" Tig
command! -nargs=* -complete=customlist,s:tig_complete Tig
      \ <mods> terminal ++close tig <args>
command! -nargs=* -complete=customlist,s:tig_complete Tiga
      \ <mods> Tig <args> --all
" }}}

" Auto commands {{{
" Helper
command! -nargs=+ Autocmd autocmd vimrc <args>

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

" rust {{{
let g:rustfmt_autosave = 1
" }}}

" man.vim {{{
" Enable :Man command.
"
" NOTE: An recommended way to enable :Man command on vim help page is to
" source default ftplugin for man by "runtime ftplugin/man.vim" in vimrc. But
" maybe it sources another file if another fplugin/man.vim file on
" runtimepath's directories. So specify default ftplugin for man explicitly.
source $VIMRUNTIME/ftplugin/man.vim
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
call minpac#extra#add('thinca/vim-singleton')

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
