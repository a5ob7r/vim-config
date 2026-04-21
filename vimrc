vim9script

#
# vimrc
#
# - The minimal requirement version is 9.1.1892 with default huge features.
# - Nowadays we are always in UTF-8 environment, aren't we?
# - Work well even if no (non-default) plugin is installed.
# - Support Unix and Windows.
#

# thinca/vim-singleton {{{
try
  packadd! vim-singleton
  singleton#enable()
catch
endtry
# }}}

# =============================================================================

# Classes {{{
class Pathname
  const value: string

  def new(value: string)
    this.value = simplify(value)
  enddef

  def Value(): string
    return this.value
  enddef

  def Join(...values: list<string>): object<Pathname>
    return reduce(values, (acc, v) => acc.Add(v), Pathname.new(this.value))
  enddef

  def Add(value: string): object<Pathname>
    const pathname = Pathname.new(value)

    if pathname.empty()
      return Pathname.new(this.value)
    endif

    if pathname.IsAbsolute()
      return pathname
    endif

    return Pathname.new($'{this.value}/{value}')
  enddef

  def empty(): bool
    return empty(this.value)
  enddef

  def IsAbsolute(): bool
    return this.value =~# '^/'
  enddef
endclass

class SyntaxInfo
  const name: string

  def new(id: number)
    this.name = synIDattr(id, 'name')
  enddef

  def Name(): string
    return this.name
  enddef
endclass

class SyntaxAt
  const id: number
  const info: object<SyntaxInfo>

  def new(line: number, column: number)
    this.id = this._FetchID(line, column)
    this.info = SyntaxInfo.new(this.id)
  enddef

  def Name(): string
    return this.info.Name()
  enddef

  def _FetchID(line: number, column: number): number
    return synID(line, column, 1)
  enddef
endclass

class TransparentSyntaxAt extends SyntaxAt
  # NOTE: No inherit "new()" from the super class?
  def new(line: number, column: number)
    this.id = this._FetchID(line, column)
    this.info = SyntaxInfo.new(this.id)
  enddef

  def _FetchID(line: number, column: number): number
    return synID(line, column, 0)
  enddef
endclass

class TranslatedSyntaxAt extends SyntaxAt
  # NOTE: No inherit "new()" from the super class?
  def new(line: number, column: number)
    this.id = this._FetchID(line, column)
    this.info = SyntaxInfo.new(this.id)
  enddef

  def _FetchID(line: number, column: number): number
    return synID(line, column, 1)->synIDtrans()
  enddef
endclass

class WithLocker
  var lock = false

  def Call(Proc: func, args: list<any>): any
    if this._IsLocked()
      throw "WithLocker.Call(): Cannot get a lock."
    endif

    defer this._Unlock()

    this._Lock()

    return call(Proc, args)
  enddef

  def _IsLocked(): bool
    return this.lock
  enddef

  def _Lock()
    this.lock = true
  enddef

  def _Unlock()
    this.lock = false
  enddef
endclass

class Xnewline
  static const _NEWLINE_KEYSTROKES = () => {
    return map($'xnewline{rand()}', (_, c) => c .. "\<BS>") .. "\n"
  }()

  def Call(): string
    # Work as just a "<CR>" if not on a normal window.
    if !&buftype->empty()
      return "\<CR>"
    endif

    try
      # Merge undo sequences of multiple newline insertions which are caused by
      # sequential invocation of this function if the current line is blank and
      # no cursor movement since the last newline insersion.
      if getreg('.') ==# _NEWLINE_KEYSTROKES
          && getline('.') =~# '^\s*$'
          # A naive detection of whether or not the cursor moved since the last
          # Insert mode leaving.
          && getpos('.') == getpos("'^")
        undojoin
      endif
    catch /^Vim(undojoin):/
      # Ignore any error from ":undojoin" to allow this function invocation
      # even if it is right after undo/redo.
    endtry

    # Insert a newline.
    return $"A{_NEWLINE_KEYSTROKES}\<Esc>"
  enddef
endclass

class Capture
  static const _LOCKER = WithLocker.new()

  const mods: string
  const raw: bool

  def new(opts = {})
    this.mods = get(opts, 'mods', '')
    this.raw = get(opts, 'raw', false)
  enddef

  def Call(command: string)
    if empty(command)
      throw 'Not found a capturable command. Run with arguments or run a command which you want to capture before run :Capture.'
    endif

    _LOCKER.Call(
      () => {
        const lines = this._Redirect(command, this.raw)

        execute this.mods 'new'
        this._MakeBufferScratch()

        setline('.', lines)

        this._MakeBufferReadonly()
      },
      []
    )
  enddef

  def _MakeBufferScratch()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
  enddef

  def _MakeBufferReadonly()
    setlocal readonly
    setlocal nomodifiable
  enddef

  # A wrapper for "execute()".
  def _Redirect(command: string, raw: bool): list<string>
    if !raw
      defer (v) => {
        &l:list = v
      }(&l:list)

      # Do not output extra characters displayed by the "list" option.
      noautocmd setlocal nolist
    endif

    return execute(command)->split('\n')
  enddef
endclass

class Timer
  var id: number

  const time: number
  const Callback: func(number)
  const options: dict<any>

  const STOPPED_TIMER_ID = v:numbermin

  def new(this.time, this.Callback, this.options)
    this.id = this.STOPPED_TIMER_ID
  enddef

  def Start()
    if this.IsStopped()
      this.id = timer_start(this.time, this.Callback, this.options)
    endif
  enddef

  def Stop()
    if this.IsStarted()
      timer_stop(this.id)
      this.id = this.STOPPED_TIMER_ID
    endif
  enddef

  def IsStarted(): bool
    return !this.IsStopped()
  enddef

  def IsStopped(): bool
    return this.id == this.STOPPED_TIMER_ID
  enddef
endclass

# TODO: Support ":hi-link"
class Highlight
  static def Current(group: string): object<Highlight>
    const current_highlight = execute($'highlight {group}')
    const current_attributes = current_highlight
      ->substitute($'\n\|{group}\s\+xxx\s', '', 'g')
      ->split()
      ->reduce((acc, v) => {
          const [k, attrs] = split(v, '=')
          acc[k] = attrs
          return acc
        }, {})

    return Highlight.new(group, current_attributes)
  enddef

  const group: string
  const attributes: dict<string>

  def new(this.group, this.attributes)
  enddef

  def Apply()
    const args = items(this.attributes)->map((_, v) => join(v, '='))

    if !empty(args)
      execute $'highlight {this.group} NONE'
      execute $'highlight {this.group} {join(args)}'
    endif
  enddef
endclass

