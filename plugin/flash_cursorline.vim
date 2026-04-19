vim9script

#
# This joke plugin is inspired from https://github.com/inside/vim-search-pulse.
#

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

    execute $'highlight {this.group} {join(args)}'
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

command! FlashCursorLine FlashCursorLine(true)
command! NoFlashCursorLine FlashCursorLine(false)

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
