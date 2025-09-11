vim9script

#
# vimrc
#
# - The minimal requirement version is 9.1.1391 with default huge features.
# - Nowadays we are always in UTF-8 environment, aren't we?
# - Work well even if no (non-default) plugin is installed.
# - Support Unix and Windows.
#

import autoload 'maxpac.vim'

# =============================================================================

# Functions {{{
# Get syntax item information at a position.
#
# https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
def SyntaxItemAttribute(line: number, column: number): string
  const item_id = synID(line, column, 1)
  const trans_item_id = synID(line, column, 0)

  const hi = synIDattr(item_id, 'name')
  const trans = synIDattr(trans_item_id, 'name')
  const lo = synIDattr(synIDtrans(item_id), 'name')

  return $'hi<{hi}> trans<{trans}> lo<{lo}>'
enddef

# Join and normalize filepaths.
def Pathjoin(...paths: list<string>): string
  const sep = has('win32') ? '\\' : '/'
  return join(paths, sep)->simplify()->substitute(printf('^\.%s', sep), '', '')
enddef

def Terminal()
  const parent_directory = empty(&buftype) ? expand('%:p:h') : ''
  const cwd = parent_directory ?? getcwd()

  term_start(&shell, {
    cwd: cwd,
    term_finish: 'close'
  })
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

  return $TERM_PROGRAM !=# 'Apple_Terminal' && &term !=# 'linux'
enddef

# Define a simple command to open a specific file using ":DefineOpener".
def! g:DefineOpener(name: string, filename: string)
  const lines =<< trim eval END
    command! -bang -bar {name} {{
      <mods> OpenHelper<bang> {filename}
    }}
  END

  execute join(lines, "\n")
enddef

def g:TabPanel(): string
  return FormatTabPanel(g:actual_curtabpage)
enddef

# +---------------+----------------------------------
# |(1)            |text text text text text text text
# |* ~/foo.txt    |text text text text text text text
# |  /a/b/bar.txt |text text text text text text text
# |(2)            |text text text text text text text
# |  ~/.c/v/vimrc |text text text text text text text
def FormatTabPanel(actual_curtabpage: number): string
  const buffers = tabpagebuflist(actual_curtabpage)->map((_k, v) => {
    const marker = bufwinnr(v) == winnr() ? '*' : ' '
    const name = bufname(v)->fnamemodify(':~')->pathshorten()

    return $"{marker} {name}"
  })

  return $"({g:actual_curtabpage})\n{buffers->join("\n")}"
enddef

# XDG Base Directory Specification
#
# https://specifications.freedesktop.org/basedir-spec/latest/
def XdgCacheHome(): string
  return $XDG_CACHE_HOME ?? $'{$HOME}/.cache'
enddef
# }}}

# Options {{{
set autoindent smartindent
set autoread
set breakindent breakindentopt=shift:2,sbr
set cdhome
set colorcolumn=81,101,121
set completeopt=menuone,longest,popup,fuzzy
set cursorline
set display=lastline
set fileformats=unix,dos,mac
set hidden
set history=10000
set hlsearch
set ignorecase smartcase
set incsearch
set keywordprg=:Man
set laststatus=2
set list listchars+=tab:>\ \|,extends:>,precedes:<
set nrformats-=octal nrformats+=unsigned
set pastetoggle=<F12>
set ruler
set scrolloff=5
set shortmess-=S
set showcmd
set showmatch
set smoothscroll
set spelllang+=cjk
set spelloptions+=camel
set tabclose=left
set tabpanel=%!TabPanel()
set tabpanelopt=columns:30,vert
set virtualedit=block
set wildmenu wildoptions+=pum,fuzzy
set wildmode=longest:full,full

if IsInTruecolorSupportedTerminal()
  set termguicolors
endif

# Maybe SKK dictionaries are encoded by "euc-jp".
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1

# Strings that start with '>' isn't compatible with the block quotation syntax
# of markdown.
set showbreak=+++\ 

if has('win32') || has('osxdarwin')
  set clipboard=unnamed
elseif has('X11')
  set clipboard-=autoselect

  if exists('$XTERM_VERSION')
    # See "x11-cut-buffer".
    set clipboard^=unnamed
  else
    set clipboard^=unnamedplus
  endif
