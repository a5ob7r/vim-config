syntax match haskellTodo /\<\%(TODO\|NOTE\|XXX\|FIXME\|NB\)\>/ contained

" Experimeltal Haddock syntax highlightings.

let s:save_current_syntax = b:current_syntax
unlet! b:current_syntax
syntax include @Tex syntax/tex.vim
let b:current_syntax = s:save_current_syntax
unlet! s:save_current_syntax
syntax iskeyword clear

" Haddock comment
syntax region haskellHaddockLineComment matchgroup=haskellHaddockLineComment start=/\s*-- \%(|\|\^\)/ end=/^\s*\%(--\)\@!/ contains=@haskellHaddockMarkup,@Spell
syntax region haskellHaddockBlockComment matchgroup=haskellHaddockLineComment start=/\s*{-|/ end=/-}/ contains=@haskellHaddockMarkup,@Spell

" Character References
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#character-references
syntax match haskellHaddockCharacterReference /&#\d\+;/ contained
syntax match haskellHaddockCharacterReference /&#x\x\+;/ contained

" Code Blocks
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#code-blocks
syntax region haskellHaddockCodeBlock matchgroup=haskellHaddockDelimiter start=/@$/ end=/@$/ contained contains=haskellHaddockCodeLeader,@haskellHaddockCode
syntax region haskellHaddockCodeBlock matchgroup=haskellHaddockDelimiter start=/>/ end=/$/ oneline contained contains=@haskellHaddockCode

" Examples
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#examples
syntax region haskellHaddockExample matchgroup=haskellHaddockDelimiter start=/>>>/ end=/$/ oneline contained contains=@haskellHaddockCode

" Properties
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#properties
syntax region haskellHaddockProperty matchgroup=haskellHaddockDelimiter start=/prop>/ end=/$/ oneline contained contains=@haskellHaddockCode

" Hyperlinked Identifiers
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#hyperlinked-identifiers
syntax match haskellHaddockHyperlinkedIdentifier "['`][[:alnum:]_'!#$%*+./<=>?@\^|\-~:`\(\)]*['`]" contained contains=@haskellHaddockModule,@haskellHaddockCode

" Emphasis, Bold and Monospaced Text
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#emphasis-bold-and-monospaced-text
syntax region haskellHaddockEmphasis matchgroup=haskellHaddockDelimiter start='\\\@<!/' skip='\\/' end='/' contained contains=haskellHaddockBold,haskellHaddockMonospace,haskellHaddockHyperlinkedIdentifier oneline
syntax region haskellHaddockBold matchgroup=haskellHaddockDelimiter start=/\\\@<!__/ skip=/\\_\\_/ end=/__/ contained contains=haskellHaddockEmphasis,haskellHaddockMonospace,haskellHaddockHyperlinkedIdentifier oneline
syntax region haskellHaddockMonospace matchgroup=haskellHaddockDelimiter start=/\\\@<!@/ skip=/\\@/ end=/@/ contained contains=haskellHaddockEmphasis,haskellHaddockBold,haskellHaddockHyperlinkedIdentifier oneline

" Linking to Modules
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#linking-to-modules
syntax match haskellHaddockLindingToModule /"\u[[:alnum:]_'\.]*"/ contained contains=@haskellHaddockModule
syntax cluster haskellHaddockModule contains=haskellType,haskellOperators

" Itemized and Enumerated Lists
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#itemized-and-enumerated-lists
syntax match haskellHaddockItemizedList /\s\+\%(\*\|-\)\s\+/ contained
syntax match haskellHaddockEnumeratedList /\s\+\%((\d\+)\|\d\+\.\)\s\+/ contained

" Definition Lists
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#definition-lists
syntax region haskellHaddockDefinitionList matchgroup=haskellHaddockDelimiter start=/\[/ skip=/\\\]:/ end=/\]:/ oneline contained

