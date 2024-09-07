vim9script

#
# vimrc
#
# - The minimal requirement version is 9.1.0000 with default huge features.
# - Nowadays we are always in UTF-8 environment, aren't we?
# - Work well even if no (non-default) plugin is installed.
# - Support Unix and Windows.
#

import autoload 'maxpac.vim'

# =============================================================================

# Variables {{{
$VIMHOME = expand('<sfile>:p:h')
# }}}

# Functions {{{
def InstallMinpac()
  # A root directory path of vim packages.
  const packhome = $'{$VIMHOME}/pack'

  const minpac_path =  $'{packhome}/minpac/opt/minpac'
  const minpac_url = 'https://github.com/k-takata/minpac.git'

  const command = $'git clone {minpac_url} {minpac_path}'

  execute 'terminal' command
enddef

# Get syntax item information at a position.
#
# https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
def SyntaxItemAttribute(line: number, column: number): string
  const item_id = synID(line, column, 1)
  const trans_item_id = synID(line, column, 0)

  return printf(
    'hi<%s> trans<%s> lo<%s>',
    synIDattr(item_id, 'name'),
    synIDattr(trans_item_id, 'name'),
    synIDattr(synIDtrans(item_id), 'name')
  )
enddef

# Join and normalize filepaths.
def Pathjoin(...paths: list<string>): string
  const sep = has('win32') ? '\\' : '/'
  return join(paths, sep)->simplify()->substitute(printf('^\.%s', sep), '', '')
enddef

def Terminal()
  # If the current buffer is for normal exsisting file editing.
  const cwd = empty(&buftype) && !expand('%')->empty() ? expand('%:p:h') : getcwd()
  const opts = {
    cwd: cwd,
    term_finish: 'close'
  }

  term_start(&shell, opts)
enddef

def IsBundledPackageLoadable(package_name: string): bool
  return !glob($'{$VIMRUNTIME}/pack/dist/opt/{package_name}/plugin/*.vim')->empty()
enddef

