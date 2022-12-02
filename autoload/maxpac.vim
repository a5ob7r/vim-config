" "maxpac" is a complement plugin manager for minpac.
"
" TODO: Implement a dependency resolver and loading.

" Convert a URL into a plugin name.
function! s:plugname(url) abort
  let l:tail = split(a:url, '/')[-1]
  return substitute(l:tail, '.git$', '', '')
endfunction

" Whether or not the plugin is loadable.
function! s:loadable(name) abort
  for l:path in split(&packpath, ',')
    if !globpath(l:path, 'pack/*/opt/' . a:name)->empty()
      return v:true
    endif
  endfor

  return v:false
endfunction

" Initialize a configuration store of maxpac.
function! maxpac#initialize() abort
  let s:maxpac = {
    \ 'names': [],
    \ 'confs': {}
    \ }
endfunction

" Return a dictionary as a plugin configiration base for maxpac.
function! maxpac#plugconf(...) abort
  let l:name = get(a:, 1, '')

  return {
    \ 'name': l:name,
    \ 'config': { 'type': 'opt' },
    \ 'pre': { -> v:null },
    \ 'post': { -> v:null },
    \ 'fallback': { -> v:null },
    \ 'deps': []
    \ }
endfunction

" A synonym of "minpac#init()".
function! maxpac#init(...) abort
  let l:config = get(a:, 1, {})

  call minpac#init(l:config)
endfunction

" Load "minpac" and initialize "maxpac".
function! maxpac#begin(...) abort
  " Initialize maxmac.
  call maxpac#initialize()

  try
    packadd minpac
  catch
    return v:false
  endtry

  let l:config = get(a:, 1, {})

  " Initialize minpac.
  call maxpac#init(l:config)

  return v:true
endfunction

" Load plugins that each of them may have hook functions. The hooks are called
" before or after loading one.
function! maxpac#end() abort
  for l:name in s:maxpac.names
    let l:conf = s:maxpac.confs[l:name]

    if s:loadable(s:plugname(l:name)) && type(l:conf.pre) == type(function('tr'))
      call l:conf.pre()
    endif

    if !maxpac#load(l:name, l:conf.config)
      if type(l:conf.fallback) == type(function('tr'))
        call l:conf.fallback()
      endif

      continue
    endif

    if type(l:conf.post) == type(function('tr'))
      call l:conf.post()
    endif
  endfor
endfunction

" Store a plugin configuration.
function! maxpac#add(conf) abort
  if type(a:conf) == type({})
    let l:conf = a:conf
  elseif type(a:conf) == type('')
    let l:conf = maxpac#plugconf(a:conf)
  else
    " TODO: Throw an error.
    return
  endif

  call add(s:maxpac.names, l:conf.name)
  let s:maxpac.confs[l:conf.name] = l:conf
endfunction

" Load a standalone plugin. The plugin is only managed by minpac, but maxpac.
" This function works as a synonym of "minpac#add()" and "packadd".
"
" NOTE: This function initializes minpac without any arguments if minpac isn't
" initialized yet. If you want to initialize with non-default value,
" initialize with the value beforehand.
function! maxpac#load(url, ...) abort
  try
    if !exists('g:minpac#opt')
      call maxpac#init()
    endif
  catch /^Vim\%((\a\+)\)\=:E117:/
    return v:false
  endtry

  let l:config = get(a:, 1, { 'type': 'opt' })
  let l:name = s:plugname(a:url)

  " Register the plugin to minpac to update.
  call minpac#add(a:url, l:config)

  " Load the plugin instantly.
  try
    execute 'packadd' l:name
  catch
    " Ignore any errors.
  endtry

  " Whether or not the plugin is added.
  return printf(',%s,', &runtimepath) =~# printf(',/[^,]*/%s,', l:name)
endfunction
