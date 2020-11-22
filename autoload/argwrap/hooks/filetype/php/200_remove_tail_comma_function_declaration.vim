function! s:dealWithFunctionDeclaration(container) abort " {{{
  if a:container.suffix !~ '\v^\)'
    return 0
  endif

  " Take anonymous and arrow functions into account
  if a:container.prefix !~? '\v(function|fn)\s*\S*\s*\($'
    return 0
  endif

  return 1
endfunction " }}}

function! argwrap#hooks#filetype#php#200_remove_tail_comma_function_declaration#pre_wrap(range, container, arguments) abort " {{{
  " Do nothing but prevent the file to be loaded more than once
  " When calling an autoload function that is not define the script that
  " should contain it is sourced every time the function is called
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_remove_tail_comma_function_declaration#pre_unwrap(range, container, arguments) abort " {{{
  " Do nothing but prevent the file to be loaded more than once
  " When calling an autoload function that is not define the script that
  " should contain it is sourced every time the function is called
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_remove_tail_comma_function_declaration#post_wrap(range, container, arguments) abort " {{{
  " Don't do anything if the user want a tail comma for function declaration
  if 0 == argwrap#getSetting('php_remove_tail_comma_function_declaration')
    return
  endif

  let l:tailComma = argwrap#getSetting('tail_comma')
  let l:tailCommaForFunctionDeclaration = argwrap#getSetting('tail_comma_braces') =~ '('

  " Don't do anything if the tail comma feature is disabled
  if !l:tailComma && !l:tailCommaForFunctionDeclaration
    return
  endif

  " Don't do anything if it's not a function declaration
  if !s:dealWithFunctionDeclaration(a:container)
    return
  endif

  let l:lineEnd = a:range.lineEnd + len(a:arguments)

  if getline(l:lineEnd) =~ '\v,\s*$'
    call setline(l:lineEnd, substitute(getline(l:lineEnd), '\s*,\s*$', '', ''))
  endif
endfunction  " }}}

function! argwrap#hooks#filetype#php#200_remove_tail_comma_function_declaration#post_unwrap(range, container, arguments) abort " {{{
  " Do nothing but prevent the file to be loaded more than once
  " When calling an autoload function that is not define the script that
  " should contain it is sourced every time the function is called
endfunction  " }}}

" vim: ts=2 sw=2 et fdm=marker
