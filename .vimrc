" =============================
"       Utility Functions
" =============================
function! SilentMkdir(path)
    if !isdirectory(a:path)
        call mkdir(a:path, "p", 0700)
    endif
endfunction

function! BufWidth()
    let width = winwidth(0)
    let numberwidth = max([&numberwidth, strlen(line('$'))+1])
    let numwidth = (&number || &relativenumber)? numberwidth : 0
    let foldwidth = &foldcolumn

    if &signcolumn == 'yes'
        let signwidth = 2
    elseif &signcolumn == 'auto'
        let signs = execute(printf('sign place buffer=%d', bufnr('')))
        let signs = split(signs, "\n")
        let signwidth = len(signs)>2? 2: 0
    else
        let signwidth = 0
    endif
    return width - numwidth - foldwidth - signwidth
endfunction

" =============================
"         Vim Settings
" =============================
" Basics
syntax enable
set number
set relativenumber
set cursorline
set hlsearch
set ignorecase
set smartcase

" Correct use of tabs
set tabstop=4
set expandtab

" Indentation
set shiftwidth=4
set shiftround
set autoindent

" Open new split panes to right and bottom
set splitbelow
set splitright

" Tab completion in status bar
set wildmenu

" Use <Space> as leader key
let mapleader="\<Space>"
noremap <Space> <Nop>

" Use 'kj' to exit insert and command mode
inoremap kj <esc>
cnoremap kj <C-C>

" Persistent undo
set undofile "Maintain undo history between sessions
set undodir=~/.vim/undodir
call SilentMkdir($HOME . "/.vim/undodir")

" Load MAN plugin
runtime ftplugin/man.vim

" Write swap and backup files in different directory
set backupdir=~/.vim/backupdir//,/tmp//
set directory=~/.vim/swapfiles//,/tmp//
call SilentMkdir($HOME . "/.vim/backupdir")
call SilentMkdir($HOME . "/.vim/swapfiles")

" ------------------------------
"   Shortcuts
" ------------------------------
" Quick save
nnoremap <Leader>w :w<CR>
nnoremap <Leader>wq :wq<CR>
" Open quickfix list item in new tab
nnoremap <C-t> <C-w><CR><C-w>T
" Move between tabs with <C-S-ARROW>
nnoremap <C-S-RIGHT> gt
nnoremap <C-S-LEFT> gT
" Select last edited text (including paste)
nnoremap gV `[v`]

" Define 'a line' and 'inside line' text objects
"   al is the whole line, including all white space
"   il is the 'text' inside the line, no leading/trailing white space
vnoremap <silent> al :<C-U>normal 0v$h<CR>
omap <silent> al :normal val<CR>
vnoremap <silent> il :<C-U>normal ^vg_<CR>
omap <silent> il :normal vil<CR>

" =============================
"     Commands & Functions
" =============================
" Run makeprg and open quickfix window
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

" Manipulate variants of a word
Plug 'tpope/vim-abolish'

" Aligning text
Plug 'godlygeek/tabular'

" More text objects
Plug 'wellle/targets.vim'

" Enhanced matching text navigation
Plug 'andymass/vim-matchup'

" Live previews for substitute commands
Plug 'markonm/traces.vim'

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

" Snippets
Plug 'SirVer/ultisnips'

" Color schemes
Plug 'altercation/vim-colors-solarized'
Plug 'sonph/onehalf', { 'rtp': 'vim' }

" Initialize plugin system
call plug#end()


" =============================
"        Plugin settings
" =============================
" ------------------------------
"   Color Scheme
" ------------------------------
set background=dark
colorscheme onehalfdark
" Enable 24-bit colors, if possible
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" ------------------------------
"    Lightline
" ------------------------------
set laststatus=2
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'onehalfdark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" ------------------------------
"    GitGutter
" ------------------------------
" Update sign column every quarter second
set updatetime=250

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

" Make location list fit content, 10 lines maximum.
function! SyntasticCheckHook(errors)
    if !empty(a:errors)
        " Compute total lines occupied by errors
        let l:nline = 0
        let l:width = BufWidth()+1
        for l:err in a:errors
            let l:str = printf("%s|%d col %d error|  %s",
                             \ expand("#".l:err['bufnr']),
                             \ l:err['lnum'], l:err['col'],
                             \ trim(l:err['text']))
            let l:nline += (strwidth(l:str)+l:width-1)/l:width
        endfor
        let g:syntastic_loc_list_height = min([l:nline, 10])
    endif
endfunction

" Disable python syntax checking
let g:syntastic_mode_map = { 'passive_filetypes': ['python'] }

" ------------------------------
"    VimCompletesMe
" ------------------------------
" Run automatically on all file types
autocmd FileType vim let b:vcm_tab_complete = 'vim'

" ------------------------------
"    UltiSnips
" ------------------------------
" Set triggers that don't conflict with VimCompletesMe
let g:UltiSnipsExpandTrigger = '<C-j>'
let g:UltiSnipsListSnippets = '<C-l>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

" Open snippet editor in split window
let g:UltiSnipsEditSplit = 'context'

" ------------------------------
"    Vim-Traces
" ------------------------------
" Support for Vim-Abolish commands
let g:traces_abolish_integration = 1

" ------------------------------
"    Vim-Markdown
" ------------------------------
" Disable folding
let g:vim_markdown_folding_disabled = 1

" ------------------------------
"            FZF
" ------------------------------
" Search files
nnoremap <Leader>f :Files<CR>
" Search inisde files
nnoremap <Leader>g :Rg<CR>
" Search lines in open buffers
nnoremap <Leader>l :BLines<CR>
nnoremap <Leader>L :Lines<CR>
" Search vim commands
nnoremap <Leader>p :Commands<CR>
" Search open buffers
nnoremap <Leader>b :Buffers<CR>
" Search through tags
nnoremap <Leader>t :BTags<CR>
nnoremap <Leader>T :Tags<CR>

" ------------------------------
"    Tabularize
" ------------------------------
" Align text to character after <Leader>a
nnoremap <expr> <Leader>a ':Tabularize /'.nr2char(getchar()).'<CR>'
vnoremap <expr> <Leader>a ':Tabularize /'.nr2char(getchar()).'<CR>'


" =============================
"        Miscellaneous
" =============================
" Highlight misspelled spelled words in red
hi SpellBad cterm=underline ctermfg=red

" Set the filetype based on the file's extension, but only if
" 'filetype' has not already been set
au BufRead,BufNewFile *.tpp set filetype=cpp
au BufRead,BufNewFile *.sbatch set filetype=sh

" Use git commit highlighting for dotfiles commits
au BufRead,BufNewFile COMMIT_EDITMSG set filetype=gitcommit


" =============================
"     Per-Project Settings
" =============================
" Load settings from .projct_vimrc for all files in a project:
"   autocmd BufReadPre,BufNewFile /patch/to/project/* source /path/to/.project_vimrc
" BufReadPre loads settings BEFORE the file is read, so that autocmd settings work.
