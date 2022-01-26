nmap <silent> <leader>gl :<C-U>Gina log --graph --all<CR>
nmap <silent> <leader>gs :<C-U>Gina status<CR>
nmap <silent> <leader>gc :<C-U>Gina commit<CR>

execute 'packadd' expand('<sfile>:t:r')

call gina#custom#mapping#nmap('log', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
call gina#custom#mapping#nmap('status', 'q', '<C-W>c', { 'noremap': 1, 'silent': 1 })
