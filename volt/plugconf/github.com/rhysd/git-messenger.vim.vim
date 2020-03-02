" vim:et:sw=2:ts=2

function! s:on_load_pre()
  let g:git_messenger_include_diff = 'all'
  let g:git_messenger_always_into_popup = v:true
  let g:git_messenger_max_popup_height = 15
endfunction

" Plugin configuration like the code written in vimrc.
" This configuration is executed *after* a plugin is loaded.
function! s:on_load_post()
endfunction

function! s:loaded_on()
  return 'start'
endfunction

function! s:depends()
  return []
endfunction