# A naive truecolor support terminal detection in the two ways.
#
# 1. Check $COLORTERM if it is defined.
# 2. Assume almost all the current major terminals without some exception like
#    below support truecolor.
#
#     - Terminal.app
#     - Linux console
#
# https://github.com/termstandard/colors
def IsInTruecolorSupportedTerminal(): bool
  if exists('$COLORTERM')
    return index(['truecolor', '24bit'], $COLORTERM) >= 0
  endif

  return !($TERM_PROGRAM ==# 'Apple_Terminal' || &term ==# 'linux')
enddef
# }}}

# Options {{{
# Allow to delete everything in Insert Mode.
set backspace=indent,eol,start

set colorcolumn=81,101,121
set cursorline

# Show characters to fill the screen as much as possible when some characters
# are out of the screen.
set display=lastline

# Maybe SKK dictionaries are encoded by "euc-jp".
# NOTE: "usc-bom" must precede "utf-8" to recognize BOM.
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1

# Prefer "<NL>" as "<EOL>" even if it is on Windows.
set fileformats=unix,dos,mac

# Automatically reload the file which is changed outside of Vim. For example
# this is useful when discarding modifications using VCS such as git.
set autoread

# Allow to hide buffers even if they are still modified.
set hidden

# The number of history of commands (":") and previous search patterns ("/").
#
# 10000 is the maximum value.
set history=10000

set hlsearch
set incsearch

# Render "statusline" for all of windows, to show window statuses not to
# separate windows.
set laststatus=2

# This option has no effect when "statusline" is not empty.
set ruler

# The cursor offset value around both of window edges.
set scrolloff=5

# Show the search count message, such as "[1/24]", when using search commands
# such as "/" and "n". This is enabled on "8.1.1270".
set shortmess-=S

set showcmd
set showmatch
set virtualedit=block

# When type the "wildchar" key that the default value is "<Tab>" in Vim,
# complete the longest match part and start "wildmenu" at the same time. And
# then complete the next item when type the key again.
set wildmode=longest:full,full

# A command mode with an enhanced completion.
set wildmenu
set wildoptions+=pum,fuzzy

# "smartindent" isn't a super option for "autoindent", and the two of options
# work in a complement way for each other. So these options should be on at
# the same time. This is recommended in the help too.
set autoindent smartindent

# List mode, which renders alternative characters instead of invisible
# (non-printable, out of screen or concealed) them.
#
# "extends" is only used when "wrap" is off.
set list
set listchars+=tab:>\ \|,extends:>,precedes:<

# Strings that start with '>' isn't compatible with the block quotation syntax
# of markdown.
set showbreak=+++\ 

set breakindent
set breakindentopt=shift:2,sbr

# "smartcase" works only if "ignorecase" is on.
set ignorecase smartcase

set pastetoggle=<F12>

set completeopt=menuone,longest,popup

if IsInTruecolorSupportedTerminal()
  set termguicolors
endif

if has('win32') || has('osxdarwin')
  # Use the "*" register as a default one, for yank, delete, change and put
  # operations instead of the '"' unnamed one. The contents of the "*"
  # register is synchronous with the system clipboard's them.
  set clipboard=unnamed
else
  # No connection to the X server if in a console.
  set clipboard=exclude:cons\|linux

  if has('unnamedplus')
    # This is similar to "unnamed", but use the "+" register instead. The
    # register is used for reading and writing of the CLIPBOARD selection but
    # not the PRIMARY one.
    set clipboard^=unnamedplus
  endif
endif

# Screen line oriented scrolling.
set smoothscroll

# Behave ":cd", ":tcd" and ":lcd" like in UNIX even if in MS-Windows.
set cdhome

set nrformats-=octal nrformats+=unsigned

if has('gui_running')
  # Add a "M" to the "guioptions" before executing ":syntax enable" or
  # ":filetype on" to avoid sourcing the "menu.vim".
  set guioptions=M
endif

# Keep other window sizes when opening/closing new windows.
set noequalalways

# Prefer single space rather than double them for text joining.
set nojoinspaces

# Stop at a TOP or BOTTOM match even if hitting "n" or "N" repeatedly.
set nowrapscan

# Create temporary files(backup, swap, undo) under secure locations to avoid
# CVE-2017-1000382.
#
# https://github.com/archlinux/svntogit-packages/blob/68635a69f0c5525210adca6ff277dc13c590399b/trunk/archlinux.vim#L22
const directory = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : expand('~/.cache')

&backupdir = $'{directory}/vim/backup//'
&directory = $'{directory}/vim/swap//'
&undodir = $'{directory}/vim/undo//'

silent mkdir(expand(&backupdir), 'p', 0700)
silent mkdir(expand(&directory), 'p', 0700)
silent mkdir(expand(&undodir), 'p', 0700)
# }}}

# Key mappings {{{
# "<Leader>" is replaced with the value of "g:mapleader" when define a
# keymapping, so we must define this variable before the mapping definition.
g:mapleader = ' '

# Use "Q" as the typed key recording starter and the terminator instead of
# "q".
noremap Q q
map q <Nop>

# Do not anything even if type "<F1>". I sometimes mistype it instead of
# typing "<ESC>".
map <F1> <Nop>
map! <F1> <Nop>

# Swap keybingings of 'j/k' and 'gj/gk' with each other.
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

# By default, "Y" is a synonym of "yy" for Vi-compatibilities.
noremap Y y$

# Change the current window height instantly.
nnoremap + <C-W>+
nnoremap - <C-W>-

# A shortcut to complete filenames.
inoremap <C-F> <C-X><C-F>

# Quit Visual mode.
vnoremap <C-L> <Esc>

# A newline version of "i_CTRL-G_k" and "i_CTRL-G_j".
inoremap <C-G><CR> <End><CR>

# https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features?redirected=1#%E5%BC%95%E7%94%A8%E7%AC%A6%E3%81%A7%E5%9B%B2%E3%81%BE%E3%82%8C%E3%81%9F%E7%AE%87%E6%89%80%E5%85%A8%E4%BD%93%E3%82%92%E9%81%B8%E6%8A%9E%E3%81%99%E3%82%8B
xnoremap a" 2i"
xnoremap a' 2i'
xnoremap a` 2i`
xnoremap ga" a"
xnoremap ga' a'
xnoremap ga` a`

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`
onoremap ga" a"
onoremap ga' a'
onoremap ga` a`

# Smart linewise upward/downward cursor movements in Vitual mode.
#
# Move the cursor line by line phycically not logically(screen) if Visual mode
# is linewise, otherwise character by character.
vnoremap <silent><expr> j mode() ==# 'V' ? 'j' : 'gj'
vnoremap <silent><expr> k mode() ==# 'V' ? 'k' : 'gk'

# Switch buffers. These are similar to "gt" and "gT" for tabs, but for
# buffers.
nnoremap <silent> gb :bNext<CR>
nnoremap <silent> gB :bprevious<CR>

# Browse quickfix/location lists by "<C-N>" and "<C-P>".
nnoremap <silent> <C-N> :<C-U>execute $'{v:count1}cnext'<CR>
nnoremap <silent> <C-P> :<C-U>execute $'{v:count1}cprevious'<CR>
nnoremap <silent> g<C-N> :<C-U>execute $'{v:count1}lnext'<CR>
nnoremap <silent> g<C-P> :<C-U>execute $'{v:count1}lprevious'<CR>
nnoremap <silent> <C-G><C-N> :<C-U>execute $'{v:count1}lnext'<CR>
nnoremap <silent> <C-G><C-P> :<C-U>execute $'{v:count1}lprevious'<CR>

# Clear the highlightings for pattern searching and run a command to refresh
# something.
nnoremap <silent> <C-L> :<C-U>nohlsearch<CR>:Refresh<CR>

nnoremap <Leader><CR> o<Esc>

nnoremap <silent> <F10> <ScriptCmd>echo SyntaxItemAttribute(line('.'), col('.'))<CR>

nnoremap <silent> <F2> :<C-U>ReloadVimrc<CR>
nnoremap <silent> <Leader><F2> :<C-U>Vimrc<CR>

# From "$VIMRUNTIME/mswin.vim".
# Save with "CTRL-S" on normal mode and insert mode.
#
# I usually save buffers to files every line editing by switching to the
# normal mode and typing ":w". However doing them every editing is a little
# bit bothersome. So I want to use these shortcuts which are often used to
# save files by GUI editros.
nnoremap <silent> <C-S> :<C-U>Update<CR>
inoremap <silent> <C-S> <Cmd>Update<CR>

nnoremap <silent> <Leader>t :<C-U>tabnew<CR>

# Like default configurations of Tmux.
nnoremap <silent> <Leader>" :<C-U>terminal<CR>
nnoremap <silent> <Leader>' <ScriptCmd>Terminal()<CR>
nnoremap <silent> <Leader>% :<C-U>vertical terminal<CR>
nnoremap <silent> <Leader>5 <ScriptCmd>vertical Terminal()<CR>
nnoremap <silent> <Leader>c :<C-U>Terminal<CR>

tnoremap <silent> <C-W><Leader>" <C-W>:terminal<CR>
tnoremap <silent> <C-W><Leader>' <ScriptCmd>Terminal()<CR>
tnoremap <silent> <C-W><Leader>% <C-W>:vertical terminal<CR>
tnoremap <silent> <C-W><Leader>5 <ScriptCmd>vertical Terminal()<CR>
tnoremap <silent> <C-W><Leader>c <C-W>:Terminal<CR>

nnoremap <silent> <Leader>y :YankComments<CR>
vnoremap <silent> <Leader>y :YankComments<CR>

# Delete finished terminal buffers by "<CR>", this behavior is similar to
# Neovim's builtin terminal.
tnoremap <silent><expr> <CR>
  \ bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? "<C-W>:bdelete<CR>"
  \ : "<CR>"

# This is required for "term_start()" without "{ 'term_finish': 'close' }".
nmap <silent><expr> <CR>
  \ &buftype ==# 'terminal' && bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? ":<C-U>bdelete<CR>"
  \ : "<Plug>(newline)"

# Maximize or minimize the current window.
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

# NOTE: "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and
# the "SPACE" one at once if in some terminal emulators.
nmap <Nul> <C-Space>
# }}}

# Commands {{{
# ":update" with new empty file creations for the current buffer.
#
# Run ":update" if the file which the current buffer is corresponding exists,
# otherwise run ":write" instead. This is because ":update" doesn't create a
# new empty file if the corresponding buffer is empty and unmodified.
#
# This is an auxiliary command for keyboard shortcuts.
command! -bang -bar -range=% Update {
  const command = expand('%')->filewritable() ? 'update' : 'write'

  execute $'<mods> :<line1>,<line2>{command}<bang>'
}

# A helper command to open a file in a split window, or the current one (if it
# is invoked with a bang mark).
command! -bang -bar -nargs=1 -complete=file Open {
  const opener = <bang>1 ? 'split' : 'edit'

  execute <q-mods> opener <q-args>
}

command! -bang -bar Vimrc {
  <mods> Open<bang> $MYVIMRC
}
command! ReloadVimrc {
  source $MYVIMRC
}

# Run commands to refresh something. Use ":OnRefresh" to register a command.
command! Refresh {
  doautocmd <nomodeline> User Refresh
}

command! Hitest {
  source $VIMRUNTIME/syntax/hitest.vim
}

command! InstallMinpac {
  InstallMinpac()
}

command! XReconnect {
  set clipboard^=unnamedplus
  xrestore
}
command! XDisconnect {
  set clipboard-=unnamedplus
}
# }}}

# Auto commands {{{
augroup vimrc
  autocmd!

  autocmd QuickFixCmdPost *grep* {
    cwindow
  }

  # Make parent directories of the file which the written buffer is corresponing
  # if these directories are missing.
  autocmd BufWritePre * {
    silent mkdir(expand('<afile>:p:h'), 'p')
  }

  # Hide extras on normal mode of terminal.
  autocmd TerminalOpen * {
    setlocal nolist nonumber colorcolumn=
  }

  autocmd BufReadPre ~/* {
    setlocal undofile
  }

  # From "$VIMRUNTIME/defaults.vim".
  # Jump cursor to last editting line.
  autocmd BufReadPost * {
    const line = line("'\"")

    if line >= 1
        && line <= line("$")
        && &filetype !~# 'commit'
        && index(['xxd', 'gitrebase'], &filetype) == -1
      execute "normal! g`\""
    endif
  }

  # Read/Write the binary format, but are these configurations really
  # comfortable? Maybe we should use a binary editor insated.
  autocmd BufReadPost * {
    if &binary
      execute 'silent %!xxd -g 1'
      set filetype=xxd
    endif
  }
  autocmd BufWritePre * {
    if &binary
      var b:cursorpos = getcurpos()
      execute '%!xxd -r'
    endif
  }
  autocmd BufWritePost * {
    if &binary
      execute 'silent %!xxd -g 1'
      set nomodified
      cursor(b:cursorpos[1], b:cursorpos[2], b:cursorpos[3])
      unlet b:cursorpos
    endif
  }
