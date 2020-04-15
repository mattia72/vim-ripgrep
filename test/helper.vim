"=============================================================================
" File:          common_test_helpers.vim
" Author:        Mattia72 
" Description:   helper functions for unit tests (works with h1mesuke/vim-unittest)   
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

function helper#new(testcase)

  let obj = {} 
  let obj.tc = a:testcase
  let obj.lorem_first_line = ''
  " TODO set get_dbg_msg = 1 for dbg output
  let obj.get_dbg_msg = 1
  if exists('g:ripgrep_parameters')
    let obj.save_rg_parameters = g:ripgrep_parameters
    let obj.save_rg_pattern = g:ripgrep_search_pattern
    let obj.save_rg_path = g:ripgrep_search_path
  else
    let obj.save_rg_parameters = ''
    let obj.save_rg_pattern = ''
    let obj.save_rg_path = ''
  endif
  let obj.save_cwd = getcwd() 


  function! obj.setup()
    execute 'cd '.expand('<sfile>:p:h')
    if exists('g:ripgrep_parameters')
      let self.save_rg_parameters = g:ripgrep_parameters
      let self.save_rg_pattern = g:ripgrep_search_pattern
      let self.save_rg_path = g:ripgrep_search_path
    endif
    let g:ripgrep_parameters = []
    let g:ripgrep_search_path = []
    let g:ripgrep_search_pattern = ''
    if (exists(':AsyncRun'))
      command! -bang -nargs=+ -range=0 -complete=file TestRipGrepAsync
	          \ execute 'AsyncRun'.<bang>.' -post=call\ ripgrep\#EchoResultMsg(2) -auto=grep -program=grep @ '.
            \ escape(ripgrep#ReadParamsAsync(<f-args>),'#%')
	  endif
    command! -nargs=+ -complete=file TestRipGrep call ripgrep#RipGrep(<f-args>)

    let self.tc.saved = {}
    let self.tc.data.marker_formats = ['# BEGIN %s', '# END %s']
    let self.lorem_first_line = self.tc.data.get('first_line')[0]
  endfunction

  function! obj.teardown()
    if exists('s:save_rg_parameters')
      let g:ripgrep_parameters = self.save_rg_parameters
      let g:ripgrep_search_pattern = self.save_rg_pattern
      let g:ripgrep_search_path = self.save_rg_path
    endif
    delcommand TestRipGrep
    delcommand TestRipGrepAsync
    cclose

    execute 'cd '.self.save_cwd
  endfunction

  function! obj.run_cmd(cmd, params, expected_qf_len, expected_qf_text)
    " clear qflist
	  call setqflist([], 'r')
	  sleep 500m

    execute a:cmd.' '.a:params

    while g:asyncrun_status == 'running' | sleep 200m | endwhile

    let qf_length = len(getqflist())

    let exp_qf_len = a:cmd =~ 'Async' ? a:expected_qf_len+2 : a:expected_qf_len

    let msg = a:cmd.' '.a:params.' should find '.exp_qf_len.' matches'
    let msg .= "\n    pwd       : ". getcwd()
    let msg .= "\n    parameters: ". string(g:ripgrep_parameters)
    let msg .= "\n    pattern   : ". g:ripgrep_search_pattern
    let msg .= "\n    path      : ". string(g:ripgrep_search_path)

    "call tc.assert(0, msg)

    if qf_length > 0
      for qf_item in getqflist()
        let msg .= "\n    qf        : ".qf_item.text
      endfor
      call self.tc.assert_equal(a:expected_qf_text, getqflist()[a:cmd =~ 'Async' ? 1 : 0].text, msg)
    endif
    call self.tc.assert_equal(exp_qf_len, qf_length, msg)

    if self.get_dbg_msg == 1
      for em in split(msg, '\n')
        echom em
      endfor
    endif

  endfunction

  function! obj.run_all_cmd(params, expected_qf_len, expected_qf_text)
    for cmd in ['TestRipGrepAsync' , 'TestRipGrep']
      call self.run_cmd(cmd, a:params, a:expected_qf_len, a:expected_qf_text)
    endfor
  endfunction

  return obj
endfunction
