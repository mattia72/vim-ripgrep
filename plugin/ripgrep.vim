"=============================================================================
" File:          ripgrep.vim
" Author:        Mattia72 
" Description:   plugin definitions
" Created:       16.04.2019
" Project Repo:  https://github.com/Mattia72/ripgrep
" License:       MIT license  {{{
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

scriptencoding utf-8

" Preprocessing
if exists('g:loaded_vim_ripgrep')
  "finish
elseif v:version < 700
  echoerr 'vim-ripgrep does not work this version of Vim "' . v:version . '".'
  finish
endif

if (!executable('rg')) 
  echoerr 'vim-ripgrep couldn''t find rg executable.'
  finish
endif

let g:loaded_vim_ripgrep = 1

let s:save_cpo = &cpo
set cpo&vim

" ----------------------
" Global options 
" ----------------------

" if grepprg settings fails with "unknown option...", set isfname& could help...
let s:save_isfname = &isfname
set isfname&
"set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set grepprg=rg\ --vimgrep\ --smart-case
let &isfname = s:save_isfname
unlet s:save_isfname

set grepformat=%f:%l:%c:%m
"TODO regex parse errors...
"set grepformat+=%E%.%#error:
"set grepformat+=%C%.%#

" ----------------------
" Functions
" ----------------------

function! g:ripgrep#SetQuickFixWindowProperties()
  set nocursorcolumn cursorline
endfunction

function! g:ripgrep#ReEscape(pattern)
  "echom '"'.a:pattern.'"'
  " \% and \# --> % and #
  let ret_str = substitute(a:pattern,'\\\\\([#%]\)',{m -> m[1]}, 'g')
  " + and ? --> \+ and \?
  let ret_str = substitute(ret_str,'\([+?]\)',{m -> "\\".m[1]}, 'g')
  " TODO support more then two word boundary
  " \b --> \< 
  let ret_str = substitute(ret_str,'\\b','\\<', '')
  let ret_str = substitute(ret_str,'\\b','\\>', '')
  " ^ --> ''
  let ret_str = substitute(ret_str,'^\^','"', '')
  "echom ret_str
  return ret_str
endfunction

function! g:ripgrep#BuildMatchCmd(regex, num)
  let cmd = ''
  let regex_prefix = '^.\{-}|.\{-}|'
  if a:num == 1
    let cmd = 'match Error "'.regex_prefix.'\(.\{-}'.a:regex.'\)\{'.a:num.'}"'
  else
    let cmd = a:num.'match Error "'.regex_prefix.'\(.\{-}'.a:regex.'\)\{'.a:num.'}"'
  endif
  "echom 'BuildMatchCmd :'.cmd
  return cmd
endfunction

