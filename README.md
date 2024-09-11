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
{
  "WieeRd/auto-lsp.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  event = "VeryLazy",
  opts = {},
},
```

[lazy.nvim]: https://github.com/folke/lazy.nvim

### [vim-plug]

```vim
Plug 'neovim/nvim-lspconfig'
Plug 'WieeRd/auto-lsp.nvim'
```

```vim
lua require("auto-lsp").setup()
```

[vim-plug]: https://github.com/junegunn/vim-plug

## Configuration

If you read this, send a death threat to the author to get him working on the docs.

## Commands

You can inspect and control some of the internals of the plugin using `:AutoLsp`.

### `:AutoLsp info`

See the list of checked filetypes and servers.

### `:AutoLsp mappings`

Open the generated server mappings file in a new window.

### `:AutoLsp build`

Clear the cache and regenerate the server mappings.

### `:AutoLsp refresh`

Each server is checked only once for its availability.
This command will recheck unavailable servers to detect newly installed ones.
`FocusGained` and `TermLeave` event will automatically trigger a refresh,
so you don't normally need to run this manually.
