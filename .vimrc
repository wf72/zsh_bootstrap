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

" not select string numbers
set mouse=a

" set listchars=tab:··
" set list

set nocompatible
set nu

" vim-plug
call plug#begin('~/.vim/plugged')
Plug 'jacoborus/tender.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Theme
syntax enable
colorscheme tender
