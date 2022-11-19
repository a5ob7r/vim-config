function! s:tig_complete(arg_lead, cmd_line, cursor_pos)
  let l:subcommands = [
        \ 'log',
        \ 'show',
        \ 'reflog',
        \ 'blame',
        \ 'grep',
        \ 'refs',
        \ 'stash',
        \ 'status',
        \ '<'
        \ ]

  let l:options = [
        \ '--',
        \ '--abbrev',
        \ '--abbrev-commit',
        \ '--after', '--since',
        \ '--all',
        \ '--all-match',
        \ '--ancestry-path',
        \ '--anchored',
        \ '--author',
        \ '--author-date-order',
        \ '--before', '--until',
        \ '--binary',
        \ '--bisect',
        \ '--boundary',
        \ '--branches',
        \ '--break-rewrites', '-B',
        \ '--cc', '-c',
        \ '--check',
        \ '--cherry',
        \ '--cherry-mark',
        \ '--cherry-pick',
        \ '--children',
        \ '--color',
        \ '--color-moved',
        \ '--color-moved-ws',
        \ '--color-words',
        \ '--committer',
        \ '--compact-summary',
        \ '--count',
        \ '--cumulative',
        \ '--date',
        \ '--date-order',
        \ '--decorate',
        \ '--decorate-refs',
        \ '--decorate-refs-exclude',
        \ '--default',
        \ '--dense',
        \ '--diff-algorithm',
        \ '--diff-filter',
        \ '--dirstat',
        \ '--dirstat-by-file',
        \ '--do-walk',
        \ '--dst-prefix',
        \ '--early-output', '--output',
        \ '--encoding',
        \ '--exclude',
        \ '--exit-code',
        \ '--ext-diff',
        \ '--extended-regexp', '-E',
        \ '--find-copies', '-C',
        \ '--find-copies-harder',
        \ '--find-object',
        \ '--find-renames', '-M',
        \ '--first-parent',
        \ '--fixed-strings', '-F',
        \ '--follow',
        \ '--format', '--pretty',
        \ '--full-diff',
        \ '--full-history',
        \ '--full-index',
        \ '-G',
        \ '--glob',
        \ '--graph',
        \ '--grep',
        \ '--grep-reflog',
        \ '-h',
        \ '--histogram',
        \ '--ignore-all-space', '-w',
        \ '--ignore-blank-lines',
        \ '--ignore-cr-at-eol',
        \ '--ignore-missing',
        \ '--ignore-space-at-eol',
        \ '--ignore-space-change', '-b',
        \ '--ignore-submodules',
        \ '--inter-hunk-context',
        \ '--invert-grep',
        \ '--irreversible-delete', '-D',
        \ '--ita-invisible-in-index',
        \ '-l',
        \ '-L',
        \ '--left-only',
        \ '--left-right',
        \ '--line-prefix',
        \ '--log-size',
        \ '--max-age',
        \ '--max-count', '-n',
        \ '--max-parents',
        \ '--merge',
        \ '--merges',
        \ '--min-age',
        \ '--minimal',
        \ '--min-parents',
        \ '--name-only',
        \ '--name-status',
        \ '--no-abbrev-commit', '--no-abbrev',
        \ '--no-color',
        \ '--no-color-moved-ws',
        \ '--no-decorate',
        \ '--no-ext-diff',
        \ '--no-follow',
        \ '--no-indent-heuristic',
        \ '--no-max-parents', '--no-min-parents',
        \ '--no-merges',
        \ '--no-notes',
        \ '--no-patch', '-s',
        \ '--no-prefix',
        \ '--no-renames',
        \ '--not',
        \ '--notes',
        \ '--no-textconv',
        \ '--no-walk',
        \ '--numstat',
        \ '-O',
        \ '--objects',
        \ '--objects-edge',
        \ '--oneline',
        \ '--output-indicator-context',
        \ '--output-indicator-new',
        \ '--output-indicator-old',
        \ '--parents',
        \ '--patch', '-u', '-p',
        \ '--patch-with-raw',
        \ '--patch-with-stat',
        \ '--patience',
        \ '--perl-regexp', '-P',
        \ '--pickaxe-all',
        \ '--pickaxe-regex',
        \ '-R',
        \ '--raw',
        \ '--reflog',
        \ '--regexp-ignore-case', '-i',
        \ '--relative',
        \ '--relative-date',
        \ '--remotes',
        \ '--remove-empty',
        \ '--rename-empty',
        \ '--reverse',
        \ '--right-only',
        \ '-S',
        \ '--shortstat',
        \ '--show-linear-break',
        \ '--show-signature',
        \ '--simplify-by-decoration',
        \ '--simplify-merges',
        \ '--single-worktree',
        \ '--skip',
        \ '--source',
        \ '--sparse',
        \ '--src-prefix',
        \ '--stat',
        \ '--stat-count',
        \ '--stat-graph-width',
        \ '--stat-width',
        \ '--stdin',
        \ '--submodule',
        \ '--summary',
        \ '--tags',
        \ '--text', '-a',
        \ '--textconv',
        \ '--topo-order',
        \ '--unified', '-U',
        \ '--use-mailmap',
        \ '--walk-reflogs', '-g',
        \ '--word-diff',
        \ '--word-diff-regex',
        \ '--ws-error-highlight',
        \ '-z'
        \ ]

  let l:branches = systemlist("git branch --all --format='%(refname:lstrip=2)'")
  if l:branches[0] =~# '(HEAD detached at [0-9a-f]\{8\})'
    let l:branches = l:branches[1:]
  endif
  let l:tags = systemlist('git tag')
  let l:hashes = systemlist('git rev-list --all --abbrev-commit')
  let l:files = map(split(globpath('.', a:arg_lead . '*'), '\n'), 'v:val[2:]')

  let l:lead_args = split(a:cmd_line)

  let l:candidates = []

  if index(l:lead_args, '--') > -1 && a:arg_lead !=# '--'
    let l:candidates = l:files
  elseif a:arg_lead =~# '^-'
    let l:candidates = l:options
  elseif len(l:lead_args) >= 3 || len(l:lead_args) == 2 && empty(a:arg_lead)
    let l:candidates = l:files + l:branches + l:tags + l:hashes
  else
    let l:candidates = l:subcommands + l:files + l:branches + l:tags + l:hashes
  endif

  return filter(l:candidates, printf("v:val =~# '^%s'", a:arg_lead))