endif

if has('gui_running')
  set guioptions+=M
endif

# Keep other window sizes when opening/closing new windows.
set noequalalways

# Prefer single space rather than double them for text joining.
set nojoinspaces

# Stop at a TOP or BOTTOM match even if hitting "n" or "N" repeatedly.
set nowrapscan

{
  # Create temporary files(backup, swap, undo) under secure locations to avoid
  # CVE-2017-1000382.
  #
  # https://github.com/archlinux/svntogit-packages/blob/68635a69f0c5525210adca6ff277dc13c590399b/trunk/archlinux.vim#L22
  const vim_cache_home = $'{XdgCacheHome()}/vim'

  &backupdir = $'{vim_cache_home}/backup//'
  &directory = $'{vim_cache_home}/swap//'
  &undodir = $'{vim_cache_home}/undo//'
}

silent expand(&backupdir)->mkdir('p', 0o700)
silent expand(&directory)->mkdir('p', 0o700)
silent expand(&undodir)->mkdir('p', 0o700)
# }}}

# Key mappings {{{
# "<Leader>" is replaced with the value of "g:mapleader" when define a
# keymapping, so we must define this variable before the mapping definition.
g:mapleader = ' '

# Use "Q" as the typed key recording starter and the terminator instead of
# "q".
noremap Q q
noremap q <Nop>

# Do not anything even if type "<F1>". I sometimes mistype it instead of
# typing "<ESC>".
noremap <F1> <Nop>
noremap! <F1> <Nop>

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

xnoremap <expr> j mode() ==# 'V' ? 'j' : 'gj'
xnoremap <expr> k mode() ==# 'V' ? 'k' : 'gk'

map Y y$

# Change the current window height instantly.
nnoremap + <C-W>+
nnoremap - <C-W>-

# A shortcut to complete filenames.
inoremap <C-F> <C-X><C-F>

# Quit Visual mode.
xnoremap <C-L> <Esc>

# This is required for "term_start()" without "{ 'term_finish': 'close' }".
nnoremap <expr> <CR>
  \ &buftype ==# 'terminal' && bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? "<Cmd>bdelete<CR>"
  \ : "<Plug>(newline)"

# Delete finished terminal buffers by "<CR>", this behavior is similar to
# Neovim's builtin terminal.
tnoremap <expr> <CR>
  \ bufnr()->term_getjob()->job_status() ==# 'dead'
  \ ? "<Cmd>bdelete<CR>"
  \ : "<CR>"

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

# Browse quickfix/location lists by "<C-N>" and "<C-P>".
nnoremap <C-N> <Cmd>execute $'{v:count1}cnext'<CR>
nnoremap <C-P> <Cmd>execute $'{v:count1}cprevious'<CR>
nnoremap g<C-N> <Cmd>execute $'{v:count1}lnext'<CR>
nnoremap g<C-P> <Cmd>execute $'{v:count1}lprevious'<CR>
nnoremap <C-G><C-N> <Cmd>execute $'{v:count1}lnext'<CR>
nnoremap <C-G><C-P> <Cmd>execute $'{v:count1}lprevious'<CR>

# Clear the highlightings for pattern searching and run a command to refresh
# something.
nnoremap <C-L> <Cmd>nohlsearch<CR><Cmd>Refresh<CR>

noremap <C-C> <Cmd>Interrupt<CR><C-C>
inoremap <C-C> <Cmd>Interrupt<CR><C-C>
cnoremap <C-C> <Cmd>Interrupt<CR><C-C>

nnoremap <F10> <ScriptCmd>echo SyntaxItemAttribute(line('.'), col('.'))<CR>

nnoremap <C-S> <Cmd>update<CR>
inoremap <C-S> <Cmd>update<CR>

nnoremap <Leader>t <Cmd>tabnew<CR>

# Like default configurations of Tmux.
nnoremap <Leader>" <Cmd>terminal<CR>
nnoremap <Leader>g" <ScriptCmd>Terminal()<CR>
nnoremap <Leader>% <Cmd>vertical terminal<CR>
nnoremap <Leader>g% <ScriptCmd>vertical Terminal()<CR>

