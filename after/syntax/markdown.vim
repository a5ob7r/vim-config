syntax match markdownDatetime /^\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}$/

highlight link markdownDatetime htmlH6
" `mkdNonListItem` is defined on vim-polyglot.
syntax cluster mkdNonListItem add=markdownDatetime
