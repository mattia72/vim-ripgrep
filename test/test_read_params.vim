"=============================================================================
" File:          test_read_params.vim
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

let s:tc = unittest#testcase#new("Parameter conversions")

function! s:tc.SETUP()
  if exists('g:ripgrep_parameters')
    let s:save_rg_parameters = g:ripgrep_parameters
    let s:save_rg_pattern = g:ripgrep_search_pattern
    let s:save_rg_path = g:ripgrep_search_path
  endif
  let g:ripgrep_parameters = []
endfunction

function! s:tc.TEARDOWN()
  if exists('s:save_rg_parameters')
    let g:ripgrep_parameters = s:save_rg_parameters 
    let g:ripgrep_search_pattern = s:save_rg_pattern 
    let g:ripgrep_search_path = s:save_rg_path 
  endif
endfunction

"----------------------------------------
" PARAMETER READING
"----------------------------------------
function! s:tc.test_param_one_word_search()
  let params_in = 'search_string'
  let params_out = g:ripgrep#ReadParams(params_in)
	call self.assert_equal('"search_string" .',params_out, "RipGrepAsync parameter input test")
	call self.assert_equal(['"search_string"', '.'], g:ripgrep_parameters, "RipGrep parameter input test")
endfunction
"----------------------------------------
function! s:tc.test_param_one_word_with_space_search()
  let params_in = 'search string'
  " this should be written in command line 'search\ string'
  let params_out = g:ripgrep#ReadParams(params_in)
	call self.assert_equal('"search string" .',params_out, "RipGrepAsync parameter input test")
	call self.assert_equal(['"search string"', '.'], g:ripgrep_parameters, "RipGrep parameter input test")
endfunction
"----------------------------------------
function! s:tc.test_param_one_word_with_apostrophe()
  let params_in = 'search string "has" aposthrophe'
  " this should be written in command line 'search\#string'
  let params_out = g:ripgrep#ReadParams(params_in)
	call self.assert_equal('"search string \x22has\x22 aposthrophe" .',params_out, "RipGrepAsync parameter input test")
	call self.assert_equal(['"search string \x22has\x22 aposthrophe"', '.'], g:ripgrep_parameters, "RipGrep params")
endfunction
"----------------------------------------
function! s:tc.test_param_one_word_with_extra_param()
  let params_out = g:ripgrep#ReadParams('"-w"', '"search"')
	call self.assert_equal('-w "search" .',params_out, "RipGrepAsync parameter input test")
	call self.assert_equal(['"-w"','"search"', '.'], g:ripgrep_parameters, "RipGrep parameter input test")
endfunction
"----------------------------------------
function! s:tc.test_param_one_word_with_extra_search()
  let params_in = 'search#string'
  " this should be written in command line 'search\#string'
  let params_out = g:ripgrep#ReadParams(params_in)
	call self.assert_equal('"search\#string" .',params_out, "RipGrepAsync parameter input test")
	call self.assert_equal(['"search\#string"', '.'], g:ripgrep_parameters, "RipGrep parameter input test")
endfunction
"----------------------------------------
function! s:tc.test_param_one_word_with_regex_search()
  let params_in = '\bsearch[a-z]\w+'
  let params_out = g:ripgrep#ReadParams(params_in)
	call self.assert_equal(['"\bsearch[a-z]\w+"', '.'], g:ripgrep_parameters, "RipGrep parameter input test")
	call self.assert_equal('"\bsearch[a-z]\w+" .',params_out, "RipGrepAsync parameter input test")
endfunction

"---------------------------------------
" HIGHTLIGHTING
"---------------------------------------
function! s:tc.test_highlight_regex()
  let params_in = '^\b \# \% \x22 \b'
  let params_out = g:ripgrep#BuildHighlightPattern(params_in)
	call self.assert_equal('\zs\< # % \%x22 \>\ze', params_out, "Highlight regex test")
endfunction

function! s:tc.test_highlight_regex_if_params_exists()
  let params_in = 'seARCH'
  let g:ripgrep_parameters = ['"-i"', '"-w"']
  let params_out = g:ripgrep#BuildHighlightPattern(params_in)
	call self.assert_equal('\c\zs\<seARCH\>\ze', params_out, "Highlight regex test")
endfunction

