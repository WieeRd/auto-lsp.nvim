# Auto-LSP.nvim

Automatically detect and setup language servers available on your system.

1. Have this plugin installed and setup.
2. Have language servers installed.
3. The servers will automatically attach to Neovim.

This works for nearly every server listed in [nvim-lspconfig].

[nvim-lspconfig]: https://github.com/neovim/nvim-lspconfig

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "WieeRd/auto-lsp.nvim",
  event = "VeryLazy",
  opts = {},
},
```

> [!NOTE]
> The dependency and build instructions are specified in [`lazy.lua`](lazy.lua).\
> They will be applied by `lazy.nvim` so that you don't have to.

## Configuration

If you read this, send a death threat to the author to get him working on the docs.
