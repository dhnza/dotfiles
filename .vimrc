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

" Sensible backspace behavior
set backspace=2

" Open new split panes to right and bottom
set splitbelow
set splitright

" Tab completion in status bar
set wildmenu

" Enable all mouse modes
set mouse=a

" Disable page scrolling keybindings
noremap <S-Up> <Up>
noremap <S-Down> <Down>

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
" Copy selected text to clipboard
vnoremap <C-S-c> "+y

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

" Open split with some Latex character sequences translated to UTF-8 glyphs
command TexPreview setlocal scrollbind | vsplit
    \ | setlocal conceallevel=2 | wincmd h

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

" Highlight exact differences in diffs
Plug 'rickhowe/diffchar.vim'

" Linting engine
Plug 'dense-analysis/ale'

" GitHub copilot integration
Plug 'github/copilot.vim'

" Fugitive plug-in for git
Plug 'tpope/vim-fugitive'

" Git diff in gutter
Plug 'airblade/vim-gitgutter'

" Pretty status line
Plug 'itchyny/lightline.vim'

" FZF, both command and plugin installation
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Latex integration
Plug 'lervag/vimtex'

" Jupyter notebook integration
Plug 'untitled-ai/jupyter_ascending.vim'

" Markdown integration
Plug 'plasticboy/vim-markdown'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Modern IDE features
Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
  " Set matching onehalfdark colors for terminal windows.
  let g:terminal_ansi_colors = [
        \ '#282c34', '#e06c75', '#98c379', '#e5c07b',
        \ '#61afef', '#c678dd', '#56b6c2', '#dcdfe4',
        \ '#5c6370', '#e06c75', '#98c379', '#e5c07b',
        \ '#61afef', '#c678dd', '#56b6c2', '#dcdfe4'
        \ ]
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
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" ------------------------------
"    GitGutter
" ------------------------------
" Update sign column every quarter second
set updatetime=250

" ------------------------------
"    ALE
" ------------------------------
" Automatically open/close location list on error
let g:ale_open_list = 1

" Show 5 lines of errors
let g:ale_list_window_size = 5

" Use virtual text only in current line
let g:ale_virtualtext_cursor = 1

" Use floating windows for hover message
let g:ale_hover_to_floating_preview = 1

" Pretty border for floating windows
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']

" ALE mappings
nnoremap <Leader>af :ALEFix<CR>

" ------------------------------
"    CoC
" ------------------------------
" Use <TAB> for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <CR> to accept selected completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" CoC mappings
nnoremap <Leader>sr <Plug>(coc-rename)
nnoremap <silent> <Leader>sd :call CocActionAsync('doHover')<CR>
nnoremap <silent> <Leader>sjd :call CocAction('jumpDefinition')<CR>
nnoremap <silent> <Leader>sji :call CocAction('jumpImplementation')<CR>
nnoremap <silent> <Leader>sjr :call CocAction('jumpReferences')<CR>
nnoremap <silent> <Leader>sa <Plug>(coc-codeaction-line)
xnoremap <silent> <Leader>sa <Plug>(coc-codeaction-selected)
nnoremap <silent> <Leader>sA <Plug>(coc-codeaction)

" Define function and class text objects
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Disable conflicting page scrolling shortcuts
nnoremap <C-f> <Nop>
nnoremap <C-b> <Nop>
vnoremap <C-f> <Nop>
vnoremap <C-b> <Nop>

" Scroll CoC float windows/popups
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1, 3) : ""
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0, 3) : ""
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1, 3)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0, 3)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1, 3) : ""
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0, 3) : ""

" CoC extensions
let g:coc_global_extensions = [
    \ 'coc-json', 
    \ 'coc-pyright', 
    \ 'coc-pydocstring',
    \ 'coc-vimtex',
    \ ]

" ------------------------------
"    UltiSnips
" ------------------------------
" Set triggers that don't conflict with CoC
let g:UltiSnipsExpandTrigger = '<C-k>'
let g:UltiSnipsListSnippets = '<C-y>'
let g:UltiSnipsJumpForwardTrigger = '<C-k>'
let g:UltiSnipsJumpBackwardTrigger = '<C-j>'

" Open snippet editor in split window
let g:UltiSnipsEditSplit = 'context'

" ------------------------------
"    Vim-Traces
" ------------------------------
" Support for Vim-Abolish commands
let g:traces_abolish_integration = 1

" ------------------------------
"    VimTeX
" ------------------------------
" Set PDF viewer
let g:vimtex_view_method = 'mupdf'

" Disable searching included files for text completion
let g:vimtex_include_search_enabled = 0

" ------------------------------
"   Jupyter-Ascending
" ------------------------------
" Add sync mapping
nnoremap <Space><Space>s :call jupyter_ascending#sync()<CR>

" Disable automatic syncing
let g:jupyter_ascending_auto_write = v:false

" ------------------------------
"    Vim-Markdown
" ------------------------------
" Disable folding
let g:vim_markdown_folding_disabled = 1

" ------------------------------
"    GitHub Copilot
" ------------------------------
" Ask for completions
nnoremap <Leader>c :Copilot<CR>

" Use <C-l> to accept completions
imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

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
nnoremap <Leader>; :Commands<CR>
" Search open buffers
nnoremap <Leader>b :Buffers<CR>
" Search through tags
nnoremap <Leader>t :BTags<CR>
nnoremap <Leader>T :Tags<CR>
" Search through help tags
nnoremap <Leader>H :Helptags<CR>
" Search through snippets
nnoremap <Leader>z :Snippets<CR>
inoremap <C-z> <C-o>:Snippets<CR>

" Run highlighted command directly
let g:fzf_commands_expect = 'alt-enter'

" ------------------------------
"    Tabularize
" ------------------------------
" Align text to character after <Leader>a
nnoremap <expr> <Leader>x ':Tabularize /'.nr2char(getchar()).'<CR>'
vnoremap <expr> <Leader>x ':Tabularize /'.nr2char(getchar()).'<CR>'


" =============================
"        Miscellaneous
" =============================
" Highlight misspelled spelled words in red
hi SpellBad cterm=underline ctermfg=red

" Remove highlighting of first quickfix item
hi QuickFixLine ctermbg=none

" Use git commit highlighting for dotfiles commits
augroup DotFilesCommit
    autocmd!
    autocmd BufRead,BufNewFile COMMIT_EDITMSG set filetype=gitcommit
augroup END


" =============================
"     Per-Project Settings
" =============================
" Load settings from .projct_vimrc for all files in a project:
" augroup PerProjectSettings
"     autocmd!
"     autocmd BufReadPre,BufNewFile /patch/to/project/* source /path/to/.project_vimrc
" augroup END
" BufReadPre loads settings BEFORE the file is read, so that autocmd settings work.