class FlashingCursorLineState
  const FLASH_HIGHLIGHTS = [
    Highlight.new('CursorLine', { ctermbg:  '16', guibg: '#000000' }),
    Highlight.new('CursorLine', { ctermbg: '232', guibg: '#080808' }),
    Highlight.new('CursorLine', { ctermbg: '233', guibg: '#121212' }),
    Highlight.new('CursorLine', { ctermbg: '234', guibg: '#1c1c1c' }),
    Highlight.new('CursorLine', { ctermbg: '235', guibg: '#262626' }),
    Highlight.new('CursorLine', { ctermbg: '236', guibg: '#303030' }),
    Highlight.new('CursorLine', { ctermbg: '237', guibg: '#3a3a3a' }),
    Highlight.new('CursorLine', { ctermbg: '238', guibg: '#444444' }),
    Highlight.new('CursorLine', { ctermbg: '239', guibg: '#4e4e4e' }),
    Highlight.new('CursorLine', { ctermbg: '240', guibg: '#585858' }),
    Highlight.new('CursorLine', { ctermbg: '241', guibg: '#626262' }),
    Highlight.new('CursorLine', { ctermbg: '242', guibg: '#6c6c6c' }),
    Highlight.new('CursorLine', { ctermbg: '243', guibg: '#767676' }),
    Highlight.new('CursorLine', { ctermbg: '244', guibg: '#808080' }),
    Highlight.new('CursorLine', { ctermbg: '245', guibg: '#8a8a8a' }),
    Highlight.new('CursorLine', { ctermbg: '246', guibg: '#949494' }),
    Highlight.new('CursorLine', { ctermbg: '247', guibg: '#9e9e9e' }),
    Highlight.new('CursorLine', { ctermbg: '248', guibg: '#a8a8a8' }),
    Highlight.new('CursorLine', { ctermbg: '249', guibg: '#b2b2b2' }),
    Highlight.new('CursorLine', { ctermbg: '250', guibg: '#bcbcbc' }),
    Highlight.new('CursorLine', { ctermbg: '251', guibg: '#c6c6c6' }),
    Highlight.new('CursorLine', { ctermbg: '252', guibg: '#d0d0d0' }),
    Highlight.new('CursorLine', { ctermbg: '253', guibg: '#dadada' }),
    Highlight.new('CursorLine', { ctermbg: '254', guibg: '#e4e4e4' }),
    Highlight.new('CursorLine', { ctermbg: '231', guibg: '#ffffff' }),
  ]

  var idx = 0

  def Next(): object<Highlight>
    const hl = this.FLASH_HIGHLIGHTS[this._Idx(this.idx)]

    if this.idx < len(this.FLASH_HIGHLIGHTS)
      ++this.idx
      return hl
    else
      return null_object
    endif
  enddef

  def Reset()
    this.idx = 0
  enddef

  def _Idx(i: number): number
    return i < len(this.FLASH_HIGHLIGHTS) ? i : - (i + 1 - len(this.FLASH_HIGHLIGHTS))
  enddef
endclass

class CursorLine
  const state: object<FlashingCursorLineState>
  const timer: object<Timer>

  var default_highlight: object<Highlight>

  def new()
    this.state = FlashingCursorLineState.new()
    this.timer = Timer.new(
      2,
      (_tid) => {
        const hl = this.state.Next()

        if hl == null_object
          this.Reset()
        else
          hl.Apply()
        endif
      },
      { repeat: -1 }
    )
  enddef

  def Flash()
    if this.timer.IsStopped()
      this._RememberCurrentHighlight()
      this.timer.Start()
    endif
  enddef

  def Reset()
    if this.timer.IsStarted()
      this.timer.Stop()
      this.state.Reset()

      if this._IsHighlightRemembered()
        this.default_highlight.Apply()
      endif
    endif
  enddef

  def _IsHighlightRemembered(): bool
    return this.default_highlight != null
  enddef

  def _RememberCurrentHighlight()
    this.default_highlight = Highlight.Current('CursorLine')
  enddef
endclass
# }}}

# Functions {{{
# Format syntax item names at a position.
#
# https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
def FormatSyntaxNamesAt(line: number, column: number): string
  const hi = SyntaxAt.new(line, column).Name()
  const trans = TransparentSyntaxAt.new(line, column).Name()
  const lo = TranslatedSyntaxAt.new(line, column).Name()

  return $'hi: "{hi}", trans: "{trans}", lo: "{lo}"'
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
  return $XDG_CACHE_HOME ?? Pathname.new($HOME).Join('.cache').Value()
enddef

def FiletypeRedetection4DotLocal(enable: bool)
  augroup vimrc:FiletypeRedetection4DotLocal
    autocmd!

    if enable
      # Re-detect a filetype for '~/.local.xxx' as '~/.xxx' if filetype detection is unsuccessful.
      autocmd BufRead,BufNewFile ~/.local.[^/]\+ {
        if empty(&filetype)
          const parent = expand('<afile>:h')
          const virtual_filename = expand('<afile>:t:s?\.local??') # A virtual filename to re-detect filetypes.
          execute $'doautocmd filetypedetect BufRead {fnameescape($'{parent}/{virtual_filename}')}'
        endif
      }
    endif
  augroup END
enddef

