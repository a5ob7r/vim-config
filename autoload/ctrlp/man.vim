if exists('g:loaded_ctrlp_man') && g:loaded_ctrlp_man
  finish
endif

let g:loaded_ctrlp_man = 1

let g:man_var = {
      \ 'init': 'ctrlp#man#init()',
      \ 'accept': 'ctrlp#man#accept',
      \ 'lname': 'man extension',
      \ 'sname': 'man',
      \ 'type': 'line',
      \ }

let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), g:man_var)
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

let s:candidates = []

function! ctrlp#man#init() abort
  return s:candidates
endfunction

function! ctrlp#man#accept(mode, str) abort
  call ctrlp#exit()

  let l:dict = ctrlp#man#parse(a:str)
  let l:cmd = printf('Man %s %s', l:dict.number, l:dict.name)

  " Load filetype plugin of `man` for `:Man` command without side effect of
  " the plugin.
  "
  " In accordance with manual need to run `runtime ftplugin/man.vim` to enable
  " `:Man`. Or `runtime! ftplugin/man.vim` to enable it even if multiple `man`
  " ftplugins are on runtimepath. They are to load `man` ftplugins without
  " filetype change to `man`. Maybe filetype plugins have some side effect.
  " These affect when load them on vimrc or different filetype buffer. So load
  " the plugins on new empty buffer to capture the effect inside the buffer.
  execute 'enew'
  set filetype=man

  execute l:cmd
endfunction

function! ctrlp#man#id() abort
  return s:id
endfunction

function! ctrlp#man#run(bang, ...) abort
  if empty(a:bang)
    let s:candidates = systemlist('apropos .')

    for l:word in a:000
      call filter(s:candidates, "v:val =~? '.*" . l:word . ".*'")
    endfor
  else
    let s:candidates = systemlist('apropos ' . join(a:000, ' '))
  endif

  call ctrlp#init(ctrlp#man#id())
endfunction

function! ctrlp#man#parse(desc) abort
  let l:arr = split(a:desc, ' (\|(\|)')

  return { 'number': l:arr[1], 'name': l:arr[0] }
endfunction