tnoremap <C-W><Leader>" <Cmd>terminal<CR>
tnoremap <C-W><Leader>g" <ScriptCmd>Terminal()<CR>
tnoremap <C-W><Leader>% <Cmd>vertical terminal<CR>
tnoremap <C-W><Leader>g% <ScriptCmd>vertical Terminal()<CR>

nnoremap <silent> <Leader>y :YankComments<CR>
xnoremap <silent> <Leader>y :YankComments<CR>

# Maximize or minimize the current window.
nnoremap <C-W>m <Cmd>resize 0<CR>
nnoremap <C-W>Vm <Cmd>vertical resize 0<CR>
nnoremap <C-W>gm <Plug>(xminimize)

nnoremap <C-W>M <Cmd>resize<CR>
nnoremap <C-W>VM <Cmd>vertical resize<CR>

tnoremap <C-W>m <Cmd>resize 0<CR>
tnoremap <C-W>Vm <Cmd>vertical resize 0<CR>
tnoremap <C-W>gm <Plug>(xminimize)

tnoremap <C-W>M <Cmd>resize<CR>
tnoremap <C-W>VM <Cmd>vertical resize<CR>

# NOTE: "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and
# the "SPACE" one at once if in some terminal emulators.
nmap <Nul> <C-Space>

nnoremap <C-W><BS> <Cmd>Bdelete<CR>
nnoremap <C-W>g<BS> <Cmd>bdelete<CR>

nnoremap <Leader>n <Cmd>ToggleNetrw<CR>
nnoremap <Leader>N <Cmd>ToggleNetrw!<CR>
# }}}

# Commands {{{
# A helper command to open a file in a split window, or the current one (if it
# is invoked with a bang mark).
command! -bang -bar -nargs=1 -complete=file OpenHelper {
  const opener = <bang>1 ? 'split' : 'edit'

  execute <q-mods> opener <q-args>
}

g:DefineOpener('Vimrc', $MYVIMRC)

command! ReloadVimrc {
  source $MYVIMRC
}

# Run commands to refresh something.
command! Refresh {
  doautocmd <nomodeline> User Refresh
}

command! Interrupt {
  doautocmd <nomodeline> User Interrupt
}

command! Hitest {
  source $VIMRUNTIME/syntax/hitest.vim
}

command! XReconnect {
  set clipboard^=unnamedplus
  xrestore
}
command! XDisconnect {
  set clipboard-=unnamedplus
}

command! ToggleTabpanel {
  if &showtabpanel == 0
    set showtabpanel=2
    set showtabline=0
  else
    set showtabpanel=0
    set showtabline=1
  endif
}
# }}}

# Auto commands {{{
augroup vimrc:OpenQuickFixWindow
  autocmd!
  autocmd QuickFixCmdPost {,vim,help}grep*,make {
    cwindow
  }
  autocmd QuickFixCmdPost l{,vim,help}grep*,lmake {
    lwindow
  }
augroup END

augroup vimrc:MakeParentDirectories
  autocmd!
  # Make parent directories of the file which the written buffer is corresponing
  # if these directories are missing.
  autocmd BufWritePre * {
    silent expand('<afile>:p:h')->mkdir('p')
  }
augroup END

augroup vimrc:NoExtrasOnTerminalNormalMode
  autocmd!
  # Hide extras on Terminal-Normal mode.
  #
  # See "options-in-terminal" to set options for non-hidden and hidden terminal
  # windows for more details.
  autocmd TerminalWinOpen * {
    setlocal nolist nonumber colorcolumn=
  }
  autocmd TerminalOpen * {
    autocmd BufWinEnter <buffer=abuf> ++once doautocmd vimrc:NoExtrasOnTerminalNormalMode TerminalWinOpen *
  }
augroup END

