function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gD <plug>(lsp-implementation)
  nmap <buffer> <leader>r <plug>(lsp-rename)
  nmap <buffer> <leader>h <plug>(lsp-hover)
  nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
  nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)

  nmap <buffer> <leader>lf <plug>(lsp-document-format)
  nmap <buffer> <leader>la <plug>(lsp-code-action)
  nmap <buffer> <leader>ll <plug>(lsp-code-lens)
  nmap <buffer> <leader>lr <plug>(lsp-references)

  let b:vim_lsp_enabled = 1
endfunction

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_delay = 200
let g:lsp_semantic_enabled = 1

augroup LSP_INSTALL
  au!
  au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup end

augroup OnLSP
  au!
  au User lsp_diagnostics_updated call lightline#update()
augroup end

function! LspErrorCount() abort
  let l:errors = lsp#get_buffer_diagnostics_counts().error
  if l:errors == 0 | return '' | endif
  return 'E: ' . l:errors
endfunction

function LspWarningCount() abort
  let l:warnings = lsp#get_buffer_diagnostics_counts().warning
  if l:warnings == 0 | return '' | endif
  return 'W: ' . l:warnings
endfunction

function! LspInformationCount() abort
  let l:informations = lsp#get_buffer_diagnostics_counts().information
  if l:informations == 0 | return '' | endif
  return 'I: ' . l:informations
endfunction

function! LspHintCount() abort
  let l:hints = lsp#get_buffer_diagnostics_counts().hint
  if l:hints == 0 | return '' | endif
  return 'H: ' . l:hints
endfunction

function! LspOk() abort
  if !get(b:, 'vim_lsp_enabled', 0)
    return ''
  endif

  let l:counts = lsp#get_buffer_diagnostics_counts()
  let l:not_zero_counts = filter(l:counts, 'v:val != 0')
  let l:ok = len(l:not_zero_counts) == 0
  if l:ok | return 'OK' | endif
  return ''
endfunction