" it should run only after grep
function! g:ripgrep#HighlightMatched()
  "echom 'Highlight...'
  call ripgrep#SetQuickFixWindowProperties()
  
 	let qf_cmd = getqflist({'title' : 1})['title']

  if qf_cmd =~ '^:\?\(AsyncRun\)\?\s\?rg' && exists('g:ripgrep_search_pattern') && exists('g:ripgrep_parameters')
    "don't match before second |
    let cmd = 'match none | match Error' 
    let regex = ripgrep#ReEscape(trim(g:ripgrep_search_pattern,'"'))
    if (g:ripgrep_search_pattern !~# '\\zs')
      let regex = '\zs'.regex
    endif
    if (g:ripgrep_search_pattern !~# '\\ze')
      let regex = regex.'\ze'
    endif
    "ignore case
    if index(g:ripgrep_parameters, '"-i"') != -1 
      let regex = '\c'.regex
    endif
    execute 'match none'
    execute ripgrep#BuildMatchCmd(regex, 1)
    execute ripgrep#BuildMatchCmd(regex, 2)
    execute ripgrep#BuildMatchCmd(regex, 3)
  endif            
endfunction

function! g:ripgrep#ReadParams(...)
  let i = a:0 - 1
  let is_path = 1
  let g:ripgrep_parameters = []
  let pattern_set=0
  let path_set=0
  let g:ripgrep_search_path = []
  while i >= 0
    echom 'Rg param '.i.': '.a:000[i]
    " if last parameter is a file/directory

    if is_path == 1 
      let file_or_dir = glob(expand(a:000[i]))
      if !empty(file_or_dir) && (isdirectory(file_or_dir) || filereadable(file_or_dir))
        echom 'Rg param '.i.' is path:'.file_or_dir
        call insert(g:ripgrep_parameters, shellescape(a:000[i]))
        call insert(g:ripgrep_search_path, file_or_dir)
      else
        let is_path = 0
        echom 'Rg param '.i.' is NOT path:'.file_or_dir
        continue
      endif
    else " else search string
      if pattern_set == 0 
        let g:ripgrep_search_pattern = '"'.escape(a:000[i], '%#"').'"'
        let pattern_set = 1
        call insert(g:ripgrep_parameters, g:ripgrep_search_pattern)
        echom 'Rg pattern:'.g:ripgrep_search_pattern
      else
        call insert(g:ripgrep_parameters, shellescape(a:000[i]))
      endif
      let is_path = 0
    endif
    let i -= 1
  endwhile
  if len(g:ripgrep_search_path) == 0
    call add(g:ripgrep_parameters, '.')
  endif

  let params = ''
  for p in g:ripgrep_parameters | let params .= trim(p,'"').' ' | endfor
  "for p in g:ripgrep_parameters | let params .= p.' ' | endfor

  echom 'Rg: '.params 
	echohl ModeMsg | echo 'RipGrep: rg '.params | echohl None
	" The return value goes to Async Command
  return params
endfunction

function! g:ripgrep#ExecRipGrep()
  let cmd = 'silent grep! '
  " now join from the beginning
  for p in g:ripgrep_parameters | let cmd .= ' '.p | endfor
  "echom 'RipGrep run: ' . cmd
	"echohl ModeMsg | echo 'RipGrep: '.substitute(cmd,'silent grep! ','rg','') | echohl None
  execute cmd
endfunction

function! ripgrep#EchoResultMsg(header_footer_line_count)
  if len(g:ripgrep_search_path) > 0
    let search_path = join(g:ripgrep_search_path,', ') 
  else
    let search_path = getcwd()
  endif

 	redraw

  let qflist = getqflist()
 	let qf_size = len(qflist) - a:header_footer_line_count
  if qf_size > 0
	  echohl ModeMsg | echo 'RipGrep: '.qf_size.' matches found in '.search_path | echohl None
	  " so we get info about parsing errors...
	  copen
  else
    echohl WarningMsg | echo 'RipGrep: No match found in '.search_path | echohl None
  endif
endfunction

function! g:ripgrep#RipGrep(...)
  " this is weird, but the args are so ok
  call call('ripgrep#ReadParams', a:000)
  call ripgrep#ExecRipGrep()  
  call ripgrep#EchoResultMsg(0)
endfunction

" ----------------------
" Autocommands
" ----------------------

augroup vim_ripgrep_global_command_group
  autocmd!
  autocmd FileType qf call ripgrep#HighlightMatched() 
  autocmd QuickFixCmdPost grep copen 8 | wincmd J

  " close with q or esc
  autocmd FileType qf if mapcheck('<esc>', 'n') ==# '' | nnoremap <buffer><silent> <esc> :cclose<bar>lclose<CR> | endif
  autocmd FileType qf if mapcheck('q', 'n') ==# '' | nnoremap <buffer><silent> q :cclose<bar>lclose<CR>
augroup END

" ----------------------
" Commands
" ----------------------

if (exists(':AsyncRun'))
  command! -bang -nargs=+ -range=0 -complete=file RipGrepAsync
	      \ execute 'AsyncRun'.<bang>.' -post=call\ ripgrep\#EchoResultMsg(2) -auto=grep -program=grep @ '.escape(ripgrep#ReadParams(<f-args>),'#%"')
endif

command! -nargs=+ -complete=file RipGrep call ripgrep#RipGrep(<f-args>)

" ----------------------
" TODO Mappings
" ----------------------

let &cpo = s:save_cpo
unlet s:save_cpo

" ----------------------
" TODO Tests
" ----------------------
"
"  Special characters
"
"ok :RipGrep ripgrep\#Echo %
"ok :RipGrepAsync ripgrep\#Echo %
"nok:RipGrep \#\% %

"  Space...
"
"ok :RipGrep autocmd\ File %
"nok:RipGrepAsync autocmd\ File %
"
"yank the next line to a register, then run with @<register>
"0f:ly$:"
