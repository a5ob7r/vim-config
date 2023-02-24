scriptencoding utf-8

" Substitute all of full-width Japanese punctuation('。' and '、') in every
" string in a range with each appropriate full-width English punctuation('．'
" and '，'). If run this with a bang('!'), substitute them in the opposite
" way.
"
" before: 我輩は、人間である。名前は、すでにある。
"  after: 我輩は，人間である．名前は，すでにある．
"
" NOTE: Vim probably changes the cursor position to the head of the command
" range while a function which have the range specified is invoked. This means
" that the returned value by "winsaveview()" which is called in the function
" is also changed by the function invocation with the command range. Because
" of this behavior, we can't get the original position where a cursor is when
" a user calls the function. However, we can avoid this behavior by passing
" the range as a function argument instead of a function call with the range.
" This is a little bit tedious and a very simple solution.
function! s:substitute_japanese_punctuations(bang, line1, line2) abort
  let l:ku_ptn = empty(a:bang) ? '。' : '．'
  let l:ku_str = !empty(a:bang) ? '。' : '．'
  let l:doku_ptn = empty(a:bang) ? '、' : '，'
  let l:doku_str = !empty(a:bang) ? '、' : '，'

  let l:view = winsaveview()

  try
    execute printf('silent keepjumps keeppatterns %d,%dsubstitute/%s/%s/eg', a:line1, a:line2, l:ku_ptn, l:ku_str)
    execute printf('silent keepjumps keeppatterns %d,%dsubstitute/%s/%s/eg', a:line1, a:line2, l:doku_ptn, l:doku_str)
  finally
    call winrestview(l:view)
  endtry
endfunction

" Break sentences followed by "。" or "．" into newline-separated them.
function! s:break_japanese_sentences() range abort
  let l:newline =
    \ &fileformat ==# 'dos' ? '\n\r' :
    \ &fileformat ==# 'unix' ? '\r' :
    \ &fileformat ==# 'mac' ? '\n' :
    \ '\r'

  execute printf('%d,%dsubstitute/\([。/．]\)/\1%s/eg', a:firstline, a:lastline, l:newline)
endfunction

command! -bang -range SubstituteJapanesePunctuations call s:substitute_japanese_punctuations(<q-bang>, <line1>, <line2>)

command! -bar -range BreakJapaneseSentences <line1>,<line2>call s:break_japanese_sentences()