# If new filetype detections are registered, re-register filetype re-detection
# for .local files to re-detect filetypes after all of other filetype
# detections are completed,
def ReregisterFiletypeRedetection4DotLocal(enable: bool)
  augroup vimrc:ReregisterFiletypeRedetection4DotLocal
    autocmd!

    if enable
      autocmd SourcePost filetype.vim,*/ftdetect/*.vim {
        FiletypeRedetection4DotLocal(true)
      }
    endif
  augroup END
enddef

def Assign2ClipboardRegisters(value: string)
  @" = value
  @* = value
  @+ = value
enddef

def YankCurrentFilename(opts = {})
  const filename = expand('%')

  if empty(filename)
    echohl WarningMsg
    echomsg 'No filename for the current buffer.'
    echohl None
    return
  endif

  const o_lineno = get(opts, 'lineno')

  if o_lineno
    const lineno = getpos('.')[1]
    Assign2ClipboardRegisters($'{filename}:{lineno}')
  else
    Assign2ClipboardRegisters(filename)
  endif
enddef

# ":close" with some exception.
#
# - Do not close the last window on the current tabpage.
# - "0" (by default) of "[count]" means the current window number.
def Close(bang: string, count: string)
  if tabpagewinnr(tabpagenr(), '$') <= 1
    echohl WarningMsg
    echo "[Close] Can't close the last window on the current tabpage."
    echohl None
    return
  endif

  const window_number = count ==# '0' ? '' : count

  execute $':{window_number}close{bang}'
enddef

# Execute ":bdelete", but this command try to keep at least one window or a
# normal buffer in the current tabpage.
def Bdelete(bang: string)
  const current_bufnr = bufnr()
  const normal_buffers = tabpagebuflist()->filter((i, v) => getbufvar(v, '&buftype')->empty())

  if empty(&buftype) ? len(normal_buffers) <= 1 : winnr('$') <= 1
    execute $'enew{bang}'
  endif

  execute $'bdelete{bang} {current_bufnr}'
enddef

# Toggle the netrw window.
def ToggleNetrw(opts = {})
  const bang = get(opts, 'bang', '')

  const cwd = empty(bang) ? getcwd() : expand('%:p:h')

  if get(b:, 'netrw_curdir', '') !=# cwd
    execute 'Explore' cwd
  elseif exists(':Rexplore') == 2 && exists('w:netrw_rexlocal')
    execute 'Rexplore'
  else
    execute 'Explore'
  endif
enddef

def DeleteBuffers(args: list<string>, opts: dict<any>)
  const arguments = args ?? ['--normal', '--listed', '--hidden']
  const bang = get(opts, 'bang', '')
  const mods = get(opts, 'mods', '')
  const line1 = get(opts, 'line1', 1)
  const line2 = get(opts, 'line2', v:numbermax)

  # Whether or not the buffer is the same as a new, unnamed and empty buffer.
  const IsEmptyBuffer = (bufinfo: dict<any>): bool => {
    return !empty(bufinfo)
      && empty(bufinfo.name)
      && bufinfo.lnum <= 1
      && empty(getbufline(bufinfo.bufnr, 1)[0])
      && !bufinfo.changed
  }

  const PREDICATES = {
    any: (_bufinfo) => true,
    displayed: (bufinfo) => !bufinfo.hidden,
    empty: (bufinfo) => IsEmptyBuffer(bufinfo),
    filled: (bufinfo) => !IsEmptyBuffer(bufinfo),
    hidden: (bufinfo) => bufinfo.hidden,
    listed: (bufinfo) => bufinfo.listed,
    normal: (bufinfo) => getbufvar(bufinfo.bufnr, '&buftype')->empty(),
    special: (bufinfo) => !getbufvar(bufinfo.bufnr, '&buftype')->empty(),
    unlisted: (bufinfo) => !bufinfo.listed,
  }

  const predicates =
    reduce(
      arguments,
      (acc, arg) => {
        const k = arg =~# '^--' ? arg[2 :] : arg

        if !PREDICATES->has_key(k)
          throw $':DeleteBuffers: ''{arg}'' is an invalid option.'
        endif

        return add(acc, PREDICATES[k])
      },
      []
    )

  getbufinfo({ bufloaded: true })->foreach((_i, bufinfo) => {
    if bufinfo.bufnr >= line1 && bufinfo.bufnr <= line2 && reduce(predicates, (acc, predicate) => acc && call(predicate, [bufinfo]), true)
      execute mods $'bdelete{bang}' bufinfo.bufnr
    endif
  })
enddef

def DeleteBuffersComplete(..._): string
  return [
    '--any',
    '--displayed',
    '--empty',
    '--filled',
    '--hidden',
    '--listed',
    '--normal',
    '--special',
    '--unlisted',
  ]->join("\n")
enddef

def Gcd(query: string, bang: string, mods: string, cder = 'cd')
  # Use "systemlist()" to strip a trailing "^@" instead of "system()".
  const [directory] = systemlist($'ghq list --exact --full-path {shellescape(query)}')

  execute mods $'{cder}{bang}' fnameescape(directory)
enddef

def GcdComplete(_ArgLead: string, _CmdLine: string, _CursorPos: number): string
  return system('ghq list')
enddef

def DictionarizedLsLine(line: string): dict<any>
  const matches = matchlist(line, '^\s*\([1-9]\d*\)\(.\{5}\) "\(.*\)" \s*line \(\d\+\)$')

  return {
    bufnr: matches[1]->str2nr(),
    indicators: matches[2],
    filename: matches[3],
    lnum: matches[4]->str2nr(),
  }
enddef

def QfLs(opts: dict<any>)
  const bang = get(opts, 'bang', '')
  const flags = get(opts, 'flags', '')

  const buffers = execute($'ls{bang} {flags}')->split('\n')->map((_, line) => DictionarizedLsLine(line))
  const max_bufnr = mapnew(buffers, (_, buffer) => buffer['bufnr'])->max()
  const bufnr_ndigits = [len(max_bufnr), 3]->max()

  setqflist([], ' ', {
    items: buffers,
    title: 'Buffer lists',
    quickfixtextfunc: (_info) => mapnew(buffers, (_, buffer) => {
      const bufnr = buffer['bufnr']
      const indicators = buffer['indicators']
      const filename = buffer['filename']
      const lnum = buffer['lnum']
      const text = getbufline(bufnr, lnum)->get(0, '')

      return printf($'%{bufnr_ndigits}d%s %-30S | {lnum} col 0 | %s', bufnr, indicators, $'"{filename}"', text)
    }),
  })
enddef

def StrTake(s: string, n: number): string
  if n > 0
    return slice(s, 0, n)
  else
    return ''
  endif
enddef

def StrTakeEnd(s: string, n: number): string
  if n > 0
    return slice(s, -n)
  else
    return ''
  endif
enddef

def StrDrop(s: string, n: number): string
  if n > 0
    return slice(s, n)
  else
    return s
  endif
enddef

def StrDropEnd(s: string, n: number): string
  if n > 0
    return slice(s, -n)
  else
    return s
  endif
enddef

def IsStrStartWith(s: string, prefix: string): bool
  return StrTake(s, len(prefix)) ==# prefix
enddef

def IsStrEndWith(s: string, suffix: string): bool
  return StrTakeEnd(s, len(suffix)) ==# suffix
enddef

def StripCommentString(s: string, commentstring: string): string
  const trimmed = trim(s)
  const [prefix, suffix; _] = split(commentstring, '%s')->map((_, v) => trim(v)) + ['', '']

  return StrDrop(trimmed, IsStrStartWith(trimmed, prefix) ? len(prefix) : 0)
    ->StrDropEnd(IsStrEndWith(trimmed, suffix) ? len(suffix) : 0)
    ->trim()
enddef

def ParagraphUnlines(lines: list<string>): string
  return reduce(lines, (acc, v) => {
    if empty(v)
      return IsStrEndWith(acc, "\n") ? $"{acc}\n" : $"{acc}\n\n"
    else
      return IsStrEndWith(acc, "\n") ? $'{acc}{v}' : $'{acc} {v}'
    endif
  })
enddef

def Divmod(a: number, b: number): tuple<number, number>
  const q = a / b
  const r = a % b

  return (q, r)
enddef

# Minimize the current window and distribute the window's height equally to
# other windows.
def Xwinminimize()
  const cur_winid = win_getid()

  wincmd =

  const heights = getwininfo()
    ->reduce((acc, v) => {
      if v['tabnr'] == tabpagenr()
        acc[v['winid']] = v['height']
      endif

      return acc
    }, {})

  var stack = [[winlayout(), winheight(0) - &winminheight]]

  # First, minimize the current window.
  resize 0

  # TODO: Atomic window resizing.
  while !empty(stack)
    var [layout, diffheight] = remove(stack, 0)

    if layout[0] ==# 'col'
      const len = len(layout[1])
      const [height, height_remain] = Divmod(diffheight, len - 1)

      # If the window height fraction exists, distribute it to each of lower
      # windows in order.
      range(len)->reverse()->reduce((distributed_height, i) => {
        const delta = (height_remain > distributed_height && layout[1][i] != ['leaf', cur_winid]) ? 1 : 0

        layout[1][i] = [layout[1][i], height + delta]

        return distributed_height + delta
      }, 0)

      stack += layout[1]
    elseif layout[0] ==# 'row'
      # TODO: Support vertical layouts.
      throw 'vimrc:Xwinminimize(): No verical layout support yet.'
    elseif layout[0] ==# 'leaf'
      const wid = layout[1]

      if wid == cur_winid
        continue
      endif

      win_execute(wid, $'resize {heights[wid] + diffheight}')
    else
      throw 'xwinminimize(): An unknown item.'
    endif
  endwhile
enddef

# Minimize the current window, and make other window's height equally.
def Xminimize()
  defer (v) => {
    &lazyredraw = v
  }(&lazyredraw)

  # Suppress view flickering caused by window resizing.
  set lazyredraw

  const winrestcmd = winrestcmd()

  try
    Xwinminimize()
  catch
    echohl WarningMsg
    echomsg v:exception
    echohl None

    execute winrestcmd
  endtry
enddef

# Substitute all of full-width Japanese punctuation('。' and '、') in every
# string in a range with each appropriate full-width English punctuation('．'
# and '，'). If run this with a bang('!'), substitute them in the opposite
# way.
#
# before: 我輩は、人間である。名前は、すでにある。
#  after: 我輩は，人間である．名前は，すでにある．
#
# NOTE: Vim probably changes the cursor position to the head of the command
# range while a function which have the range specified is invoked. This means
# that the returned value by "winsaveview()" which is called in the function
# is also changed by the function invocation with the command range. Because
# of this behavior, we can't get the original position where a cursor is when
# a user calls the function. However, we can avoid this behavior by passing
# the range as a function argument instead of a function call with the range.
# This is a little bit tedious and a very simple solution.
def SubstituteJapanesePunctuations(bang: string, line1: number, line2: number)
  const period = {
    ja: '。',
    en: '．',
  }
  const comma = {
    ja: '、',
    en: '，',
  }

  const lang_from = empty(bang) ? 'ja' : 'en'
  const lang_to = empty(bang) ? 'en' : 'ja'

  defer (view) => {
    winrestview(view)
  }(winsaveview())

  execute $'silent keepjumps keeppatterns :{line1},{line2}substitute/{period[lang_from]}/{period[lang_to]}/eg'
  execute $'silent keepjumps keeppatterns :{line1},{line2}substitute/{comma[lang_from]}/{comma[lang_to]}/eg'
enddef

# Read/Write the binary format, but are these configurations really
# comfortable? Maybe we should use a binary editor insated.
def BinaryEditableByXxd(enable: bool)
  augroup vimrc:xxd
    autocmd! * <buffer>

    if enable
      autocmd BufReadPost <buffer> {
        execute 'silent :%!xxd -g 1'
        set filetype=xxd
      }
      autocmd BufWritePre <buffer> {
        b:cursorpos = getcurpos()
        execute ':%!xxd -r'
      }
      autocmd BufWritePost <buffer> {
        execute 'silent :%!xxd -g 1'
        set nomodified
        cursor(b:cursorpos[1], b:cursorpos[2], b:cursorpos[3])
        unlet b:cursorpos
      }
    endif
  augroup END
enddef

const cursorline = CursorLine.new()

def FlashCursorLine(enable: bool)
  augroup FlashCursorLine
    autocmd!

    if enable
      autocmd WinEnter,BufEnter * {
        if &buftype !=# 'terminal'
          cursorline.Reset()
          cursorline.Flash()
        endif
      }
      autocmd TerminalWinOpen,BufWinEnter * {
        if &buftype ==# 'terminal'
          cursorline.Reset()
        endif
      }
      autocmd ColorSchemePre * {
        cursorline.Reset()
      }
    endif
  augroup END
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
set pumheight=16
set scrolloff=5
set shortmess-=S
set showmatch
set smoothscroll
set spelllang+=cjk
set spelloptions+=camel
set tabclose=left
set tabpanel=%!TabPanel()
set tabpanelopt=columns:30,vert
set virtualedit=block
set wildmode=longest:full,full
set wildoptions+=pum,fuzzy

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
  #
  # TODO: Switch from "$XDG_CACHE_HOME" to "$XDG_DATA_HOME" or "$XDG_STATE_HOME".
  const vim_cache_home = Pathname.new(XdgCacheHome()).Join('vim')

  &backupdir = $'{vim_cache_home.Join('backup').Value()}//'
  &directory = $'{vim_cache_home.Join('swap').Value()}//'
  &undodir = $'{vim_cache_home.Join('undo').Value()}//'

  [&backupdir, &directory, &undodir]->foreach((_, path) => {
    if !isdirectory(path)
      mkdir(path, 'p', 0o700)
    endif
  })
}
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

nnoremap <F10> <ScriptCmd>echo FormatSyntaxNamesAt(line('.'), col('.'))<CR>

nnoremap <C-S> <Cmd>update<CR>
inoremap <C-S> <Cmd>update<CR>

nnoremap <Leader>t <Cmd>execute $'{v:count ?? ''}tabnew'<CR>

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
nnoremap <C-W>gm <ScriptCmd>Xminimize()<CR>

nnoremap <C-W>M <Cmd>resize<CR>
nnoremap <C-W>VM <Cmd>vertical resize<CR>

tnoremap <C-W>m <Cmd>resize 0<CR>
tnoremap <C-W>Vm <Cmd>vertical resize 0<CR>
tnoremap <C-W>gm <ScriptCmd>Xminimize()<CR>

tnoremap <C-W>M <Cmd>resize<CR>
tnoremap <C-W>VM <Cmd>vertical resize<CR>

# NOTE: "<Nul>" is sent instead of "<C-Space>" when type the "CTRL" key and
# the "SPACE" one at once if in some terminal emulators.
nmap <Nul> <C-Space>

nnoremap <C-W><BS> <Cmd>Bdelete<CR>
nnoremap <C-W>g<BS> <Cmd>bdelete<CR>

nnoremap <Leader>n <Cmd>ToggleNetrw<CR>
nnoremap <Leader>N <Cmd>ToggleNetrw!<CR>

# Create a newline instantly even if in Normal mode, but work as just a "<CR>"
# if in a "command-line-window".
nnoremap <expr> <Plug>(newline) Xnewline.new().Call()
# }}}

# Commands {{{
# A helper command to open a file in a split window, or the current one (if it
# is invoked with a bang mark).
command! -bang -bar -nargs=1 -complete=file OpenHelper {
  const opener = <bang>1 ? 'split' : 'edit'

  execute <q-mods> opener <q-args>
}

g:DefineOpener('Vimrc', $MYVIMRC)

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

command! EnableFiletypeRedetection4DotLocal {
  FiletypeRedetection4DotLocal(true)
  ReregisterFiletypeRedetection4DotLocal(true)
}

command! DisableFiletypeRedetection4DotLocal {
  FiletypeRedetection4DotLocal(false)
  ReregisterFiletypeRedetection4DotLocal(false)
}

command! -bar Writable {
  setlocal noreadonly modifiable swapfile
}
command! -bang -bar -nargs=? -complete=file RO {
  if !empty(<q-args>)
    # NOTE: Cause "E471" when no argument is specified if ":OpenHelper <args>".
    execute <q-mods> 'OpenHelper<bang>' <q-args>
  endif

  setlocal readonly nomodifiable noswapfile
}

command! -bang YankCurrentFilename {
  YankCurrentFilename({ lineno: <bang>false })
}

command! -bang -bar -count -addr=windows Close {
  Close(<q-bang>, <q-count>)
}

command! -bang -bar Bdelete {
  Bdelete(<q-bang>)
}

command! -bar -bang ToggleNetrw {
  ToggleNetrw({ bang: <q-bang> })
}

# :DeleteBuffers --listed --hidden --normal
# :silent 1,10DeleteBuffers! --any
command! -bang -bar -nargs=* -range=% -addr=loaded_buffers -complete=custom,DeleteBuffersComplete DeleteBuffers {
  DeleteBuffers([<f-args>], { bang: <q-bang>, mods: <q-mods>, line1: <line1>, line2: <line2> })
}

# ":cd" to a VCS repository managed by "ghq" using only the sub-path.
#
# ":Gcd vim-config"
command! -bang -nargs=1 -complete=custom,GcdComplete Gcd {
  Gcd(<q-args>, <q-bang>, <q-mods>)
}

# A ":tcd" version of ":Gcd".
command! -bang -nargs=1 -complete=custom,GcdComplete Gtcd {
  Gcd(<q-args>, <q-bang>, <q-mods>, 'tcd')
}

# A ":lcd" version of ":Gcd".
command! -bang -nargs=1 -complete=custom,GcdComplete Glcd {
  Gcd(<q-args>, <q-bang>, <q-mods>, 'lcd')
}

# "files", "buffers" and "ls", but view the outputs in a quickfix window.
command! -bang -bar -nargs=* Files {
  silent doautocmd QuickFixCmdPre Files
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Files
}
command! -bang -bar -nargs=* Buffers {
  silent doautocmd QuickFixCmdPre Buffers
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Buffers
}
command! -bang -bar -nargs=* Ls {
  silent doautocmd QuickFixCmdPre Ls
  QfLs({ bang: <q-bang>, flags: <q-args> })
  silent doautocmd QuickFixCmdPost Ls
}

command! -range -register YankComments {
  getline(<line1>, <line2>)
    ->map((_, line) => StripCommentString(line, &commentstring))
    ->ParagraphUnlines()
    ->setreg(v:register)
}

# ":tabclose" with range support.
command! -bar -bang -range -addr=tabs -nargs=? Tabclose {
  if empty(<q-args>)
    range(<line1>, <line2>)->reverse()->foreach((_, v) => execute($'<mods> :{v}tabclose<bang>') )
  else
    <mods> :<args>tabclose<bang>
  endif
}

command! -bang -range SubstituteJapanesePunctuations {
  SubstituteJapanesePunctuations(<q-bang>, <line1>, <line2>)
}

# Break sentences followed by "。" or "．" into newline-separated them.
command! -bar -range BreakJapaneseSentences {
  keeppatterns :<line1>,<line2>substitute/\([。．]\)/\1\r/eg
}

# Capture Ex command outputs and write it to a new scratch buffer.
command! -bang -nargs=* -complete=command Capture {
  Capture.new({ mods: <q-mods>, raw: <bang>false }).Call(<q-args> ?? @:)
}

# Joke commands inspired by https://github.com/inside/vim-search-pulse.
command! FlashCursorLine FlashCursorLine(true)
command! NoFlashCursorLine FlashCursorLine(false)
# }}}

# Auto commands {{{
augroup vimrc:OpenQuickFixWindow
  autocmd!
  autocmd QuickFixCmdPost {,vim,help}grep*,make,Files,Buffers,Ls {
    cwindow
  }
  autocmd QuickFixCmdPost l{,vim,help}grep*,lmake {
    lwindow
  }
augroup END

augroup vimrc:MakeParentDirectories
  autocmd!
  # Create a parent directory of the file to which Vim write the buffer if
  # missing.
  autocmd BufWritePre * {
    const parent = expand('<afile>:p:h')

    if !isdirectory(parent)
      echohl WarningMsg
      const reply = input($'"{fnamemodify(parent, ':~:.')->fnameescape()}/" does not exist. Create? [y/n] ')
      echohl None

      if reply ==# 'y'
        mkdir(parent, 'p')
      endif
    endif
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

augroup vimrc:refresh:Checktime
  autocmd!
  autocmd User Refresh {
    checktime %
  }
augroup END

augroup vimrc:binary
  autocmd!
  autocmd OptionSet binary {
    BinaryEditableByXxd(v:option_new ==# '1')
  }
augroup END
# }}}

# Standard plugins {{{
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
packadd! matchit
# }}}

# =============================================================================

# Plugins {{{
# maxpac {{{
class Maxpac
  # The default value for "{config}" of "minpac#add()".
  const DEFAULT_CONFIG = { type: 'opt' }

  # "{config}"s of "minpac#init()".
  const init = {}

  # "{url}"s of "minpac#add()".
  final urls = []

  # "{config}"s of "minpac#add()".
  final configs = {}

  var minpacabled = false

  def new(this.init = v:none)
  enddef

  def Minpacable()
    if this.minpacabled
      return
    endif

    packadd minpac

    minpac#init(this.init)

    foreach(this.urls, (_, url) => minpac#add(url, this.configs[url]))

    this.minpacabled = true
  enddef

  def Add(url: string, config = {}): bool
    # TODO: Support drive letters for MS-Windows.
    if url =~# '^\%(/\|\~\)'
      return this._LoadLocal(url)
    else
      this._Register(url, config)
      return this._Load(url)
    endif
  enddef

  def _Register(url: string, config: dict<any>)
    add(this.urls, url)
    this.configs[url] = extendnew(this.DEFAULT_CONFIG, config)
  enddef

  def _LoadLocal(path: string): bool
    if glob(path)->empty()
      return false
    endif

    final rtp = split(&runtimepath, ',')
    insert(rtp, path, 1)
    if !globpath(path, 'after', true)->empty()
      insert(rtp, $'{path}/after', -1)
    endif
    &runtimepath = join(rtp, ',')

    if v:vim_did_init
      globpath(path, 'plugin/**/*.vim', true, true)->foreach((_, plugin) => {
        execute 'source' fnameescape(plugin)
      })
    endif

    return true
  enddef

  def _Load(uri: string): bool
    const name = this.Plugname(uri)

    try
      if v:vim_did_init
        execute 'packadd' name
      else
        execute 'packadd!' name
      endif
    catch
      # Ignore any errors.
    endtry

    return this.Loaded(name)
  enddef

  # Whether or not the plugin is loaded.
  def Loaded(name: string): bool
    return !globpath(&runtimepath, $'pack/*/opt/{name}')->empty()
  enddef

  # Convert an URI into a plugin (directory) name.
  def Plugname(uri: string): string
    if get(this.configs, uri, {})->has_key('name')
      return this.configs[uri]['name']
    elseif uri =~# '\C^https\=://.*\.git$' # NOTE: a naive regexp, but probably no problem in practice.
      return fnamemodify(uri, ':t:r')
    else
      return fnamemodify(uri, ':t')
    endif
  enddef