augroup END

# Register a command to refresh something.
command! -bar -nargs=+ OnRefresh {
  autocmd refresh User Refresh <args>
}

augroup refresh
  autocmd!
augroup END

OnRefresh redraw
# }}}

# Standard plugins {{{
# Avoid loading some standard plugins. {{{
# netrw
g:loaded_netrw = 1
g:loaded_netrwPlugin = 1

# These two plugins provide plugin management, but they are already obsolete.
g:loaded_getscriptPlugin = 1
g:loaded_vimballPlugin = 1
# }}}

# netrw configurations {{{
# WIP: Must match to line not but filename when `g:netrw_liststyle = 1`, on
# the commit hash of vim/vim: a452b808b4da2d272ca4a50865eb8ca89a58f239
g:netrw_list_hide = '^\..*\~ *'
g:netrw_sizestyle = 'H'
# }}}
# }}}

# Bundled plugins {{{
packadd! editorconfig
# }}}

# =============================================================================

# Plugins {{{
# Plugin hooks {{{
# thinca/vim-singleton {{{
def VimSingletonPost()
  singleton#enable()
enddef
# }}}

# k-takata/minpac {{{
def MinpacPost()
  command! -bar -nargs=1 PackInstall {
    minpac#add(<q-args>, { type: 'opt' })
    minpac#update(maxpac.Plugname(<q-args>), { do: $'packadd {maxpac.Plugname(<q-args>)}' })
  }

  command! -bar -nargs=? -complete=custom,PackComplete PackUpdate {
    call('minpac#update', map([<f-args>], (_, v) => maxpac.Plugname(v)))
  }

  command! -bar -nargs=? -complete=custom,PackComplete PackClean {
    call('minpac#clean', map([<f-args>], (_, v) => maxpac.Plugname(v)))
  }

  # This command is from the minpac help file.
  command! -nargs=1 -complete=custom,PackComplete PackOpenDir {
    term_start(&shell, {
      cwd: minpac#getpluginfo(maxpac.Plugname(<q-args>))['dir'],
      term_finish: 'close' }
    )
  }
enddef

def PackComplete(..._): string
  return minpac#getpluglist()->keys()->sort()->join("\n")
enddef
# }}}

