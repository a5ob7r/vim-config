command! PackInit call minpac#init()
command! PackUpdate call minpac#update()
command! PackInstall PackUpdate
command! PackClean call minpac#clean()
command! PackStatus call minpac#status()

command! PackInstallSelf call minpac#extra#install()
command! PackLoadAllOpt call minpac#extra#load_opt_plugins()
