# ArgWrap #

ArgWrap is an industrial strength argument wrapping and unwrapping extension for the [Vim](http://www.vim.org/) text
editor. It can be used for collapsing and expanding everything from function calls to array and dictionary definitions.
All operations are easily reversible and correctly preserve the indentation of the surrounding code.

![](http://foosoft.net/projects/argwrap/img/demo.gif)

## Installation ##

1.  Clone or otherwise download ArgWrap extension from the [GitHub](https://github.com/FooSoft/vim-argwrap) page.

    If you are using [pathogen.vim](https://github.com/tpope/vim-pathogen) for plugin management you can clone the
    repository directly to your bundle directory:

    ```
    $ git clone https://github.com/FooSoft/vim-argwrap ~/.vim/bundle/vim-argwrap
    ```

2.  Create a keyboard binding for the `ArgWrap` command inside your `~/.vimrc` file.

    For example, to declare a normal mode mapping, add the following command:

    ```
    nnoremap <silent> <leader>a :ArgWrap<CR>
    ```

## Usage ##

1.  Position the cursor *inside* of the scope of the parenthesis, brackets or curly braces you wish to wrap/unwrap (not
    on top, before or after them).

2.  Execute the keyboard binding you defined above to *toggle* the wrapping and unwrapping of arguments.

## Configuration ##

You can customize the behavior of this extension by setting values for any of the following optional buffer and global
variables in your `.vimrc` file:

*   `g:argwrap_wrap_closing_brace` or `b:argwrap_wrap_closing_brace`

    *Specifies if the closing brace should be wrapped to a new line.*

    Brace wrapping enabled (default)

    ```
    Foo(
        wibble,
        wobble,
        wubble
    )
    ```

    Brace wrapping disabled (`let g:argwrap_wrap_closing_brace = 0`)

    ```
    Foo(
        wibble,
        wobble,
        wubble)
    ```

*   `g:argwrap_padded_braces` or `b:argwrap_wrap_closing_brace`

    *Specifies which brace types should be padded on the inside with spaces.*

    `''`: do not add padding for any braces (empty string):

    ```
    [1, 2, 3]
    {1, 2, 3}
    ```

    `'['`: padding for square braces only (curly braces are not padded):

    ```
    [ 1, 2, 3 ]
    {1, 2, 3}
    ```

    Padding can be specified for multiple brace types as follows:

    ```
    let g:argwrap_padded_braces = '[{'
    ```
