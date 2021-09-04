" https://github.com/fugue/goldplate
" Golden test runner.
augroup GOLDPLATE
  autocmd!
  autocmd BufRead,BufNewFile *.goldplate setlocal filetype=json
augroup END
