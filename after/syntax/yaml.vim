syntax region yamlString matchgroup=yamlFlowStringDelimiter start=/\\\@<!"/ skip=/\\"/ end=/"/  contains=yamlEscape contained containedin=yamlPlainScalar
syntax region yamlString matchgroup=yamlFlowStringDelimiter start=/\\\@<!'/ end=/'/  contains=yamlEscape contained containedin=yamlPlainScalar
