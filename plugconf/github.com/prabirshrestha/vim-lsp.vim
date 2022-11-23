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

  nnoremap <silent><buffer><expr> <C-j> lsp#scroll(+1)
  nnoremap <silent><buffer><expr> <C-k> lsp#scroll(-1)

  let b:vim_lsp_enabled = 1
endfunction

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_delay = 200
let g:lsp_semantic_enabled = 1

let g:lsp_experimental_workspace_folders = 1

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

function! s:lsp_log_file()
  return get(g:, 'lsp_log_file', '')
endfunction

command! CurrentLspLogging echo s:lsp_log_file()
command! -nargs=* -complete=file EnableLspLogging
      \ let g:lsp_log_file = empty(<q-args>) ? expand('~/vim-lsp.log') : <q-args>
command! DisableLspLogging let g:lsp_log_file = ''

function! s:view_lsp_log()
  let l:log = s:lsp_log_file()

  if filereadable(l:log)
    call term_start(
          \ printf('less %s', l:log),
          \ {
          \   'env': { 'LESS': '' },
          \   'term_finish': 'close',
          \ })
  endif
endfunction

command! ViewLspLog call s:view_lsp_log()

function! s:clear_lsp_log()
  let l:log = s:lsp_log_file()

  if filewritable(l:log)
    call writefile([], l:log)
  endif
endfunction

command! ClearLspLog call s:clear_lsp_log()
