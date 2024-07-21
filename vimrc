"
" vimrc
"
" - The minimal requirement version is 9.1.0000 with default huge features.
" - Nowadays we are always in UTF-8 environment, aren't we?
" - Work well even if no (non-default) plugin is installed.
" - Support Unix and Windows.
" - No support Neovim.
"

" =============================================================================

" Functions {{{
function! s:InstallMinpac() abort
  " A root directory path of vim packages.
  const l:packhome = $'{split(&packpath, ',')[0]}/pack'

  const l:minpac_path =  $'{l:packhome}/minpac/opt/minpac'
  const l:minpac_url = 'https://github.com/k-takata/minpac.git'

  if isdirectory(l:minpac_path) || ! executable('git')
    return
  endif

  const l:command = $'git clone {l:minpac_url} {l:minpac_path}'

  execute 'terminal' l:command
endfunction

" Get syntax item information at a position.
"
" https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function! s:SyntaxItemAttribute(line, column) abort
  const l:item_id = synID(a:line, a:column, 1)
  const l:trans_item_id = synID(a:line, a:column, 0)

  return printf(
    \ 'hi<%s> trans<%s> lo<%s>',
    \ synIDattr(l:item_id, 'name'),
    \ synIDattr(l:trans_item_id, 'name'),
    \ synIDattr(synIDtrans(l:item_id), 'name')
    \ )
endfunction

" Join and normalize filepaths.
function! s:Pathjoin(...) abort
  const l:sep = has('win32') ? '\\' : '/'
  return join(a:000, l:sep)->simplify()->substitute(printf('^\.%s', l:sep), '', '')
endfunction

function! s:Terminal(bang = '', mods = '') abort
  " If the current buffer is for normal exsisting file editing.
  const l:cwd = empty(&buftype) && !expand('%')->empty() ? expand('%:p:h') : getcwd()
  const l:opts = #{ curwin: !empty(a:bang), cwd: l:cwd, term_finish: 'close' }

  execute a:mods 'call term_start(&shell, l:opts)'
endfunction

function! s:IsBundledPackageLoadable(package_name) abort
  return !glob($'{$VIMRUNTIME}/pack/dist/opt/{a:package_name}/plugin/*.vim')->empty()
endfunction

" Whether "<C-Space>" is usable for keymappings or not. Use "<Nul>" instead if
" not.
"
" NOTE: "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and
" the "SPACE" one as once if in some terminal emulators.
function! s:IsEnableControlSpaceKeymapping() abort
  return has('gui_running') || getenv('TERM_PROGRAM') ==# 'iTerm.app' || index(['xterm', 'xterm-kitty'], &term) >= 0
endfunction
" }}}

" Variables {{{
let $VIMHOME = expand('<sfile>:p:h')
" }}}

" Options {{{
" Allow to delete everything in Insert Mode.
set backspace=indent,eol,start

set colorcolumn=81,101,121
set cursorline

" Show characters to fill the screen as much as possible when some characters
" are out of the screen.
set display=lastline

" Maybe SKK dictionaries are encoded by "euc-jp".
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
set wildoptions+=pum,fuzzy

" "smartindent" isn't a super option for "autoindent", and the two of options
" work in a complement way for each other. So these options should be on at
" the same time. This is recommended in the help too.
set autoindent smartindent

" List mode, which renders alternative characters instead of invisible
" (non-printable, out of screen or concealed) them.
"
" "extends" is only used when "wrap" is off.
set list
set listchars+=tab:>\ \|,extends:>,precedes:<

" Strings that start with '>' isn't compatible with the block quotation syntax
" of markdown.
set showbreak=+++\ 

set breakindent
set breakindentopt=shift:2,sbr

" "smartcase" works only if "ignorecase" is on.
set ignorecase smartcase

set pastetoggle=<F12>

set completeopt=menuone,longest,popup

" Xterm and st (simple terminal) also support true (or direct) colors.
if $COLORTERM ==# 'truecolor' || index(['xterm', 'st-256color'], $TERM) > -1
  set termguicolors
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

" Screen line oriented scrolling.
set smoothscroll

" Behave ":cd", ":tcd" and ":lcd" like in UNIX even if in MS-Windows.
set cdhome

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

" Create temporary files(backup, swap, undo) under secure locations to avoid
" CVE-2017-1000382.
"
" https://github.com/archlinux/svntogit-packages/blob/68635a69f0c5525210adca6ff277dc13c590399b/trunk/archlinux.vim#L22
let s:directory = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : expand('~/.cache')

let &g:backupdir = $'{s:directory}/vim/backup//'
let &g:directory = $'{s:directory}/vim/swap//'
let &g:undodir = $'{s:directory}/vim/undo//'

silent call mkdir(expand(&g:backupdir), 'p', 0700)
silent call mkdir(expand(&g:directory), 'p', 0700)
silent call mkdir(expand(&g:undodir), 'p', 0700)
" }}}

" Key mappings {{{
" "<Leader>" is replaced with the value of "g:mapleader" when define a
" keymapping, so we must define this variable before the mapping definition.
let g:mapleader = ' '

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
nnoremap <silent> <C-N> :<C-U>execute $'{v:count1}cnext'<CR>
nnoremap <silent> <C-P> :<C-U>execute $'{v:count1}cprevious'<CR>
nnoremap <silent> g<C-N> :<C-U>execute $'{v:count1}lnext'<CR>
nnoremap <silent> g<C-P> :<C-U>execute $'{v:count1}lprevious'<CR>
nnoremap <silent> <C-G><C-N> :<C-U>execute $'{v:count1}lnext'<CR>
nnoremap <silent> <C-G><C-P> :<C-U>execute $'{v:count1}lprevious'<CR>

" Clear the highlightings for pattern searching and run a command to refresh
" something.
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR>:Refresh<CR>

nnoremap <Leader><CR> o<Esc>

map <silent> p <Plug>(put)
map <silent> P <Plug>(Put)

nnoremap <silent> <F10> :<C-U>echo <SID>SyntaxItemAttribute(line('.'), col('.'))<CR>

