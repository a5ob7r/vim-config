let g:lsp_settings_enable_suggestions = 0

let g:lsp_settings = get(g:, 'lsp_settings', {})
let g:lsp_settings['texlab'] = {
      \ 'workspace_config': {
      \   'latex': {
      \     'build': {
      \       'args': ['%f'],
      \       'onSave': v:true,
      \       'forwardSearchAfter': v:true
      \       },
      \     'forwardSearch': {
      \       'executable': 'zathura',
      \       'args': ['--synctex-forward', '%l:1:%f', '%p']
      \       }
      \     }
      \   }
      \ }
let g:lsp_settings['haskell-language-server'] = {
      \ 'cmd': ['haskell-language-server-wrapper', '--lsp']
      \ }
