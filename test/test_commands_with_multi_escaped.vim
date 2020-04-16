"=============================================================================
" File:          test_ripgrep.vim
" Author:        Mattia72 
" Description:   unit tests (works with h1mesuke/vim-unittest)   
" Created:       16.05.2019
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

let s:here = expand('<sfile>:p:h')
let s:tc = unittest#testcase#new("Commands with multi escaped chars", { 'data': s:here . '/test_data.dat' })

exec 'source '.s:here.'/helper.vim'

let g:helper = helper#new(s:tc, g:ripgrep_dbg )

function! s:tc.SETUP()
  call g:helper.setup()
endfunction

function! s:tc.TEARDOWN()
  call g:helper.teardown()
endfunction

"---------------------------------------
" COMMAND TEST
"---------------------------------------

function! s:tc.test_1_search_hashes()
  call g:helper.run_all_cmd('hashes\#\# test_data.dat', 1, 'test #hashes#')
endfunction

"function! s:tc.test_2_search_percents()
  "call g:helper.run_all_cmd('more\%\ percents\% test_data.dat', 1, 'test more% percents%')
"endfunction

"function! s:tc.test_3_search_backslashes()
  "call g:helper.run_all_cmd('\\backslashes\\ test_data.dat', 1, 'test \backslashes\')
"endfunction

unlet s:tc
