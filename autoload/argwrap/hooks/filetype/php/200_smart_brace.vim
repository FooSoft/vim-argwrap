function! s:dealWithMethodArguments(container) abort " {{{
  if a:container.suffix !~ '\v^\)'
    return 0
  endif

  if a:container.prefix !~? '\v^%(public|protected|private)(\s+static)?\s+function\s+\S+\s*\($'
    return 0
  endif

  return 1
endfunction " }}}

function! s:fixMethodOpeningBraceAfterWrap(range, container, arguments) abort " {{{
  if !s:dealWithMethodArguments(a:container)
    return
  endif

  let l:lineEnd = a:range.lineEnd + len(a:arguments)

  " Add 1 more line if the brace is also wrapped
  if 0 != argwrap#getSetting('wrap_closing_brace')
    let l:lineEnd += 1
  endif

  if getline(l:lineEnd + 1) =~ '\v^\s*\{'
    execute printf('undojoin | normal! %dGJ', l:lineEnd)
  endif
endfunction " }}}

function! s:fixMethodOpeningBraceAfterUnwrap(range, container, arguments) abort " {{{
  if !s:dealWithMethodArguments(a:container)
    return
  endif

  if a:container.suffix !~ '\v^\).*\{\s*$'
    return
  endif

  execute printf("undojoin | normal! %dG$F{gelct{\<CR>", a:range.lineStart)
endfunction " }}}

function! argwrap#hooks#filetype#php#200_smart_brace#pre_wrap(range, container, arguments) abort " {{{
  " Do nothing but prevent the file to be loaded more than once
  " When calling an autoload function that is not define, the script that
  " should contain it is sourced every time the function is called
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_smart_brace#pre_unwrap(range, container, arguments) abort " {{{
  " Do nothing but prevent the file to be loaded more than once
  " When calling an autoload function that is not define, the script that
  " should contain it is sourced every time the function is called
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_smart_brace#post_wrap(range, container, arguments) abort " {{{
  if argwrap#getSetting('php_smart_brace')
    call s:fixMethodOpeningBraceAfterWrap(a:range, a:container, a:arguments)
  endif
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_smart_brace#post_unwrap(range, container, arguments) abort " {{{
  if argwrap#getSetting('php_smart_brace')
    call s:fixMethodOpeningBraceAfterUnwrap(a:range, a:container, a:arguments)
  endif
endfunction  " }}}

" vim: ts=2 sw=2 et fdm=marker
