vim9script

def StrTake(s: string, n: number): string
  if n > 0
    return slice(s, 0, n)
  else
    return ''
  endif
enddef

def StrTakeEnd(s: string, n: number): string
  if n > 0
    return slice(s, -n)
  else
    return ''
  endif
enddef

def StrDrop(s: string, n: number): string
  if n > 0
    return slice(s, n)
  else
    return s
  endif
enddef

def StrDropEnd(s: string, n: number): string
  if n > 0
    return slice(s, -n)
  else
    return s
  endif
enddef

def IsStrStartWith(s: string, prefix: string): bool
  return StrTake(s, len(prefix)) ==# prefix
enddef

def IsStrEndWith(s: string, suffix: string): bool
  return StrTakeEnd(s, len(suffix)) ==# suffix
enddef

def StripCommentString(s: string, commentstring: string): string
  const trimmed = trim(s)
  const [prefix, suffix; _] = split(commentstring, '%s')->map((_, v) => trim(v)) + ['', '']

  return StrDrop(trimmed, IsStrStartWith(trimmed, prefix) ? len(prefix) : 0)
    ->StrDropEnd(IsStrEndWith(trimmed, suffix) ? len(suffix) : 0)
    ->trim()
enddef

def ParagraphUnlines(lines: list<string>): string
  return reduce(lines, (acc, v) => {
    if empty(v)
      return IsStrEndWith(acc, "\n") ? $"{acc}\n" : $"{acc}\n\n"
    else
      return IsStrEndWith(acc, "\n") ? $'{acc}{v}' : $'{acc} {v}'
    endif
  })
enddef

command! -range -register YankComments {
  getline(<line1>, <line2>)
    ->map((_, line) => StripCommentString(line, &commentstring))
    ->ParagraphUnlines()
    ->setreg(v:register)
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