augroup vimrc:Undoable
  autocmd!
  autocmd BufReadPre ~/* {
    setlocal undofile
  }
augroup END

augroup vimrc:RestoreCursor
  autocmd!
  # See "restore-cursor".
  autocmd BufReadPost * {
    const line = line("'\"")

    if line >= 1
        && line <= line("$")
        && &filetype !~# 'commit'
        && index(['xxd', 'gitrebase'], &filetype) == -1
      execute "normal! g`\""
    endif
  }
augroup END

augroup vimrc:refresh:Redraw
  autocmd!
  autocmd User Refresh redraw
augroup END
# }}}

# Standard plugins {{{
# Avoid loading some standard plugins. {{{
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

# ":Man" {{{
# NOTE: A recommended way to enable ":Man" command on vim help page is to
# source a default man ftplugin by ":runtime ftplugin/man.vim" in vimrc.
# However it sources other ftplugin files which probably have side-effects.
# So exlicitly specify the default man ftplugin.
source $VIMRUNTIME/ftplugin/man.vim
# }}}
# }}}

# Bundled plugins {{{
packadd! comment
packadd! editorconfig
packadd! hlyank
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
    const plugname = maxpac.Plugname(<q-args>)
    const pluginfo = minpac#getpluginfo(plugname)

    term_start(&shell, { cwd: pluginfo['dir'], term_finish: 'close' })
  }
enddef

def MinpacFallback()
  command! InstallMinpac {
    # A root directory path of vim packages.
    const packhome = simplify($'{$MYVIMDIR}/pack')

    const repository = 'https://github.com/k-takata/minpac.git'
    const directory =  $'{packhome}/minpac/opt/minpac'

    const command = $'git clone {repository} {directory}'

    execute 'terminal' command
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
        ['mode', 'binary', 'paste'],
        ['readonly', 'relativepath', 'modified'],
        ['linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok'],
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

  augroup vimrc:refresh:UpdateLightline
    autocmd!
    autocmd User Refresh lightline#update()
  augroup END
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

# rhysd/git-messenger.vim {{{
def GitMessengerVimPost()
  g:git_messenger_include_diff = 'all'
  g:git_messenger_always_into_popup = true
  g:git_messenger_max_popup_height = 15
enddef
# }}}

# hrsh7th/vim-vsnip {{{
def VimVsnipPre()
  g:vsnip_snippet_dir = simplify($'{$MYVIMDIR}/vsnip')
enddef

def VimVsnipPost()
  inoremap <expr> <Tab>
    \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
    \ vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
  snoremap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  inoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
  snoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
enddef
# }}}

# kana/vim-operator-replace {{{
def VimOperatorReplacePost()
  noremap _ <Plug>(operator-replace)
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
  augroup vimrc:interrupt:ripgrep
    autocmd!
    autocmd User Interrupt {
      ripgrep#stop()
    }
  augroup END

  ripgrep#observe#add_observer(g:ripgrep#event#other, 'RipgrepContextObserver')

  command! -bang -count -nargs=+ -complete=customlist,RgComplete Rg {
    const arguments = RgArgsParser.new(<q-args>, { filename_expand: true }).Call()
      ->copy()
      ->map((_, arg) => arg.Value())

    Ripgrep(['-C<count>'] + arguments, { case: <bang>1, escape: <bang>1 })
  }

  noremap <Leader>f <Plug>(operator-ripgrep-g)
  noremap g<Leader>f <Plug>(operator-ripgrep)

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
    # Escape the strings for "string" type of "{command}" of "job_start()".
    arguments += copy(args)->map(( _, val) => escape(val, ' "\'))
  else
    arguments += args
  endif

  ripgrep#search(join(arguments))
enddef

def RgComplete(ArgLead: string, CmdLine: string, CursorPos: number): list<string>
  const cmd_line_lead = slice(CmdLine, 0, CursorPos)
  const args = RgCmdLineParser.new(cmd_line_lead).Call()

  const last_arg_typename = empty(args) ? null_string : typename(args[-1])
  const is_cursor_at_filename =
       last_arg_typename ==# 'object<RgFilenameArg>'
    || empty(ArgLead) && last_arg_typename ==# 'object<RgPatternArg>'

  if is_cursor_at_filename
    return getcompletion(ArgLead, 'file')
  else
    return []
  endif
enddef

abstract class RgArg
  var value: string

  def Value(): string
    return this.value
  enddef
endclass

class RgModifierArg extends RgArg
  def new(this.value)
  enddef
endclass

class RgCommandArg extends RgArg
  def new(this.value)
  enddef
endclass

class RgOptionArg extends RgArg
  def new(this.value)
  enddef
endclass

class RgDoubleHyphensArg extends RgArg
  def new(this.value)
  enddef
endclass

class RgPatternArg extends RgArg
  def new(this.value)
  enddef
endclass

class RgFilenameArg extends RgArg
  def new(this.value)
  enddef

  def Expand(): RgFilenameArg
    this.value = expand(this.value)

    return this
  enddef
endclass

def StripLeadingWhitespaces(s: string): string
  return substitute(s, '^\s\+', '', '')
enddef

class RgCmdLineParser
  const cmd_line: string

  def new(this.cmd_line)
  enddef

  def Call(): list<object<RgArg>>
    var matched: string
    var start: number
    var end: number

    var modifiers: list<object<RgModifierArg>> = []
    var commands: list<object<RgCommandArg>> = []
    var arguments: list<object<RgArg>> = []

    var remains = StripLeadingWhitespaces(this.cmd_line)

    [modifiers, remains] = this._ParseModifiers(remains)
    [commands, remains] = this._ParseCommand(remains)
    [arguments, _] = this._ParseArguments(remains)

    return modifiers + commands + arguments
  enddef

  def _ParseModifiers(s: string): tuple<list<object<RgModifierArg>>, string>
    const [matched, _, end] = matchstrpos(s, '\C^\%([[:space:]:]*\<[a-z]\+\>\)\+')
    const modifiers = split(matched, '[[:space:]:]\+')->map((_, modifier) => RgModifierArg.new(modifier))
    const remains = end == -1 ? s : s[end :]

    return (modifiers, remains)
  enddef

  def _ParseCommand(s: string): tuple<list<object<RgCommandArg>>, string>
    const stripped = substitute(s, '^[[:space:]:]*', '', '')
    const [matched, _, end] = matchstrpos(stripped, $'\C^[,;.$%+0-9]*[[:space:]:]*[A-Z][a-zA-Z0-9]*!\=')
    const command = RgCommandArg.new(matched)

    return ([command], stripped[end :])
  enddef

  def _ParseArguments(s: string): tuple<list<object<RgArg>>, string>
    const stripped = StripLeadingWhitespaces(s)

    return (RgArgsParser.new(stripped).Call(), '')
  enddef
endclass

# :Rg -w --ignore-case foo
# :Rg the\ .\"\'word\\ vimrc gvimrc
# :Rg "\\ \"word \\bthe\\b . \\" vimrc
# :Rg '\bthe\b \. ''\\\' vimrc
class RgArgsParser
  const args: string
  const o_filename_expand: bool

  def new(this.args, opts = {})
    this.o_filename_expand = get(opts, 'filename_expand', false)
  enddef

  def Call(): list<object<RgArg>>
    final arguments: list<object<RgArg>> = []

    var double_hyphens_found = false
    var pattern_found = false

    var word: string
    var remains = this._SplitIntoWords(this.args)

    while !empty(remains)
      [word; remains] = remains

      if !double_hyphens_found && word ==# '--'
        double_hyphens_found = true
        add(arguments, RgDoubleHyphensArg.new(word))
      elseif !double_hyphens_found && word =~# '^-'
        add(arguments, RgOptionArg.new(word))
      else
        if pattern_found
          add(arguments, this.o_filename_expand ? RgFilenameArg.new(word).Expand() : RgFilenameArg.new(word))
        else
          pattern_found = true
          add(arguments, RgPatternArg.new(word))
        endif
      endif
    endwhile

    return arguments
  enddef

  def _SplitIntoWords(s: string): list<string>
    var remains = StripLeadingWhitespaces(s)

    final args = []

    var matched: string
    var end: number

    while !empty(remains)
      if remains[0] ==# '"'
        [matched, _, end] = matchstrpos(remains, '^""\|^"[^\\"]*"\|^"\%([^\\"]*\\.[^\\"]*\)\{-}"')

        if end == -1
          add(args, remains)
          remains = ''
        else
          add(args, slice(matched, 1, -1)->substitute('\\\(.\)', '\1', 'g'))
          remains = StripLeadingWhitespaces(remains[end :])
        endif
      elseif remains[0] ==# "'"
        [matched, _, end] = matchstrpos(remains, '^''\%([^'']*\%(''''\)\=\)\+''')

        if end == -1
          add(args, remains)
          remains = ''
        else
          add(args, slice(matched, 1, -1)->substitute("''", "'", 'g'))
          remains = StripLeadingWhitespaces(remains[end :])
        endif
      else
        [matched, _, end] = matchstrpos(remains, '\%(\\.\|\S\)\+')
        add(args, matched)
        remains = StripLeadingWhitespaces(remains[end :])
      endif
    endwhile

    return args
  enddef
endclass

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

  final words = ['Rg', '-F']

  if o_boundaries
    add(words, '-w')
  endif

  const [_l_bufnum, l_lnum, l_col, _l_off] = getcharpos("'[")
  const [_r_bufnum, r_lnum, r_col, _r_off] = getcharpos("']")

  const l_col_idx = l_col - 1
  const r_col_idx = r_col - (&selection ==# 'inclusive' ? 1 : 2)

  const buflines =
    motion_wiseness ==# 'block' ? bufname('%')->getbufline(l_lnum, r_lnum)->map((_, val) => val[l_col_idx : r_col_idx]) :
    motion_wiseness ==# 'line' ? bufname('%')->getbufline(l_lnum, r_lnum) :
    bufname('%')->getbufline(l_lnum)->map((_, val) => val[l_col_idx : r_col_idx])

  if match(buflines, '^\s*-') >= 0
    add(words, '--')
  endif

  if match(buflines, '[ "'']') >= 0
    add(words, $"'{copy(buflines)->map((_, val) => substitute(val, "'", "''", 'g'))->join("\n")}'")
  else
    add(words, join(buflines, "\n"))
  endif

  const cmdline = join(words)

  execute cmdline

  if o_highlight && motion_wiseness ==# 'char'
    @/ = o_boundaries ? printf('\V\<%s\>', escape(buflines[0], '\/')) : printf('\V%s', escape(buflines[0], '\/'))
  endif

  if o_push_history_entry
    histadd('cmd', cmdline)
  endif
enddef
# }}}

# haya14busa/vim-asterisk {{{
def VimAsteriskPost()
  # Keep the cursor offset while searching. See "search-offset".
  g:asterisk#keeppos = 1

  noremap * <Plug>(asterisk-z*)
  noremap # <Plug>(asterisk-z#)
  noremap g* <Plug>(asterisk-gz*)
  noremap g# <Plug>(asterisk-gz#)
  noremap z* <Plug>(asterisk-*)
  noremap z# <Plug>(asterisk-#)
  noremap gz* <Plug>(asterisk-g*)
  noremap gz# <Plug>(asterisk-g#)
enddef
# }}}

# monaqa/modesearch.vim {{{
def ModesearchVimPost()
  nnoremap g/ <Plug>(modesearch-slash-rawstr)
  nnoremap g? <Plug>(modesearch-question-regexp)
  cnoremap <C-x> <Plug>(modesearch-toggle-mode)
enddef
# }}}

# thinca/vim-localrc {{{
def VimLocalrcPost()
  command! -bang -bar VimrcLocal {
    OpenLocalrc(<q-bang>, <q-mods>, expand('~'))
  }
  command! -bang -bar -nargs=? -complete=dir OpenLocalrc {
    OpenLocalrc(<q-bang>, <q-mods>, <q-args> ?? expand('%:p:h'))
  }
enddef

def OpenLocalrc(bang: string, mods: string, dir: string)
  const localrc_filename = get(g:, 'localrc_filename', '.local.vimrc')
  const localrc_filepath = Pathjoin(dir, fnameescape(localrc_filename))

  execute $'{mods} OpenHelper{bang} {localrc_filepath}'
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
  # inoremap <C-K> <Plug>(linefeed-goup)
  # inoremap <C-G>k <Plug>(linefeed-up)
  # inoremap <C-G><C-K> <Plug>(linefeed-up)
  # inoremap <C-G><C-K> <Plug>(linefeed-up)
  # inoremap <C-J> <Plug>(linefeed-godown)
  # inoremap <C-G>j <Plug>(linefeed-down)
  # inoremap <C-G><C-J> <Plug>(linefeed-down)
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
      nnoremap <buffer> q <Cmd>Vista!!<CR>
    }
  augroup END

  nnoremap <Leader>v <Cmd>Vista!!<CR>
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
  nnoremap <Leader>gl <Cmd>GinLog --graph --oneline --all -500<CR>
  nnoremap <Leader>gs <Cmd>GinStatus<CR>
  nnoremap <Leader>gb <Cmd>GinBranch<CR>
  nnoremap <Leader>gc <Cmd>Gin commit<CR>

  augroup vimrc:gin
    autocmd!
    autocmd FileType gin {
      setlocal nomodeline
    }
    autocmd BufReadCmd gin{branch,diff,edit,log,status,}://* {
      setlocal nobuflisted

      nnoremap <buffer> q <Cmd>Close<CR>
    }
  augroup END
enddef
# }}}

# Shougo/ddu.vim {{{
def DduVimPost()
  ddu#custom#patch_global({
    kindOptions: {
      file: {
        defaultAction: 'open',
      },
    },
    sourceOptions: {
      _: {
        matchers: ['matcher_fzy'],
      },
    },
    ui: 'ff',
  })

  ddu#custom#patch_local('file', {
    sourceOptions: {
      file_rec: {
        defaultAction: 'mopen',
      },
    },
    sources: ['file_rec'],
  })

  ddu#custom#patch_local('buffer', {
    sourceOptions: {
      buffer: {
        defaultAction: 'mopen',
      },
    },
    sources: ['buffer'],
  })

  ddu#custom#patch_local('ghq', {
    actionParams: {
      execute: {
        command: 'tcd'
      },
    },
    sourceOptions: {
      ghq: {
        defaultAction: 'execute',
      },
    },
    sources: ['ghq'],
  })

  ddu#custom#action('kind', 'file', 'mopen', (args) => {
    foreach(args.items, (idx, item) => {
      const opener = idx == 0 ? 'edit' : 'split'

      execute opener item.action.path
    })

    return 0
  })

  nnoremap <C-Space> <ScriptCmd>ddu#start({ name: 'file' })<CR>
  nnoremap <Leader>b <ScriptCmd>ddu#start({ name: 'buffer' })<CR>
  nnoremap <Leader>gq <ScriptCmd>ddu#start({ name: 'ghq' })<CR>

  augroup vimrc:ddu
    autocmd!

    autocmd FileType ddu-ff {
      nnoremap <buffer> <CR> <ScriptCmd>ddu#ui#do_action('itemAction')<CR>
      nnoremap <buffer> <C-X> <ScriptCmd>ddu#ui#do_action('itemAction', { name: 'open', params: { command: 'split' } })<CR>
      nnoremap <buffer> i <ScriptCmd>ddu#ui#do_action('openFilterWindow')<CR>
      nnoremap <buffer> <Space> <ScriptCmd>ddu#ui#do_action('toggleSelectItem')<CR>
      nnoremap <buffer> q <ScriptCmd>ddu#ui#do_action('quit')<CR>
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
      AddLspServers()
    }

    autocmd User LspAttached {
      nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
      nnoremap <buffer> gD <Cmd>LspGotoImpl<CR>
    }
  augroup END
enddef

def SetLspOptions()
  g:LspOptionsSet({
    aleSupport: true,
    autoPopulateDiags: true,
    showDiagOnStatusLine: true,
    showDiagWithVirtualText: true,
  })
enddef

def AddLspServers()
  var servers = []

  if executable('bash-language-server')
    add(servers, {
      name: 'bash-language-server',
      filetype: ['sh'],
      path: 'bash-language-server',
      args: ['start'],
    })
  endif

  if executable('yaml-language-server')
    add(servers, {
      name: 'yaml-language-server',
      filetype: ['yaml'],
      path: 'yaml-language-server',
      args: ['--stdio'],
    })
  endif

  g:LspAddServer(servers)
enddef
# }}}

# dstein64/vim-startuptime {{{
def VimStartuptimePost()
  augroup vimrc:VimStartuptime
    autocmd!
    autocmd Filetype startuptime {
      nnoremap <buffer> q <Cmd>quit<CR>
    }
  augroup END
enddef
# }}}

# vim-denops/denops.vim {{{
def DenopsVimPost()
  # See "denops-recommended".
  augroup vimrc:interrupt:denops
    autocmd!
    autocmd User Interrupt {
      denops#interrupt()
    }
  augroup END

  command! DenopsRestart denops#server#restart()
  command! DenopsFixCache denops#cache#update({ reload: true })
enddef
# }}}

# bfrg/vim-qf-preview {{{
def VimQfPreviewPost()
  augroup vimrc:VimQfPreview
    autocmd!
    autocmd FileType qf {
      nnoremap <buffer> p <Plug>(qf-preview-open)
    }
  augroup END
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

# Operators.
maxpac.Add('kana/vim-operator-user')
maxpac.Add('kana/vim-operator-replace', { post: VimOperatorReplacePost })

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
maxpac.Add('Vftdan/vim-syntax-libconfig')
maxpac.Add('a5ob7r/chmod.vim')
maxpac.Add('a5ob7r/linefeed.vim', { post: LinefeedVimPost })
maxpac.Add('a5ob7r/rspec-daemon.vim')
maxpac.Add('a5ob7r/shellcheckrc.vim', { pre: ShellcheckrcVimPre })
maxpac.Add('a5ob7r/tig.vim')
maxpac.Add('airblade/vim-gitgutter', { pre: VimGitgutterPre })
maxpac.Add('aliou/bats.vim')
maxpac.Add('andymass/vim-matchup', { fallback: VimMatchupFallback })
maxpac.Add('azabiong/vim-highlighter')
maxpac.Add('bfrg/vim-qf-history')
maxpac.Add('bfrg/vim-qf-preview', { post: VimQfPreviewPost })
maxpac.Add('bronson/vim-trailing-whitespace', { post: VimTrailingWhitespacePost })
maxpac.Add('chrisbra/csv.vim')
maxpac.Add('dstein64/vim-startuptime', { post: VimStartuptimePost })
maxpac.Add('fladson/vim-kitty')
maxpac.Add('girishji/vimbits', { pre: VimbitsPre }) # For ":h vimtips".
maxpac.Add('gpanders/vim-oldfiles')
maxpac.Add('haya14busa/vim-asterisk', { post: VimAsteriskPost })
maxpac.Add('hrsh7th/vim-vsnip', { pre: VimVsnipPre, post: VimVsnipPost })
maxpac.Add('hrsh7th/vim-vsnip-integ')
maxpac.Add('itchyny/screensaver.vim', { post: ScreensaverVimPost })
maxpac.Add('junegunn/goyo.vim')
maxpac.Add('junegunn/vader.vim')
maxpac.Add('junegunn/vim-easy-align')
maxpac.Add('k-takata/minpac', { post: MinpacPost, fallback: MinpacFallback })
maxpac.Add('kannokanno/previm')
maxpac.Add('kchmck/vim-coffee-script')
maxpac.Add('keith/rspec.vim')
maxpac.Add('kyoh86/vim-ripgrep', { post: VimRipgrepPost })
maxpac.Add('lambdalisue/vital-Whisky')
maxpac.Add('liuchengxu/vista.vim', { pre: VistaVimPre })
maxpac.Add('machakann/vim-sandwich', { post: VimSandwichPost })
maxpac.Add('machakann/vim-swap')
maxpac.Add('maximbaz/lightline-ale')
maxpac.Add('monaqa/modesearch.vim', { post: ModesearchVimPost })
maxpac.Add('neovimhaskell/haskell-vim')
maxpac.Add('pocke/rbs.vim')
maxpac.Add('preservim/vim-markdown', { pre: VimMarkdownPre })
maxpac.Add('rafamadriz/friendly-snippets')
maxpac.Add('rhysd/git-messenger.vim', { post: GitMessengerVimPost })
maxpac.Add('thinca/vim-localrc', { post: VimLocalrcPost })
maxpac.Add('thinca/vim-prettyprint')
maxpac.Add('thinca/vim-themis')
maxpac.Add('tpope/vim-endwise')
maxpac.Add('tyru/eskk.vim')
maxpac.Add('tyru/open-browser.vim')
maxpac.Add('vim-jp/vital.vim')
maxpac.Add('w0rp/ale', { pre: AlePre })
maxpac.Add('yasuhiroki/github-actions-yaml.vim')
maxpac.Add('yegappan/lsp', { pre: LspPre })
maxpac.Add('zorab47/procfile.vim')

# =============================================================================

# denops.vim

if executable('deno')
  maxpac.Add('vim-denops/denops.vim', { post: DenopsVimPost })

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
