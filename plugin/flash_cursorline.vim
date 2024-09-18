vim9script

var timer_id = -1
var idx = 0
var original_cursorline_highlight = null_string

const bw_colors = [
  [ 16, '#000000'],
  [232, '#080808'],
  [233, '#121212'],
  [234, '#1c1c1c'],
  [235, '#262626'],
  [236, '#303030'],
  [237, '#3a3a3a'],
  [238, '#444444'],
  [239, '#4e4e4e'],
  [240, '#585858'],
  [241, '#626262'],
  [242, '#6c6c6c'],
  [243, '#767676'],
  [244, '#808080'],
  [245, '#8a8a8a'],
  [246, '#949494'],
  [247, '#9e9e9e'],
  [248, '#a8a8a8'],
  [249, '#b2b2b2'],
  [250, '#bcbcbc'],
  [251, '#c6c6c6'],
  [252, '#d0d0d0'],
  [253, '#dadada'],
  [254, '#e4e4e4'],
  [231, '#ffffff'],
]

def Idx(i: number): number
  return i < len(bw_colors) ? i : - (i + 1 - len(bw_colors))
enddef

def SetCursorLineBackground(ctermbg: number, guibg: string)
  execute $'highlight CursorLine ctermbg={ctermbg} guibg={guibg}'
enddef

def FlashCursorLineHandler(_tid: number)
  const [ctermbg, guibg] = bw_colors[Idx(idx)]

  SetCursorLineBackground(ctermbg, guibg)

  ++idx

  if idx >= len(bw_colors) * 2
    ResetFlashCursorLine()
  endif
enddef

def SetFlashCursorLineTimer()
  timer_id = timer_start(2, FlashCursorLineHandler, { repeat: len(bw_colors) * 2 })
enddef

def ResetFlashCursorLine()
  if timer_id == -1
    original_cursorline_highlight = execute('highlight CursorLine')->substitute('\n\|\sxxx\s', '', 'g')
  endif

  timer_stop(timer_id)
  timer_id = -1
  idx = 0

  execute $'highlight {original_cursorline_highlight}'
enddef

def FlashCursorLine(enable: bool)
  augroup FlashCursorLine
    autocmd!

    if enable
      autocmd WinEnter * {
        ResetFlashCursorLine()
        SetFlashCursorLineTimer()
      }
    endif
  augroup END
enddef

command! FlashCursorLine FlashCursorLine(true)
command! NoFlashCursorLine FlashCursorLine(false)

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
