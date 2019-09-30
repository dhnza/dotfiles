" =============================
"       Utility Functions
" =============================
function! SilentMkdir(path)
    if !isdirectory(a:path)
        call mkdir(a:path, "p", 0700)
    endif
endfunction

" =============================
"         Vim Settings
" =============================
" Basics
syntax enable
set number
set cursorline
set hlsearch

" Correct use of tabs
set tabstop=4
set expandtab

" Indentation
set shiftwidth=4
set autoindent

" Open new split panes to right and bottom
set splitbelow
set splitright

" Use <Space> as leader key
let mapleader="\<Space>"
noremap <Space> <Nop>

" Use per-project vim settings
set exrc
set secure "only run commands in .vimrc files owned by me

" Persistent undo
set undofile "Maintain undo history between sessions
set undodir=~/.vim/undodir
call SilentMkdir($HOME . "/.vim/undodir")

" Write swap and backup files in different directory
set backupdir=~/.vim/backupdir//,/tmp//
set directory=~/.vim/swapfiles//,/tmp//
call SilentMkdir($HOME . "/.vim/backupdir")
call SilentMkdir($HOME . "/.vim/swapfiles")

" ------------------------------
"   Shortcuts
" ------------------------------
" Quick save
nmap <Leader>w :w<CR>
nmap <Leader>wq :wq<CR>
" Open quickfix list item in new tab
nmap <C-t> <C-w><CR><C-w>T


" =============================
"     Commands & Functions
" =============================
" Run makeprg and open quicfix window
command -nargs=* Make make! <args> | cwindow

function! DeleteInactiveBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'buflisted(v:val) && index(tpbl, v:val)==-1')
        silent exec 'bd' buf
    endfor
endfunction


" =============================
"         Vim Plug
" =============================
" Automatically install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

" High-light current word
Plug 'RRethy/vim-illuminate'

" Commenting shortcuts
Plug 'tomtom/tcomment_vim'

" Useful shell commands inside vim
Plug 'tpope/vim-eunuch'

" Surrounding text
Plug 'tpope/vim-surround'

" '.' command support for plugins
Plug 'tpope/vim-repeat'

" Handy navigation shortcuts
Plug 'tpope/vim-unimpaired'

" Aligning text
Plug 'godlygeek/tabular'

" Syntax checker
Plug 'vim-syntastic/syntastic'

" Fugitive plug-in for git
Plug 'tpope/vim-fugitive'

" Git diff in gutter
Plug 'airblade/vim-gitgutter'

" Pretty status line
Plug 'itchyny/lightline.vim'

" FZF, both command and plugin installation
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Markdown integration
Plug 'plasticboy/vim-markdown'

" Tab completion
Plug 'ajh17/VimCompletesMe'

" Solarized colorscheme
Plug 'altercation/vim-colors-solarized'

" Initialize plugin system
call plug#end()


" =============================
"        Plugin settings
" =============================
" ------------------------------
"   Solarized dark
" ------------------------------
set background=dark
colorscheme solarized

" ------------------------------
"    Lightline
" ------------------------------
set laststatus=2
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" ------------------------------
"    Syntastic
" ------------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" Disable python syntax checking
let g:syntastic_mode_map = { 'passive_filetypes': ['python'] }

" ------------------------------
"    VimCompletesMe
" ------------------------------
" Run automatically on all file types
autocmd FileType vim let b:vcm_tab_complete = 'vim'

" ------------------------------
"    Vim-Markdown
" ------------------------------
" Disable folding
let g:vim_markdown_folding_disabled = 1

" ------------------------------
"            FZF
" ------------------------------
" Search files with <C-f>
nnoremap <C-f> :Files<Cr>
" Search inisde files with <C-g>
nnoremap <C-g> :Rg<Cr>
" Search lines in open buffers with <C-s>
nnoremap <C-l> :Lines<Cr>
" Search vim commands with <C-p>
nnoremap <C-p> :Commands<Cr>
" Search open buffers with <C-b>
nnoremap <C-b> :Buffers<Cr>

" ------------------------------
"    Tabularize
" ------------------------------
" Align text to '=' and ':'
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:<CR>
vmap <Leader>a: :Tabularize /:<CR>


" =============================
"        Miscellaneous
" =============================
" Set the filetype based on the file's extension, but only if
" 'filetype' has not already been set
au BufRead,BufNewFile *.tpp set filetype=cpp
au BufRead,BufNewFile *.sbatch set filetype=sh

" Use git commit highlighting for dotfiles commits
au BufRead,BufNewFile COMMIT_EDITMSG set filetype=gitcommit
