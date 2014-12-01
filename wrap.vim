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


function! FindRange()
    let [l:lineStart, l:colStart] = searchpairpos("(", "", ")", "Wnb")
    let [l:lineEnd,   l:colEnd]   = searchpairpos("(", "", ")", "Wn")
    return {"lineStart": l:lineStart, "colStart": l:colStart, "lineEnd": l:lineEnd, "colEnd": l:colEnd}
endfunction

function! ExtractArgumentText(range)
    let l:text = ""

    for l:lineIndex in range(a:range.lineStart, a:range.lineEnd)
        let l:lineText = getline(l:lineIndex)

        let l:extractStart = 0
        if l:lineIndex == a:range.lineStart
            let l:extractStart = a:range.colStart
        endif

        let l:extractEnd = strlen(l:lineText)
        if l:lineIndex == a:range.lineEnd
            let l:extractEnd = a:range.colEnd - 1
        endif

        if l:extractStart < l:extractEnd
            let l:extract = l:lineText[l:extractStart : l:extractEnd - 1]
            let l:extract = substitute(l:extract, "^\\s\\+", "", "g")
            let l:extract = substitute(l:extract, ",$", ", ", "g")
            let l:text .= l:extract
        endif
    endfor

    return l:text
endfunction

function! UpdateScopeStack(stack, char)
    let l:pairs  = {"\"": "\"", "\'": "\'", ")": "(", "]": "[", "}": "{"}
    let l:length = len(a:stack)

    if l:length > 0 && get(l:pairs, a:char, "") == a:stack[l:length - 1]
        call remove(a:stack, l:length - 1)
    elseif index(values(l:pairs), a:char) >= 0
        call add(a:stack, a:char)
    endif
endfunction

function! TrimArgument(text)
    let l:stripped = substitute(a:text, "\\s\\+", "", "")
    let l:stripped = substitute(l:stripped, "^\\s\\+", "", "")
    return l:stripped
endfunction

function! ExtractArguments(text)
    let l:stack     = []
    let l:arguments = []
    let l:argument  = ""

    for l:index in range(strlen(a:text))
        let l:char = a:text[l:index]
        call UpdateScopeStack(l:stack, l:char)

        if len(l:stack) == 0 && l:char == ","
            call add(l:arguments, TrimArgument(l:argument))
            let l:argument = ""
        else
            let l:argument .= l:char
        endif
    endfor

    call add(l:arguments, TrimArgument(l:argument))
    return l:arguments
endfunction

function! ExtractContainer(range)
    let l:prefix = getline(a:range.lineStart)[: a:range.colStart - 1]
    let l:suffix = getline(a:range.lineEnd)[a:range.colEnd - 1:]
    return {"prefix": l:prefix, "suffix": l:suffix}
endfunction

function! WrapContainer(range, container, arguments)
    let l:line = a:range.lineStart
    call setline(l:line, a:container.prefix)
    for l:argument in a:arguments
        call append(l:line, l:argument)
        let l:line += 1
        exec printf("%s>", l:line)
    endfor
    call append(l:line, a:container.suffix)
endfunction

function! UnwrapContainer(range, container, arguments)
    let l:text = a:container.prefix . join(a:arguments, ", ") . a:container.suffix
    call setline(a:range.lineStart, l:text)
    exec printf("%d,%dd", a:range.lineStart + 1, a:range.lineEnd)
endfunction

function! Unwrap()
    let l:range     = FindRange()
    let l:argText   = ExtractArgumentText(l:range)
    let l:arguments = ExtractArguments(l:argText)
    let l:container = ExtractContainer(l:range)

    call UnwrapContainer(l:range, l:container, l:arguments)
endfunction

function! Wrap()
    let l:range     = FindRange()
    let l:argText   = ExtractArgumentText(l:range)
    let l:arguments = ExtractArguments(l:argText)
    let l:container = ExtractContainer(l:range)

    call WrapContainer(l:range, l:container, l:arguments)
endfunction
