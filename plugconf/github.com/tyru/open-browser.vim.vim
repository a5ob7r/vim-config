nmap <leader>K <Plug>(openbrowser-smart-search)

function! SearchEnglishWord(word) abort
  let l:searchUrl = 'https://dictionary.cambridge.org/dictionary/english/'
  let l:url = l:searchUrl . a:word
  call openbrowser#open(l:url)
endfunction

function! SearchUnderCursorEnglishWord() abort
  let l:word = expand('<cword>')
  call SearchEnglishWord(l:word)
endfunction
