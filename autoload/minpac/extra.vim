" minpac-extra

function! s:pack_home() abort
  return split(&packpath, ',')[0] . '/pack'
endfunction

function! minpac#extra#install() abort
  let l:minpac_path = s:pack_home() . '/minpac/opt/minpac'
  let l:minpac_url = 'https://github.com/k-takata/minpac.git'

  if isdirectory(l:minpac_path) || ! executable('git')
    return
  endif

  call system(printf('git clone %s %s', l:minpac_url, l:minpac_path))
endfunction

" Convert URL to plugin name.
function! s:url2name(url)
  return split(a:url, '/')[-1]
endfunction

" Whether or not the plugin is installed.
function! minpac#extra#exists(url)
  let l:name = s:url2name(a:url)

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
function! minpac#extra#init(config = {})
  " If minpac has not been initialized.
  if !exists('g:minpac#opt')
    call minpac#init(a:config)
  endif
endfunction

" Source and initialize minpac.
function! minpac#extra#setup(config = {})
  if ! minpac#extra#load()
    return v:false
  endif

  call minpac#extra#init(a:config)
  return v:true
endfunction

" minpac#add with extra. Do nothing if no minpac is installed.
function! minpac#extra#add(url, config = { 'type': 'opt' })
  if ! minpac#extra#setup()
    return
  endif

  " Register plugin to minpac to update.
  call minpac#add(a:url, a:config)

  let l:name = s:url2name(a:url)
  silent! execute printf('packadd %s', l:name)
endfunction

" Load all opt plugins.
function! minpac#extra#load_opt_plugins()
  for l:pack in minpac#getpackages('minpac', 'opt', '*', v:true)
    execute printf('packadd %s', l:pack)
  endfor
endfunction

function! minpac#extra#install_and_load_plugins()
  " NOTE: Must specify not '*' but empty string or omit it as first argument
  " to install all registered plugins.
  call minpac#update('', { 'do': 'call minpac#extra#load_opt_plugins()' })
endfunction
