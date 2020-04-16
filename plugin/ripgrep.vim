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

"let s:ripgrep_debug = 1
"unlet s:ripgrep_debug

" Preprocessing
if !exists('s:ripgrep_debug')
  if exists('g:loaded_vim_ripgrep') 
    finish
  elseif v:version < 700
    echoerr 'vim-ripgrep does not work this version of Vim "' . v:version . '".'
    finish
  endif
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
set grepprg=rg\ --vimgrep
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

function! g:ripgrep#BuildHighlightPattern(pattern)
  call ripgrep#echod('BuildHighlightPattern:"'.a:pattern.'"')
  " \% and \# --> % and #
  let regex = substitute(a:pattern,'\\\([#%]\)',{m -> m[1]}, 'g')
  " ',+ and ? --> \+ and \?
  let regex = substitute(regex,'\([''+?|()]\)',{m -> "\\".m[1]}, 'g')
  " eg. apostrophe (") \x22 --> \%x22
  let regex = substitute(regex,'\\\([xu]\d\+\)',{m -> "\\%".m[1]}, 'g')

  " TODO support more then two word boundary
  " \b --> \< 
  let regex = substitute(regex,'\\b','\\<', '')
  let regex = substitute(regex,'\\b','\\>', '')
  " ^ --> ''
  let regex = substitute(regex,'^\^','', '')

  "word 
  if index(g:ripgrep_parameters, '"-w"') != -1 
    let regex = '\<'.regex.'\>'
  endif
  "start/end match
  let regex = '\zs'.regex.'\ze'
  "ignore case
  if index(g:ripgrep_parameters, '"-i"') != -1 
    let regex = '\c'.regex
  endif

  call ripgrep#echod('BuildHighlightPattern:'.regex)
  return regex
endfunction

function! g:ripgrep#BuildMatchCmd(regex, match_cmd_num)
  let cmd = ''
  let regex_prefix = '^.\{-}|.\{-}|'
  if a:match_cmd_num == 1
    let cmd = 'match Error '''.regex_prefix.'\(.\{-}'.a:regex.'\)\{'.a:match_cmd_num.'}'''
  else
    let cmd = a:match_cmd_num.'match Error '''.regex_prefix.'\(.\{-}'.a:regex.'\)\{'.a:match_cmd_num.'}'''
  endif
  "call ripgrep#echod('BuildMatchCmd :'.cmd)
  return cmd
endfunction

function! g:ripgrep#IsRgExecutedInQF()
 	let qf_cmd = getqflist({'title' : 1})['title']
  if &buftype == 'quickfix'
 	  match none
  endif
  return qf_cmd =~ '^:\?\(AsyncRun\)\?\s\?rg'
endfunction

" it should run only after grep
function! g:ripgrep#HighlightMatchedInQuickfixIfRgExecuted()
  if &buftype == 'quickfix' && ripgrep#IsRgExecutedInQF()
    call ripgrep#echod('Highlight matching text ...')
    call ripgrep#SetQuickFixWindowProperties()

    if exists('g:ripgrep_search_pattern') && exists('g:ripgrep_parameters')
      let regex = ripgrep#BuildHighlightPattern(trim(g:ripgrep_search_pattern,'"'))
      execute 'match none'
      execute ripgrep#BuildMatchCmd(regex, 1)
      execute ripgrep#BuildMatchCmd(regex, 2)
      execute ripgrep#BuildMatchCmd(regex, 3)
    endif            
  endif
endfunction

function! g:ripgrep#echod(msg)
  if exists('s:ripgrep_debug')
    if exists(':Decho')
      call Decho(a:msg)
    else
      echom a:msg
    endif
  endif
endfunction

function! g:ripgrep#BuildParamsForCmd()
  let params = ''
  for p in g:ripgrep_parameters 
    if (p!=g:ripgrep_search_pattern)
      " we should remove only one from the begin and the end
      let param = substitute(p,'^"','','')
      let param = substitute(param,'"$','','')
    else
      let param = g:ripgrep_search_pattern
    endif
    let params .= param.' ' 
  endfor
  return params
endfunction

function! g:ripgrep#EscapeSearchPattern(pattern)
  let escaped = a:pattern
  " backslash (\) --> \\
  "let escaped  = substitute(escaped,'\\','\\\\\\\\', 'g')

  let escaped = trim(escape(escaped, '%#'),'"')
  " apostrophe (") --> \x22 
  let escaped  = substitute(escaped,'"','\\x22', 'g')
  
  let g:ripgrep_search_pattern = '"'.escaped.'"'
  return g:ripgrep_search_pattern
endfunction

