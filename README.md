# My Vim Configures
## Plugin manager
- [volt](https://github.com/vim-volt/volt) - vim plugin manager

## Setup
### Link this directory to HOME
On Linux os macOS,
```sh
ln -sfv $PWD ~/.vim
```

On Windows,
```bat
mklink /D %HOMEPATH%\vimfiles %CD%
```

### Define VOLTPATH
Set `VOLTPATH` as an environment variable for volt.

On Linux or macOS,
```sh
echo export VOLTPATH=~/.vim/volt >> ~/.zshenv.local
```

On Windows,
```bat
```
