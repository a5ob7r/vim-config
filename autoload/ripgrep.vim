function! ripgrep#run(...) abort
  let l:q = ''

  if a:0 == 0
    let l:q = expand('<cword>')
  else
    let l:q = a:1
  endif

  let l:query = shellescape(l:q)

  cexpr system("rg --vimgrep --hidden " . l:query)
  copen
endfunction

function! ripgrep#visual() abort
  let l:q = utils#get_visual_selection()
  call ripgrep#run(l:q)
endfunction
