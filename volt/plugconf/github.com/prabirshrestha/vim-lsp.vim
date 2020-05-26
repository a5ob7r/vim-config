" vim:et:sw=2:ts=2

function! s:on_load_pre()
  " Plugin configuration like the code written in vimrc.
  " This configuration is executed *before* a plugin is loaded.
  let g:lsp_diagnostics_enabled = 0

  map <leader>d <plug>(lsp-definition)
endfunction

function! s:on_load_post()
  " Plugin configuration like the code written in vimrc.
  " This configuration is executed *after* a plugin is loaded.
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
      au FileType c,cpp,objc,objcpp,cc setlocal omnifunc=lsp#complete
    endif

    if executable('bash-language-server')
      au User lsp_setup call lsp#register_server({
            \ 'name': 'bash-language-server',
            \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
            \ 'whitelist': ['sh'],
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
  augroup end
endfunction

function! s:loaded_on()
  " This function determines when a plugin is loaded.
  "
  " Possible values are:
  " * 'start' (a plugin will be loaded at VimEnter event)
  " * 'filetype=<filetypes>' (a plugin will be loaded at FileType event)
  " * 'excmd=<excmds>' (a plugin will be loaded at CmdUndefined event)
  " <filetypes> and <excmds> can be multiple values separated by comma.
  "
  " This function must contain 'return "<str>"' code.
  " (the argument of :return must be string literal)

  return 'start'
endfunction

function! s:depends()
  " Dependencies of this plugin.
  " The specified dependencies are loaded after this plugin is loaded.
  "
  " This function must contain 'return [<repos>, ...]' code.
  " (the argument of :return must be list literal, and the elements are string)
  " e.g. return ['github.com/tyru/open-browser.vim']

  return ['github/prabirshrestha/async.vim']
endfunction
