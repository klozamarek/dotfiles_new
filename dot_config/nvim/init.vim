"-- GENERAL SETTINGS
set nocompatible
set nrformats=
set wildmenu
set wildmode=full
set history=200
set foldmethod=marker
nnoremap <space> <nop>
let g:mapleader = "\<space>"
" -- edit vimrc with f5 and source it with f6
nnoremap <silent> <leader><F5> :tabedit $MYVIMRC<CR>
nnoremap <silent> <leader><F6> :source $MYVIMRC<CR>
" -- the copy goes to clipboard
set clipboard+=unnamedplus
" -- show line numbers
set number
" -- use realtive line numbering by default
set relativenumber
" -- disable creating of *.swp files
set noswapfile
" -- hide buffers instead of closing
set hidden
" -- save undo trees in files
set undofile
" -- save undo trees in files
set undodir=$HOME/.config/nvim/undo
" -- numbers of undo saved
set undolevels=10000
set undoreload=10000
" -- disable search highlighting
nnoremap <silent> <Esc><Esc> :nohlsearch<CR><Esc>
" -- windows switching
nnoremap <M-h> <c-w>h
nnoremap <M-j> <c-w>j
nnoremap <M-k> <c-w>k
nnoremap <M-l> <c-w>l
if has('nvim')
  tnoremap <M-h> <c-\><c-n><c-w>h
  tnoremap <M-j> <c-\><c-n><c-w>j
  tnoremap <M-k> <c-\><c-n><c-w>k
  tnoremap <M-l> <c-\><c-n><c-w>l
endif
" -- quick way to save file
  nnoremap <leader>s :w<CR>
" -- select all text
noremap vA ggVG
" -- indentation
set expandtab     " replace <Tab with spaces
set tabstop=2     " number of spaces that a <Tab> in the file counts for
set softtabstop=2 " remove <Tab> symbols as it was spaces
set shiftwidth=2  " indent size for << and >>
set shiftround    " round indent to multiple of 'shiftwidth' (for << and >>)
" -- search
set ignorecase " ignore case of letters
set smartcase  " override the 'ignorecase' when there is uppercase letters
" -- keep search results at the center of screen
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
" -- colors and highlightings
set cursorline      " highlight current line
set cursorcolumn    " highlight column
if has('nvim')                    " config for cursor in TERMINAL Mode
    highlight! link TermCursor Cursor
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif
" -- terminal
nnoremap <silent> <leader><Enter> :tabnew<CR>:terminal<CR>
" -- opening splits with terminal in all directions
nnoremap <Leader>h<Enter> :leftabove  vnew<CR>:terminal<CR>
nnoremap <Leader>l<Enter> :rightbelow vnew<CR>:terminal<CR>
nnoremap <Leader>k<Enter> :leftabove  new<CR>:terminal<CR>
nnoremap <Leader>j<Enter> :rightbelow new<CR>:terminal<CR>
" -- mapping to swich to Normal mode
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-v><Esc> <Esc>
endif
" -- copy current file path to clipboard
nnoremap <leader>% :call CopyCurrentFilePath()<CR>
function! CopyCurrentFilePath() " {{{
  let @+ = expand('%')
  echo @+
endfunction
" -- trailing whitespaces
set list
set list listchars=tab:\┆\ ,trail:·,nbsp:±
set list
let &listchars='tab:┆ ,trail:·'
" -- remove trailing whitespaces in current buffer
nnoremap <Leader><BS>s :1,$s/[ ]*$//<CR>:nohlsearch<CR>1G
" -- switch between tabs
nmap <leader>1 1gt
nmap <leader>2 2gt
nmap <leader>3 3gt
nmap <leader>4 4gt
nmap <leader>5 5gt
nmap <leader>6 6gt
nmap <leader>7 7gt
nmap <leader>8 8gt
nmap <leader>9 9gt
" -- creating splits with empty buffers in all directions
nnoremap <Leader>hn :leftabove  vnew<CR>
nnoremap <Leader>ln :rightbelow vnew<CR>
nnoremap <Leader>kn :leftabove  new<CR>
nnoremap <Leader>jn :rightbelow new<CR>
" -- if split in given direction exists - jump, else create new split
function! JumpOrOpenNewSplit(key, cmd, fzf) " {{{
  let current_window = winnr()
  execute 'wincmd' a:key
  if current_window == winnr()
    execute a:cmd
    if a:fzf
      Files
    endif
  else
    if a:fzf
      Files
    endif
  endif
