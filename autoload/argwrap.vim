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


function! argwrap#validateRange(range)
    return len(a:range) > 0 && !(a:range.lineStart == 0 && a:range.colStart == 0 || a:range.lineEnd == 0 && a:range.colEnd == 0)
endfunction

function! argwrap#compareRanges(range1, range2)
    let [l:buffer, l:line, l:col, l:offset] = getpos('.')

    let l:lineDiff1 = a:range1.lineStart - l:line
    let l:colDiff1 = a:range1.colStart - l:col
    let l:lineDiff2 = a:range2.lineStart - l:line
    let l:colDiff2 = a:range2.colStart - l:col

    if l:lineDiff1 < l:lineDiff2
        return 1
    elseif l:lineDiff1 > l:lineDiff2
        return -1
    elseif l:colDiff1 < l:colDiff2
        return 1
    elseif l:colDiff1 > l:colDiff2
        return -1
    else
        return 0
    endif
endfunction

function! argwrap#findRange(braces)
    let l:filter = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'
    let [l:lineStart, l:colStart] = searchpairpos(a:braces[0], '', a:braces[1], 'Wnb', filter)
    let [l:lineEnd, l:colEnd] = searchpairpos(a:braces[0], '', a:braces[1], 'Wcn', filter)
    return {'lineStart': l:lineStart, 'colStart': l:colStart, 'lineEnd': l:lineEnd, 'colEnd': l:colEnd}
endfunction

function! argwrap#findClosestRange()
    let l:ranges = []
    for l:braces in [['(', ')'], ['\[', '\]'], ['{', '}']]
        let l:range = argwrap#findRange(braces)
        if argwrap#validateRange(l:range)
            call add(l:ranges, l:range)
        endif
    endfor

    if len(l:ranges) == 0
        return {}
    else
        return sort(l:ranges, 'argwrap#compareRanges')[0]
    endif
endfunction

function! argwrap#extractContainerArgText(range, linePrefix)
    let l:text = ''

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
            let l:extract = substitute(l:extract, '^\s*\(.\{-}\)\s*$', '\1', '')
            if stridx(l:extract, a:linePrefix) == 0
                let l:extract = l:extract[len(a:linePrefix):]
            endif
            let l:extract = substitute(l:extract, ',$', ', ', '')
            let l:text .= l:extract
        endif
    endfor

    return l:text
endfunction

