" t-takata/minpac {{{
function! PackInit() abort
  call minpac#init()

  call minpac#add('t-takata/minpac', { 'type': 'opt' })
  call minpac#add('KeitaNakamura/neodark.vim')
  call minpac#add('SirVer/ultisnips')
  call minpac#add('airblade/vim-gitgutter')
  call minpac#add('bronson/vim-trailing-whitespace')
  call minpac#add('editorconfig/editorconfig-vim')
  call minpac#add('honza/vim-snippets')
  call minpac#add('itchyny/lightline.vim')
  call minpac#add('itchyny/vim-gitbranch')
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('kannokanno/previm')
  call minpac#add('lervag/vimtex')
  call minpac#add('liuchengxu/vista.vim')
  call minpac#add('mattn/emmet-vim')
  call minpac#add('mattn/vim-lexiv')
  call minpac#add('maximbaz/lightline-ale')
  call minpac#add('mechatroner/rainbow_csv')
  call minpac#add('prabirshrestha/async.vim')
  call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
  call minpac#add('prabirshrestha/asyncomplete-ultisnips.vim')
  call minpac#add('prabirshrestha/asyncomplete.vim')
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('rhysd/git-messenger.vim')
  call minpac#add('sheerun/vim-polyglot')
  call minpac#add('thinca/vim-localrc')
  call minpac#add('tpope/vim-commentary')
  call minpac#add('tpope/vim-endwise')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('w0rp/ale')
endfunction

command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
command! PackStatus call minpac#status()
" }}}

" KeitaNakamura/neodark.vim {{{
let g:neodark#background='#202020'
colorscheme neodark
" }}}

" SirVer/ultisnips {{{
augroup USE_RSPEC_AS_RUBY
  au!
  autocmd Filetype rspec UltiSnipsAddFiletypes ruby
augroup end
" }}}

" airblade/vim-gitgutter {{{
let g:gitgutter_sign_added = 'A'
let g:gitgutter_sign_modified = 'M'
let g:gitgutter_sign_removed = 'D'
let g:gitgutter_sign_removed_first_line = 'd'
let g:gitgutter_sign_modified_removed = 'm'
" }}}

" itchyny/lightline.vim {{{
let g:lightline = {
      \ 'active': {
      \   'left': [
      \       [ 'mode', 'paste' ],
      \       [ 'gitbranch', 'readonly', 'relativepath', 'modified' ],
      \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
      \       [ 'lsp_errors', 'lsp_warnings', 'lsp_informations', 'lsp_hints', 'lsp_ok' ]
      \     ]
      \   },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \   },
      \ 'component_expand': {
      \   'linter_checking': 'lightline#ale#checking',
      \   'linter_warnings': 'lightline#ale#warnings',
      \   'linter_errors': 'lightline#ale#errors',
      \   'linter_ok': 'lightline#ale#ok',
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
      \ },
      \ 'colorscheme': 'neodark'
      \ }
" }}}

" junegunn/fzf.vim {{{
let g:fzf_buffers_jump = 1

nnoremap <leader>b :Buffers<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>/ :BLines<CR>
nnoremap <leader>g :Rg<CR>
" }}}

" lervag/vimtex {{{
let g:tex_flavor = 'latex'

if has('linux')
  let g:vimtex_view_method = 'zathura'
endif
" }}}

" liuchengxu/vista.vim {{{
let g:vista_sidebar_width = 50
nnoremap <leader>v :Vista!!<CR>
" }}}

" prabirshrestha/vim-lsp {{{
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader><Space> <plug>(lsp-hover)
  nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
  nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)

  ALEDisableBuffer
endfunction

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_float_delay = 200
let g:lsp_highlight_references_enabled = 1
let g:lsp_semantic_enabled = 1

augroup LSP_INSTALL
  au!
  au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup end

augroup OnLSP
  au!
  au User lsp_diagnostics_updated call lightline#update()
augroup end

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

  if executable('solargraph')
    au User lsp_setup call lsp#register_server({
          \ 'name': 'solargraph',
          \ 'cmd': {server_info->['solargraph', 'stdio']},
          \ 'initialization_options': {
          \   "diagnostics": "true",
          \   "rename": "true",
          \   "useBundler": "true"
          \ },
          \ 'whitelist': ['ruby'],
          \ })
  endif
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
  let l:counts = lsp#get_buffer_diagnostics_counts()
  let l:ok = filter(l:counts, 'v:val != 0')->len() == 0
  if l:ok | return 'OK' | endif
  return ''
endfunction
" }}}

" rhysd/git-messenger.vim {{{
let g:git_messenger_include_diff = 'all'
let g:git_messenger_always_into_popup = v:true
let g:git_messenger_max_popup_height = 15
" }}}

" sheerun/vim-polyglot {{{
let g:polyglot_disabled = ['sensible']
" }}}

" w0rp/ale {{{
highlight ALEErrorSign ctermfg=9 guifg=#C30500
highlight ALEWarningSign ctermfg=11 guifg=#ED6237
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0
let g:ale_linters = {
      \ 'zsh': ['shellcheck']
      \}
let g:ale_python_auto_pipenv = 1
let g:ale_disable_lsp = 1

nmap <silent> <C-p> <Plug>(ale_previous_wrap)
nmap <silent> <C-n> <Plug>(ale_next_wrap)
" }}}

packloadall

" After plugin loaded {{{
" prabirshrestha/asyncomplete-ultisnips.vim {{{
call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
      \ 'name': 'ultisnips',
      \ 'whitelist': ['*'],
      \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
      \ }))
" }}}
" }}}

" vim:set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
