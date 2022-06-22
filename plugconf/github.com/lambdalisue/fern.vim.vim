let g:fern#default_hidden = 1
let g:fern#default_exclude = '.*\~$'

command! CurrentFernLogging echo get(g:, 'fern#logfile', v:null)
command! -nargs=* -complete=file EnableFernLogging
      \ let g:fern#logfile = empty(<q-args>) ? '~/fern.tsv' : <q-args>
command! DisableFernLogging let g:fern#logfile = v:null
command! FernLogDebug let g:fern#loglevel = g:fern#DEBUG
command! FernLogInfo let g:fern#loglevel = g:fern#INFO
command! FernLogWARN let g:fern#loglevel = g:fern#WARN
command! FernLogError let g:fern#loglevel = g:fern#Error
