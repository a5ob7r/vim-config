" Fixed version of shTodo.
syntax match shTodo /\<\%(TODO\|NOTE\|XXX\|FIXME\|NB\)\ze\%(:\|\>\)/ contained

syntax match shShebang '\%^#!/.*$' contained
syntax cluster shCommentGroup add=shShebang

if exists('v:versionlong') && v:versionlong >= 9001275 && v:versionlong <= 9001361
  " NOTE: Rollback broken shell syntax of runtime files since be4e01637 and
  " until dd60c365c.
  if exists('b:is_kornshell') || exists('b:is_bash') || exists('b:is_posix')
    syntax clear shCommandSub
    syntax region shCommandSub matchgroup=shCmdSubRegion start=/\$(\ze[^(]/  skip=/\\\\\|\\./ end=/)/  contains=@shCommandSubList
  endif
endif

highlight default link shShebang PreProc
