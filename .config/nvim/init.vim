" Reuse your Vim setup in Neovim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Use the system Python 3 for plugins that require it
let g:python3_host_prog = exepath('python3')
