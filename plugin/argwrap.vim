" Copyright (c) 2014 Alex Yatskov <alex@foosoft.net>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy of
" this software and associated documentation files (the "Software"), to deal in
" the Software without restriction, including without limitation the rights to
" use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
" the Software, and to permit persons to whom the Software is furnished to do so,
" subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
" FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
" COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
" IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
" CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

call argwrap#initSetting('line_prefix', '')
call argwrap#initSetting('padded_braces', '')
call argwrap#initSetting('tail_comma', 0)
call argwrap#initSetting('tail_comma_braces', '')
call argwrap#initSetting('tail_indent_braces', '')
call argwrap#initSetting('wrap_closing_brace', 1)
call argwrap#initSetting('comma_first', 0)
call argwrap#initSetting('comma_first_indent', 0)
call argwrap#initSetting('filetype_hooks', {})
call argwrap#initSetting('php_smart_brace', 0)

command! ArgWrap call argwrap#toggle()

nnoremap <silent> <Plug>(ArgWrapToggle) :call argwrap#toggle() <BAR>
  \ silent! call repeat#set("\<Plug>(ArgWrapToggle)")<CR>
