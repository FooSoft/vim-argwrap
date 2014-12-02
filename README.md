## vim-argwrap ##

This is an industrial strength argument wrapping and unwrapping extension for the [Vim](http://www.vim.org/) text
editor. It can be used for collapsing and expanding everything from function calls to array and dictionary definitions.

### Installation and Usage ###

1.  Clone or otherwise download the vim-argwrap extension from the [GitHub
    page](https://github.com/FooSoft/vim-argwrap). If you are using
    [vim-pathogen](https://github.com/tpope/vim-pathogen) for plugin management (if you aren't you should) you can
    clone the repository directly to your bundle directory:<br>`git clone
    https://github.com/FooSoft/vim-argwrap ~/.vim/bundle/vim-argwrap`.
1.  Create a keyboard binding for `argwrap#toggle()` inside your `~/.vimrc` file. For example, you may declare a normal
    mode hotkey:<br>`nnoremap <silent> <leader>w :call argwrap#toggle()<CR>`.
2.  Position cursor *inside* of the scope of the parenthesis or brackets you wish to wrap/unwrap (not on top or before
    or after them).
3.  Execute the keyboard binding defined above to *toggle* wrapping and unwrapping arguments.

### Examples ###

Below are examples of some common use cases demonstrating the capabilities of vim-argwrap. The extension functions the
same way regardless if it is being used on a function call, list or dictionary definitions.

Let's first look at a simple function invocation. When there are many arguments being passed in, we may wish to wrap
them to improve readability. If we position your cursor anywhere between the `(` and `)` parenthesis and execute the
`argwrap#toggle()` command, the function call arguments will be wrapped to one per line.

```
Foo('wibble', 'wobble', 'wubble')

```
```
Foo(
    'wibble',
    'wobble',
    'wubble'
)

```

List definitions work in a similar fashion:

```
foo = ['bar', 'baz', 'qux', 'quux', 'corge']
```
```
foo = [
    'bar',
    'baz',
    'qux',
    'quux',
    'corge'
]
```

Dictionaries work just fine too:

```
foo = {'bar': 1, 'baz': 3, 'qux': 3, 'quux': 7}
```
```
foo = {
    'bar': 1,
    'baz': 3,
    'qux': 3,
    'quux': 7
}
```

Finally, nested combinations of all the above are also supported:

```
Foo(['wibble', 'wobble', 'wubble'], 'spam', {'bar': 'baz', qux: [1, 3, 3, 7]})
```
```
Foo(
    ['wibble', 'wobble', 'wubble'],
    'spam',
    {'bar': 'baz', 'qux': [1, 3, 3, 7]}
)

Foo(
    [
        'wibble',
        'wobble',
        'wubble'
    ],
    'spam',
    {
        'bar': 'baz',
        'qux': [
            1,
            3,
            3,
            7
        ]
    }
)

```

All of the above argument wrapping and unwrapping operations demonstrated above are toggle-able and correctly preserve
the indentation of the surrounding code. This extension has been tested to work in scenarios of various complexity, but
if you discover a problem let me know.