endfunction " }}}
nnoremap <silent> <Leader>hh :call JumpOrOpenNewSplit('h', ':leftabove vsplit', 0)<CR>
nnoremap <silent> <Leader>ll :call JumpOrOpenNewSplit('l', ':rightbelow vsplit', 0)<CR>
nnoremap <silent> <Leader>kk :call JumpOrOpenNewSplit('k', ':leftabove split', 0)<CR>
nnoremap <silent> <Leader>jj :call JumpOrOpenNewSplit('j', ':rightbelow split', 0)<CR>
" -- universal closing behavior
nnoremap <silent> Q :call CloseSplitOrDeleteBuffer()<CR>
function! CloseSplitOrDeleteBuffer()
  if winnr('$') > 1
    wincmd c
  else
    execute 'Bdelete'
  endif
endfunction
" -- delete all hidden buffers
nnoremap <silent> <Leader><BS>b :call DeleteHiddenBuffers()<CR>
function! DeleteHiddenBuffers()
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    silent execute 'Bwipeout' buf
  endfor
endfunction

" -- PLUGINS
" -- Autoinstall vim-plug 
if empty(glob('$XDG_CONFIG_HOME/nvim/autoload/plug.vim'))
silent !curl -fLo $XDG_CONFIG_HOME/nvim/autoload/plug.vim --create-dirs
\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
autocmd VimEnter * PlugInstall
endif
call plug#begin('$XDG_CONFIG_HOME/nvim/plugged') " Plugins initialization start
Plug 'morhetz/gruvbox'
Plug 'chrisbra/csv.vim'
Plug 'moll/vim-bbye'
Plug 'simeji/winresizer'
Plug 'junegunn/fzf.vim'
Plug 'simnalamburt/vim-mundo'
Plug 'jez/vim-superman'
Plug 'mcchrish/nnn.vim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-surround'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-commentary'
Plug 'felipec/notmuch-vim'
" Plug 'imain/notmuch-vim'
call plug#end()
" -- Plugin settings
" -- set grubox theme
let g:gruvbox_italic=1
autocmd vimenter * ++nested colorscheme gruvbox
" -- keybind for Mundo Toggle
nnoremap <F5> :MundoToggle<CR>
" -- set settings for chisbra/csv.vim
augroup filetype_csv
autocmd! 
autocmd BufRead,BufWritePost *.csv :%ArrangeColumn
autocmd BufWritePre *.csv :%UnArrangeColumn
augroup END
" -- settings for vim_airline
let g:airline_powerline_fonts = 1
" -- settings for jungeunn/fzf
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>a :Buffers<CR>
nnoremap <silent> <leader>A :Windows<CR>
nnoremap <silent> <leader>; :BLines<CR>
nnoremap <silent> <leader>o :BTags<CR>
nnoremap <silent> <leader>O :Tags<CR>
nnoremap <silent> <leader>? :History<CR>
nnoremap <silent> <leader>, :History:<CR>
nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>
nnoremap <silent> <leader>. :AgIn 
nnoremap <silent> K :call SearchWordWithAg()<CR>
vnoremap <silent> K :call SearchVisualSelectionWithAg()<CR>
nnoremap <silent> <leader>gl :Commits<CR>
nnoremap <silent> <leader>ga :BCommits<CR>
nnoremap <silent> <leader>ft :Filetypes<CR>
imap <C-x><C-f> <plug>(fzf-complete-file-ag)
imap <C-x><C-l> <plug>(fzf-complete-line)
function! SearchWordWithAg()
  execute 'Ag' expand('<cword>')
endfunction
function! SearchVisualSelectionWithAg() range
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  let old_clipboard = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', old_reg, old_regtype)
  let &clipboard = old_clipboard
  execute 'Ag' selection
