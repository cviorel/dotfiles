
"
"       This is the personal .vimrc file of Viorel Ciucu
"       viorel.ciucu@gmail.com
"       Modified on: 15.03.2013
"
"

set nocompatible        " Disable vi compatibility.
syntax enable           " Syntax highlighing
set background=dark
set t_Co=256

" Color schemes
"colorscheme             Mustang
"colorscheme             smyck " http://color.smyck.org/
colorscheme             desert

" Enable filetype plugins
filetype plugin on
filetype indent on

set autoindent          " Always set autoindenting on
set expandtab           " Tabs are spaces, not tabs
set tabstop=4           " An indentation every four columns
set softtabstop=4       " Let backspace delete indent
set smartindent
set nowrap              " No wrap
set nobackup            " Do not keep a backup file.
set history=100         " Number of lines of command line history
set undolevels=200      " Number of undo levels.
set textwidth=0         " Don't wrap words by default.
set showcmd             " Show (partial) command in status line
set showmatch           " Show matching brackets.
set showmode            " Show current mode
set ruler               " Show the line and column numbers of the cursor
set ignorecase          " Case insensitive matching
set smartcase           " When searching try to be smart about cases
set incsearch           " Incremental search
set noautoindent        " I indent my code myself
set nocindent           " I indent my code myself
set scrolloff=5         " Keep a context when scrolling
set noerrorbells        " No beeps
set modeline            " Enable modeline
set esckeys             " Cursor keys in insert mode
set gdefault            " Use 'g' flag by default with :s/foo/bar/
set magic               " Use 'magic' patterns (extended regular expressions)
set mat=2               " How many tenths of a second to blink when matching brackets
set tabstop=4           " Number of spaces <tab> counts for
set shiftwidth=4        " Indent width for autoindent
set ttyscroll=0         " Turn off scrolling (this is faster)
set ttyfast             " We have a fast terminal connection
set hlsearch            " Highlight search matches
set autowrite           " Automatically save before :next, :make etc.
set scrolljump=5        " Lines to scroll when cursor leaves screen
set scrolloff=10        " Minimum lines to keep above and below cursor

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=%{HasPaste()}
set statusline+=%F
set statusline+=%h%m%r%w                        " flags
set statusline+=\ [cwd:\ %{getcwd()}]                     " current directory
set statusline+=%=                              " right align
set statusline+=[%{strlen(&ft)?&ft:'none'},\    " filetype
set statusline+=%{strlen(&fenc)?&fenc:&enc},\   " encoding
set statusline+=%{&fileformat}]\                " file format
set statusline+=[%l,%c]\                        " line and column
set statusline+=%P                              " percentage of file


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE '
    en
    return ''
endfunction

" Display a vertical line at X columns to see where I have to wrap the lines
set colorcolumn=80
highlight ColorColumn ctermbg=DarkGray
