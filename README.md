## vim-argwrap ##

This is an industrial strength argument wrapping and unwrapping extension for the [Vim](http://www.vim.org/) text
editor. It can be used for collapsing and expanding everything from function calls to array and dictionary definitions.

### Installation and Usage ###

1.  Clone or otherwise download the *vim-argwrap* extension from the [GitHub](https://github.com/FooSoft/vim-argwrap).
    If you are using [pathogen](https://github.com/tpope/vim-pathogen) for plugin management (you should) you can clone
    the repository directly to your bundle directory:

    `git clone https://github.com/FooSoft/vim-argwrap ~/.vim/bundle/vim-argwrap`.

2.  Create a keyboard binding for `argwrap#toggle()` inside your `~/.vimrc` file. For example, to declare a normal
    mode mapping, add the following command:

    `nnoremap <silent> <leader>w :call argwrap#toggle()<CR>`.

3.  Position the cursor *inside* of the scope of the parenthesis, brackets or curly braces you wish to wrap/unwrap (not
    on top or before or after them).

4.  Execute the keyboard binding you defined above to *toggle* the wrapping and unwrapping of arguments.

### Examples ###

Below are some examples of common use cases demonstrating the capabilities of vim-argwrap. Note that the extension
functions identically regardless if it is being used on a function call, list or dictionary definitions.

Let's begin with a simple function invocation. When there are many arguments being passed to the function, we often wish
to wrap them to improve code readability. If you position your cursor anywhere between the `(` and `)` parenthesis and
execute the `argwrap#toggle()` command, the argument list will be wrapped to one per line.

```
Foo('wibble', 'wobble', 'wubble')

```

Becomes this:

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

Becomes this:

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

Becomes this:

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

Becomes this:


```
Foo(
    ['wibble', 'wobble', 'wubble'],
    'spam',
    {'bar': 'baz', 'qux': [1, 3, 3, 7]}
)

```

You can continue expanding to:


```

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

The argument wrapping and unwrapping operations demonstrated above are easily reversible and correctly preserve the
indentation of the surrounding code. This extension has been tested to work in scenarios of various complexity, but if
you discover a problem don't hesitate to report it.
