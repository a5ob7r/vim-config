nmap <leader>gl :Gina log --graph --all<CR>
nmap <leader>gs :Gina status<CR>
nmap <leader>gc :Gina commit<CR>

execute 'packadd' expand('<sfile>:t:r')

call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
