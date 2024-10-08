vim9script

# "maxpac" is a complement plugin manager for minpac.

var maxpac = {}

# Whether or not the plugin is loadable.
def Loadable(uri: string): bool
  return uri =~# '^\%(file://\)\=/'
    ? !substitute(uri, '^file://', '', '')->glob()->empty()
    : !globpath(&packpath, $'pack/*/opt/{Plugname(uri)}')->empty()
enddef

# Whether or not the plugin is loaded.
def Loaded(name: string): bool
  return !globpath(&runtimepath, $'pack/*/opt/{name}')->empty()
enddef

# Convert an URI into a plugin (directory) name.
export def Plugname(uri: string): string
  const tail = split(uri, '/')[-1]
  return uri =~# '^https\=://' ? substitute(tail, '\C\.git$', '', '') : tail
enddef

# Initialize a configuration store of maxpac.
export def Initialize()
  maxpac = {
    names: [],
    confs: {}
  }
enddef

# Return a dictionary as a plugin configiration base for maxpac.
export def Plugconf(name: string): dict<any>
  return {
    config: { type: 'opt' },
    pre: () => null,
    post: () => null,
    fallback: () => null
  }
enddef

# Load "minpac" and initialize "maxpac".
export def Begin(config: dict<any> = {}): bool
  # Initialize maxmac.
  Initialize()

  try
    packadd minpac
  catch
    return false
  endtry

  minpac#init(config)

  return true
enddef

# Load plugins that each of them may have hook functions. The hooks are called
# before or after loading one.
export def End()
  for name in maxpac.names
    var conf = maxpac.confs[name]

    if Loadable(name)
      conf.pre()
    endif

    if !Load(name, conf.config)
      conf.fallback()

      continue
    endif

    conf.post()
  endfor
enddef

# Store a plugin configuration.
export def Add(name: string, config = {}): dict<any>
  var conf = extend(Plugconf(name), config)

  add(maxpac.names, name)
  maxpac.confs[name] = conf

  return conf
enddef

# Load a standalone plugin. The plugin is only managed by minpac, but maxpac.
# This function works as a synonym of "minpac#add()" and "packadd".
#
# This can handle local plugins such as "files:///path/to/plugin" too. However
# they are just loaded by hand and are managed by neither minpac and maxpac.
#
# NOTE: This function initializes minpac without any arguments if minpac isn't
# initialized yet. If you want to initialize with non-default value,
# initialize with the value beforehand.
export def Load(uri: string, config: dict<any> = { type: 'opt' }): bool
  try
    if !exists('g:minpac#opt')
      minpac#init()
    endif
  catch /^Vim\%((\a\+)\)\=:E117:/
    return false
  endtry

  # TODO: Support drive letters for MS-Windows.
  if uri =~# '^\%(file://\)\=/'
    const path = substitute(uri, '^file://', '', '')

    if glob(path)->empty()
      return 0
    endif

    execute $'set runtimepath^={fnameescape(path)}'

    const after = globpath(path, 'after')
    if !empty(after)
      execute $'set runtimepath+={fnameescape(after)}'
    endif

    for plugin in globpath(path, 'plugin/**/*.vim', 0, 1)
      execute 'source' fnameescape(plugin)
    endfor

    return 1
  else
    const name = Plugname(uri)

    # Register the plugin to minpac to update.
    minpac#add(uri, config)

    # Load the plugin instantly.
    try
      execute 'packadd' name
    catch
      # Ignore any errors.
    endtry

    return Loaded(name)
  endif
enddef

# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