nnoremap <silent> <F2> :<C-U>ReloadVimrc<CR>
nnoremap <silent> <Leader><F2> :<C-U>Vimrc<CR>

" From "$VIMRUNTIME/mswin.vim".
" Save with "CTRL-S" on normal mode and insert mode.
"
" I usually save buffers to files every line editing by switching to the
" normal mode and typing ":w". However doing them every editing is a little
" bit bothersome. So I want to use these shortcuts which are often used to
" save files by GUI editros.
nnoremap <silent> <C-S> :<C-U>Update<CR>
inoremap <silent> <C-S> <Cmd>Update<CR>

nnoremap <silent> <Leader>t :<C-U>tabnew<CR>

" Like default configurations of Tmux.
nnoremap <silent> <Leader>" :<C-U>terminal<CR>
nnoremap <silent> <Leader>' :<C-U>call <SID>Terminal()<CR>
nnoremap <silent> <Leader>% :<C-U>vertical terminal<CR>
nnoremap <silent> <Leader>5 :<C-U>call <SID>Terminal('', 'vertical')<CR>
nnoremap <silent> <Leader>c :<C-U>Terminal<CR>

tnoremap <silent> <C-W><Leader>" <C-W>:terminal<CR>
tnoremap <silent> <C-W><Leader>' <C-W>:call <SID>Terminal()<CR>
tnoremap <silent> <C-W><Leader>% <C-W>:vertical terminal<CR>
tnoremap <silent> <C-W><Leader>5 <C-W>:call <SID>Terminal('', 'vertical')<CR>
tnoremap <silent> <C-W><Leader>c <C-W>:Terminal<CR>

nnoremap <silent> <Leader>y :YankComments<CR>
vnoremap <silent> <Leader>y :YankComments<CR>

" Delete finished terminal buffers by "<CR>", this behavior is similar to
" Neovim's builtin terminal.
tnoremap <silent><expr> <CR>
  \ bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? "<C-W>:bdelete<CR>"
  \ : "<CR>"

" This is required for "term_start()" without "{ 'term_finish': 'close' }".
nmap <silent><expr> <CR>
  \ &buftype ==# 'terminal' && bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? ":<C-U>bdelete<CR>"
  \ : "<Plug>(newline)"

" Maximize or minimize the current window.
nnoremap <silent> <C-W>m :<C-U>resize 0<CR>
nnoremap <silent> <C-W>Vm :<C-U>vertical resize 0<CR>
nmap <silent> <C-W>gm <Plug>(xminimize)

nnoremap <silent> <C-W>M :<C-U>resize<CR>
nnoremap <silent> <C-W>VM :<C-U>vertical resize<CR>

tnoremap <silent> <C-W>m <C-W>:resize 0<CR>
tnoremap <silent> <C-W>Vm <C-W>:vertical resize 0<CR>
tmap <silent> <C-W>gm <Plug>(xminimize)

tnoremap <silent> <C-W>M <C-W>:resize<CR>
tnoremap <silent> <C-W>VM <C-W>:vertical resize<CR>
" }}}

" Commands {{{
" ":update" with new empty file creations for the current buffer.
"
" Run ":update" if the file which the current buffer is corresponding exists,
" otherwise run ":write" instead. This is because ":update" doesn't create a
" new empty file if the corresponding buffer is empty and unmodified.
"
" This is an auxiliary command for keyboard shortcuts.
command! -bang -bar -range=% Update
  \ execute printf('<mods> <line1>,<line2>%s<bang>', expand('%')->filewritable() ? 'update' : 'write')

" A helper command to open a file in a split window, or the current one (if it
" is invoked with a bang mark).
command! -bang -bar -nargs=1 -complete=file Open execute <q-mods> (<bang>1 ? 'split' : 'edit') <q-args>

command! -bang -bar Vimrc <mods> Open<bang> $MYVIMRC
command! ReloadVimrc source $MYVIMRC

" Run commands to refresh something. Use ":OnRefresh" to register a command.
command! Refresh doautocmd <nomodeline> User Refresh

command! Hitest source $VIMRUNTIME/syntax/hitest.vim

command! InstallMinpac call s:InstallMinpac()
" }}}

" Auto commands {{{
command! -nargs=+ Autocmd autocmd vimrc <args>

augroup vimrc
  " This throws "E216" if no such a autocmd group, so first of all we need to
  " define it using ":augroup".
  autocmd!
augroup END

Autocmd QuickFixCmdPost *grep* cwindow

" Make parent directories of the file which the written buffer is corresponing
" if these directories are missing.
Autocmd BufWritePre * silent call mkdir(expand('<afile>:p:h'), 'p')

" Hide extras on normal mode of terminal.
Autocmd TerminalOpen * setlocal nolist nonumber colorcolumn=

