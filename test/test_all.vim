"
" Use following command to run these tests:
" :UnitTest
"
let s:here = expand('<sfile>:p:h')
execute 'source' s:here . '/test_read_params.vim'
execute 'source' s:here . '/test_simple_commands.vim'
execute 'source' s:here . '/test_commands_with_single_escaped.vim'
execute 'source' s:here . '/test_commands_with_multi_escaped.vim'
