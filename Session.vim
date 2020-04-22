let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~\dev\vim\vim-ripgrep\test
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +293 ~\dev\vim\vim-ripgrep\plugin\ripgrep.vim
badd +108 ~\dev\vim\vim-ripgrep\doc\ripgrep.txt
badd +2 test_commands_with_multi_escaped.vim
badd +110 helper.vim
badd +4 test_data.dat
badd +9 test_all.vim
badd +1 ~\dev\vim\vim-ripgrep\Session.vim
badd +53 test_commands_with_single_escaped.vim
badd +13 ~\dev\vim\vim-ripgrep\README.md
badd +56 test_read_path_to_params.vim
badd +49 test_simple_commands.vim
badd +696 ~\.vim\plugged\vim-unittest\doc\unittest.txt
badd +1 test_read_params.vim
argglobal
%argdel
set stal=2
edit test_read_path_to_params.vim
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 119 + 120) / 240)
exe '2resize ' . ((&lines * 30 + 31) / 62)
exe 'vert 2resize ' . ((&columns * 120 + 120) / 240)
exe '3resize ' . ((&lines * 29 + 31) / 62)
exe 'vert 3resize ' . ((&columns * 120 + 120) / 240)
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
let s:l = 56 - ((40 * winheight(0) + 30) / 60)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
56
normal! 041|
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
let s:l = 293 - ((19 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
293
normal! 0
lcd ~\dev\vim\vim-ripgrep\test
wincmd w
argglobal
if bufexists("~\dev\vim\vim-ripgrep\test\test_read_path_to_params.vim") | buffer ~\dev\vim\vim-ripgrep\test\test_read_path_to_params.vim | else | edit ~\dev\vim\vim-ripgrep\test\test_read_path_to_params.vim | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 56 - ((24 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
56
normal! 041|
wincmd w
exe 'vert 1resize ' . ((&columns * 119 + 120) / 240)
exe '2resize ' . ((&lines * 30 + 31) / 62)
exe 'vert 2resize ' . ((&columns * 120 + 120) / 240)
exe '3resize ' . ((&lines * 29 + 31) / 62)
exe 'vert 3resize ' . ((&columns * 120 + 120) / 240)
tabedit ~\dev\vim\vim-ripgrep\plugin\ripgrep.vim
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=diff
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 129 - ((29 * winheight(0) + 30) / 60)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
129
normal! 016|
lcd ~\dev\vim\vim-ripgrep\test
tabnext 1
set stal=1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToOS
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
