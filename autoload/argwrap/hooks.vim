function! s:loadGlobalHooks() abort " {{{
  if !exists('g:argwrap_global_hooks')
    let g:argwrap_global_hooks = []

    for hook in globpath(&runtimepath, 'autoload/argwrap/hooks/*.vim', 0, 1)
      let l:filename = matchstr(hook, '\vhooks/\zs.+\ze\.vim$')

      call add(g:argwrap_global_hooks, printf('argwrap#hooks#%s', l:filename))
    endfor
  endif

  return g:argwrap_global_hooks
endfunction " }}}

function! s:loadFiletypeHooks(filetype) abort " {{{
  if !exists('g:argwrap_filetype_hooks.'.a:filetype)
    let g:argwrap_filetype_hooks[a:filetype] = []
    let l:hooks = g:argwrap_filetype_hooks[a:filetype]

    for filetypeHook in globpath(&runtimepath, 'autoload/argwrap/hooks/filetype/*/*.vim', 0, 1)
      let l:filetype = matchstr(filetypeHook, '\vhooks/filetype/\zs.+\ze/.+\.vim$')
      let l:filename = matchstr(filetypeHook, '\vhooks/filetype/.+/\zs.+\ze\.vim$')

      call add(l:hooks, printf('argwrap#hooks#filetype#%s#%s', l:filetype, l:filename))
    endfor
  endif

  return g:argwrap_filetype_hooks[a:filetype]
endfunction " }}}

function! s:load() abort " {{{
  if !exists('b:argwrap_hooks')
    let b:argwrap_hooks = s:loadGlobalHooks() + s:loadFiletypeHooks(&filetype)
  endif

  return b:argwrap_hooks
endfunction " }}}

function! argwrap#hooks#execute(name, ...) abort " {{{
  " Reverse the order of the hooks for post hooks so that a pre hook with a
  " low priority is executed before and a post hook is executed after
  " For instance for a hook responsible to preserve the cursor position it
  " must be the first to be executed to save the position of the cursor but
  " the last to be executed to restore it after all other hooks have been
  " executed
  let l:hooks = a:name =~? '\v^post' ? reverse(copy(s:load())) : s:load()

  for hook in l:hooks
    silent! call call(printf('%s#%s', hook, a:name), a:000)
  endfor
endfunction " }}}

" vim: ts=2 sw=2 et fdm=marker
