# ArgWrap #

ArgWrap is an industrial strength argument wrapping and unwrapping extension for the Vim text editor. It can be used for
collapsing and expanding everything from function calls to array and dictionary definitions.  All operations are easily
reversible and correctly preserve the indentation of the surrounding code.

![](https://foosoft.net/projects/vim-argwrap/img/demo.gif)

## Installation ##

1.  Clone or otherwise download ArgWrap extension. Users of [pathogen.vim](https://github.com/tpope/vim-pathogen) can
    clone the repository directly to their bundle directory:

    ```
    $ git clone https://github.com/FooSoft/vim-argwrap ~/.vim/bundle/vim-argwrap
    ```

2.  Create a keyboard binding for the `ArgWrap` command inside your `~/.vimrc` file.

    For example, to declare a normal mode mapping, add the following command:

    ```
    nnoremap <silent> <leader>a :ArgWrap<CR>
    ```

## Configuration ##

You can customize the behavior of this extension by setting values for any of the following optional *buffer* and
*global* configuration variables in your `.vimrc` file. Buffer variables (prefixed with `b:`) take precedence over
global variables (prefixed with `g:`), making them ideal for configuring the behavior of this extension on a file by
file basis using `ftplugin` or `autocmd`. For example, the `argwrap_tail_comma` variable has two variants declared as
`b:argwrap_tail_comma` and `g:argwrap_tail_comma`, for buffer and global scopes respectively.

*   **argwrap_line_prefix**

    Specifies a line prefix to be added and removed when working with languages that require newlines to be escaped.

    *Line prefix disabled (default)*

    ```
    Foo(
        wibble,
        wobble,
        wubble
    )
    ```

    *Line prefix enabled for Vimscript (`let g:argwrap_line_prefix = '\'`)*

    ```
    Foo(
        \wibble,
        \wobble,
        \wubble
    \)
    ```

*   **argwrap_padded_braces**

    Specifies which brace types should be padded on the inside with spaces.

    *Brace padding disabled (default)*

    ```
    [1, 2, 3]
    {1, 2, 3}
    ```

    *Brace padding enabled for square brackets only (`let g:argwrap_padded_braces = '['`)*

    ```
    [ 1, 2, 3 ]
    {1, 2, 3}
    ```

    *Padding can be specified for multiple brace types (`let g:argwrap_padded_braces = '[{'`)*

*   **argwrap_tail_comma**

    Specifies if the closing brace should be preceded with a comma when wrapping lines.

    *Tail comma disabled (default)*

    ```
    Foo(
        wibble,
        wobble,
        wubble
    )
    ```

    *Tail comma enabled (`let g:argwrap_tail_comma = 1`)*

    ```
    Foo(
        wibble,
        wobble,
        wubble,
    )
    ```

*   **argwrap_wrap_closing_brace**

    Specifies if the closing brace should be wrapped to a new line.

    *Brace wrapping enabled (default)*

    ```
    Foo(
        wibble,
        wobble,
        wubble
    )
    ```

    *Brace wrapping disabled (`let g:argwrap_wrap_closing_brace = 0`)*

    ```
    Foo(
        wibble,
        wobble,
        wubble)
    ```

## Usage ##

1.  Position the cursor *inside* of the scope of the parenthesis, brackets or curly braces you wish to wrap/unwrap (not
    on top, before or after them).
2.  Execute the keyboard binding you defined above to *toggle* the wrapping and unwrapping of arguments.

## License ##

MIT