endfunction

function! s:tig(bang, mods, args) abort
  let l:editor = printf("printf '%s%s%s'", '\\033]51;', '["call", "Tapi_TigEditor", ["%s", "%s"]]', '\\x07')

  let l:cmd = join(['tig'] + a:args)
  let l:options = {
    \ 'curwin': !empty(a:bang),
    \ 'term_finish': 'close',
    \ 'env': { 'TIG_EDITOR': l:editor }
    \ }

  execute join(a:mods) 'call term_start(l:cmd, l:options)'
endfunction

function! Tapi_TigEditor(bufnum, arglist) abort
  if len(a:arglist) != 2
    echoerr '[Tapi_TigEditor] Invalid number of arguments.'
    return
  endif

  let l:lineno = '+1'

  if empty(a:arglist[1])
    let l:filename = fnameescape(a:arglist[0])
  else
    if a:arglist[0] =~# '^+[1-9]\d*$'
      let l:lineno = a:arglist[0]
    endif

    let l:filename = fnameescape(a:arglist[1])
  endif

  execute 'rightbelow split' l:lineno l:filename
endfunction

command! -bang -nargs=* -complete=customlist,s:tig_complete Tig
  \ call s:tig(<q-bang>, [<f-mods>], [<f-args>])
command! -bang -nargs=* -complete=customlist,s:tig_complete Tiga
  \ <mods> Tig<bang> <args> --all
