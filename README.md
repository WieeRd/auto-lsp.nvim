# Auto-LSP.nvim

Automatically detect and setup language servers that are available on your system.

## About

WORK IN PROGRESS

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "neovim/nvim-lspconfig" },

{
  "WieeRd/auto-lsp.nvim",
  event = "VeryLazy",
  opts = {},
},
```

## Configuration

```lua
require("auto-lsp").setup({
  global_config = {},
  server_config = {},
  auto_refresh = true,
  skip_executable_check = false,
})
```

### `global_config`

### `server_config`

### `auto_refresh`

### `skip_executable_check`