" URLs
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#urls
syntax region haskellHaddockUrl matchgroup=haskellHaddockDelimiter start=/</ end=/>/ oneline contained contains=haskellHaddockRawUrl
syntax match haskellHaddockRawUrl =\%(https\?\|ssh\)://[^[:space:]<>()\[\]"'`^$\\]\+= contained

" Links
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#links
syntax match haskellHaddockLink /\[.*\](.*)/ contained contains=haskellHaddockLinkName,haskellHaddockLinkUrl
syntax region haskellHaddockLinkName matchgroup=haskellHaddockDelimiter start=/\[/ end=/\]/ oneline contained nextgroup=haskellHaddockLinkUrl
syntax region haskellHaddockLinkUrl matchgroup=haskellHaddockDelimiter start=/(/ end=/)/ oneline contained contains=haskellHaddockRawUrl,haskellHaddockLindingToModule

" Mathematics / LaTeX
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#mathematics-latex
syntax region haskellHaddockLaTex matchgroup=haskellHaddockDelimiter start=/\%(|.*\)\@<!\\\[/ end=/\\\]/ contained contains=haskellHaddockCodeLeader,@Tex

" Grid Tables
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#grid-tables
syntax match haskellHaddockGridTable /+-[-+]*+/ contained
syntax match haskellHaddockGridTable /+=[=+]*+/ contained
syntax match haskellHaddockGridTable /|/ contained

" Anchors
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#anchors
syntax match haskellHaddockAnchor /#\S\+#/ contained
syntax match haskellHaddockLinkToAnchor /"\S\+#\S\+"/ contained

" Headings
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#headings
syntax match haskellHaddockHeading /=\{1,6}/ contained

" Since
" https://haskell-haddock.readthedocs.io/en/latest/markup.html#since
syntax region haskellHaddockSince start=/@since\s\+/ end=/$/ oneline contained contains=haskellHaddockSinceNumber
syntax match haskellHaddockSinceNumber /[0-9]\+\%(\.[0-9]\+\)*/ contained

syntax cluster haskellHaddockMarkup contains=haskellHaddockCharacterReference,haskellHaddockCodeBlock,haskellHaddockExample,haskellHaddockProperty,haskellHaddockLindingToModule,haskellHaddockItemizedList,haskellHaddockEnumeratedList,haskellHaddockHyperlinkedIdentifier,haskellHaddockEmphasis,haskellHaddockBold,haskellHaddockMonospace,haskellHaddockDefinitionList,haskellHaddockUrl,haskellHaddockLink,haskellHaddockLaTex,haskellHaddockGridTable,haskellHaddockAnchor,haskellHaddockLinkToAnchor,haskellHaddockHeading,haskellHaddockSince
syntax cluster haskellHaddockCode contains=haskellOperators,haskellSeparator,haskellParens,haskellWhere,haskellLet,haskellDefault,haskellTypeSig,haskellType,haskellDerive,haskellDeclKeyword,haskellDecl,haskellString,haskellForeignImport,haskellPragma,haskellImport,haskellKeyword,haskellConditional,haskellNumber,haskellNumber,haskellBrackets,haskellInfix,haskellInfix,haskellQuoted,haskellBacktick,haskellChar,haskellLiquid,haskellPreProc,haskellShebang,haskellQuasiQuote,haskellTHBlock
syntax match haskellHaddockCodeLeader /^\s*\zs--/ contained

highlight default link haskellHaddockLineComment SpecialComment
highlight default link haskellHaddockBlockComment SpecialComment
highlight default link haskellHaddockDelimiter Delimiter
highlight default link haskellHaddockRawUrl Underlined
highlight default link haskellHaddockCodeLeader haskellHaddockLineComment
highlight default link haskellHaddockItemizedList haskellHaddockDelimiter
highlight default link haskellHaddockEnumeratedList haskellHaddockDelimiter
highlight default link haskellHaddockGridTable haskellHaddockDelimiter
highlight default link haskellHaddockHeading haskellHaddockDelimiter
highlight default link haskellHaddockSinceNumber haskellFloat
