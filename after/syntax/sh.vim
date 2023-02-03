" Fixed version of shTodo.
syntax match shTodo /\<\%(TODO\|NOTE\|XXX\|FIXME\|NB\)\ze\%(:\|\>\)/ contained

syntax match shShebang '\%^#!/.*$' contained
syntax cluster shCommentGroup add=shShebang

" NOTE: As a workaround, rollback broken shell syntax of runtime files at be4e01637 to earlier.
if exists('b:is_kornshell') || exists('b:is_bash') || exists('b:is_posix')
  syntax clear shCommandSub
  syntax region shCommandSub matchgroup=shCmdSubRegion start=/\$(\ze[^(]/  skip=/\\\\\|\\./ end=/)/  contains=@shCommandSubList
endif

highlight default link shShebang PreProc
