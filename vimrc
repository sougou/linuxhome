set nocompatible

execute pathogen#infect()
syntax on
filetype plugin indent on

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! s:SGgrep(...)
  let arg_list = (a:0==0) ? [expand("<cword>")] : a:000
  let tmpfile = tempname()
  let args = ''
  for arg in arg_list
    let args = args . arg . " "
  endfor
  execute 'silent! !(find . -iname ''*.go''; find . -iname ''*.y''; find . -iname ''*.py'') | grep -v ''/vendor/'' | grep -v ''/\.proto'' | xargs grep -n ' . args . ' > ' . tmpfile
  execute "silent! cgetfile " . tmpfile
  botright copen
endfunction
com! -nargs=* SG call s:SGgrep(<f-args>)

function! s:SFind(...)
  let arg = (a:0==0) ? expand("<cword>") : a:1
  let tmpfile = tempname()
  let cwd = getcwd()
  execute 'silent! !((find . -iname ' . arg . ' -type f; find . -iname ' . arg . '.go; find . -iname ' . arg . '.py)|grep -v ''.git''|sort|uniq) > ' . tmpfile
  let file_list = readfile(tmpfile)
  if len(file_list) == 0
    echo "No match for" arg
  elseif len(file_list) == 1
    execute "edit " . file_list[0]
  else
    let efm_save = &efm
    set efm=%f
    execute "silent! cgetfile " . tmpfile
    let &efm=efm_save
    " Open window at bottom always
    botright copen
  endif
endfunction
com! -nargs=? SF call s:SFind(<f-args>)

function! QFixToggle()
  if exists("g:qfix_win")
    cclose
    unlet g:qfix_win
  else
    botright copen
    let g:qfix_win = bufnr("$")
  endif
endfunction
nnoremap <silent> ` :call QFixToggle()<CR>

function! QuickFixOpenAll()
  if empty(getqflist())
    return
  endif
  let s:prev_val = ""
  for d in getqflist()
    let s:curr_val = bufname(d.bufnr)
    if (s:curr_val != s:prev_val)
      exec "edit " . s:curr_val
    endif
    let s:prev_val = s:curr_val
  endfor
endfunction
com! LoadAll call QuickFixOpenAll()

function! DeleteCurrentBuffer()
  let buf_num = bufnr("%")
  hide bnext
  execute "silent! bdelete " . buf_num
endfunction

set number
set backspace=2
set ai
set textwidth=0
set nobackup
set history=3000
set ignorecase smartcase
set incsearch
set nobackup
set showmatch
set ruler
set nowrap
set smartindent
set bs=indent,start
set hlsearch
set hidden
set shiftwidth=2
set tabstop=2
set expandtab
set mouse=nvc
au BufEnter * :syntax sync fromstart
au FileType go nmap <buffer> <Leader>i <Plug>(go-info)
au FileType go nmap <buffer> <Leader>gd <Plug>(go-doc)
au FileType go nmap <buffer> <C-]> <Plug>(go-def)
au FileType go setlocal ts=2 sw=2
au FileType text set textwidth=0

" Disable preview window for autcomplete
set completeopt=menu,menuone,longest

let python_highlight_builtins=1
let python_highlight_exceptions=1

let g:go_list_type='quickfix'
let g:go_list_height=10

" No bells
set vb t_vb=

" Key Mappings
let mapleader=" "
nnoremap <C-n> :hide bnext<CR>
nnoremap <C-p> :hide bprev<CR>
nnoremap <C-_> :call DeleteCurrentBuffer()<CR>
nnoremap <Leader>n :cnext<CR>
nnoremap <Leader>p :cprev<CR>
nnoremap <Leader><Left> <C-W><Left>
nnoremap <Leader><Right> <C-W><Right>
nnoremap <Leader><Up> <C-W><Up>
nnoremap <Leader><Down> <C-W><Down>
nnoremap <Leader>\| :vs<CR>
nnoremap <Leader>_ :sp<CR>
nnoremap <Leader>o :SF 
nnoremap <Leader>s :SG 
nnoremap <Leader>b :make<CR>:cw<CR>
nnoremap <Leader>t :GoTest<CR>
nnoremap <Leader>r :GoReferrers<CR>

inoremap <C-x><C-x> <C-x><C-o>
