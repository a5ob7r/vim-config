let g:vsnip_snippet_dir = expand('~/.vim/vsnip')

imap <expr> <Tab> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<Tab>'
