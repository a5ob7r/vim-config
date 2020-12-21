# My Vim Config

## Setup

### Linux or macOS

```sh
$ ln -sfv $PWD ~/.vim

$ ln -sfv $PWD/.ctags.d ~
$ ln -sfv $PWD/.vintrc.yaml ~

$ git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
```

### Windows

```bat
mklink /D %HOMEPATH%\vimfiles %CD%
```
