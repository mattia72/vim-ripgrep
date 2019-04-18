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
  finish
elseif v:version < 700
  echoerr 'vim-ripgrep does not work this version of Vim "' . v:version . '".'
  finish
endif

let g:loaded_vim_ripgrep = 1

let s:save_cpo = &cpo
set cpo&vim

" ----------------------
" Global options 
" ----------------------

" ----------------------
" Autocommands
" ----------------------
augroup vim_ripgrep_global_command_group
  autocmd!
  autocmd QuickFixCmdPost grep call g:GrepPostActions() 
augroup END

" ----------------------
" Functions
" ----------------------

function! g:GrepPostActions()
  let qflist = getqflist()
  "call setqflist([], 'a', {'title' : 'Cmd output'})
  let cmd = 'copen | match Error '

  if len(qflist) > 0
    if exists('g:ripgrep_search_pattern') && exists('g:ripgrep_parameters')
      "ignore case
      if index(g:ripgrep_parameters, '"-i"') != -1 
        let cmd = ''.cmd.shellescape('\c'.trim(g:ripgrep_search_pattern,'"'))
      else     
        let cmd = ''.cmd.g:ripgrep_search_pattern
      endif
      "let @/ = trim(g:ripgrep_search_pattern,'"')
      echom 'execute:'.cmd
      execute cmd
    endif            
    wincmd J
  else 
    "TODO better info about searched pathes
	  echom 'len '.len(g:ripgrep_search_path)
    if len(g:ripgrep_search_path) > 0
	    echohl WarningMsg | echo 'No match found in '.join(g:ripgrep_search_path,', ') | echohl None
	    echom 'No match found in '.join(g:ripgrep_search_path,', ')
	  else
	    echohl WarningMsg | echo 'No match found in '.getcwd() | echohl None
	    echom 'No match found in '.getcwd() 
	  endif
  endif
endfunction

function! RipGrep(...)
  let cmd = 'silent grep! '
  let i = a:0 - 1
  let is_path = 1
  let g:ripgrep_parameters = []
  let pattern_set=0
  let path_set=0
  let g:ripgrep_search_path = []
  while i >= 0
    " if last parameter is a file/directory
    if !empty(glob(expand(a:000[i]))) && is_path == 1
      call insert(g:ripgrep_parameters, shellescape(expand(a:000[i])))
      call insert(g:ripgrep_search_path, expand(a:000[i]))
    else " else search string
      if pattern_set == 0 
        let g:ripgrep_search_pattern = shellescape(a:000[i])
        let pattern_set = 1
      endif
      call insert(g:ripgrep_parameters, shellescape(a:000[i]))
      let is_path = 0
    endif
    let i -= 1
  endwhile
  " now join from the beginning
  for p in g:ripgrep_parameters | let cmd .= ' ' . p | endfor

  "echom 'RipGrep run: ' . cmd
	echohl ModeMsg | echo 'RipGrep'.substitute(cmd,'silent grep!','','') | echohl None
  execute cmd
endfunction

" ----------------------
" Commands
" ----------------------
command! -nargs=+ -complete=file RipGrep call RipGrep(<f-args>) | cwindow 

" ----------------------
" Mappings
" ----------------------


let &cpo = s:save_cpo
unlet s:save_cpo