Autocmd BufReadPre ~/* setlocal undofile

" From "$VIMRUNTIME/defaults.vim".
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
" Avoid loading some standard plugins. {{{
" netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" These two plugins provide plugin management, but they are already obsolete.
let g:loaded_getscriptPlugin = 1
let g:loaded_vimballPlugin = 1
" }}}

" netrw configurations {{{
" WIP: Must match to line not but filename when `g:netrw_liststyle = 1`, on
" the commit hash of vim/vim: a452b808b4da2d272ca4a50865eb8ca89a58f239
let g:netrw_list_hide = '^\..*\~ *'
let g:netrw_sizestyle = 'H'
" }}}
" }}}

" Bundled plugins {{{
packadd! editorconfig
" }}}

" =============================================================================

" Plugins {{{
call maxpac#Begin()

" =============================================================================

" thinca/vim-singleton {{{
" NOTE: Call this as soon as possible!
" NOTE: Maybe "+clientserver" is disabled in macOS even if a Vim is compiled
" with "--with-features=huge".
if has('clientserver')
  let s:singleton = maxpac#Add('thinca/vim-singleton')

  function! s:singleton.post() abort
    call singleton#enable()
  endfunction
endif
" }}}

" k-takata/minpac {{{
let s:minpac = maxpac#Add('k-takata/minpac')

function! s:minpac.post() abort
  function! s:PackComplete(...) abort
    return minpac#getpluglist()->keys()->sort()->join("\n")
  endfunction

  command! -bar -nargs=? PackInstall
    \   if empty(<q-args>)
    \ |   call minpac#update()
    \ | else
    \ |   call minpac#add(<q-args>, #{ type: 'opt' })
    \ |   call minpac#update(maxpac#Plugname(<q-args>), #{ do: printf('packadd %s', maxpac#Plugname(<q-args>)) })
    \ | endif

  command! -bar -nargs=? -complete=custom,s:PackComplete PackUpdate
    \   if empty(<q-args>)
    \ |   call minpac#update()
    \ | else
    \ |   call minpac#update(maxpac#Plugname(<q-args>))
    \ | endif

  command! -bar -nargs=? -complete=custom,s:PackComplete PackClean
    \   if empty(<q-args>)
    \ |   call minpac#clean()
    \ | else
    \ |   call minpac#clean(maxpac#Plugname(<q-args>))
    \ | endif

  " This command is from the minpac help file.
  command! -nargs=1 -complete=custom,s:PackComplete PackOpenDir
    \ call term_start(&shell, #{
    \   cwd: minpac#getpluginfo(maxpac#Plugname(<q-args>))['dir'],
    \   term_finish: 'close',
    \ })
endfunction
" }}}

" =============================================================================

" KeitaNakamura/neodark.vim {{{
let s:neodark = maxpac#Add('KeitaNakamura/neodark.vim')

function! s:neodark.post() abort
  " Prefer a near black background color.
  let g:neodark#background = '#202020'

  function! s:ApplyNeodark(bang) abort
    " Neodark requires 256 colors at least. For example Linux console supports
    " only 8 colors.
    if empty(a:bang) && &t_Co < 256
      return
    endif

    colorscheme neodark

    " Cyan, but the default is orange in a strange way.
    let g:terminal_ansi_colors[6] = '#72c7d1'
    " Light black
    " Adjust the autosuggested text color for zsh.
    let g:terminal_ansi_colors[8] = '#5f5f5f'
  endfunction

  command! -bang -bar Neodark call s:ApplyNeodark(<q-bang>)

  Autocmd VimEnter * ++nested Neodark
endfunction
" }}}

" itchyny/lightline.vim {{{
let s:lightline = maxpac#Add('itchyny/lightline.vim')

function! s:lightline.pre() abort
  let g:lightline = #{
    \ active: #{
    \   left: [
    \     [ 'mode', 'binary', 'paste' ],
    \     [ 'readonly', 'relativepath', 'modified' ],
    \     [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \     [ 'lsp_checking', 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok', 'lsp_progress' ]
    \   ]
    \ },
    \ component: #{
    \   binary: '%{&binary ? "BINARY" : ""}'
    \ },
    \ component_visible_condition: #{
    \   binary: '&binary'
    \ },
    \ component_expand: #{
    \   linter_checking: 'lightline#ale#checking',
    \   linter_errors: 'lightline#ale#errors',
    \   linter_warnings: 'lightline#ale#warnings',
    \   linter_infos: 'lightline#ale#infos',
    \   linter_ok: 'lightline#ale#ok',
    \   lsp_checking: 'lightline#lsp#checking',
    \   lsp_errors: 'lightline#lsp#error',
    \   lsp_warnings: 'lightline#lsp#warning',
    \   lsp_informations: 'lightline#lsp#information',
    \   lsp_hints: 'lightline#lsp#hint',
    \   lsp_ok: 'lightline#lsp#ok',
    \   lsp_progress: 'lightline_lsp_progress#progress'
    \ },
    \ component_type: #{
    \   linter_checking: 'left',
    \   linter_errors: 'error',
    \   linter_warnings: 'warning',
    \   linter_infos: 'left',
    \   linter_ok: 'left',
    \   lsp_checking: 'left',
    \   lsp_errors: 'error',
    \   lsp_warnings: 'warning',
    \   lsp_informations: 'left',
    \   lsp_hints: 'left',
    \   lsp_ok: 'left',
    \   lsp_progress: 'left'
    \ }
    \ }

  function! s:SetLightlineColorscheme(colorscheme) abort
    let g:lightline = get(g:, 'lightline', {})
    let g:lightline['colorscheme'] = a:colorscheme
  endfunction

  function! s:HasLightlineColorscheme(colorscheme) abort
    return !globpath(&runtimepath, $'autoload/lightline/colorscheme/{a:colorscheme}.vim', 1)->empty()
  endfunction

  function! s:UpdateLightline() abort
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
  endfunction

  function! s:ChangeLightlineColorscheme() abort
    if !get(g:, 'lightline_colorscheme_change_on_the_fly', 1)
      return
    endif

    const l:colorscheme =
      \ !exists('g:lightline_colorscheme_mapping') ? g:colors_name
      \ : type(g:lightline_colorscheme_mapping) == type('') ? call(g:lightline_colorscheme_mapping, [g:colors_name])
      \ : type(g:lightline_colorscheme_mapping) == type(function('tr')) ? g:lightline_colorscheme_mapping(g:colors_name)
      \ : type(g:lightline_colorscheme_mapping) == type({}) ? get(g:lightline_colorscheme_mapping, g:colors_name, g:colors_name)
      \ : g:colors_name

    if s:HasLightlineColorscheme(l:colorscheme)
      call s:SetLightlineColorscheme(l:colorscheme)
    endif
  endfunction

  function! s:LightlineColorschemes(...) abort
    return globpath(&runtimepath, 'autoload/lightline/colorscheme/*.vim', 1, 1)->map({ _, val -> fnamemodify(val, ':t:r') })->join("\n")
  endfunction

  " The original version is from the help file of "lightline".
  command! -bar -nargs=1 -complete=custom,s:LightlineColorschemes LightlineColorscheme
    \   if exists('g:loaded_lightline')
    \ |   call s:SetLightlineColorscheme(<q-args>)
    \ |   call s:UpdateLightline()
    \ | endif

  " Synchronous lightline's colorscheme with Vim's one on the fly.
  Autocmd ColorScheme *
    \   if exists('g:loaded_lightline')
    \ |   call s:ChangeLightlineColorscheme()
    \ |   call s:UpdateLightline()
    \ | endif

  OnRefresh call lightline#update()
endfunction
" }}}

" =============================================================================

" airblade/vim-gitgutter {{{
let s:gitgutter = maxpac#Add('airblade/vim-gitgutter')

function! s:gitgutter.pre() abort
  let g:gitgutter_sign_added = 'A'
  let g:gitgutter_sign_modified = 'M'
  let g:gitgutter_sign_removed = 'D'
  let g:gitgutter_sign_removed_first_line = 'd'
  let g:gitgutter_sign_modified_removed = 'm'
endfunction
" }}}

" lambdalisue/gina.vim {{{
let s:gina = maxpac#Add('lambdalisue/gina.vim')

function! s:gina.post() abort
  nmap <silent> <Leader>gl :<C-U>Gina log --graph --all<CR>
  nmap <silent> <Leader>gs :<C-U>Gina status<CR>
  nmap <silent> <Leader>gc :<C-U>Gina commit<CR>

  call gina#custom#mapping#nmap('log', 'q', '<C-W>c', #{ noremap: 1, silent: 1 })
  call gina#custom#mapping#nmap('log', 'yy', '<Plug>(gina-yank-rev)', #{ silent: 1 })
  call gina#custom#mapping#nmap('status', 'q', '<C-W>c', #{ noremap: 1, silent: 1 })
  call gina#custom#mapping#nmap('status', 'yy', '<Plug>(gina-yank-path)', #{ silent: 1 })
endfunction
" }}}

" rhysd/git-messenger.vim {{{
let s:git_messenger = maxpac#Add('rhysd/git-messenger.vim')

function! s:git_messenger.post() abort
  let g:git_messenger_include_diff = 'all'
  let g:git_messenger_always_into_popup = v:true
  let g:git_messenger_max_popup_height = 15
endfunction
" }}}

" =============================================================================

" ctrlpvim/ctrlp.vim {{{
let s:ctrlp = maxpac#Add('ctrlpvim/ctrlp.vim')

function! s:ctrlp.pre() abort
  let g:ctrlp_map = s:IsEnableControlSpaceKeymapping() ? '<C-Space>' : '<Nul>'

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

  function! s:CtrlpProxy(bang, dir = getcwd()) abort
    const l:bang = empty(a:bang) ? '' : '!'

    const l:home = expand('~')

    " Make vim heavy or freeze to run CtrlP to search many files. For example
    " this is caused when run `CtrlP` on home directory or edit a file on home
    " directory.
    if empty(l:bang) && l:home ==# a:dir
      throw 'Forbidden to run CtrlP on home directory'
    endif

    CtrlP a:dir
  endfunction

  command! -bang -nargs=? -complete=dir CtrlPp call s:CtrlpProxy(<q-bang>, <f-args>)

  nnoremap <silent> <Leader>b :<C-U>CtrlPBuffer<CR>
endfunction
" }}}

" mattn/ctrlp-matchfuzzy {{{
let s:ctrlp_matchfuzzy = maxpac#Add('mattn/ctrlp-matchfuzzy')

function! s:ctrlp_matchfuzzy.post() abort
  let g:ctrlp_match_func = #{ match: 'ctrlp_matchfuzzy#matcher' }
endfunction
" }}}

" mattn/ctrlp-ghq {{{
let s:ctrlp_ghq = maxpac#Add('mattn/ctrlp-ghq')

function! s:ctrlp_ghq.post() abort
  let g:ctrlp_ghq_actions = [
    \ #{ label: 'edit', action: 'edit', path: 1 },
    \ #{ label: 'tabnew', action: 'tabnew', path: 1 }
    \ ]

  nnoremap <silent> <Leader>gq :<C-U>CtrlPGhq<CR>
endfunction
" }}}

" a5ob7r/ctrlp-man {{{
let s:ctrlp_man = maxpac#Add('a5ob7r/ctrlp-man')

function! s:ctrlp_man.post() abort
  function! s:LookupManual() abort
    const l:q = input('keyword> ', '', 'shellcmd')

    if empty(l:q)
      return
    endif

    execute 'CtrlPMan' l:q
  endfunction

  command! LookupManual call s:LookupManual()

  nnoremap <silent> <Leader>m :LookupManual<CR>
endfunction
" }}}

" =============================================================================

" prabirshrestha/vim-lsp {{{
let s:vim_lsp = maxpac#Add('prabirshrestha/vim-lsp')

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

  let g:lsp_diagnostics_virtual_text_align = 'after'

  let g:lsp_experimental_workspace_folders = 1

  function! s:OnLspBufferEnabled() abort
    setlocal omnifunc=lsp#complete
    setlocal tagfunc=lsp#tagfunc

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

  Autocmd User lsp_buffer_enabled call s:OnLspBufferEnabled()

  function! s:LspLogFile() abort
    return get(g:, 'lsp_log_file', '')
  endfunction

  command! CurrentLspLogging echo s:LspLogFile()
  command! -nargs=* -complete=file EnableLspLogging
    \ let g:lsp_log_file = empty(<q-args>) ? $'{$VIMHOME}/tmp/vim-lsp.log' : <q-args>
  command! DisableLspLogging let g:lsp_log_file = ''

  function! s:ViewLspLog() abort
    const l:log = s:LspLogFile()

    if filereadable(l:log)
      call term_start(
        \ $'less {l:log}',
        \ #{
        \   env: #{ LESS: '' },
        \   term_finish: 'close',
        \ })
    endif
  endfunction

  command! ViewLspLog call s:ViewLspLog()

  function! s:RunWithLspLog(template) abort
    const l:log = s:LspLogFile()

    if filereadable(l:log)
      call term_start([&shell, &shellcmdflag, printf(a:template, l:log)], #{ term_finish: 'close' })
    endif
  endfunction

  command! -nargs=+ -complete=shellcmd RunWithLspLog call s:RunWithLspLog(<q-args>)

  function! s:ClearLspLog() abort
    const l:log = s:LspLogFile()

    if filewritable(l:log)
      call writefile([], l:log)
    endif
  endfunction

  command! ClearLspLog call s:ClearLspLog()
endfunction
" }}}

" mattn/vim-lsp-settings {{{
let s:vim_lsp_settings = maxpac#Add('mattn/vim-lsp-settings')

function! s:vim_lsp_settings.pre() abort
  " Use this only as a preset configuration for LSP, not a installer.
  let g:lsp_settings_enable_suggestions = 0

  let g:lsp_settings = get(g:, 'lsp_settings', {})
  " Prefer Vim + latexmk than texlab for now.
  let g:lsp_settings['texlab'] = #{
    \ disabled: 1,
    \ workspace_config: #{
    \   latex: #{
    \     build: #{
    \       args: ['%f'],
    \       onSave: v:true,
    \       forwardSearchAfter: v:true
    \       },
    \     forwardSearch: #{
    \       executable: 'zathura',
    \       args: ['--synctex-forward', '%l:1:%f', '%p']
    \       }
    \     }
    \   }
    \ }
endfunction
" }}}

call maxpac#Add('tsuyoshicho/lightline-lsp')
call maxpac#Add('micchy326/lightline-lsp-progress')

" =============================================================================

" hrsh7th/vim-vsnip {{{
let s:vsnip = maxpac#Add('hrsh7th/vim-vsnip')

function! s:vsnip.pre() abort
  let g:vsnip_snippet_dir = $'{$VIMHOME}/vsnip'
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

call maxpac#Add('hrsh7th/vim-vsnip-integ')
call maxpac#Add('rafamadriz/friendly-snippets')

" =============================================================================

call maxpac#Add('kana/vim-operator-user')

" kana/vim-operator-replace {{{
let s:replace = maxpac#Add('kana/vim-operator-replace')

function! s:replace.post() abort
  map _ <Plug>(operator-replace)
endfunction
" }}}

" =============================================================================

" a5ob7r/shellcheckrc.vim {{{
let s:shellcheckrc = maxpac#Add('a5ob7r/shellcheckrc.vim')

function! s:shellcheckrc.pre() abort
  let g:shellcheck_directive_highlight = 1
endfunction
" }}}

" preservim/vim-markdown {{{
let s:markdown = maxpac#Add('preservim/vim-markdown')

function! s:markdown.pre() abort
  " No need to insert any indent preceding a new list item after inserting a
  " newline.
  let g:vim_markdown_new_list_item_indent = 0

  let g:vim_markdown_folding_disabled = 1
endfunction
" }}}

" tyru/open-browser.vim {{{
let s:open_browser = maxpac#Add('tyru/open-browser.vim')

function! s:open_browser.post() abort
  nmap <Leader>K <Plug>(openbrowser-smart-search)
  nnoremap <Leader>k :call SearchUnderCursorEnglishWord()<CR>

  function! SearchEnglishWord(word) abort
    const l:url = $'https://dictionary.cambridge.org/dictionary/english/{a:word}'
    call openbrowser#open(l:url)
  endfunction

  function! SearchUnderCursorEnglishWord() abort
    const l:word = expand('<cword>')
    call SearchEnglishWord(l:word)
  endfunction
endfunction
" }}}

" w0rp/ale {{{
let s:ale = maxpac#Add('w0rp/ale')

function! s:ale.pre() abort
  " Use ALE only as a linter engine.
  let g:ale_disable_lsp = 1

  let g:ale_python_auto_pipenv = 1
  let g:ale_python_auto_poetry = 1

  Autocmd User lsp_buffer_enabled ALEDisableBuffer
endfunction
" }}}

" kyoh86/vim-ripgrep {{{
let s:ripgrep = maxpac#Add('kyoh86/vim-ripgrep')

function! s:ripgrep.post() abort
  function! RipgrepContextObserver(message) abort
    if a:message['type'] !=# 'context'
      return
    endif

    const l:data = a:message['data']

    const l:item = #{
      \ filename: l:data['path']['text'],
      \ lnum: l:data['line_number'],
      \ text: l:data['lines']['text'],
      \ }

    call setqflist([l:item], 'a')
  endfunction

  call ripgrep#observe#add_observer(g:ripgrep#event#other, 'RipgrepContextObserver')

  command! -bang -count -nargs=+ -complete=file Rg call s:Ripgrep(['-C<count>', <q-args>], #{ case: <bang>1, escape: <bang>1 })

  function! s:Ripgrep(args, opts = {}) abort
    const l:o_case = get(a:opts, 'case')
    const l:o_escape = get(a:opts, 'escape')

    let l:args = []

    if l:o_case
      let l:args += [&ignorecase ? &smartcase ? '--smart-case' : '--ignore-case' : '--case-sensitive']
    endif

    if l:o_escape
      " Change the "<q-args>" to the "{command}" argument for "job_start()" literally.
      let l:args += copy(a:args)->map({ _, val -> s:JobArgumentalizeEscape(val) })
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
  function! s:JobArgumentalizeEscape(s) abort
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
    call s:OperatorRipgrep(a:motion_wiseness, { 'boundaries': 0, 'push_history_entry': 1, 'highlight': 1 })
  endfunction

  function! Op_ripgrep_g(motion_wiseness) abort
    call s:OperatorRipgrep(a:motion_wiseness, { 'boundaries': 1, 'push_history_entry': 1, 'highlight': 1 })
  endfunction

  " TODO: Consider ideal linewise and blockwise operations.
  function! s:OperatorRipgrep(motion_wiseness, opts = {}) abort
    const l:o_boundaries = get(a:opts, 'boundaries')
    const l:o_push_history_entry = get(a:opts, 'push_history_entry')
    const l:o_highlight = get(a:opts, 'highlight')

    let l:words = ['Rg', '-F']

    if l:o_boundaries
      let l:words += ['-w']
    endif

    const [l:_l_bufnum, l:l_lnum, l:l_col, l:_l_off] = getpos("'[")
    const [l:_r_bufnum, l:r_lnum, l:r_col, l:_r_off] = getpos("']")

    let l:l_col_idx = l:l_col - 1
    let l:r_col_idx = l:r_col - (&selection ==# 'inclusive' ? 1 : 2)

    const l:buflines =
          \ a:motion_wiseness ==# 'block' ? bufname('%')->getbufline(l:l_lnum, l:r_lnum)->map({ _, val -> val[l:l_col_idx : l:r_col_idx] }) :
          \ a:motion_wiseness ==# 'line' ? bufname('%')->getbufline(l:l_lnum, l:r_lnum) :
          \ bufname('%')->getbufline(l:l_lnum)->map({ _, val -> val[l:l_col_idx : l:r_col_idx] })

    let l:words += match(l:buflines, '^\s*-') + 1 ? ['--'] : []
    let l:words += match(l:buflines, ' ') + 1 ? [printf('"%s"', copy(l:buflines)->map({ _, val -> s:CommandLineArgumentalizeEscape(val) })->join("\n"))] : [copy(l:buflines)->map({ _, val -> s:CommandLineArgumentalizeEscape(val) })->join("\n")]

    const l:command = join(l:words)

    execute l:command

    if l:o_highlight && a:motion_wiseness ==# 'char'
      let @/ = l:o_boundaries ? printf('\V\<%s\>', escape(l:buflines[0], '\/')) : printf('\V%s', escape(l:buflines[0], '\/'))
    endif

    if l:o_push_history_entry
      call s:SmartRipgrepCommandHistoryPush(l:command)
    endif
  endfunction

  " Escape command line special characters ("cmdline-special"), any
  " double-quotes and any backslashes preceding spaces.
  function! s:CommandLineArgumentalizeEscape(s) abort
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

  function! s:SmartRipgrepCommandHistoryPush(command) abort
    const l:history_entry = a:command
    const l:latest_history_entry = histget('cmd', -1)

    if l:history_entry !=# l:latest_history_entry
      call histadd('cmd', l:history_entry)
    endif
  endfunction
endfunction
" }}}

" haya14busa/vim-asterisk {{{
let s:asterisk = maxpac#Add('haya14busa/vim-asterisk')

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
let s:modesearch = maxpac#Add('monaqa/modesearch.vim')

function! s:modesearch.post() abort
  nmap <silent> g/ <Plug>(modesearch-slash-rawstr)
  nmap <silent> g? <Plug>(modesearch-question-regexp)
  cmap <silent> <C-x> <Plug>(modesearch-toggle-mode)
endfunction
" }}}

" thinca/vim-localrc {{{
let s:localrc = maxpac#Add('thinca/vim-localrc')

function! s:localrc.post() abort
  function! s:OpenLocalrc(bang, mods, dir) abort
    const l:filename = get(g:, 'localrc_filename', '.local.vimrc')
    const l:localrc = s:Pathjoin(a:dir, fnameescape(l:filename))

    execute $'{a:mods} Open{a:bang} {l:localrc}'
  endfunction

  command! -bang -bar VimrcLocal
    \ call s:OpenLocalrc(<q-bang>, <q-mods>, expand('~'))
  command! -bang -bar -nargs=? -complete=dir OpenLocalrc
    \ call s:OpenLocalrc(<q-bang>, <q-mods>, empty(<q-args>) ? expand('%:p:h') : <q-args>)
endfunction
" }}}

" andymass/vim-matchup {{{
let s:matchup = maxpac#Add('andymass/vim-matchup')

function! s:matchup.fallback() abort
  " The enhanced "%", to find many extra matchings and jump the cursor to them.
  "
  " NOTE: "matchit" isn't a standard plugin, but it's bundled in Vim by default.
  packadd! matchit
endfunction
" }}}

" Eliot00/git-lens.vim {{{
let s:gitlens = maxpac#Add('Eliot00/git-lens.vim')

function! s:gitlens.post() abort
  command! -bar ToggleGitLens call ToggleGitLens()
endfunction
" }}}

" a5ob7r/linefeed.vim {{{
let s:linefeed = maxpac#Add('a5ob7r/linefeed.vim')

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
let s:man = maxpac#Add('vim-utils/vim-man')

function! s:man.post() abort
  command! -nargs=* -bar -complete=customlist,man#completion#run M Man <args>

  call l:self.common()
endfunction

function! s:man.fallback() abort
  " NOTE: A recommended way to enable ":Man" command on vim help page is to
  " source a default man ftplugin by ":runtime ftplugin/man.vim" in vimrc.
  " However it sources other ftplugin files which probably have side-effects.
  " So exlicitly specify the default man ftplugin.
  try
    source $VIMRUNTIME/ftplugin/man.vim
  catch
    echoerr v:exception
    return
  endtry

  command! -nargs=+ -complete=shellcmd M <mods> Man <args>

  call l:self.common()
endfunction

function! s:man.common() abort
  set keywordprg=:Man
endfunction
" }}}

" machakann/vim-sandwich {{{
let s:sandwich = maxpac#Add('machakann/vim-sandwich')

function! s:sandwich.post() abort
  let g:sandwich#recipes = get(g:, 'sandwich#recipes', deepcopy(g:sandwich#default_recipes))
  let g:sandwich#recipes += [
    \   #{ buns: ['{ ', ' }'],
    \      nesting: 1,
    \      match_syntax: 1,
    \      kind: ['add', 'replace'],
    \      action: ['add'],
    \      input: ['}']
    \   },
    \   #{ buns: ['[ ', ' ]'],
    \      nesting: 1,
    \      match_syntax: 1,
    \      kind: ['add', 'replace'],
    \      action: ['add'],
    \      input: [']']
    \   },
    \   #{ buns: ['( ', ' )'],
    \      nesting: 1,
    \      match_syntax: 1,
    \      kind: ['add', 'replace'],
    \      action: ['add'],
    \      input: [')']
    \   },
    \   #{ buns: ['{\s*', '\s*}'],
    \      nesting: 1,
    \      regex: 1,
    \      match_syntax: 1,
    \      kind: ['delete', 'replace', 'textobj'],
    \      action: ['delete'],
    \      input: ['}']
    \   },
    \   #{ buns: ['\[\s*', '\s*\]'],
    \      nesting: 1,
    \      regex: 1,
    \      match_syntax: 1,
    \      kind: ['delete', 'replace', 'textobj'],
    \      action: ['delete'],
    \      input: [']']
    \   },
    \   #{ buns: ['(\s*', '\s*)'],
    \      nesting: 1,
    \      regex: 1,
    \      match_syntax: 1,
    \      kind: ['delete', 'replace', 'textobj'],
    \      action: ['delete'],
    \      input: [')']
    \   }
    \ ]
endfunction
" }}}

" liuchengxu/vista.vim {{{
let s:vista = maxpac#Add('liuchengxu/vista.vim')

function! s:vista.pre() abort
  let g:vista_no_mappings = 1

  Autocmd FileType vista,vista_kind nnoremap <buffer><silent> q :<C-U>Vista!!<CR>

  nnoremap <silent> <Leader>v :<C-U>Vista!!<CR>
endfunction
" }}}

" itchyny/screensaver.vim {{{
let s:screensaver = maxpac#Add('itchyny/screensaver.vim')

function! s:screensaver.post() abort
  " Clear the cmdline area when starting a screensaver.
  Autocmd FileType screensaver echo
endfunction
" }}}

" bronson/vim-trailing-whitespace {{{
let s:trailing_whitespace = maxpac#Add('bronson/vim-trailing-whitespace')

function! s:trailing_whitespace.post() abort
  let g:extra_whitespace_ignored_filetypes = get(g:, 'extra_whitespace_ignored_filetypes', [])
  let g:extra_whitespace_ignored_filetypes += ['screensaver']
endfunction
" }}}

" =============================================================================

" lambdalisue/fern.vim {{{
let s:fern = maxpac#Add('lambdalisue/fern.vim')

function! s:fern.pre() abort
  let g:fern#default_hidden = 1
  let g:fern#default_exclude = '.*\~$'

  " Toggle a fern buffer to keep the cursor position. A tab should only have
  " one fern buffer.
  function! s:ToggleFern() abort
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

  command! -bar ToggleFern call s:ToggleFern()

  Autocmd Filetype fern let t:fern_buffer_id = bufnr()
  Autocmd BufLeave * if &ft !=# 'fern' | let t:non_fern_buffer_id = bufnr() | endif
  Autocmd DirChanged * unlet! t:fern_buffer_id

  function! s:FernLogFile() abort
    return get(g:, 'fern#logfile', v:null)
  endfunction

  command! CurrentFernLogging echo s:FernLogFile()
  command! -nargs=* -complete=file EnableFernLogging
    \ let g:fern#logfile = empty(<q-args>) ? '$VIMHOME/tmp/fern.tsv' : <q-args>
  command! DisableFernLogging let g:fern#logfile = v:null
  command! FernLogDebug let g:fern#loglevel = g:fern#DEBUG
  command! FernLogInfo let g:fern#loglevel = g:fern#INFO
  command! FernLogWARN let g:fern#loglevel = g:fern#WARN
  command! FernLogError let g:fern#loglevel = g:fern#Error

  function! s:RunWithFernLog(template) abort
    const l:log = s:FernLogFile()

    if filereadable(l:log)
      call term_start([&shell, &shellcmdflag, printf(a:template, l:log)], #{ term_finish: 'close' })
    endif
  endfunction

  command! -nargs=+ -complete=shellcmd RunWithFernLog call s:RunWithFernLog(<q-args>)
endfunction

function! s:fern.fallback() abort
  unlet g:loaded_netrw
  unlet g:loaded_netrwPlugin

  nnoremap <silent> <Leader>n :<C-U>ToggleNetrw<CR>
  nnoremap <silent> <Leader>N :<C-U>ToggleNetrw!<CR>
endfunction
" }}}

call maxpac#Add('lambdalisue/fern-hijack.vim')
call maxpac#Add('lambdalisue/fern-git-status.vim')

" a5ob7r/fern-renderer-lsflavor.vim {{{
let s:lsflavor = maxpac#Add('a5ob7r/fern-renderer-lsflavor.vim')

function! s:lsflavor.pre() abort
  let g:fern#renderer = 'lsflavor'
endfunction
" }}}

"==============================================================================

" prabirshrestha/asyncomplete.vim {{{
let s:asyncomplete = maxpac#Add('prabirshrestha/asyncomplete.vim')

function! s:asyncomplete.pre() abort
  let g:asyncomplete_enable_for_all = 0

  function! s:ToggleAsyncomplete(asyncomplete_enable = get(b:, 'asyncomplete_enable')) abort
    if a:asyncomplete_enable
      call asyncomplete#disable_for_buffer()

      execute $'augroup toggle_asyncomplete_{bufnr('%')}'
        autocmd!
      augroup END
    else
      const l:bufname = fnameescape(bufname('%'))

      execute $'augroup toggle_asyncomplete_{bufnr('%')}'
        autocmd!
        execute $'autocmd BufEnter {l:bufname} set completeopt=menuone,noinsert,noselect'
        execute $'autocmd BufLeave {l:bufname} set completeopt={&completeopt}'
        execute $'autocmd BufWipeout {l:bufname} set completeopt={&completeopt}'
      augroup END

      call asyncomplete#enable_for_buffer()
    endif
  endfunction

  command! ToggleAsyncomplete call s:ToggleAsyncomplete()
  command! EnableAsyncomplete call s:ToggleAsyncomplete(0)
  command! DisableAsyncomplete call s:ToggleAsyncomplete(1)
endfunction
" }}}

call maxpac#Add('prabirshrestha/asyncomplete-lsp.vim')

" =============================================================================

" Text object.
call maxpac#Add('kana/vim-textobj-user')

call maxpac#Add('D4KU/vim-textobj-chainmember')
call maxpac#Add('Julian/vim-textobj-variable-segment')
call maxpac#Add('deris/vim-textobj-enclosedsyntax')
call maxpac#Add('kana/vim-textobj-datetime')
call maxpac#Add('kana/vim-textobj-entire')
call maxpac#Add('kana/vim-textobj-indent')
call maxpac#Add('kana/vim-textobj-line')
call maxpac#Add('kana/vim-textobj-syntax')
call maxpac#Add('mattn/vim-textobj-url')
call maxpac#Add('osyo-manga/vim-textobj-blockwise')
call maxpac#Add('saaguero/vim-textobj-pastedtext')
call maxpac#Add('sgur/vim-textobj-parameter')
call maxpac#Add('thinca/vim-textobj-comment')

call maxpac#Add('machakann/vim-textobj-delimited')
call maxpac#Add('machakann/vim-textobj-functioncall')

" Misc.
call maxpac#Add('LumaKernel/coqpit.vim')
call maxpac#Add('a5ob7r/chmod.vim')
call maxpac#Add('a5ob7r/rspec-daemon.vim')
call maxpac#Add('a5ob7r/tig.vim')
call maxpac#Add('aliou/bats.vim')
call maxpac#Add('azabiong/vim-highlighter')
call maxpac#Add('fladson/vim-kitty')
call maxpac#Add('gpanders/vim-oldfiles')
call maxpac#Add('junegunn/goyo.vim')
call maxpac#Add('junegunn/vader.vim')
call maxpac#Add('junegunn/vim-easy-align')
call maxpac#Add('kannokanno/previm')
call maxpac#Add('keith/rspec.vim')
call maxpac#Add('lambdalisue/vital-Whisky')
call maxpac#Add('machakann/vim-highlightedyank')
call maxpac#Add('machakann/vim-swap')
call maxpac#Add('maximbaz/lightline-ale')
call maxpac#Add('neovimhaskell/haskell-vim')
call maxpac#Add('pocke/rbs.vim')
call maxpac#Add('thinca/vim-prettyprint')
call maxpac#Add('thinca/vim-themis')
call maxpac#Add('tpope/vim-endwise')
call maxpac#Add('tyru/eskk.vim')
call maxpac#Add('vim-jp/vital.vim')
call maxpac#Add('yasuhiroki/github-actions-yaml.vim')

if s:IsBundledPackageLoadable('comment')
  " "comment.vim" package is bundled since 5400a5d4269874fe4f1c35dfdd3c039ea17dfd62.
  packadd! comment
else
  call maxpac#Add('tpope/vim-commentary')
endif

" =============================================================================

" denops.vim

if executable('deno')
  call maxpac#Add('vim-denops/denops.vim')

  let s:gin = maxpac#Add('lambdalisue/gin.vim')

  function! s:gin.post() abort
    let g:gin_diff_persistent_args = ['--patch', '--stat']

    if executable('delta')
      let g:gin_diff_persistent_args += ['++processor=delta --color-only']
    elseif executable('diff-highlight')
      let g:gin_diff_persistent_args += ['++processor=diff-highlight']
    endif

    " Add a number argument to limit the number of commits because ":GinLog"
    " is too slow in a large repository.
    "
    " https://github.com/lambdalisue/gin.vim/issues/116
    nmap <silent> <Leader>gl :<C-U>GinLog --graph --oneline --all -500<CR>
    nmap <silent> <Leader>gs :<C-U>GinStatus<CR>
    nmap <silent> <Leader>gc :<C-U>Gin commit<CR>

    Autocmd BufReadCmd gin{branch,diff,edit,log,status,}://* setlocal nobuflisted
  endfunction

  let s:ddu = maxpac#Add('Shougo/ddu.vim')

  function! s:ddu.post() abort
    call ddu#custom#patch_global(#{
    \   ui: 'ff',
    \   sources: ['file_rec'],
    \   sourceOptions: #{
    \     _: #{
    \       matchers: ['matcher_fzy'],
    \     },
    \   },
    \   kindOptions: #{
    \     file: #{
    \       defaultAction: 'open',
    \     },
    \   },
    \ })

    call ddu#custom#action('kind', 'file', 'tcd', { args -> s:DduKindFileActionTcd(args) })

    function! s:DduKindFileActionTcd(args) abort
      execute $'tcd {a:args.items[0].action.path}'

      return 0
    endfunction

    if s:IsEnableControlSpaceKeymapping()
      nnoremap <silent> <C-Space> <Cmd>call ddu#start()<CR>
    else
      nnoremap <silent> <Nul> <Cmd>call ddu#start()<CR>
    endif

    nnoremap <silent> <Leader>b <Cmd>call ddu#start(#{ sources: ['buffer'] })<CR>
    nnoremap <silent> <Leader>gq <Cmd>call ddu#start(#{ sources: ['ghq'], kindOptions: #{ file: #{ defaultAction: 'tcd' } } })<CR>

    Autocmd FileType ddu-ff call s:DduFfKeybindings()
    function! s:DduFfKeybindings() abort
      nnoremap <buffer><silent> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR>
      nnoremap <buffer><silent> <C-X> <Cmd>call ddu#ui#do_action('itemAction', #{ name: 'open', params: #{ command: 'split' } })<CR>
      nnoremap <buffer><silent> i <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
      nnoremap <buffer><silent> q <Cmd>call ddu#ui#do_action('quit')<CR>
    endfunction

    Autocmd FileType ddu-ff-filter call s:DduFfFilterKeybindings()
    function! s:DduFfFilterKeybindings() abort
      inoremap <buffer><silent> <CR> <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
      nnoremap <buffer><silent> <CR> <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
      nnoremap <buffer><silent> q <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
    endfunction
  endfunction

  call maxpac#Add('Shougo/ddu-ui-ff')

  call maxpac#Add('4513ECHO/ddu-source-ghq')
  call maxpac#Add('Shougo/ddu-source-file_rec')
  call maxpac#Add('shun/ddu-source-buffer')

  call maxpac#Add('matsui54/ddu-filter-fzy')

  call maxpac#Add('Shougo/ddu-kind-file')
endif

" =============================================================================

call maxpac#End()
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

" Fire VimEnter manually on reload {{{
if !has('vim_starting')
  doautocmd <nomodeline> VimEnter
endif
" }}}

" =============================================================================

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
