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
  let [l:period_fw_jp, l:period_fw_en, l:comma_fw_jp, l:comma_fw_en] = ['。', '．', '、',  '，']
  let [l:period_from, l:period_to, l:comma_from, l:comma_to] = empty(a:bang) ? [l:period_fw_jp, l:period_fw_en, l:comma_fw_jp, l:comma_fw_en] : [l:period_fw_en, l:period_fw_jp, l:comma_fw_en, l:comma_fw_jp]
  let l:view = winsaveview()

  try
    execute printf('silent keepjumps keeppatterns %d,%dsubstitute/%s/%s/eg', a:line1, a:line2, l:period_from, l:period_to)
    execute printf('silent keepjumps keeppatterns %d,%dsubstitute/%s/%s/eg', a:line1, a:line2, l:comma_from, l:comma_to)
  finally
    call winrestview(l:view)
  endtry
endfunction

" Break sentences followed by "。" or "．" into newline-separated them.
function! s:break_japanese_sentences() range abort
  execute printf('%d,%dsubstitute/\([。．]\)/\1\r/eg', a:firstline, a:lastline)
endfunction

command! -bang -range SubstituteJapanesePunctuations call s:substitute_japanese_punctuations(<q-bang>, <line1>, <line2>)

command! -bar -range BreakJapaneseSentences <line1>,<line2>call s:break_japanese_sentences()