function! argwrap#updateScope(stack, char)
    let l:pairs = {'"': '"', '''': '''', ')': '(', ']': '[', '}': '{'}
    let l:length = len(a:stack)

    if l:length > 0 && get(l:pairs, a:char, '') == a:stack[l:length - 1]
        call remove(a:stack, l:length - 1)
    elseif index(values(l:pairs), a:char) >= 0
        call add(a:stack, a:char)
    endif
endfunction

function! argwrap#trimArgument(text)
    let l:trim = substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
    let l:trim = substitute(l:trim, '\([:=]\)\s\{2,}', '\1 ', '')
    return substitute(l:trim, '\s\{2,}\([:=]\)', ' \1', '')
endfunction

function! argwrap#extractContainerArgs(text)
    let l:text = substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')

    let l:stack = []
    let l:arguments = []
    let l:argument = ''

    if len(l:text) > 0
        for l:index in range(strlen(l:text))
            let l:char = l:text[l:index]
            call argwrap#updateScope(l:stack, l:char)

            if len(l:stack) == 0 && l:char == ','
                let l:argument = argwrap#trimArgument(l:argument)
                if len(l:argument) > 0
                    call add(l:arguments, l:argument)
                endif
                let l:argument = ''
            else
                let l:argument .= l:char
            endif
        endfor

        let l:argument = argwrap#trimArgument(l:argument)
        if len(l:argument) > 0
            call add(l:arguments, l:argument)
        endif
    endif

    return l:arguments
endfunction

function! argwrap#extractContainer(range)
    let l:textStart = getline(a:range.lineStart)
    let l:textEnd = getline(a:range.lineEnd)

    let l:indent = matchstr(l:textStart, '\s*')
    let l:prefix = l:textStart[strlen(l:indent) : a:range.colStart - 1]
    let l:suffix = l:textEnd[a:range.colEnd - 1:]

    return {'indent': l:indent, 'prefix': l:prefix, 'suffix': l:suffix}
endfunction

function! argwrap#wrapContainer(range, container, arguments, wrapBrace, tailComma, tailCommaBraces, tailIndentBraces, linePrefix, commaFirst, commaFirstIndent)
    let l:argCount = len(a:arguments)
    let l:line = a:range.lineStart
    let l:prefix = a:container.prefix[len(a:container.prefix) - 1]

    call setline(l:line, a:container.indent . a:container.prefix)

    for l:index in range(l:argCount)
        let l:last = l:index == l:argCount - 1
        let l:first = l:index == 0
        let l:text = ''

        if a:commaFirst
            let l:text .= a:container.indent . a:linePrefix
            if !l:first
                let l:text .= ', '
            end
            let l:text .= a:arguments[l:index]
        else
            let l:text .= a:container.indent . a:linePrefix . a:arguments[l:index]
            if  !l:last || a:tailComma || a:tailCommaBraces =~ l:prefix
                let l:text .= ','
            end
        end

        if l:last && !a:wrapBrace
            let l:text .= a:container.suffix
        end

        call append(l:line, l:text)
        let l:line += 1
        silent! exec printf('%s>', l:line)

        if l:first && a:commaFirstIndent
            let width = &l:shiftwidth
            let &l:shiftwidth = 2
            silent! exec printf('%s>', l:line)
            let &l:shiftwidth = l:width
        end
    endfor

    if a:wrapBrace
        call append(l:line, a:container.indent . a:linePrefix . a:container.suffix)
        if a:tailIndentBraces =~ l:prefix
            silent! exec printf('%s>', l:line + 1)
        end
    endif
endfunction

function! argwrap#unwrapContainer(range, container, arguments, padded)
    let l:brace = a:container.prefix[strlen(a:container.prefix) - 1]
    if stridx(a:padded, l:brace) == -1
        let l:padding = ''
    else
        let l:padding = ' '
    endif

    let l:text = a:container.indent . a:container.prefix . l:padding . join(a:arguments, ', ') . l:padding . a:container.suffix
    call setline(a:range.lineStart, l:text)
    exec printf('silent %d,%dd_', a:range.lineStart + 1, a:range.lineEnd)
endfunction

function! argwrap#getSetting(name, default)
    let l:bName = 'b:argwrap_' . a:name
    let l:gName = 'g:argwrap_' . a:name

    if exists(l:bName)
        return {l:bName}
    elseif exists(l:gName)
        return {l:gName}
    else
        return a:default
    endif
endfunction

function! argwrap#toggle()
    let l:cursor = getpos('.')

    let l:linePrefix = argwrap#getSetting('line_prefix', '')
    let l:padded = argwrap#getSetting('padded_braces', '')
    let l:tailComma = argwrap#getSetting('tail_comma', 0)
    let l:tailCommaBraces = argwrap#getSetting('tail_comma_braces', '')
    let l:tailIndentBraces = argwrap#getSetting('tail_indent_braces', '')
    let l:wrapBrace = argwrap#getSetting('wrap_closing_brace', 1)
    let l:commaFirst = argwrap#getSetting('comma_first', 0)
    let l:commaFirstIndent = argwrap#getSetting('comma_first_indent', 0)

    let l:range = argwrap#findClosestRange()
    if !argwrap#validateRange(l:range)
        return
    endif

    let l:argText = argwrap#extractContainerArgText(l:range, l:linePrefix)
    let l:arguments = argwrap#extractContainerArgs(l:argText)
    if len(l:arguments) == 0
        return
    endif

    let l:container = argwrap#extractContainer(l:range)
    if l:range.lineStart == l:range.lineEnd
        call argwrap#wrapContainer(l:range, l:container, l:arguments, l:wrapBrace, l:tailComma, l:tailCommaBraces, l:tailIndentBraces, l:linePrefix, l:commaFirst, l:commaFirstIndent)
        let l:cursor[1] = l:range.lineStart + 1
    else
        call argwrap#unwrapContainer(l:range, l:container, l:arguments, l:padded)
        let l:cursor[1] = l:range.lineStart
    endif

    call setpos('.', l:cursor)
endfunction