endclass

g:maxpac = Maxpac.new()

command! InstallMinpac {
  # A root directory path of vim packages.
  const packhome = Pathname.new($MYVIMDIR).Join('pack')

  const repository = 'https://github.com/k-takata/minpac.git'
  const directory =  packhome.Join('minpac/opt/minpac').Value()

  const command = $'git clone {repository} {directory}'

  execute 'terminal' command
}

command! Minpacable {
  g:maxpac.Minpacable()
}
# }}}

# Plugin hooks {{{
# k-takata/minpac {{{
augroup vimrc:hooks:minpac
  autocmd!
  autocmd SourcePre */minpac/*.vim ++once {
    Minpac()
  }
augroup END

def Minpac()
  delcommand InstallMinpac

  command! -bar -nargs=1 PackInstall {
    Minpacable

    const plugname = g:maxpac.Plugname(<q-args>)

    minpac#add(<q-args>, { type: 'opt' })
    minpac#update(plugname, { do: $'packadd {plugname}' })
  }

  # ":PackUpdate": Update all registered plugins.
  # ":PackUpdate {plugin_name} ...": Update specified and registered plugins.
  command! -bar -nargs=? -complete=custom,PackComplete PackUpdate {
    Minpacable

    if empty(<q-args>)
      minpac#update()
    else
      minpac#update([<f-args>])
    endif
  }

  # ":PackClean": Clean unregistered plugins.
  # ":PackClean {plugin_name} ...": Clean specified and registered plugins.
  # ":PackClean *": Clean all plugins.
  command! -bar -nargs=? -complete=custom,PackComplete PackClean {
    Minpacable

    minpac#clean([<f-args>])
  }

  # This command is from the minpac help file.
  command! -nargs=1 -complete=custom,PackComplete PackOpenDir {
    Minpacable

    const pluginfo = minpac#getpluginfo(<q-args>)

    term_start(&shell, { cwd: pluginfo['dir'], term_finish: 'close' })
  }
enddef

def PackComplete(..._): string
  Minpacable

  return minpac#getpluglist()->keys()->sort()->join("\n")
enddef
# }}}

# KeitaNakamura/neodark.vim {{{
augroup vimrc:hooks:neodark.vim
  autocmd!
  autocmd SourcePre */neodark.vim/*.vim ++once {
    NeodarkVim()
  }
augroup END

def NeodarkVim()
  # Prefer a near black background color.
  g:neodark#background = '#202020'

  command! -bar Neodark {
    Neodark()
  }

  augroup vimrc:neodark
    autocmd!
    autocmd VimEnter * ++nested {
      # Neodark requires 256 colors at least. For example Linux console
      # supports only 8 colors.
      if str2nr(&t_Co) >= 256
        Neodark
      endif
    }
  augroup END
enddef

def Neodark()
  colorscheme neodark

  # Cyan; prefer cyan over orange that is the default neodark color.
  g:terminal_ansi_colors[6] = '#72c7d1'
  # Light black; Adjust the autosuggested text color for zsh.
  g:terminal_ansi_colors[8] = '#5f5f5f'
enddef
# }}}

# itchyny/lightline.vim {{{
augroup vimrc:hooks:lightline.vim
  autocmd!
  autocmd SourcePre */lightline.vim/*.vim ++once {
    LightlineVim()
  }
augroup END

def LightlineVim()
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
  return globpath(&runtimepath, 'autoload/lightline/colorscheme/*.vim', true, true)
    ->map((_, val) => fnamemodify(val, ':t:r'))
    ->join("\n")
enddef
# }}}

# airblade/vim-gitgutter {{{
augroup vimrc:hooks:vim-gitgutter
  autocmd!
  autocmd SourcePre */vim-gitgutter/*.vim ++once {
    VimGitgutter()
  }
augroup END

def VimGitgutter()
  g:gitgutter_sign_added = 'A'
  g:gitgutter_sign_modified = 'M'
  g:gitgutter_sign_removed = 'D'
  g:gitgutter_sign_removed_first_line = 'd'
  g:gitgutter_sign_modified_removed = 'm'
enddef
# }}}

# rhysd/git-messenger.vim {{{
augroup vimrc:hooks:git-messenger.vim
  autocmd!
  autocmd SourcePre */git-messenger.vim/*.vim ++once {
    GitMessengerVim()
  }
augroup END

def GitMessengerVim()
  g:git_messenger_include_diff = 'all'
  g:git_messenger_always_into_popup = true
  g:git_messenger_max_popup_height = 15
enddef
# }}}

# hrsh7th/vim-vsnip {{{
augroup vimrc:hooks:vim-vsnip
  autocmd!
  autocmd SourcePre */vim-vsnip/*.vim ++once {
    VimVsnip()
  }
augroup END

def VimVsnip()
  g:vsnip_snippet_dir = Pathname.new($MYVIMDIR).Join('vsnip').Value()

  inoremap <expr> <Tab>
    \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
    \ vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
  snoremap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  inoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
  snoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
enddef
# }}}

# kana/vim-operator-replace {{{
augroup vimrc:hooks:vim-operator-replace
  autocmd!
  autocmd SourcePre */vim-operator-replace/*.vim ++once {
    VimOperatorReplace()
  }
augroup END

def VimOperatorReplace()
  noremap _ <Plug>(operator-replace)
enddef
# }}}

# a5ob7r/shellcheckrc.vim {{{
augroup vimrc:hooks:shellcheckrc.vim
  autocmd!
  autocmd SourcePre */shellcheckrc.vim/*.vim ++once {
    ShellcheckrcVim()
  }
augroup END

def ShellcheckrcVim()
  g:shellcheck_directive_highlight = get(g:, 'shellcheck_directive_highlight', 1)
enddef
# }}}

# preservim/vim-markdown {{{
augroup vimrc:hooks:vim-markdown
  autocmd!
  autocmd SourcePre */vim-markdown/*.vim ++once {
    VimMarkdown()
  }
augroup END

def VimMarkdown()
  # No need to insert any indent preceding a new list item after inserting a
  # newline.
  g:vim_markdown_new_list_item_indent = get(g:, 'vim_markdown_new_list_item_indent', 0)

  g:vim_markdown_folding_disabled = get(g:, 'vim_markdown_folding_disabled', 1)
enddef
# }}}

# w0rp/ale {{{
augroup vimrc:hooks:ale
  autocmd!
  autocmd SourcePre */ale/*.vim ++once {
    Ale()
  }
augroup END

def Ale()
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
augroup vimrc:hooks:vim-ripgrep
  autocmd!
  # TODO: Find an appropriate hook event.
  autocmd VimEnter * ++once {
    if g:maxpac.Loaded('vim-ripgrep') && g:maxpac.Loaded('vim-operator-user')
      VimRipgrep()
    endif
  }
augroup END

def VimRipgrep()
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

enum RegionSelectionType
  Char('v'),
  Line('V'),
  Block('')

  const value: string

  def Value(): string
    return this.value
  enddef

  static const _MAP = {
    char: RegionSelectionType.Char,
    line: RegionSelectionType.Line,
    block: RegionSelectionType.Block,
  }

  static def Fetch(motion_wiseness: string): RegionSelectionType
    return _MAP[motion_wiseness]
  enddef
endenum

# TODO: Consider ideal linewise and blockwise operations.
def OperatorRipgrep(motion_wiseness: string, opts = {})
  const o_boundaries = get(opts, 'boundaries')
  const o_push_history_entry = get(opts, 'push_history_entry')
  const o_highlight = get(opts, 'highlight')

  final words = ['Rg', '-F']

  if o_boundaries
    add(words, '-w')
  endif

  const buflines = getregion(getpos("'["), getpos("']"), {
    type: RegionSelectionType.Fetch(motion_wiseness).Value()
  })

  if len(buflines) >= 2
    add(words, '-U')
  endif

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
augroup vimrc:hooks:vim-asterisk
  autocmd!
  autocmd SourcePre */vim-asterisk/*.vim ++once {
    VimAsterisk()
  }
augroup END

def VimAsterisk()
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
augroup vimrc:hooks:modesearch.vim
  autocmd!
  autocmd SourcePre */modesearch.vim/*.vim ++once {
    ModesearchVim()
  }
augroup END

def ModesearchVim()
  nnoremap g/ <Plug>(modesearch-slash-rawstr)
  nnoremap g? <Plug>(modesearch-question-regexp)
  cnoremap <C-x> <Plug>(modesearch-toggle-mode)
enddef
# }}}

# thinca/vim-localrc {{{
augroup vimrc:hooks:vim-localrc
  autocmd!
  autocmd SourcePre */vim-localrc/*.vim ++once {
    VimLocalrc()
  }
augroup END

def VimLocalrc()
  command! -bang -bar VimrcLocal {
    OpenLocalrc(<q-bang>, <q-mods>, expand('~'))
  }
  command! -bang -bar -nargs=? -complete=dir OpenLocalrc {
    OpenLocalrc(<q-bang>, <q-mods>, <q-args> ?? expand('%:p:h'))
  }
enddef

def OpenLocalrc(bang: string, mods: string, dir: string)
  const localrc_filename = get(g:, 'localrc_filename', '.local.vimrc')
  const localrc_filepath = Pathname.new(dir).Join(localrc_filename).Value()

  execute $'{mods} OpenHelper{bang} {fnameescape(localrc_filepath)}'
enddef
# }}}

# Eliot00/git-lens.vim {{{
augroup vimrc:hooks:git-lens.vim
  autocmd!
  autocmd SourcePre */git-lens.vim/*.vim ++once {
    GitlensVim()
  }
augroup END

def GitlensVim()
  command! -bar ToggleGitLens {
    g:ToggleGitLens()
  }
enddef
# }}}

# a5ob7r/linefeed.vim {{{
augroup vimrc:hooks:linefeed.vim
  autocmd!
  autocmd SourcePre */linefeed.vim/*.vim ++once {
    LinefeedVim()
  }
augroup END

def LinefeedVim()
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
augroup vimrc:hooks:vim-sandwich
  autocmd!
  autocmd SourcePre */vim-sandwich/*.vim ++once {
    VimSandwich()
  }
augroup END

def VimSandwich()
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
augroup vimrc:hooks:vista.vim
  autocmd!
  autocmd SourcePre */vista.vim/*.vim ++once {
    VistaVim()
  }
augroup END

def VistaVim()
  nnoremap <Leader>v <Cmd>Vista!!<CR>
enddef
# }}}

# itchyny/screensaver.vim {{{
augroup vimrc:hooks:screensaver.vim
  autocmd!
  autocmd SourcePre */screensaver.vim/*.vim ++once {
    ScreensaverVim()
  }
augroup END

def ScreensaverVim()
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
augroup vimrc:hooks:vim-trailing-whitespace
  autocmd!
  autocmd SourcePre */vim-trailing-whitespace/*.vim ++once {
    VimTrailingWhitespace()
  }
augroup END

def VimTrailingWhitespace()
  g:extra_whitespace_ignored_filetypes = get(g:, 'extra_whitespace_ignored_filetypes', [])
  g:extra_whitespace_ignored_filetypes += ['screensaver']
enddef
# }}}

# girishji/vimbits {{{
augroup vimrc:hooks:vimbits
  autocmd!
  autocmd SourcePre */vimbits/*.vim ++once {
    Vimbits()
  }
augroup END

def Vimbits()
  g:vimbits_highlightonyank = false
  g:vimbits_easyjump = false
  g:vimbits_fFtT = true
  g:vimbits_vim9cmdline = false
enddef
# }}}

# lambdalisue/gin.vim {{{
augroup vimrc:hooks:gin.vim
  autocmd!
  autocmd SourcePre */gin.vim/*.vim ++once {
    GinVim()
  }
augroup END

def GinVim()
  g:gin_diff_persistent_args = ['--patch', '--stat']

  if executable('delta')
    g:gin_diff_persistent_args += ['++processor=delta --color-only']
  elseif executable('diff-highlight')
    g:gin_diff_persistent_args += ['++processor=diff-highlight']
  endif

  # "git changes" is defined in my gitconfig.
  command! -nargs=* -complete=file GinChanges {
    GinBuffer changes <args>
  }

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
    autocmd FileType gin-buffer {
      setlocal nomodeline

      b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
      b:undo_ftplugin ..= '| setlocal modeline<'
    }
    autocmd FileType gin-log {
      nnoremap <buffer> <C-W><CR> <Plug>(gin-action-show:split)

      b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
      b:undo_ftplugin ..= '| nunmap <buffer> <C-W><CR>'
    }
    autocmd FileType gin-status {
      nnoremap <buffer> gf <Plug>(gin-action-edit:local)
      nnoremap <buffer> <C-W>f <Plug>(gin-action-edit:local:split)
      nnoremap <buffer> <C-W>gf <Plug>(gin-action-edit:local:tabedit)

      const undos =<< trim eval END
        {get(b:, 'undo_ftplugin', 'execute')}
        silent! execute 'nunmap <buffer> gf'
        silent! execute 'nunmap <buffer> <C-W>f'
        silent! execute 'nunmap <buffer> <C-W>gf'
      END
      b:undo_ftplugin = join(undos, '|')
    }
    autocmd FileType gin-{branch,buffer,diff,edit,log,status} {
      setlocal nobuflisted

      nnoremap <buffer> q <Cmd>Close<CR>

      b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
      b:undo_ftplugin ..= '| setlocal buflisted< | nunmap <buffer> q'
    }
  augroup END
enddef
# }}}

# Shougo/ddu.vim {{{
augroup vimrc:hooks:ddu.vim
  autocmd!
  autocmd User DenopsReady ++once {
    DduVim()
  }
augroup END

def DduVim()
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
    uiParams: {
      ff: {
        cursorPos: 1,
      },
    },
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
      nnoremap <buffer> I <ScriptCmd>ddu#ui#do_action('openFilterWindow')<CR><C-B>
      nnoremap <buffer> <Space> <ScriptCmd>ddu#ui#do_action('toggleSelectItem')<CR>
      nnoremap <buffer> q <ScriptCmd>ddu#ui#do_action('quit')<CR>
    }
  augroup END
enddef
# }}}

# Einenlum/yaml-revealer {{{
augroup vimrc:hooks:yaml-revealer
  autocmd!
  autocmd SourcePre */yaml-revealer/*.vim ++once {
    YamlRevealer()
  }
augroup END

def YamlRevealer()
  command! SearchYamlKey {
    SearchYamlKey()
  }
enddef
# }}}

# yegappan/lsp {{{
augroup vimrc:hooks:lsp
  autocmd!
  autocmd SourcePre */lsp/*.vim ++once {
    Lsp()
  }
augroup END

def Lsp()
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

  if executable('docker-language-server')
    add(servers, {
      name: 'docker-language-server',
      filetype: ['dockerfile'],
      path: 'docker-language-server',
      args: ['start', '--stdio'],
    })
  endif

  g:LspAddServer(servers)
enddef
# }}}

# dstein64/vim-startuptime {{{
augroup vimrc:hooks:vim-startuptime
  autocmd!
  autocmd SourcePre */vim-startuptime/*.vim ++once {
    VimStartuptime()
  }
augroup END

def VimStartuptime()
  augroup vimrc:VimStartuptime
    autocmd!
    autocmd Filetype startuptime {
      nnoremap <buffer> q <Cmd>quit<CR>
    }
  augroup END
enddef
# }}}

# vim-denops/denops.vim {{{
augroup vimrc:hooks:denops.vim
  autocmd!
  autocmd SourcePre */denops.vim/*.vim ++once {
    DenopsVim()
  }
augroup END

def DenopsVim()
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
augroup vimrc:hooks:vim-qf-preview
  autocmd!
  # ":runtime", which ftplugin loading uses it, doesn't fire
  # "Source{Pre,Post}" events because perhaps it's not a ":source".
  autocmd FileType qf ++once {
    if g:maxpac.Loaded('vim-qf-preview')
      VimQfPreviewFtplugin()
      VimQfPreview()
    endif
  }
augroup END

def VimQfPreview()
  augroup vimrc:VimQfPreview
    autocmd!
    autocmd FileType qf {
      VimQfPreviewFtplugin()
    }
  augroup END
enddef

def VimQfPreviewFtplugin()
  nnoremap <buffer> p <Plug>(qf-preview-open)

  b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
  b:undo_ftplugin ..= '| nunmap <buffer> p'
enddef
# }}}

# psliwka/vim-dirtytalk {{{
augroup vimrc:hooks:vim-dirtytalk
  autocmd!
  autocmd SourcePost */vim-dirtytalk/*.vim ++once {
    VimDirtytalk()
  }
augroup END

def VimDirtytalk()
  set spelllang+=programming

  if Pathname.new($MYVIMDIR).Join('spell/programming.*.spl').Value()->glob()->empty()
    execute 'silent DirtytalkUpdate'
  endif
enddef

def VimDirtytalkPostUpdate(_hooktype: string, _name: string)
  if exists(':DirtytalkUpdate') == 2
    execute 'silent DirtytalkUpdate'
  endif
enddef
# }}}

# bfrg/vim-qf-history {{{
augroup vimrc:hooks:vim-qf-history
  autocmd!
  autocmd SourcePre */vim-qf-history/*.vim ++once {
    VimQfHistory()
  }
augroup END

def VimQfHistory()
  augroup vimrc:VimQfHistory
    autocmd!
    autocmd QuickFixCmdPost chistory {
      cwindow
    }
    autocmd QuickFixCmdPost lhistory {
      lwindow
    }
  augroup END
enddef
# }}}
# }}}

# Plugin registrations. {{{
# NOTE: Maybe "+clientserver" is disabled in macOS even if a Vim is compiled
# with "--with-features=huge".
if has('clientserver')
  g:maxpac.Add('thinca/vim-singleton')
endif

g:maxpac.Add('itchyny/lightline.vim')
g:maxpac.Add('a5ob7r/lightline-otf') # Load lightline-otf earlier than lightline.vim.

# Operators.
g:maxpac.Add('kana/vim-operator-user')
g:maxpac.Add('kana/vim-operator-replace')

# Text objects.
g:maxpac.Add('kana/vim-textobj-user')
g:maxpac.Add('D4KU/vim-textobj-chainmember')
g:maxpac.Add('Julian/vim-textobj-variable-segment')
g:maxpac.Add('deris/vim-textobj-enclosedsyntax')
g:maxpac.Add('kana/vim-textobj-datetime')
g:maxpac.Add('kana/vim-textobj-entire')
g:maxpac.Add('kana/vim-textobj-indent')
g:maxpac.Add('kana/vim-textobj-line')
g:maxpac.Add('kana/vim-textobj-syntax')
g:maxpac.Add('mattn/vim-textobj-url')
g:maxpac.Add('osyo-manga/vim-textobj-blockwise')
g:maxpac.Add('saaguero/vim-textobj-pastedtext')
g:maxpac.Add('sgur/vim-textobj-parameter')
g:maxpac.Add('thinca/vim-textobj-comment')

g:maxpac.Add('machakann/vim-textobj-delimited')
g:maxpac.Add('machakann/vim-textobj-functioncall')

# Filetype plugins.
g:maxpac.Add('Einenlum/yaml-revealer')
g:maxpac.Add('LumaKernel/coqpit.vim')
g:maxpac.Add('Vftdan/vim-syntax-libconfig')
g:maxpac.Add('a5ob7r/shellcheckrc.vim')
g:maxpac.Add('a5ob7r/tig.vim')
g:maxpac.Add('aliou/bats.vim')
g:maxpac.Add('chrisbra/csv.vim')
g:maxpac.Add('fladson/vim-kitty')
g:maxpac.Add('kchmck/vim-coffee-script')
g:maxpac.Add('keith/rspec.vim')
g:maxpac.Add('kyoh86/vim-jsonl')
g:maxpac.Add('neovimhaskell/haskell-vim')
g:maxpac.Add('pocke/rbs.vim')
g:maxpac.Add('preservim/vim-markdown')
g:maxpac.Add('yasuhiroki/github-actions-yaml.vim')
g:maxpac.Add('zorab47/procfile.vim')

# Misc.
g:maxpac.Add('Eliot00/git-lens.vim')
g:maxpac.Add('KeitaNakamura/neodark.vim')
g:maxpac.Add('a5ob7r/chmod.vim')
g:maxpac.Add('a5ob7r/linefeed.vim')
g:maxpac.Add('a5ob7r/rspec-daemon.vim')
g:maxpac.Add('airblade/vim-gitgutter')
g:maxpac.Add('andymass/vim-matchup')
g:maxpac.Add('azabiong/vim-highlighter')
g:maxpac.Add('bfrg/vim-qf-history')
g:maxpac.Add('bfrg/vim-qf-preview')
g:maxpac.Add('bronson/vim-trailing-whitespace')
g:maxpac.Add('dstein64/vim-startuptime')
g:maxpac.Add('girishji/vimbits') # For ":h vimtips".
g:maxpac.Add('gpanders/vim-oldfiles')
g:maxpac.Add('haya14busa/vim-asterisk')
g:maxpac.Add('hrsh7th/vim-vsnip')
g:maxpac.Add('hrsh7th/vim-vsnip-integ')
g:maxpac.Add('itchyny/screensaver.vim')
g:maxpac.Add('junegunn/goyo.vim')
g:maxpac.Add('junegunn/vader.vim')
g:maxpac.Add('junegunn/vim-easy-align')
g:maxpac.Add('k-takata/minpac')
g:maxpac.Add('kannokanno/previm')
g:maxpac.Add('kyoh86/vim-ripgrep')
g:maxpac.Add('lambdalisue/vital-Whisky')
g:maxpac.Add('liuchengxu/vista.vim')
g:maxpac.Add('machakann/vim-sandwich')
g:maxpac.Add('machakann/vim-swap')
g:maxpac.Add('maximbaz/lightline-ale')
g:maxpac.Add('monaqa/modesearch.vim')
g:maxpac.Add('psliwka/vim-dirtytalk', { do: VimDirtytalkPostUpdate })
g:maxpac.Add('rafamadriz/friendly-snippets')
g:maxpac.Add('rhysd/git-messenger.vim')
g:maxpac.Add('thinca/vim-localrc')
g:maxpac.Add('thinca/vim-prettyprint')
g:maxpac.Add('thinca/vim-themis')
g:maxpac.Add('tpope/vim-endwise')
g:maxpac.Add('tyru/eskk.vim')
g:maxpac.Add('tyru/open-browser.vim')
g:maxpac.Add('vim-jp/vital.vim')
g:maxpac.Add('w0rp/ale')
g:maxpac.Add('yegappan/lsp')

# =============================================================================

# denops.vim

if executable('deno')
  g:maxpac.Add('vim-denops/denops.vim')

  g:maxpac.Add('lambdalisue/gin.vim')
  g:maxpac.Add('Shougo/ddu.vim')

  g:maxpac.Add('Shougo/ddu-ui-ff')

  g:maxpac.Add('4513ECHO/ddu-source-ghq')
  g:maxpac.Add('Shougo/ddu-source-file_rec')
  g:maxpac.Add('shun/ddu-source-buffer')

  g:maxpac.Add('matsui54/ddu-filter-fzy')

  g:maxpac.Add('Shougo/ddu-kind-file')
endif
# }}}
# }}}

# Filetypes {{{
filetype plugin indent on

EnableFiletypeRedetection4DotLocal
# }}}

# Syntax {{{
syntax enable
# }}}

# =============================================================================

# vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
