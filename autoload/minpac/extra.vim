" minpac-extra

let s:vim_root = expand('<sfile>:p:h:h:h')
let s:minpac_extra_plugconf_root = get(g:, 'minpac_extra_plugconf_root', 'plugconf')

" Convert URL to separated plugin config path.
function! s:plugconf_from(url)
  let l:plugconf = substitute(a:url, '^https\{,1}://', '', '')
  let l:plugconf = substitute(l:plugconf, '\.git$', '', '')

  return join([s:vim_root, minpac#extra#plugconf_root(), l:plugconf . '.vim'], '/')
endfunction

" Convert URL to plugin name.
function! s:plugname_from(url)
  let l:tail = split(a:url, '/')[-1]
  return substitute(l:tail, '.git$', '', '')
endfunction

function! s:pack_home() abort
  return split(&packpath, ',')[0] . '/pack'
endfunction

function! minpac#extra#plugconf_root()
  return s:minpac_extra_plugconf_root
endfunction

function! minpac#extra#install() abort
  let l:minpac_path = s:pack_home() . '/minpac/opt/minpac'
  let l:minpac_url = 'https://github.com/k-takata/minpac.git'

  if isdirectory(l:minpac_path) || ! executable('git')
    return
  endif

  call system(printf('git clone %s %s', l:minpac_url, l:minpac_path))
endfunction

" Whether or not the plugin is installed.
function! minpac#extra#exists(url)
  let l:name = s:plugname_from(a:url)

  return ! empty(minpac#getpackages('minpac', '*', l:name))
endfunction

" Source minpac if it has not been done yet.
function! minpac#extra#load()
  if exists('g:loaded_minpac')
    return v:true
  endif

  try
    packadd minpac
    return v:true
  catch
    return v:false
  endtry
endfunction

" Initialize minpac if it has not been done yet.
function! minpac#extra#init(...)
  let l:config = get(a:, 1, {})
  " If minpac has not been initialized.
  if !exists('g:minpac#opt')
    call minpac#init(l:config)
  endif
endfunction

" Source and initialize minpac.
function! minpac#extra#setup(...)
  let l:config = get(a:, 1, {})
  if ! minpac#extra#load()
    return v:false
  endif

  call minpac#extra#init(l:config)
  return v:true
endfunction

" minpac#add with extra. Do nothing if no minpac is installed.
function! minpac#extra#add(url, ...)
  let l:config = get(a:, 1, { 'type': 'opt' })
  if ! minpac#extra#setup()
    return
  endif

  " Register plugin to minpac to update.
  call minpac#add(a:url, l:config)

  let l:name = s:plugname_from(a:url)
  let l:url = minpac#getpluginfo(l:name).url
  let l:plugconf = s:plugconf_from(l:url)

  if ! minpac#extra#exists(l:url)
    return
  endif

  if filereadable(l:plugconf)
    execute 'source' l:plugconf
  endif

  if ! utils#is_packadded(l:name)
    execute 'packadd' l:name
  endif
endfunction

" Load all opt plugins.
function! minpac#extra#load_opt_plugins()
  for l:name in minpac#getpackages('minpac', 'opt', '*', v:true)
    try
      let l:url = minpac#getpluginfo(l:name).url
      call minpac#extra#add(l:url)
    catch /^Vim\%((\a\+)\)\=:E716:/
      " Ignore a disabled plugin.
    endtry
  endfor
endfunction

function! minpac#extra#install_and_load_plugins()
  " NOTE: Must specify not '*' but empty string or omit it as first argument
  " to install all registered plugins.
  call minpac#update('', { 'do': 'call minpac#extra#load_opt_plugins()' })
endfunction
