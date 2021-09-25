let g:lightline = {
      \ 'active': {
      \   'left': [
      \       [ 'mode', 'paste' ],
      \       [ 'readonly', 'relativepath', 'modified' ],
      \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
      \       [ 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok' ]
      \     ]
      \   },
      \ 'component_expand': {
      \   'lsp_errors': 'LspErrorCount',
      \   'lsp_warnings': 'LspWarningCount',
      \   'lsp_informations': 'LspInformationCount',
      \   'lsp_hints': 'LspHintCount',
      \   'lsp_ok': 'LspOk'
      \ },
      \ 'component_type': {
      \   'linter_checking': 'left',
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \   'linter_ok': 'left',
      \   'lsp_errors': 'error',
      \   'lsp_warnings': 'warning',
      \   'lsp_informations': 'left',
      \   'lsp_hints': 'left',
      \   'lsp_ok': 'left'
      \ }
      \ }

function! s:update_lightline()
  if ! exists('g:loaded_lightline')
    return
  endif

  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

augroup update_lightline_colorscheme
  autocmd!
  autocmd ColorScheme * call s:update_lightline()
augroup END
