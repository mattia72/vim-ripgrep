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

let s:tmpCwd = getcwd() 
let s:here = expand('<sfile>:p:h')
let s:tc = unittest#testcase#new("Command output", { 'data': s:here . '/test_data.dat' })

function! s:tc.SETUP()
  execute 'cd '.s:here
  if exists('g:ripgrep_parameters')
    let s:save_rg_parameters = g:ripgrep_parameters
    let s:save_rg_pattern = g:ripgrep_search_pattern
    let s:save_rg_path = g:ripgrep_search_path
  endif
  let g:ripgrep_parameters = []
  if (exists(':AsyncRun'))
    " the only difference is -strip
    command! -bang -nargs=+ -range=0 -complete=file TestRipGrepAsync
	        \ execute 'AsyncRun'.<bang>.' -strip -post=call\ ripgrep\#EchoResultMsg(2) -auto=grep -program=grep @ '.
	        \ escape(ripgrep#ReadParams(<f-args>),'#%\')
	endif
  command! -nargs=+ -complete=file TestRipGrep call ripgrep#RipGrep(<f-args>)

  let self.saved = {}
  let self.data.marker_formats = ['# BEGIN %s', '# END %s']
  let s:lorem_first_line = self.data.get('first_line')[0]
endfunction

function! s:tc.TEARDOWN()
  if exists('s:save_rg_parameters')
    "let g:ripgrep_parameters = s:save_rg_parameters 
    "let g:ripgrep_search_pattern = s:save_rg_pattern 
    "let g:ripgrep_search_path = s:save_rg_path 
  endif
  delcommand TestRipGrep
  delcommand TestRipGrepAsync
  cclose

  execute 'cd '.s:tmpCwd
endfunction

"---------------------------------------
" COMMAND TEST
"---------------------------------------

function! s:tc.run_all_cmd(params, expected_qf_len, expected_qf_text)
  for cmd in ['TestRipGrep', 'TestRipGrepAsync']
    execute cmd.' '.a:params
    while g:asyncrun_status == 'running' 
      sleep 100m
    endwhile
    let qf_length = len(getqflist())
    let msg = cmd.' '.a:params.' should find '.a:expected_qf_len.' matches'
    let msg .= "\n    Pwd       : ". getcwd()
    let msg .= "\n    parameters: ". string(g:ripgrep_parameters)
    if qf_length > 0
      for qf_item in getqflist()
        let msg .= "\n    qf        : ".qf_item.text
      endfor
      call self.assert_equal(a:expected_qf_text, getqflist()[0].text, msg)
    endif
    call self.assert_equal(a:expected_qf_len, qf_length, msg)
  endfor
endfunction

function! s:tc.test_search_simple_word()
  call self.run_all_cmd('dolor test_data.dat', 4, s:lorem_first_line)
endfunction

function! s:tc.test_search_simple_whole_word()
  call self.run_all_cmd('-w dolor test_data.dat', 1, s:lorem_first_line)
endfunction

function! s:tc.test_search_simple_whole_word_only_in_dat()
  call self.run_all_cmd('-w -g *.dat dolor', 1, s:lorem_first_line)
endfunction

function! s:tc.test_search_comment()
  call self.run_all_cmd('\#\s*test\ comment test_data.dat', 1, '# test comment')
endfunction

function! s:tc.test_search_space()
  call self.run_all_cmd('test\ space test_data.dat', 1, 'test space')
endfunction

function! s:tc.test_search_hash()
  call self.run_all_cmd('hash\# test_data.dat', 1, 'test hash#')
endfunction

function! s:tc.test_search_percent()
  call self.run_all_cmd('percent\% test_data.dat', 1, 'test percent%')
endfunction

unlet s:tc
