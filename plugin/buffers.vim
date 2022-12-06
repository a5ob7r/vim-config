" ":buffers" as a dictionary.
function! s:buffers(bang, flags) abort
  let l:items = []

  for l:line in split(execute(printf('buffers%s %s', a:bang, a:flags)), '\n')
    let l:item = {}
    let l:matches = matchlist(l:line, '^\s*\([1-9]\d*\)\(.\{5}\) "\(.*\)" \s*line \(\d\+\)$')

    let l:item['bufnr'] = str2nr(l:matches[1])
    let l:item['indicators'] = l:matches[2]
    let l:item['filename'] = l:matches[3]
    let l:item['lnum'] = str2nr(l:matches[4])

    call add(l:items, l:item)
  endfor

  return l:items
endfunction

function! s:qfbuflines(info) abort
  let l:buffers = {}

  for l:buf in s:buffers('!', '')
    let l:buffers[l:buf['bufnr']] = l:buf
  endfor

  let l:items = getqflist({ 'id': a:info['id'], 'items': v:true }).items
  let l:ndigits = max([3] + map(copy(l:items), { _, val -> len(val['bufnr']) }))

  let l:lines = []

  for l:item in l:items[a:info['start_idx'] - 1 : a:info['end_idx'] - 1]
    let l:buffer = l:buffers[l:item['bufnr']]

    let l:line = printf(
      \ '%' . l:ndigits . 'd%s "%s"%s | %d col %d | %s', l:item['bufnr'],
      \ l:buffer['indicators'],
      \ l:buffer['filename'],
      \ join(map(range(max([0, 30 - 2 - len(l:buffer['filename'])])), "' '"), ''),
      \ l:item['lnum'],
      \ l:item['col'],
      \ l:item['text']
      \ )
    call add(l:lines, l:line)
  endfor

  return l:lines
endfunction

function! s:qfbuffers(bang, flags) abort
  let l:bufs = s:buffers(a:bang, a:flags)

  for l:buf in l:bufs
    let l:buf['text'] = get(getbufline(l:buf['bufnr'], l:buf['lnum']), 0, '')
  endfor

  call setqflist([], ' ', { 'items': l:bufs, 'title': 'Buffer Lists', 'quickfixtextfunc': 's:qfbuflines' })
  copen
endfunction

" "files", "buffers" and "ls", but view the outputs in a quickfix window.
command! -bang -bar -nargs=* Files call s:qfbuffers(<q-bang>, <q-args>)
command! -bang -bar -nargs=* Buffers call s:qfbuffers(<q-bang>, <q-args>)
command! -bang -bar -nargs=* Ls call s:qfbuffers(<q-bang>, <q-args>)
