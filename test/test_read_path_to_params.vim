"=============================================================================
" File:          test_read_path_to_params.vim
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

let s:tc = unittest#testcase#new("Path to parameter")

function! s:tc.SETUP()
  if exists('g:ripgrep_parameters')
    let s:save_rg_parameters = g:ripgrep_parameters
  endif
  if exists('g:ripgrep_search_pattern')
    let s:save_rg_pattern    = g:ripgrep_search_pattern
  endif
  if exists('g:ripgrep_search_path')
    let s:save_rg_path       = g:ripgrep_search_path
  endif
  let g:ripgrep_parameters     = []
  let g:ripgrep_search_pattern = []
  let g:ripgrep_search_path    = []
  let s:save_path = &path
endfunction

function! s:tc.TEARDOWN()
  if exists('s:save_rg_parameters')
    let g:ripgrep_parameters = s:save_rg_parameters 
  endif
  if exists('s:save_rg_pattern')
    let g:ripgrep_search_pattern = s:save_rg_pattern 
  endif
  if exists('s:save_rg_path')
    let g:ripgrep_search_path = s:save_rg_path 
  endif
  set path<
endfunction

" setup for each test
function! s:tc.setup()
  let g:ripgrep_search_path    = []
endfunction
"----------------------------------------
" TESTS
"----------------------------------------
function! s:tc.test_1_path2param_dot()
  setlocal path=. 
  let expected = '.'
  let path_arr = g:ripgrep#Path2Param()
  let params_out = join(g:ripgrep_search_path, ',')
	call self.assert_equal(expected, params_out, "Path2Param test path=.")
endfunction
"----------------------------------------
function! s:tc.test_2_path2param_dot_and_tilde()
  setlocal path=.,~ 
  let expected = '.,'.glob('~')
  let path_arr = g:ripgrep#Path2Param()
  "echom string(path_arr)
  let params_out = join(g:ripgrep_search_path, ',')
	call self.assert_equal(expected, params_out, "Path2Param test path=.,~")
endfunction
