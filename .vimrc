" Helps force plug-ins to load correctly when it is turned back on below.
filetype off

" Enable syntax highlighting
syntax on

" Set the shell
set shell=/bin/zsh

" Paste mode
nnoremap <leader>pa :set nopaste!<CR><Paste>

set tabstop=4
set shiftwidth=4
set smarttab
set et

set showcmd
set showmatch
set hlsearch
set incsearch
set ignorecase
set smartcase
set autowrite
set hidden

set listchars=tab:··
set list

set nocompatible
set colorscheme desert