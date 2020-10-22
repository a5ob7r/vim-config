function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader><Space> <plug>(lsp-hover)
endfunction

function! s:on_load_pre()
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_float_delay = 200
  let g:lsp_highlight_references_enabled = 1
  let g:lsp_semantic_enabled = 1

  augroup LSP_INSTALL
    au!
    au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  augroup end
endfunction

function! s:on_load_post()
  augroup REGISTER_LSPS
    au!

    if executable('pyls')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'pyls',
            \ 'cmd': {server_info->['pyls']},
            \ 'whitelist': ['python'],
            \ })
    endif

    if executable('clangd')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'clangd',
            \ 'cmd': {server_info->['clangd']},
            \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
            \ })
    endif

    if executable('bash-language-server')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'bash-language-server',
            \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
            \ 'whitelist': ['sh'],
            \ })
    endif

    if executable('intelephense')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'intelephense',
            \ 'cmd': {server_info->[&shell, &shellcmdflag, 'intelephense --stdio']},
            \ 'initialization_options': {"storagePath": $HOME . "/.cache/intelephense"},
            \ 'whitelist': ['php'],
            \ })
    endif

    if executable('haskell-language-server-wrapper') && executable('haskell-language-server')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'hls',
            \ 'cmd': {server_info->[&shell, &shellcmdflag, 'haskell-language-server-wrapper --lsp']},
            \ 'whitelist': ['haskell'],
            \ })
    endif

    " au User lsp_setup call lsp#register_server({
    "       \ 'name': 'solargraph',
    "       \ 'cmd': {server_info->['socat', '-', 'TCP:localhost:7658,shut-none']},
    "       \ 'whitelist': ['ruby'],
    "       \ })
    if executable('solargraph')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'solargraph',
            \ 'cmd': {server_info->['solargraph', 'stdio']},
            \ 'whitelist': ['ruby'],
            \ })
    endif
  augroup end
endfunction

function! s:loaded_on()
  return 'start'
endfunction

function! s:depends()
  return ['github/prabirshrestha/async.vim']
endfunction