# KeitaNakamura/neodark.vim {{{
def NeodarkVimPost()
  # Prefer a near black background color.
  g:neodark#background = '#202020'

  command! -bang -bar Neodark {
    ApplyNeodark(<q-bang>)
  }

  augroup vimrc:neodark
    autocmd!
    autocmd VimEnter * ++nested {
      Neodark
    }
  augroup END
enddef

def ApplyNeodark(bang: string)
  # Neodark requires 256 colors at least. For example Linux console supports
  # only 8 colors.
  if empty(bang) && str2nr(&t_Co) < 256
    return
  endif

  colorscheme neodark

  # Cyan, but the default is orange in a strange way.
  g:terminal_ansi_colors[6] = '#72c7d1'
  # Light black
  # Adjust the autosuggested text color for zsh.
  g:terminal_ansi_colors[8] = '#5f5f5f'
enddef
# }}}

# itchyny/lightline.vim {{{
def LightlineVimPre()
  g:lightline = {
    active: {
      left: [
        [ 'mode', 'binary', 'paste' ],
        [ 'readonly', 'relativepath', 'modified' ],
        [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
      ]
    },
    component: {
      binary: '%{&binary ? "BINARY" : ""}'
    },
    component_visible_condition: {
      binary: '&binary'
    },
    component_expand: {
      linter_checking: 'lightline#ale#checking',
      linter_errors: 'lightline#ale#errors',
      linter_warnings: 'lightline#ale#warnings',
      linter_infos: 'lightline#ale#infos',
      linter_ok: 'lightline#ale#ok',
    },
    component_type: {
      linter_checking: 'left',
      linter_errors: 'error',
      linter_warnings: 'warning',
      linter_infos: 'left',
      linter_ok: 'left',
    }
  }

  # The original version is from the help file of "lightline".
  command! -bar -nargs=1 -complete=custom,LightlineColorschemes LightlineColorscheme {
    if exists('g:loaded_lightline')
      SetLightlineColorscheme(<q-args>)
      UpdateLightline()
    endif
  }

  OnRefresh lightline#update()
enddef

def SetLightlineColorscheme(colorscheme: string)
  g:lightline = get(g:, 'lightline', {})
  g:lightline['colorscheme'] = colorscheme
enddef

def UpdateLightline()
  lightline#init()
  lightline#colorscheme()
  lightline#update()
enddef

def LightlineColorschemes(..._): string
  return globpath(&runtimepath, 'autoload/lightline/colorscheme/*.vim', 1, 1)->map((_, val) => fnamemodify(val, ':t:r'))->join("\n")
enddef
# }}}

# airblade/vim-gitgutter {{{
def VimGitgutterPre()
  g:gitgutter_sign_added = 'A'
  g:gitgutter_sign_modified = 'M'
  g:gitgutter_sign_removed = 'D'
  g:gitgutter_sign_removed_first_line = 'd'
  g:gitgutter_sign_modified_removed = 'm'
enddef
# }}}

# lambdalisue/gina.vim {{{
def GinaVimPost()
  nmap <silent> <Leader>gl :<C-U>Gina log --graph --all<CR>
  nmap <silent> <Leader>gs :<C-U>Gina status<CR>
  nmap <silent> <Leader>gc :<C-U>Gina commit<CR>

  gina#custom#mapping#nmap('log', 'q', '<C-W>c', { noremap: 1, silent: 1 })
  gina#custom#mapping#nmap('log', 'yy', '<Plug>(gina-yank-rev)', { silent: 1 })
  gina#custom#mapping#nmap('status', 'q', '<C-W>c', { noremap: 1, silent: 1 })
  gina#custom#mapping#nmap('status', 'yy', '<Plug>(gina-yank-path)', { silent: 1 })
enddef
# }}}

# rhysd/git-messenger.vim {{{
def GitMessengerVimPost()
  g:git_messenger_include_diff = 'all'
  g:git_messenger_always_into_popup = true
  g:git_messenger_max_popup_height = 15
enddef
# }}}

# hrsh7th/vim-vsnip {{{
def VimVsnipPre()
  g:vsnip_snippet_dir = $'{$VIMHOME}/vsnip'
enddef

def VimVsnipPost()
  imap <expr> <Tab>
    \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
    \ vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
  smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
  smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
enddef
# }}}

# kana/vim-operator-replace {{{
def VimOperatorReplacePost()
  map _ <Plug>(operator-replace)
enddef
# }}}

# a5ob7r/shellcheckrc.vim {{{
def ShellcheckrcVimPre()
  g:shellcheck_directive_highlight = 1
enddef
# }}}

# preservim/vim-markdown {{{
def VimMarkdownPre()
  # No need to insert any indent preceding a new list item after inserting a
  # newline.
  g:vim_markdown_new_list_item_indent = 0

  g:vim_markdown_folding_disabled = 1
enddef
# }}}

# w0rp/ale {{{
def AlePre()
  # Use ALE only as a linter engine.
  g:ale_disable_lsp = 1

  g:ale_linters_explicit = 1

  g:ale_python_auto_pipenv = 1
  g:ale_python_auto_poetry = 1

  g:ale_linters = {
    gha: ['actionlint'],
  }

  g:ale_linter_aliases = {
    gha: 'yaml',
  }
enddef
# }}}

# kyoh86/vim-ripgrep {{{
def VimRipgrepPost()
  ripgrep#observe#add_observer(g:ripgrep#event#other, 'RipgrepContextObserver')

  command! -bang -count -nargs=+ -complete=file Rg {
    Ripgrep(['-C<count>', <q-args>], { case: <bang>1, escape: <bang>1 })
  }

  map <Leader>f <Plug>(operator-ripgrep-g)
  map g<Leader>f <Plug>(operator-ripgrep)

  operator#user#define('ripgrep', 'Op_ripgrep')
  operator#user#define('ripgrep-g', 'Op_ripgrep_g')
enddef

def! g:RipgrepContextObserver(message: dict<any>)
  if message['type'] !=# 'context'
    return
  endif

  const data = message['data']

  const item = {
    filename: data['path']['text'],
    lnum: data['line_number'],
    text: data['lines']['text'],
  }

  setqflist([item], 'a')
enddef

def Ripgrep(args: list<string>, opts = {})
  const o_case = get(opts, 'case')
  const o_escape = get(opts, 'escape')

  var arguments = []

  if o_case
    arguments += [&ignorecase ? &smartcase ? '--smart-case' : '--ignore-case' : '--case-sensitive']
  endif

  if o_escape
    # Change the "<q-args>" to the "{command}" argument for "job_start()" literally.
    arguments += copy(args)->map(( _, val) => JobArgumentalizeEscape(val))
  else
    arguments += args
  endif

  ripgrep#search(join(arguments))
enddef

# Escape backslashes without them escaping a double quote or a space.
#
# :Rg \bvim\b -> job_start('rg \\bvim\\b')
# :Rg \"\ vim\b -> job_start('rg \"\ vim\\b')
#
def JobArgumentalizeEscape(s: string): string
  var tokens = []
  var str = s

  while 1
    var [matched, start, end] = matchstrpos(str, '\%(\%(\\\\\)*\)\@<=\\[" ]')

    if !!(start + 1)
      tokens += (!!start ? [escape(str[0 : start - 1], '\')] : []) + [matched]
      str = str[end :]
    else
      tokens += [escape(str, '\')]
      break
    endif
  endwhile

  return join(tokens, '')
enddef

def! g:Op_ripgrep(motion_wiseness: string)
  OperatorRipgrep(motion_wiseness, { boundaries: 0, push_history_entry: 1, highlight: 1 })
enddef

def! g:Op_ripgrep_g(motion_wiseness: string)
  OperatorRipgrep(motion_wiseness, { boundaries: 1, push_history_entry: 1, highlight: 1 })
enddef

# TODO: Consider ideal linewise and blockwise operations.
def OperatorRipgrep(motion_wiseness: string, opts = {})
  const o_boundaries = get(opts, 'boundaries')
  const o_push_history_entry = get(opts, 'push_history_entry')
  const o_highlight = get(opts, 'highlight')

  var words = ['Rg', '-F']

  if o_boundaries
    words += ['-w']
  endif

  const [_l_bufnum, l_lnum, l_col, _l_off] = getcharpos("'[")
  const [_r_bufnum, r_lnum, r_col, _r_off] = getcharpos("']")

  const l_col_idx = l_col - 1
  const r_col_idx = r_col - (&selection ==# 'inclusive' ? 1 : 2)

  const buflines =
    motion_wiseness ==# 'block' ? bufname('%')->getbufline(l_lnum, r_lnum)->map((_, val) => val[l_col_idx : r_col_idx]) :
    motion_wiseness ==# 'line' ? bufname('%')->getbufline(l_lnum, r_lnum) :
    bufname('%')->getbufline(l_lnum)->map((_, val) => val[l_col_idx : r_col_idx])

  words += match(buflines, '^\s*-') + 1 ? ['--'] : []
  words += match(buflines, ' ') + 1
    ? [printf('"%s"', copy(buflines)->map((_, val) => CommandLineArgumentalizeEscape(val))->join("\n"))]
    : [copy(buflines)->map((_, val) => CommandLineArgumentalizeEscape(val))->join("\n")]

  const command = join(words)

  execute command

  if o_highlight && motion_wiseness ==# 'char'
    @/ = o_boundaries ? printf('\V\<%s\>', escape(buflines[0], '\/')) : printf('\V%s', escape(buflines[0], '\/'))
  endif

  if o_push_history_entry
    histadd('cmd', command)
  endif
enddef

# Escape command line special characters ("cmdline-special"), any
# double-quotes and any backslashes preceding spaces.
def CommandLineArgumentalizeEscape(s: string): string
  var tokens = []
  var str = s

  while 1
    var [matched, start, end] = matchstrpos(str, '\C<\(cword\|cWORD\|cexpr\|cfile\|afile\|abuf\|amatch\|sfile\|stack\|script\|slnum\|sflnum\|client\)>\|\\ ')

    if !!(start + 1)
      tokens += (!!start ? [escape(str[0 : start - 1], '"%#')] : []) + [escape(matched, '<\')]
      str = str[end : ]
    else
      tokens += [escape(str, '"%#')]
      break
    endif
  endwhile

  return join(tokens, '')
enddef
# }}}

# haya14busa/vim-asterisk {{{
def VimAsteriskPost()
  # Keep the cursor offset while searching. See "search-offset".
  g:asterisk#keeppos = 1

  map * <Plug>(asterisk-z*)
  map # <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
  map z* <Plug>(asterisk-*)
  map z# <Plug>(asterisk-#)
  map gz* <Plug>(asterisk-g*)
  map gz# <Plug>(asterisk-g#)
enddef
# }}}

# monaqa/modesearch.vim {{{
def ModesearchVimPost()
  nmap <silent> g/ <Plug>(modesearch-slash-rawstr)
  nmap <silent> g? <Plug>(modesearch-question-regexp)
  cmap <silent> <C-x> <Plug>(modesearch-toggle-mode)
enddef
# }}}

# thinca/vim-localrc {{{
def VimLocalrcPost()
  command! -bang -bar VimrcLocal {
    OpenLocalrc(<q-bang>, <q-mods>, expand('~'))
  }
  command! -bang -bar -nargs=? -complete=dir OpenLocalrc {
    OpenLocalrc(<q-bang>, <q-mods>, empty(<q-args>) ? expand('%:p:h') : <q-args>)
  }
enddef

def OpenLocalrc(bang: string, mods: string, dir: string)
  const localrc_filename = get(g:, 'localrc_filename', '.local.vimrc')
  const localrc_filepath = Pathjoin(dir, fnameescape(localrc_filename))

  execute $'{mods} Open{bang} {localrc_filepath}'
enddef
# }}}

# andymass/vim-matchup {{{
def VimMatchupFallback()
  # The enhanced "%", to find many extra matchings and jump the cursor to them.
  #
  # NOTE: "matchit" isn't a standard plugin, but it's bundled in Vim by default.
  packadd! matchit
enddef
# }}}

# Eliot00/git-lens.vim {{{
def GitlensVimPost()
  command! -bar ToggleGitLens {
    ToggleGitLens()
  }
enddef
# }}}

# a5ob7r/linefeed.vim {{{
def LinefeedVimPost()
  # TODO: These keymappings override some default them and conflict with other
  # plugin's default one.
  # imap <silent> <C-K> <Plug>(linefeed-goup)
  # imap <silent> <C-G>k <Plug>(linefeed-up)
  # imap <silent> <C-G><C-K> <Plug>(linefeed-up)
  # imap <silent> <C-G><C-K> <Plug>(linefeed-up)
  # imap <silent> <C-J> <Plug>(linefeed-godown)
  # imap <silent> <C-G>j <Plug>(linefeed-down)
  # imap <silent> <C-G><C-J> <Plug>(linefeed-down)
enddef
# }}}

# vim-utils/vim-man {{{
def VimManPost()
  command! -nargs=* -bar -complete=customlist,man#completion#run M {
    Man <args>
  }

  VimManCommon()
enddef

def ManFallback()
  # NOTE: A recommended way to enable ":Man" command on vim help page is to
  # source a default man ftplugin by ":runtime ftplugin/man.vim" in vimrc.
  # However it sources other ftplugin files which probably have side-effects.
  # So exlicitly specify the default man ftplugin.
  try
    source $VIMRUNTIME/ftplugin/man.vim
  catch
    echoerr v:exception
    return
  endtry

  command! -nargs=+ -complete=shellcmd M {
    <mods> Man <args>
  }

  VimManCommon()
enddef

def VimManCommon()
  set keywordprg=:Man
enddef
# }}}

# machakann/vim-sandwich {{{
def VimSandwichPost()
  g:sandwich#recipes = get(g:, 'sandwich#recipes', deepcopy(g:sandwich#default_recipes))
  g:sandwich#recipes += [
    { buns: ['{ ', ' }'],
      nesting: 1,
      match_syntax: 1,
      kind: ['add', 'replace'],
      action: ['add'],
      input: ['}']
    },
    { buns: ['[ ', ' ]'],
      nesting: 1,
      match_syntax: 1,
      kind: ['add', 'replace'],
      action: ['add'],
      input: [']']
    },
    { buns: ['( ', ' )'],
      nesting: 1,
      match_syntax: 1,
      kind: ['add', 'replace'],
      action: ['add'],
      input: [')']
    },
    { buns: ['{\s*', '\s*}'],
      nesting: 1,
      regex: 1,
      match_syntax: 1,
      kind: ['delete', 'replace', 'textobj'],
      action: ['delete'],
      input: ['}']
    },
    { buns: ['\[\s*', '\s*\]'],
      nesting: 1,
      regex: 1,
      match_syntax: 1,
      kind: ['delete', 'replace', 'textobj'],
      action: ['delete'],
      input: [']']
    },
    { buns: ['(\s*', '\s*)'],
      nesting: 1,
      regex: 1,
      match_syntax: 1,
      kind: ['delete', 'replace', 'textobj'],
      action: ['delete'],
      input: [')']
    }
  ]
enddef
# }}}

# liuchengxu/vista.vim {{{
def VistaVimPre()
  g:vista_no_mappings = 1

  augroup vimrc:vista
    autocmd!
    autocmd FileType vista,vista_kind {
      nnoremap <buffer><silent> q :<C-U>Vista!!<CR>
    }
  augroup END

  nnoremap <silent> <Leader>v :<C-U>Vista!!<CR>
enddef
# }}}

# itchyny/screensaver.vim {{{
def ScreensaverVimPost()
  augroup vimrc:screensaver
    autocmd!
    # Clear the cmdline area when starting a screensaver.
    autocmd FileType screensaver {
      echo
    }
  augroup END
enddef
# }}}

# bronson/vim-trailing-whitespace {{{
def VimTrailingWhitespacePost()
  g:extra_whitespace_ignored_filetypes = get(g:, 'extra_whitespace_ignored_filetypes', [])
  g:extra_whitespace_ignored_filetypes += ['screensaver']
enddef
# }}}

# girishji/vimbits {{{
def VimbitsPre()
  g:vimbits_highlightonyank = false
  g:vimbits_easyjump = false
  g:vimbits_fFtT = true
  g:vimbits_vim9cmdline = false
enddef
# }}}

# lambdalisue/fern.vim {{{
def FernVimPre()
  g:fern#default_hidden = 1
  g:fern#default_exclude = '.*\~$'

  command! -bar ToggleFern {
    ToggleFern()
  }

  augroup vimrc:fern
    autocmd!
    autocmd Filetype fern {
      t:fern_buffer_id = bufnr()
    }
    autocmd BufLeave * {
      if &ft !=# 'fern'
        t:non_fern_buffer_id = bufnr()
      endif
    }
    autocmd DirChanged * {
      unlet! t:fern_buffer_id
    }
  augroup END

  command! CurrentFernLogging {
    echo FernLogFile()
  }
  command! -nargs=* -complete=file EnableFernLogging {
    g:fern#logfile = empty(<q-args>) ? '$VIMHOME/tmp/fern.tsv' : <q-args>
  }
  command! DisableFernLogging {
    g:fern#logfile = null
  }
  command! FernLogDebug {
    g:fern#loglevel = g:fern#DEBUG
  }
  command! FernLogInfo {
    g:fern#loglevel = g:fern#INFO
  }
  command! FernLogWARN {
    g:fern#loglevel = g:fern#WARN
  }
  command! FernLogError {
    g:fern#loglevel = g:fern#Error
  }

  command! -nargs=+ -complete=shellcmd RunWithFernLog {
    RunWithFernLog(<q-args>)
  }
enddef

def FernVimFallback()
  unlet g:loaded_netrw
  unlet g:loaded_netrwPlugin

  nnoremap <silent> <Leader>n :<C-U>ToggleNetrw<CR>
  nnoremap <silent> <Leader>N :<C-U>ToggleNetrw!<CR>
enddef

# Toggle a fern buffer to keep the cursor position. A tab should only have
# one fern buffer.
def ToggleFern()
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
enddef

def FernLogFile(): string
  return get(g:, 'fern#logfile', null)
enddef

def RunWithFernLog(template: string)
  const log = FernLogFile()

  if filereadable(log)
    term_start([&shell, &shellcmdflag, printf(template, log)], { term_finish: 'close' })
  endif
enddef
# }}}

# a5ob7r/fern-renderer-lsflavor.vim {{{
def FernRendererLsflavorVimPre()
  g:fern#renderer = 'lsflavor'
enddef
# }}}

# lambdalisue/gin.vim {{{
def GinVimPost()
  g:gin_diff_persistent_args = ['--patch', '--stat']

  if executable('delta')
    g:gin_diff_persistent_args += ['++processor=delta --color-only']
  elseif executable('diff-highlight')
    g:gin_diff_persistent_args += ['++processor=diff-highlight']
  endif

  # Add a number argument to limit the number of commits because ":GinLog"
  # is too slow in a large repository.
  #
  # https://github.com/lambdalisue/gin.vim/issues/116
  nmap <silent> <Leader>gl :<C-U>GinLog --graph --oneline --all -500<CR>
  nmap <silent> <Leader>gs :<C-U>GinStatus<CR>
  nmap <silent> <Leader>gb <Cmd>GinBranch<CR>
  nmap <silent> <Leader>gc :<C-U>Gin commit<CR>

  augroup vimrc:gin
    autocmd!
    autocmd BufReadCmd gin{branch,diff,edit,log,status,}://* {
      setlocal nobuflisted
    }
  augroup END
enddef
# }}}

# Shougo/ddu.vim {{{
def DduVimPost()
  ddu#custom#patch_global({
    ui: 'ff',
    sources: ['file_rec'],
    sourceOptions: {
      _: {
        matchers: ['matcher_fzy'],
      },
    },
    kindOptions: {
      file: {
        defaultAction: 'open',
      },
    },
  })

  ddu#custom#action('kind', 'file', 'tcd', (args) => {
    execute $'tcd {args.items[0].action.path}'

    return 0
  })

  nnoremap <silent> <C-Space> <ScriptCmd>ddu#start()<CR>

  nnoremap <silent> <Leader>b <ScriptCmd>ddu#start({ sources: ['buffer'] })<CR>
  nnoremap <silent> <Leader>gq <ScriptCmd>ddu#start({ sources: ['ghq'], kindOptions: { file: { defaultAction: 'tcd' } } })<CR>

  augroup vimrc:ddu
    autocmd!

    autocmd FileType ddu-ff {
      nnoremap <buffer><silent> <CR> <ScriptCmd>ddu#ui#do_action('itemAction')<CR>
      nnoremap <buffer><silent> <C-X> <ScriptCmd>ddu#ui#do_action('itemAction', { name: 'open', params: { command: 'split' } })<CR>
      nnoremap <buffer><silent> i <ScriptCmd>ddu#ui#do_action('openFilterWindow')<CR>
      nnoremap <buffer><silent> q <ScriptCmd>ddu#ui#do_action('quit')<CR>
    }
  augroup END
enddef
# }}}

# Einenlum/yaml-revealer {{{
def YamlRevealerPost()
  command! SearchYamlKey {
    SearchYamlKey()
  }
enddef
# }}}

# yegappan/lsp {{{
def LspPre()
  augroup vimrc:lsp
    autocmd!

    autocmd User LspSetup {
      SetLspOptions()
    }

    autocmd User LspAttached {
      nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
      nnoremap <buffer> gD <Cmd>LspGotoImpl<CR>
    }
  augroup END
enddef

def SetLspOptions()
  g:LspOptionsSet({
    autoPopulateDiags: true,
  })
enddef
# }}}
# }}}

# Plugin registrations. {{{
maxpac.Begin()

# NOTE: Call this as soon as possible!
# NOTE: Maybe "+clientserver" is disabled in macOS even if a Vim is compiled
# with "--with-features=huge".
if has('clientserver')
  maxpac.Add('thinca/vim-singleton', { post: VimSingletonPost })
endif

maxpac.Add('a5ob7r/lightline-otf')
maxpac.Add('itchyny/lightline.vim', { pre: LightlineVimPre })

maxpac.Add('hrsh7th/vim-vsnip', { pre: VimVsnipPre, post: VimVsnipPost })
maxpac.Add('hrsh7th/vim-vsnip-integ')
maxpac.Add('rafamadriz/friendly-snippets')

maxpac.Add('lambdalisue/fern.vim', { pre: FernVimPre, fallback: FernVimFallback })
maxpac.Add('lambdalisue/fern-hijack.vim')
maxpac.Add('lambdalisue/fern-git-status.vim')
maxpac.Add('a5ob7r/fern-renderer-lsflavor.vim', { pre: FernRendererLsflavorVimPre })

# Operators.
maxpac.Add('kana/vim-operator-user')
maxpac.Add('kana/vim-operator-replace', { post: VimOperatorReplacePost })

maxpac.Add('kyoh86/vim-ripgrep', { post: VimRipgrepPost })

# Text objects.
maxpac.Add('kana/vim-textobj-user')

maxpac.Add('D4KU/vim-textobj-chainmember')
maxpac.Add('Julian/vim-textobj-variable-segment')
maxpac.Add('deris/vim-textobj-enclosedsyntax')
maxpac.Add('kana/vim-textobj-datetime')
maxpac.Add('kana/vim-textobj-entire')
maxpac.Add('kana/vim-textobj-indent')
maxpac.Add('kana/vim-textobj-line')
maxpac.Add('kana/vim-textobj-syntax')
maxpac.Add('mattn/vim-textobj-url')
maxpac.Add('osyo-manga/vim-textobj-blockwise')
maxpac.Add('saaguero/vim-textobj-pastedtext')
maxpac.Add('sgur/vim-textobj-parameter')
maxpac.Add('thinca/vim-textobj-comment')

maxpac.Add('machakann/vim-textobj-delimited')
maxpac.Add('machakann/vim-textobj-functioncall')

# Misc.
maxpac.Add('Einenlum/yaml-revealer', { post: YamlRevealerPost })
maxpac.Add('Eliot00/git-lens.vim', { post: GitlensVimPost })
maxpac.Add('KeitaNakamura/neodark.vim', { post: NeodarkVimPost })
maxpac.Add('LumaKernel/coqpit.vim')
maxpac.Add('a5ob7r/chmod.vim')
maxpac.Add('a5ob7r/linefeed.vim', { post: LinefeedVimPost })
maxpac.Add('a5ob7r/rspec-daemon.vim')
maxpac.Add('a5ob7r/shellcheckrc.vim', { pre: ShellcheckrcVimPre })
maxpac.Add('a5ob7r/tig.vim')
maxpac.Add('airblade/vim-gitgutter', { pre: VimGitgutterPre })
maxpac.Add('aliou/bats.vim')
maxpac.Add('andymass/vim-matchup', { fallback: VimMatchupFallback })
maxpac.Add('azabiong/vim-highlighter')
maxpac.Add('bronson/vim-trailing-whitespace', { post: VimTrailingWhitespacePost })
maxpac.Add('chrisbra/csv.vim')
maxpac.Add('fladson/vim-kitty')
maxpac.Add('girishji/vimbits', { pre: VimbitsPre }) # For ":h vimtips".
maxpac.Add('gpanders/vim-oldfiles')
maxpac.Add('haya14busa/vim-asterisk', { post: VimAsteriskPost })
maxpac.Add('itchyny/screensaver.vim', { post: ScreensaverVimPost })
maxpac.Add('junegunn/goyo.vim')
maxpac.Add('junegunn/vader.vim')
maxpac.Add('junegunn/vim-easy-align')
maxpac.Add('k-takata/minpac', { post: MinpacPost })
maxpac.Add('kannokanno/previm')
maxpac.Add('kchmck/vim-coffee-script')
maxpac.Add('keith/rspec.vim')
maxpac.Add('lambdalisue/gina.vim', { post: GinaVimPost })
maxpac.Add('lambdalisue/vital-Whisky')
maxpac.Add('liuchengxu/vista.vim', { pre: VistaVimPre })
maxpac.Add('machakann/vim-highlightedyank')
maxpac.Add('machakann/vim-sandwich', { post: VimSandwichPost })
maxpac.Add('machakann/vim-swap')
maxpac.Add('maximbaz/lightline-ale')
maxpac.Add('monaqa/modesearch.vim', { post: ModesearchVimPost })
maxpac.Add('neovimhaskell/haskell-vim')
maxpac.Add('pocke/rbs.vim')
maxpac.Add('preservim/vim-markdown', { pre: VimMarkdownPre })
maxpac.Add('rhysd/git-messenger.vim', { post: GitMessengerVimPost })
maxpac.Add('thinca/vim-localrc', { post: VimLocalrcPost })
maxpac.Add('thinca/vim-prettyprint')
maxpac.Add('thinca/vim-themis')
maxpac.Add('tpope/vim-endwise')
maxpac.Add('tyru/eskk.vim')
maxpac.Add('tyru/open-browser.vim')
maxpac.Add('vim-jp/vital.vim')
maxpac.Add('vim-utils/vim-man', { post: VimManPost })
maxpac.Add('w0rp/ale', { pre: AlePre })
maxpac.Add('yasuhiroki/github-actions-yaml.vim')
maxpac.Add('yegappan/lsp', { pre: LspPre })
maxpac.Add('zorab47/procfile.vim')

if IsBundledPackageLoadable('comment')
  # "comment.vim" package is bundled since 5400a5d4269874fe4f1c35dfdd3c039ea17dfd62.
  packadd! comment
else
  maxpac.Add('tpope/vim-commentary')
endif

# =============================================================================

# denops.vim

if executable('deno')
  maxpac.Add('vim-denops/denops.vim')

  maxpac.Add('lambdalisue/gin.vim', { post: GinVimPost })

  maxpac.Add('Shougo/ddu.vim', { post: DduVimPost })

  maxpac.Add('Shougo/ddu-ui-ff')

  maxpac.Add('4513ECHO/ddu-source-ghq')
  maxpac.Add('Shougo/ddu-source-file_rec')
  maxpac.Add('shun/ddu-source-buffer')

  maxpac.Add('matsui54/ddu-filter-fzy')

  maxpac.Add('Shougo/ddu-kind-file')
endif

maxpac.End()
# }}}
# }}}

# Filetypes {{{
filetype off
filetype plugin indent off
filetype plugin indent on
# }}}

# Syntax {{{
syntax off
syntax enable
# }}}

# Fire VimEnter manually on reload {{{
if !has('vim_starting')
  doautocmd <nomodeline> VimEnter
endif
# }}}

# =============================================================================

# vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
