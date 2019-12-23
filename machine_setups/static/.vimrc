set nocompatible

if $TERM =~# "256color" || $TERM ==# "xterm"
    set t_Co=256
endif

set nolinebreak
set sidescroll=1
set history=9999
set lazyredraw
set mouse=a
set textwidth=79

set wrap
set wrapmargin=0

set showmatch
set matchtime=5

set cursorline
set cursorcolumn

set ignorecase
set smartcase

set nospell
set spelllang=en_gb

set wildmenu
set wildchar=<Tab>
set wildignore+=*.DS_Store
set wildignore+=*.ap_
set wildignore+=*.apk
set wildignore+=*.class
set wildignore+=*.dex
set wildignore+=*.dll
set wildignore+=*.dylib
set wildignore+=*.exe
set wildignore+=*.gif
set wildignore+=*.jpg
set wildignore+=*.mp3
set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.png
set wildignore+=*.pyc
set wildignore+=*.so
set wildignore+=*.so.*

set list
set listchars=
set listchars+=tab:>-
set listchars+=trail:*
set listchars+=precedes:<
set listchars+=extends:>
set listchars+=nbsp:*

set number
set norelativenumber
set numberwidth=1

set nobackup
set writebackup

set ruler
set rulerformat=%<%F\ %h%m%r%w%y%=%-14.(%l,%c%V%)\ %P

set laststatus=2
set statusline=%n:%F\ %w%m%=%y\ Col:%c\ Line:%P\/%L

set complete=.,w,b,u,i,t
set completeopt+=menu
set completeopt+=longest
set completeopt+=preview

set foldenable
set foldcolumn=1
set foldmethod=manual
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4

set report=0
set noerrorbells
set visualbell
set showmode
set showcmd
set incsearch
set hlsearch
set nrformats=hex
syntax enable
filetype on
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete
set hidden
set viewoptions-=options

set background=dark
colorscheme maroloccio

"------------------------------------------------------------------------------
"
" FIXME
"
filetype off
filetype indent off
filetype indent on
syntax on
"------------------------------------------------------------------------------

" Paste
set pastetoggle=<F2>

"------------------------------------------------------------------------------

" gradle syntax highlighting
au BufNewFile,BufRead *.gradle set filetype=groovy

"------------------------------------------------------------------------------

execute pathogen#infect()

"------------------------------------------------------------------------------

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
" see https://github.com/vim-syntastic/syntastic, section
" 4.5. Q. How can I pass additional arguments to a checker?
" Shellcheck checks whether a sourced file exists even when -x option is
" applied.
let g:syntastic_sh_shellcheck_args = '-x'

"------------------------------------------------------------------------------
"
finish
