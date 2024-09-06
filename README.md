# Auto-LSP.nvim

Automatically detect and setup language servers available on your system.

1. Have this plugin installed and setup.
2. Have language servers installed.
3. The servers will automatically attach to Neovim.

This works for nearly every server listed in [nvim-lspconfig].

[nvim-lspconfig]: https://github.com/neovim/nvim-lspconfig

## Installation

### [lazy.nvim]

```lua
{ "neovim/nvim-lspconfig", lazy = true },

{
  "WieeRd/auto-lsp.nvim",
  event = "VeryLazy",
  opts = {},
},
```

[lazy.nvim]: https://github.com/folke/lazy.nvim

### [vim-plug]

```vim
Plug 'neovim/nvim-lspconfig', { 'do': ':let g:auto_lsp_update = 1' }
Plug 'WieeRd/auto-lsp.nvim', { 'do': ':let g:auto_lsp_update = 1' }
```

```vim
lua require("auto-lsp").setup()
```

[vim-plug]: https://github.com/junegunn/vim-plug

## Building

The server mappings need to be regenerated whenever [nvim-lspconfig] is updated.

- You can automate this using the post-install hook of your plugin manager.
- Simply set `g:auto_lsp_update` to `1` upon each update, before the plugin loads.

See [#Installation/vim-plug](#vim-plug) for an example.

> [!NOTE]
> If you use [lazy.nvim], the `build` keys in [`lazy.lua`](lazy.lua) will be
> applied automatically. No need to specify them manually.

## Configuration

If you read this, send a death threat to the author to get him working on the docs.
