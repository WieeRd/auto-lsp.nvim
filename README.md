# Auto-LSP.nvim

Automatically detect and setup language servers available on your system.

1. Have `auto-lsp.nvim` installed and setup.
2. Have language servers installed, using *any* method you prefer.
3. `lspconfig[server].setup()` is called automatically for each server.

As simple as that! Enjoy the fully automated integration with language servers.

## How It Works

Docs WIP.

## Limitations

Docs WIP.

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

`setup()` optionally takes a key-value table of server name and server config.

Each config value can either:

- A server configuration table, passed to each server's `:h lspconfig-setup`.
- A function that returns such table.
- A boolean value, force-enabling or disabling the server.

```lua
require("auto-lsp").setup({
  -- '*' is a special key defining the "global config" applied to every server.
  -- Each per-server config will be merged with this table using `vim.tbl_deep_extend()`.
  -- One use case of this key would be applying extended capabilities from nvim-cmp.
  ["*"] = function()
    return {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    }
  end,

  -- Override the default settings of LuaLS.
  -- Passed to `lspconfig["lua_ls"].setup(config)` as the config.
  -- https://luals.github.io/wiki/configuration/#neovim
  -- https://luals.github.io/wiki/settings/
  ["lua_ls"] = {
    settings = {
      Lua = {
        completion = { showWord = "Disable" },
        hint = {
          enable = true,
          setType = true,
          arrayIndex = "Disable",
        },
      },
    },
  },

  -- Skip the availability check and always setup Pyright.
  -- See `# Limitations` for the reasons why you might need to do this.
  ["pyright"] = true,

  -- Do not setup Rust Analyzer even if the executable is found in the $PATH.
  -- Useful if using `rustaceanvim` and don't want to setup RA via lspconfig.
  ["rust_analyzer"] = false,

  -- Servers not specified in this table will be automatically setup
  -- with default configurations if their executable is available.
})
```

## Commands

You can inspect and control some of the internals of the plugin using `:AutoLsp`.

### `:AutoLsp info`

See the list of checked filetypes and servers.

### `:AutoLsp mappings`

Open the generated server mappings file in a new window.

### `:AutoLsp build`

Clear the cache and regenerate the server mappings.

### `:AutoLsp refresh`

Each server is checked only once per session for its availability.
This command will recheck to detect new servers installed after Neovim was launched.
`FocusGained` and `TermLeave` event will automatically trigger a refresh,
so you don't normally need to run this manually.
