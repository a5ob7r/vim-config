" "maxpac" is a complement plugin manager for minpac.
"
" TODO: Implement a dependency resolver and loading.

" Whether or not the plugin is loadable.
function! s:Loadable(uri) abort
  return
    \ a:uri =~# '^\%(file://\)\=/'
    \ ? !substitute(a:uri, '^file://', '', '')->glob()->empty()
    \ : !globpath(&packpath, $'pack/*/opt/{maxpac#plugname(a:uri)}')->empty()
endfunction

" Whether or not the plugin is loaded.
function! s:Loaded(name) abort
  return !globpath(&runtimepath, $'pack/*/opt/{a:name}')->empty()
endfunction

" Convert an URI into a plugin (directory) name.
function! maxpac#plugname(uri) abort
  const l:tail = split(a:uri, '/')[-1]
  return a:uri =~# '^https\=://' ? substitute(l:tail, '\C\.git$', '', '') : l:tail
endfunction

" Initialize a configuration store of maxpac.
function! maxpac#initialize() abort
  let s:maxpac = #{
    \ names: [],
    \ confs: {}
    \ }
endfunction

" Return a dictionary as a plugin configiration base for maxpac.
function! maxpac#plugconf(name) abort
  return #{
    \ name: a:name,
    \ config: #{ type: 'opt' },
    \ pre: { -> v:null },
    \ post: { -> v:null },
    \ fallback: { -> v:null },
    \ deps: []
    \ }
endfunction

" Load "minpac" and initialize "maxpac".
function! maxpac#begin(config = {}) abort
  " Initialize maxmac.
  call maxpac#initialize()

  try
    packadd minpac
  catch
    return v:false
  endtry

  call minpac#init(a:config)

  return v:true
endfunction

" Load plugins that each of them may have hook functions. The hooks are called
" before or after loading one.
function! maxpac#end() abort
  for l:name in s:maxpac.names
    let l:conf = s:maxpac.confs[l:name]

    if s:Loadable(l:name) && type(l:conf.pre) == type(function('tr'))
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
function! maxpac#add(name) abort
  let l:conf = maxpac#plugconf(a:name)

  call add(s:maxpac.names, l:conf.name)
  let s:maxpac.confs[l:conf.name] = l:conf

  return l:conf
endfunction

" Load a standalone plugin. The plugin is only managed by minpac, but maxpac.
" This function works as a synonym of "minpac#add()" and "packadd".
"
" This can handle local plugins such as "files:///path/to/plugin" too. However
" they are just loaded by hand and are managed by neither minpac and maxpac.
"
" NOTE: This function initializes minpac without any arguments if minpac isn't
" initialized yet. If you want to initialize with non-default value,
" initialize with the value beforehand.
function! maxpac#load(uri, config = #{ type: 'opt' }) abort
  try
    if !exists('g:minpac#opt')
      call minpac#init()
    endif
  catch /^Vim\%((\a\+)\)\=:E117:/
    return v:false
  endtry

  " TODO: Support drive letters for MS-Windows.
  if a:uri =~# '^\%(file://\)\=/'
    const l:path = substitute(a:uri, '^file://', '', '')

    if glob(l:path)->empty()
      return 0
    endif

    execute $'set runtimepath^={fnameescape(l:path)}'

    const l:after = globpath(l:path, 'after')
    if !empty(l:after)
      execute $'set runtimepath+={fnameescape(l:after)}'
    endif

    for l:plugin in globpath(l:path, 'plugin/**/*.vim', 0, 1)
      execute 'source' fnameescape(l:plugin)
    endfor

    return 1
  else
    const l:name = maxpac#plugname(a:uri)

    " Register the plugin to minpac to update.
    call minpac#add(a:uri, a:config)

    " Load the plugin instantly.
    try
      execute 'packadd' l:name
    catch
      " Ignore any errors.
    endtry

    return s:Loaded(l:name)
  endif
endfunction
