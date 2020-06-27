function! s:extractCursorPositionForUnwrappedArguments(range, arguments) abort " {{{
  let l:cursorColumn = col('.')
  let l:lineText = getline(a:range.lineStart)
  let l:position = {}

  let l:argumentNumber = 0
  for argument in a:arguments
    let l:argumentNumber += 1
    let l:argumentStart = stridx(l:lineText, argument)
    let l:argumentEnd = l:argumentStart + len(argument)

    if l:cursorColumn <= l:argumentStart
      let l:cursorColumn = l:argumentStart + 1
    endif

    if l:argumentEnd < l:cursorColumn
      if l:lineText[l:cursorColumn - 1:] =~ '\v^,' " Cursor on the separator
        if !argwrap#getSetting('comma_first')
          let l:cursorColumn = l:argumentEnd + 1
        else
          let l:position.argumentNumber = l:argumentNumber + 1
          let l:position.column = -1

          break
        endif
      elseif l:lineText[l:cursorColumn - 1:] =~ '\v^\s+,' " Cursor before the separator
        let l:cursorColumn = l:argumentEnd
      endif
    endif

    if l:cursorColumn <= l:argumentEnd + 1
      let l:position.argumentNumber = l:argumentNumber
      let l:position.column = l:cursorColumn - l:argumentStart

      break
    end
  endfor

  " If the position was not found it's because the cursor is after the last
  " argument
  if empty(l:position)
  let l:position.argumentNumber = l:argumentNumber
    let l:position.column = l:argumentEnd - l:argumentStart
  endif

  return l:position
endfunction " }}}

function! s:extractCursorPositionForWrappedArguments(range, arguments) abort " {{{
  let l:position = {}
  let l:isCommaFirst = argwrap#getSetting('comma_first')
  let l:cursorColumn = col('.')
  let l:cursorArgumentNumber = line('.') - a:range.lineStart
  " In case the cursor is on the start line
  let l:cursorArgumentNumber = min([len(a:arguments), l:cursorArgumentNumber])
  " In case the cursor is on the end line
  let l:cursorArgumentNumber = max([1, l:cursorArgumentNumber])
  let l:argumentLine = getline('.')
  let l:argumentText = a:arguments[l:cursorArgumentNumber - 1]
  let l:argumentStart = stridx(l:argumentLine, l:argumentText)
  let l:argumentEnd = l:argumentStart + len(l:argumentText)
  let l:position.argumentNumber = l:cursorArgumentNumber
  let l:position.column = l:cursorColumn - l:argumentStart

  if l:cursorColumn <= l:argumentStart
    let l:position.column = 1

    if l:isCommaFirst
      if l:argumentLine[l:cursorColumn - 1:] =~ '\v^,' " Cursor on the separator
        " The cursor should be placed on the separtor
        let l:position.argumentNumber -= 1
        let l:position.column = len(a:arguments[l:position.argumentNumber - 1]) + 1
      elseif l:argumentLine[l:cursorColumn - 1:] =~ '\v^\s+,' " Cursor before the separator
        " The cursor should be placed on the end of the previous argument
        let l:position.argumentNumber -= 1
        let l:position.column = len(a:arguments[l:position.argumentNumber - 1])
      endif
    endif
  endif

  if l:argumentEnd < l:cursorColumn
    let l:position.column = len(l:argumentText)

    if !l:isCommaFirst
      if l:argumentLine[l:cursorColumn - 1:] =~ '\v^\s+,' " Cursor before the separator
        " The cursor should be placed on the end of the current argument
      elseif l:argumentLine[l:cursorColumn - 1:] =~ '\v^,' " Cursor on the separator
        " The cursor should be placed on the separator
        let l:position.column += 1
      endif
    endif
  endif

  return l:position
endfunction " }}}

function! s:getCursorPositionForWrappedArguments(range, container, arguments) abort " {{{
  let l:line = a:range.lineStart + a:container.cursor.argumentNumber
  let l:argumentStart = stridx(getline(l:line), a:arguments[a:container.cursor.argumentNumber - 1])
  let l:column = l:argumentStart + a:container.cursor.column

  return {'line': l:line, 'column': l:column}
endfunction " }}}

function! s:getCursorPositionForUnwrappedArguments(range, container, arguments) abort " {{{
  let l:line = a:range.lineStart
  let l:column = a:range.colStart

  " For each arguments before the one where the cursor must be positioned
  for index in range(a:container.cursor.argumentNumber - 1)
    " Add the length of the argument + 2 for the separator ', '
    let l:column += len(a:arguments[index]) + 2
  endfor

  let l:column += a:container.cursor.column

  return {'line': l:line, 'column': l:column}
endfunction " }}}

function! s:setCursorPosition(position) abort " {{{
  let l:curpos = getcurpos()
  let l:curpos[1] = a:position.line
  let l:curpos[2] = a:position.column

  call setpos('.', l:curpos)
endfunction  " }}}

function! argwrap#hooks#000_curpos#pre_wrap(range, container, arguments) abort " {{{
  let a:container.cursor = s:extractCursorPositionForUnwrappedArguments(a:range, a:arguments)
endfunction  " }}}

function! argwrap#hooks#000_curpos#pre_unwrap(range, container, arguments) abort " {{{
  let a:container.cursor = s:extractCursorPositionForWrappedArguments(a:range, a:arguments)
endfunction  " }}}

function! argwrap#hooks#000_curpos#post_wrap(range, container, arguments) abort " {{{
  let l:position = s:getCursorPositionForWrappedArguments(a:range, a:container, a:arguments)

  call s:setCursorPosition(l:position)
endfunction  " }}}

function! argwrap#hooks#000_curpos#post_unwrap(range, container, arguments) abort " {{{
  let l:position = s:getCursorPositionForUnwrappedArguments(a:range, a:container, a:arguments)

  call s:setCursorPosition(l:position)
endfunction  " }}}

" vim: ts=2 sw=2 et fdm=marker
