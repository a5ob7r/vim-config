# My Vim Config

## Optionals

- [dtach](https://github.com/crigler/dtach)
  - executed in [bin/xvim](bin/xvim) if it is installed
- [ripgrep](https://github.com/BurntSushi/ripgrep)
  - required by [ripgrep.vim](https://github.com/kyoh86/vim-ripgrep)

## Setup

### Linux or macOS

```sh
$ bin/setup
```

### Windows

```bat
mklink /D %HOMEPATH%\vimfiles %CD%
```

## Install plugins

```vim
:InstallMinpac
:ReloadVimrc
:PackUpdate
:ReloadVimrc
```
