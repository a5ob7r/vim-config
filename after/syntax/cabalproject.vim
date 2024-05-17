" Override some defaults {{{
syntax match CabalProjectCompiler /\<\%(ghc\|ghcjs\|jhc\|lhc\|uhc\|haskell-suite\)-\d\+\%(\.\d\+\)*\>/
syntax keyword CabalProjectProfilingLevel late late-toplevel

highlight link CabalProjectProfilingLevel Constant
" }}}

syntax iskeyword @,48-57,_,192-255,$,-

syntax match cabalProjectStanzaField /^\s\+\w\%(\w\|-\)\+/
syntax match cabalProjectUnixTimestamp /@\d\+/
syntax match cabalProjectUTCTimestamp /\<\d\{4}-\d\{2}-\d\{2}T\d\{2}:\d\{2}:\d\{2}Z\>/
syntax match cabalProjectTodo /\<\%(TODO\|NOTE\|XXX\|FIXME\|NB\)\>/ contained containedin=CabalProjectComment

highlight default link cabalProjectStanzaField CabalProjectField
highlight default link cabalProjectUnixTimestamp Constant
highlight default link cabalProjectUTCTimestamp Constant
highlight default link cabalProjectTodo Todo

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker :
