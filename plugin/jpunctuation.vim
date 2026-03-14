vim9script

# Substitute all of full-width Japanese punctuation('。' and '、') in every
# string in a range with each appropriate full-width English punctuation('．'
# and '，'). If run this with a bang('!'), substitute them in the opposite
# way.
#
# before: 我輩は、人間である。名前は、すでにある。
#  after: 我輩は，人間である．名前は，すでにある．
#
# NOTE: Vim probably changes the cursor position to the head of the command
# range while a function which have the range specified is invoked. This means
# that the returned value by "winsaveview()" which is called in the function
# is also changed by the function invocation with the command range. Because
# of this behavior, we can't get the original position where a cursor is when
# a user calls the function. However, we can avoid this behavior by passing
# the range as a function argument instead of a function call with the range.
# This is a little bit tedious and a very simple solution.
def SubstituteJapanesePunctuations(bang: string, line1: number, line2: number)
  const period = {
    ja: '。',
    en: '．',
  }
  const comma = {
    ja: '、',
    en: '，',
  }

  const lang_from = empty(bang) ? 'ja' : 'en'
  const lang_to = empty(bang) ? 'en' : 'ja'

  defer (view) => {
    winrestview(view)
  }(winsaveview())

  execute $'silent keepjumps keeppatterns :{line1},{line2}substitute/{period[lang_from]}/{period[lang_to]}/eg'
  execute $'silent keepjumps keeppatterns :{line1},{line2}substitute/{comma[lang_from]}/{comma[lang_to]}/eg'
enddef

command! -bang -range SubstituteJapanesePunctuations {
  SubstituteJapanesePunctuations(<q-bang>, <line1>, <line2>)
}

# Break sentences followed by "。" or "．" into newline-separated them.
command! -bar -range BreakJapaneseSentences {
  keeppatterns :<line1>,<line2>substitute/\([。．]\)/\1\r/eg
}

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
