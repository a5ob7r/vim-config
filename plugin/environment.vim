" List names and values of environment variables and filter them.
function! s:environments(bang, ...) abort
  let l:env = environ()
  let l:keys = sort(keys(l:env))

  let l:regex = a:0 > 0 ? a:1 : ''

  for l:k in l:keys
    if empty(a:bang)
      if l:k !~# l:regex
        continue
      endif
    else
      if l:k !~? l:regex
        continue
      endif
    endif

    let l:v = l:env[l:k]

    if l:v =~# "'"
      if l:v =~# '"'
        let l:v = substitute(l:v, '"', '\\"', 'g')
      endif

      echo printf('%s="%s"', l:k, l:v)
    elseif l:v =~# '\m\(\s\|\r\|\n\|["!#\^\$\&|=?\\\*\[\]\{\}()<>]\)'
      echo printf("%s='%s'", l:k, l:v)
    else
      echo printf('%s=%s', l:k, l:v)
    endif
  endfor
endfunction

command! -bang -nargs=* Environments call s:environments(<q-bang>, <q-args>)
