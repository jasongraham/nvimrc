" (n)vim config file

" Evaluate once
let is_windows = has('win32') || has('win64')
let is_nvim = has('nvim')
let conf_dir = fnamemodify(resolve(expand($MYVIMRC)), ':p:h')

" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
if is_windows
    let plugin_dir = '$USERPROFILE\AppData\Local\nvim\plugged'
elseif is_nvim " and Linux or MAC
    let plugin_dir = '~/.local/share/nvim/plugged'
else " Vim and Linux or MAC
    let plugin_dir = '~/.vim/plugged'
endif

call plug#begin(plugin_dir)
" LanguageClient plugins and extensions
if is_windows
    Plug 'autozimu/LanguageClient-neovim', {
                \ 'branch': 'next',
                \ 'do': 'powershell -executionpolicy bypass -File install.ps1',
                \ }
else
    Plug 'autozimu/LanguageClient-neovim', {
                \ 'branch': 'next',
                \ 'do': 'bash install.sh',
                \ }
    Plug 'junegunn/fzf', { 'do': './install --bin' }
    Plug 'junegunn/fzf.vim'
endif

" Syntastic for stuff that doesn't currently have LanguageClient options
Plug 'vim-syntastic/syntastic'

" Completion Manager
if !is_nvim
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" Completion Manager Plugins
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-syntax' | Plug 'Shougo/neco-syntax'
Plug 'ncm2/ncm2-neoinclude' | Plug 'Shougo/neoinclude.vim'
Plug 'ncm2/ncm2-vim' | Plug 'Shougo/neco-vim'

" Airline plugs and extensions
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
if !is_windows
    Plug 'powerline/fonts', { 'do': 'bash install.sh' }
endif

" Makes vim git-aware
Plug 'tpope/vim-fugitive'

" comment stuff out easily
Plug 'tpope/vim-commentary'

" Easier incrementing and decrementing of dates with <C-a>/<C-x>
Plug 'tpope/vim-speeddating'

" Shows trailing white-space and provides function to trim it
Plug 'ntpeters/vim-better-whitespace'

" Show indent guides, toggle with <leader>ig
Plug 'thaerkh/vim-indentguides'

" Shows function signatures based on completions
Plug 'Shougo/echodoc.vim'

" Easy alignment with 'ga'
Plug 'junegunn/vim-easy-align'

" Tagbar (requires something to generate ctags)
Plug 'majutsushi/tagbar'

" Shows contents of registers when doing macros
Plug 'junegunn/vim-peekaboo'

" Giant colorscheme pack. No default is set, put that in machine specific file
" user.vim
Plug 'flazz/vim-colorschemes'

" Rust integration
Plug 'rust-lang/rust.vim'

" Machine specific plugins
let userplug_conf = conf_dir . "/userplug.vim"
if filereadable(userplug_conf)
    execute 'source ' . fnameescape(userplug_conf)
endif
call plug#end()

set hidden
set number
set signcolumn=yes
let mapleader = ','
set smarttab
set ignorecase
set smartcase
set hlsearch
set incsearch
set autoindent
set copyindent
set backspace=indent,eol,start
set showmatch
set cursorline
set colorcolumn=80
set pastetoggle=<F2>

set lazyredraw

" Default shift / tabwidth
set expandtab
set tabstop=4
set shiftwidth=4

" Completion manager config
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect,preview
set shortmess+=c
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> (pumvisible() ? "\<C-y>\<cr>" : "\<CR>")
let g:cm_matcher = {'case': 'smartcase', 'module': 'cm_matchers.fuzzy_matcher'}

" Airline config
if !is_windows
    let g:airline_powerline_fonts = 1
endif

" Configuration for echodoc
set cmdheight=2
let g:echodoc_enable_at_startup = 1

" Easy align config
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Indent guides
nmap <silent> <leader>ig :IndentGuidesToggle<CR>

" Tagbar config
nnoremap <silent> <leader>T :TagbarOpenAutoClose<CR>

nnoremap <silent> <leader><space> :StripWhitespace<cr>
nnoremap <silent> <leader>/ :nohlsearch<CR>

" Navigate across split lines
nnoremap j gj
nnoremap k gk

" Split navigation
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" Syntastic config
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_mode_map = {
            \ "mode": "active",
            \ "active_filetypes": [],
            \ "passive_filetypes": []
            \ }

" Get rustfmt to format files on save
if executable('rustfmt')
    let g:rustfmt_autosave = 1
endif

" Language Client Configuration
augroup LanguageClientConfig
    autocmd!
    autocmd filetype python,rust,vhdl
                \ nnoremap <buffer> gd :call
                \ LanguageClient_textDocument_definition()<cr>
    autocmd filetype python,rust,vhdl
                \ nnoremap <buffer> K :call
                \ LanguageClient_textDocument_hover()<cr>
    autocmd filetype python,rust,vhdl
                \ nnoremap <buffer> <leader>rr :call
                \ LanguageClient_textDocument_rename()<cr>
    autocmd filetype python,rust,vhdl
                \ nnoremap <buffer> <leader>lf :call
                \ LanguageClient_textDocument_documentSymbol()<cr>

    " Have gq action perform formatting on the range as expected
    autocmd filetype python,rust,vhdl setlocal
                \ formatexpr=LanguageClient_textDocument_rangeFormatting()

augroup end

" Use the location list rather than the quickfix list for messages
let g:LanguageClient_diagnosticsList = 'Location'

" Set up specific languages with for LanguageClients
" Disable syntastic for those filetypes to use the LanguageServer information
" instead.
let g:LanguageClient_serverCommands = {}
let g:LanguageClient_rootMarkers = {}
if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls']
    let g:LanguageClient_rootMarkers.python = ['setup.py', 'setup.cfg']
    let g:syntastic_mode_map.passive_filetypes += ['python']
endif
if executable('rls')
    let g:LanguageClient_serverCommands.rust = ['rls']
    let g:LanguageClient_rootMarkers.rust = ['Cargo.toml']
    let g:syntastic_mode_map.passive_filetypes += ['rust']
endif
" Experimenting with https://www.vhdltool.com/
if executable('vhdl-tool')
    let g:LanguageClient_serverCommands.vhdl = ['vhdl-tool', 'lsp']
    let g:LanguageClient_rootMarkers.vhdl = ['vhdltool-config.yaml']
    let g:syntastic_mode_map.passive_filetypes += ['vhdl']
endif

augroup python_files
    autocmd!

    autocmd filetype python setlocal expandtab shiftwidth=4 tabstop=4
    autocmd filetype python setlocal textwidth=79

    " Disable autowrapping
    autocmd filetype python setlocal formatoptions-=t
augroup end

augroup rust_files
    autocmd!
    autocmd filetype rust setlocal expandtab shiftwidth=4 tabstop=4
augroup end

augroup vimscript_files
    autocmd!

    autocmd filetype vim setlocal expandtab shiftwidth=4 tabstop=4
    autocmd filetype vim setlocal textwidth=79

    " Disable autowrapping
    autocmd filetype vim setlocal formatoptions-=t
augroup end

augroup vhdl_files
    autocmd!
    autocmd filetype vhdl setlocal expandtab shiftwidth=2 tabstop=2
augroup end

augroup yaml_files
    autocmd!
    autocmd filetype yaml setlocal expandtab shiftwidth=2 tabstop=2
augroup end

" Machine specific stuff (keep this at the end)
let user_conf = conf_dir . "/user.vim"
if filereadable(user_conf)
    execute 'source ' . fnameescape(user_conf)
endif
