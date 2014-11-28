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
    let [l:lineEnd, l:colEnd] = searchpairpos("(", "", ")", "Wn")

    if l:lineStart == l:lineEnd && l:colStart == l:colEnd
        return []
    endif

    return [l:lineStart, l:colStart, l:lineEnd, l:colEnd]
endfunction

function! ExtractText(range)
    let [l:lineStart, l:colStart, l:lineEnd, l:colEnd] = a:range
    let l:text = ""

    for l:lineIndex in range(l:lineStart, l:lineEnd)
        let l:lineText = getline(l:lineIndex)

        let l:extractStart = 0
        if l:lineIndex == l:lineStart
            let l:extractStart = l:colStart
        endif

        let l:extractEnd = strlen(l:lineText)
        if l:lineIndex == l:lineEnd
            let l:extractEnd = l:colEnd - 1
        endif

        if l:extractStart < l:extractEnd
            let l:text .= l:lineText[l:extractStart : l:extractEnd - 1]
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

function! ExtractArguments(text)
    let l:stack     = []
    let l:arguments = []
    let l:argument  = ""

    for l:index in range(strlen(a:text))
        let l:char = a:text[l:index]
        call UpdateScopeStack(l:stack, l:char)

        if len(l:stack) == 0 && l:char == ","
            call add(l:arguments, l:argument)
            let l:argument = ""
        else
            let l:argument .= l:char
        endif
    endfor

    call add(l:arguments, l:argument)
    return l:arguments
endfunction

function! Wrap()
    let l:range = FindRange()
    if len(l:range) == 0
        return
    endif

    let l:text = ExtractText(l:range)
    let l:args = ExtractArguments(l:text)
    echo l:args
endfunction

