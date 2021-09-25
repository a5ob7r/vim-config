let g:lsp_settings_enable_suggestions = 0
let g:lsp_settings = {
      \ 'texlab': {
      \   'workspace_config': {
      \     'latex': {
      \       'build': {
      \         'args': ['%f'],
      \         'onSave': v:true,
      \         'forwardSearchAfter': v:true
      \         },
      \       'forwardSearch': {
      \         'executable': 'zathura',
      \         'args': ['--synctex-forward', '%l:1:%f', '%p']
      \         }
      \       }
      \     }
      \   }
      \ }
