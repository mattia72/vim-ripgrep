let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~\dev\vim\vim-ripgrep\test
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
set stal=2
tabnew
tabrewind
edit helper.vim
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 115 - ((27 * winheight(0) + 21) / 43)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
115
normal! 036|
tabnext
edit test_commands_with_multi_escaped.vim
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 34 - ((9 * winheight(0) + 10) / 21)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
34
normal! 033|
lcd ~\dev\vim\vim-ripgrep\test
wincmd w
argglobal
if bufexists("~\dev\vim\vim-ripgrep\plugin\ripgrep.vim") | buffer ~\dev\vim\vim-ripgrep\plugin\ripgrep.vim | else | edit ~\dev\vim\vim-ripgrep\plugin\ripgrep.vim | endif
setlocal fdm=diff
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 31 - ((30 * winheight(0) + 21) / 43)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
31
normal! 021|
lcd ~\dev\vim\vim-ripgrep\test
wincmd w
2wincmd w
wincmd =
tabnext 2
set stal=1
badd +12 ~\dev\vim\vim-ripgrep\test\test_all.vim
badd +107 ~\dev\vim\vim-ripgrep\test\helper.vim
badd +55 ~\dev\vim\vim-ripgrep\test\test_commands_with_multi_escaped.vim
badd +0 ~\dev\vim\vim-ripgrep\plugin\ripgrep.vim
badd +1 ~\dev\vim\vim-ripgrep\Session.vim
badd +4 ~\dev\vim\vim-ripgrep\test\test_data.dat
badd +53 ~\dev\vim\vim-ripgrep\test\test_commands_with_single_escaped.vim
badd +13 ~\dev\vim\vim-ripgrep\README.md
badd +89 ~\dev\vim\vim-ripgrep\test\test_read_params.vim
badd +30 ~\dev\vim\vim-ripgrep\test\test_simple_commands.vim
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOS
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