function! g:ripgrep#ReadParams(...)
  let g:ripgrep_parameters = []
  let g:ripgrep_search_path = []
  let g:ripgrep_search_pattern = ''
  let pattern_set=0
  let path_set=0
  let i = a:0 - 1
  let is_path = 1
  call ripgrep#echod('ReadParams: '.string(a:000))
  while i >= 0
    call ripgrep#echod('ReadParams param '.i.': '.a:000[i])
    " if last parameter is a file/directory

    if is_path == 1 
      let file_or_dir = glob(expand(a:000[i]))
      if !empty(file_or_dir) && (isdirectory(file_or_dir) || filereadable(file_or_dir))
        call ripgrep#echod('ReadParams param '.i.' is path:'.file_or_dir)
        call insert(g:ripgrep_parameters, shellescape(a:000[i]))
        call insert(g:ripgrep_search_path, file_or_dir)
      else
        let is_path = 0
        call ripgrep#echod('ReadParams param '.i.' is NOT path!')
        continue
      endif
    else " else search string
      if pattern_set == 0 
        let escaped = ripgrep#EscapeSearchPattern(a:000[i])
        call insert(g:ripgrep_parameters, g:ripgrep_search_pattern)
        call ripgrep#echod('ReadParams param '.i.' is pattern:'.g:ripgrep_search_pattern)
        let pattern_set = 1
      else " else rg parameters
        call ripgrep#echod('ReadParams param '.i.' is rg parameter:'.a:000[i])
        call insert(g:ripgrep_parameters, shellescape(trim(a:000[i],'"')))
      endif
      let is_path = 0
    endif
    let i -= 1
  endwhile

  if len(g:ripgrep_search_path) == 0
    call add(g:ripgrep_parameters, '.')
  endif

endfunction

function! g:ripgrep#ExecRipGrep()
  let cmd = 'silent grep! '
  " now join from the beginning
  for p in g:ripgrep_parameters | let cmd .= ' '.p | endfor
  call ripgrep#echod('ExecRipGrep: execute ' . cmd)
	"echohl ModeMsg | echo 'vim-ripgrep: '.substitute(cmd,'silent grep! ','rg','') | echohl None
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
	  echohl ModeMsg | echo 'vim-ripgrep: '.qf_size.' matches found in '.search_path | echohl None
	  " so we get info about parsing errors...
	  copen
  else
    echohl WarningMsg | echo 'vim-ripgrep: No match found in '.search_path | echohl None
  endif
endfunction

function! g:ripgrep#ReadParamsForCmd(...)
  " this is weird, but the args are so ok
  call call('ripgrep#ReadParams', a:000)
  let params = ripgrep#BuildParamsForCmd()
  call ripgrep#echod('ReadParamsForCmd: '.params )

	echohl ModeMsg | echo 'vim-ripgrep: rg '.params | echohl None
	" The return value goes to Async Command
  return trim(params,' ')
endfunction

function! g:ripgrep#RipGrep(...)
  " this is weird, but the args are so ok
  call call('ripgrep#ReadParams', a:000)
  call ripgrep#ExecRipGrep()  
  call ripgrep#EchoResultMsg(0)
endfunction

function! g:ripgrep#Path2Param()
  let arr = split(&path,',')
  " TODO RipGrep in path!
endfunction

" ----------------------
" Autocommands
" ----------------------

augroup vim_ripgrep_global_command_group
  autocmd!
  autocmd WinEnter * call ripgrep#HighlightMatchedInQuickfixIfRgExecuted() 
  autocmd QuickFixCmdPost grep if ripgrep#IsRgExecutedInQF() | copen 8 | wincmd J | call ripgrep#HighlightMatchedInQuickfixIfRgExecuted() | endif

  " close with q or esc
  autocmd FileType qf if mapcheck('<esc>', 'n') ==# '' | nnoremap <buffer><silent> <esc> :cclose<bar>lclose<CR> | endif
  autocmd FileType qf if mapcheck('q', 'n') ==# '' | nnoremap <buffer><silent> q :cclose<bar>lclose<CR>
augroup END

" ----------------------
" Commands
" ----------------------

" TODO RipGrep in path!
if (exists(':AsyncRun'))
  command! -bang -nargs=+ -range=0 -complete=file RipGrep
	        \ execute 'AsyncRun'.<bang>.' -post=call\ ripgrep\#EchoResultMsg(2) -auto=grep -program=grep @ '.
          \ escape(ripgrep#ReadParamsForCmd(<f-args>),'#%')
else
  command! -nargs=+ -complete=file RipGrep call ripgrep#RipGrep(<f-args>)
endif

" ----------------------
" Mappings
" ----------------------

if !exists('g:ripgrep_skip_mappings')
  " ripgrep word under cursor in current file
  nnoremap <leader>rw <ESC>:execute 'RipGrep -w '.ripgrep#EscapeSearchPattern('<C-R><C-W>').' %'<CR>
  " ripgrep word under cursor in current dir
  nnoremap <leader>rW <ESC>:execute 'RipGrep -w '.ripgrep#EscapeSearchPattern('<C-R><C-W>')<CR>
  " ripgrep selected in current file
  vnoremap <leader>rs y<ESC>:execute 'RipGrep '.ripgrep#EscapeSearchPattern(escape('<C-R>0',' ')).' %'<CR>
  " ripgrep selected in current dir 
  vnoremap <leader>rS y<ESC>:execute 'RipGrep '.ripgrep#EscapeSearchPattern(escape('<C-R>0',' '))<CR>
endif


let &cpo = s:save_cpo
unlet s:save_cpo

" ----------------------
" TODO Tests
" ----------------------
"
"For running a command listed here yank the next line as is to a register 
"(eg. to t: "tyy), then run it with @<register>:
"0f:ly$:"

"  Special characters
" ----------------------
"ok :RipGrep ripgrep\#Echo %
"ok :RipGrep -w ripgrep %
"nok:RipGrep \#\% %
"ok :RipGrep ^\s*"\ .* %
"ok :RipGrep ^\s*\x22\ .* %
"nok zs is not supported by rg: RipGrep ^\s*\zs\x22\ .* %
"ok : !rg ^\s+"".* %

"  Space...
"
"ok :RipGrep autocmd\ File %
"