endfunction
function! SearchWithAgInDirectory(...)
  call fzf#vim#ag(join(a:000[1:], ' '), extend({'dir': a:1}, g:fzf#vim#default_layout))
endfunction
command! -nargs=+ -complete=dir AgIn call SearchWithAgInDirectory(<f-args>)
" -- settings for fugitive
let g:fugitive_git_executable = 'LANG=en_US.UTF-8 git'
nnoremap <silent> <leader>gs :G<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gc :G commit<CR>
nnoremap <silent> <leader>gb :G_blame<CR>
nnoremap <silent> <leader>ge :Gedit<CR>
nnoremap <silent> <leader>gE :Gedit<space>
nnoremap <silent> <leader>gl :G pull <CR>
nnoremap <silent> <leader>gr :Gread<CR>
nnoremap <silent> <leader>gR :Gread<space>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gW :Gwrite!<CR>
nnoremap <silent> <leader>gq :Gwq<CR>
nnoremap <silent> <leader>gQ :Gwq!<CR>
" -- review last commit
function! ReviewLastCommit()
if exists('b:git_dir')
  Gtabedit HEAD^{}
  nnoremap <buffer> <silent> q :<C-U>bdelete<CR>
else
  echo 'No git a git repository:' expand('%:p')
endif
endfunction
nnoremap <silent> <leader>g` :call ReviewLastCommit()<CR>
" -- Git push -u origin master
function! GitPushSetUpstream() abort
  echo "Pushing..."
  exe 'Git push -u origin ' . FugitiveHead()
  echo "Pushed!"
endfunction
command! Gp call GitPushSetUpstream()
nnoremap <silent> <leader>gp :call GitPushSetUpstream()<CR>
augroup fugitiveSettings
  autocmd!
  autocmd FileType gitcommit setlocal nolist
  autocmd BufReadPost fugitive://* setlocal bufhidden=delete
augroup END
" -- settings for telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<CR>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').git_status()<CR>
" -- settings for bbye
nnoremap <leader>q :Bdelete<CR>
" -- settings for winresizer
let g:winresizer_start_key = "<F2>"
" -- settings for nnn.nvim
nnoremap <leader>e :NnnExplorer<cr>
let g:nnn#action = {
\ '<c-t>': 'tab split',
\ '<c-s>': 'split',
\ '<c-v>': 'vsplit' }
" -- settings for vim-indent-guides
let g:indent_guides_default_mapping = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_exclude_filetypes = ['help', 'startify', 'man', 'rogue']
" -- settings for vim-commentary
set commentstring=#\ %s
" -- settings for NotMuch
" define custom search folders at startup
let g:notmuch_folders = [
  \ [ 'new', 'tag:inbox and tag:unread' ],
  \ [ 'everything', '*' ],
  \ [ 'inbox', 'tag:inbox' ],
  \ [ 'all-serp w/o bloats', 'to:ssserpent and not tag:shop and not tag:lists and not tag:google and not tag:lot and not tag:linkedin and not tag:fun' ],
  \ [ 'all-texo w/o bloats', 'to:kloza.marek and not tag:shop and not tag:lists and not tag:google and not tag:lot and not tag:linkedin and not tag:fun' ],
  \ [ 'to-do', 'tag:to-do' ],
  \ [ 'sent', 'tag:sent' ],
  \ [ 'daxa', 'tag:daxa' ],
  \ [ 'linkedin', 'tag:linkedin' ],
  \ [ 'shops', 'tag:shop' ],
  \ [ 'lists', 'tag:lists' ],
  \ [ 'google', 'tag:google' ],
  \ [ 'lot', 'tag:lot' ],
  \ [ 'entertainment', 'tag:fun' ],
  \ ]
" establish external programs
let g:notmuch_reader = 'neomutt -f %s'
let g:notmuch_sendmail = 'sendmail'
" set custom key mappings
let g:notmuch_custom_search_maps = {
  \ 'o':  'search_tag("+to-do -inbox")',
  \ 'd':  'search_tag("+deleted -inbox -unread")',
  \ }

let g:notmuch_custom_show_maps = {
  \ 'o':  'show_tag("+to-do -inbox")',
  \ 'd':  'show_tag("+deleted -inbox -unread")',
  \ }
