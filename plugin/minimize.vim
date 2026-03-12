vim9script

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

# Minimize the current window, and make other window's height equally.
nnoremap <Plug>(xminimize) <ScriptCmd>Xminimize()<CR>
tnoremap <Plug>(xminimize) <ScriptCmd>Xminimize()<CR>

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
