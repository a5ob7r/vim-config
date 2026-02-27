" Fixed version of shTodo.
syntax match shTodo /\<\%(TODO\|NOTE\|XXX\|FIXME\|NB\)\ze\%(:\|\>\)/ contained

syntax match shShebang '\%^#!/.*$' contained
syntax cluster shCommentGroup add=shShebang

highlight default link shShebang PreProc
