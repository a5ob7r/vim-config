" TODO: Contextual syntax highlight, but this will make the syntax highlights
" unstable. The syntax highlight will need to fit whole contextaul lines in
" the screen for accurate highlights.

let s:global_keywords = {
  \   'default': {
  \     'after_script': {},
  \     'artifacts': {},
  \     'before_script': {},
  \     'cache': {},
  \     'hooks': {},
  \     'id_tokens': {},
  \     'image': {},
  \     'interruptible': {},
  \     'retry': {},
  \     'services': {},
  \     'tags': {},
  \     'timeout': {},
  \   },
  \   'include': {
  \     'component': {},
  \     'local': {},
  \     'project': {
  \       'ref': {},
  \       'file': {},
  \     },
  \     'remote': {},
  \     'template': {},
  \     'inputs': {},
  \   },
  \   'stages': {},
  \   'variables': {},
  \   'workflow': {
  \     'auto_cancel': {
  \       'on_new_commit': {},
  \       'on_job_failure': {},
  \       'name': {},
  \       'rules': {
  \         'variables': {},
  \         'auto_cancel': {},
  \       },
  \     },
  \   },
  \ }
let s:header_keywords = {
  \   'spec': {
  \     'inputs': {
  \       'default': {},
  \       'description': {},
  \       'options': {},
  \       'regex': {},
  \       'type': {},
  \     }
  \   },
  \ }
let s:job_keywords = {
  \   'after_script': {},
  \   'allow_failure': {
  \     'exit_codes': {}
  \   },
  \   'artifacts': {
  \     'paths': {},
  \     'exclude': {},
  \     'expire_in': {},
  \     'expose_as': {},
  \     'name': {},
  \     'public': {},
  \     'access': {},
  \     'reports': {},
  \     'untracked': {},
  \     'when': {},
  \   },
  \   'before_script': {},
  \   'cache': {
  \     'paths': {},
  \     'key': {
  \       'files': {},
  \       'prefix': {},
  \       'untracked': {},
  \       'unprotect': {},
  \       'when': {},
  \       'policy': {},
  \       'fallback_keys': {},
  \     },
  \   },
  \   'coverage': {},
  \   'dast_configuration': {},
  \   'dependencies': {},
  \   'environment': {
  \     'name': {},
  \     'url': {},
  \     'on_stop': {},
  \     'action': {},
  \     'auto_stop_in': {},
  \     'kubernetes': {},
  \     'deployment_tier': {},
  \   },
  \   'extends': {},
  \   'hooks': {
  \     'pre_get_sources_script': {},
  \   },
  \   'identity': {},
  \   'id_tokens': {
  \     'aud': {}
  \   },
  \   'image': {
  \     'name': {},
  \     'entrypoint': {},
  \     'docker': {},
  \     'pull_policy': {},
  \   },
  \   'inherit': {
  \     'default': {},
  \     'variables': {},
  \   },
  \   'interruptible': {},
  \   'needs': {
  \     'artifacts': {},
  \     'project': {
  \       'job': {},
  \       'ref': {},
  \       'artifacts': {},
  \     },
  \     'optional': {},
  \     'pipeline': {
  \       'matrix': {},
  \     },
  \   },
  \   'pages': {
  \     'publish': {},
  \     'pages': {
  \       'path_prefix': {},
  \   },
  \   },
  \   'parallel': {
  \     'matrix': {},
  \   },
  \   'release': {
  \     'tag_name': {},
  \     'tag_message': {},
  \     'name': {},
  \     'description': {},
  \     'ref': {},
  \     'minestones': {},
  \     'released_at': {},
  \     'assets': {
  \       'links': {
  \         'name': {},
  \         'url': {},
  \         'filepath': {},
  \         'link_type': {},
  \       },
  \     },
  \   },
  \   'resource_group': {},
  \   'retry': {
  \     'when': {},
  \     'exit_codes': {},
  \   },
  \   'rules': {
  \     'if': {},
  \     'changes': {
  \       'paths': {},
  \       'compare_to': {},
  \     },
  \     'exists': {},
  \     'allow_failures': {},
  \     'needs': {},
  \     'variables': {},
  \     'interruptible': {},
  \   },
  \   'script': {},
  \   'secrets': {
  \     'vault': {
  \       'engine': {
  \         'name': {},
  \         'path': {},
  \       },
  \       'path': {},
  \       'field': {},
  \     },
  \     'gcp_secret_manager': {
  \       'name': {},
  \       'version': {},
  \     },
  \     'azure_key_vault': {
  \       'name': {},
  \       'version': {},
  \     },
  \     'file': {},
  \     'token': {},
  \   },
  \   'services': {
  \     'docker': {
  \       'platform': {},
  \       'user': {},
  \     },
  \     'pull_policy': {}
  \   },
  \   'stage': {},
  \   'tags': {},
  \   'timeout': {},
  \   'trigger': {
  \     'include': {},
  \     'project': {},
  \     'strategy': {},
  \     'forward': {},
  \   },
  \   'variables': {
  \     'description': {},
  \     'value': {},
  \     'options': {},
  \     'expand': {},
  \     'when': {},
  \   },
  \   'when': {},
  \ }

function! s:deep_keys(v) abort
  let l:dicts = type(a:v) == type([]) ? a:v : [a:v]

  return s:aux_deep_keys(l:dicts, [])
endfunction

function! s:aux_deep_keys(dicts, keys) abort
  if empty(a:dicts)
    return uniq(sort(a:keys))
  endif

  let l:dicts = flatten(map(copy(a:dicts), 'values(v:val)'))
  let l:keys = extend(a:keys, flatten(map(copy(a:dicts), 'keys(v:val)')))

  return s:aux_deep_keys(l:dicts, l:keys)
endfunction

" XXX: Why the leading "\@!" and "\@<!" are needed at the same time? Is it
" possible to combine them for simplification?
execute 'syntax match gitlabCIKeyword /^\@!\%(\S.*\)\@<!\%(' . join(s:deep_keys([s:job_keywords] + values(s:header_keywords) + values(s:global_keywords)), '\|') . '\)\ze\s*:\s*/ contained containedin=yamlBlockMappingKey'
execute 'syntax match gitlabCITopLevelKeyword /^\%(' . join(uniq(sort(keys(s:global_keywords) + keys(s:header_keywords))), '\|') . '\)\ze\s*:\s*/ contained containedin=yamlBlockMappingKey'

syntax region gitlabCISpecInputInterpolation matchgroup=gitlabCISpecInputInterpolationSurround start=/$\[\[/ matchgroup=gitlabCISpecInputInterpolationSurround end=/\]\]/ contained containedin=yamlPlainScalar,yamlFlowString
syntax keyword gitlabCISpecInputInterpolationKeyword inputs contained containedin=gitlabCISpecInputInterpolation

highlight default link gitlabCIKeyword Keyword
highlight default link gitlabCITopLevelKeyword Keyword

highlight default link gitlabCISpecInputInterpolationSurround PreProc
highlight default link gitlabCISpecInputInterpolationKeyword Keyword

" vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
