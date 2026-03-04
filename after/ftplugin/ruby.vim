setlocal textwidth=120

command! -buffer -range=% RSpecOutline {
  keeppattern <mods> :<line1>,<line2>global/\<\%(x\=\%(context\|describe\|it\)\|skip\)\>/
}

let b:undo_ftplugin ..= '| setlocal textwidth< | delcommand -buffer RSpecOutline'

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
