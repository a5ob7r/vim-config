function! s:exec(...) abort
  let l:exec = 'rg'
  let l:args = ['--vimgrep'] + a:000

  cexpr ([l:exec] + l:args)->join()->system()
  copen
endfunction

function! ripgrep#run(bang, ...) abort
  if empty(a:bang)
    let l:q = get(a:000, 0, expand('<cword>'))
    let l:args = [shellescape(l:q)]
  else
    let l:args = a:000
  endif

  call call('s:exec', l:args)
endfunction

function! ripgrep#visual() abort
  let l:q = utils#get_visual_selection()
  call s:exec(l:q)
endfunction
