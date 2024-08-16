-- This is a minimal version of `mappings.lua` to demonstrate its schema and purpose.

return {
  -- List of servers without any associated filetypes.
  -- Typically tools that can work with any text files.
  generic_servers = {
    "contextive",
  },

  -- Mapping of filetype to list of servers that are associated with it.
  filetype_servers = {
    ["elixir"] = { "elixirls" },
    ["gdscript"] = { "gdscript" },
    ["rust"] = { "rust_analyzer" },
  },

  -- How to check the availability of the server.
  -- * string: if vim.fn.executable(exec) == 1
  -- * true: skip the check and always start
  -- * false: requires user configuration to start
  server_executable = {
    ["contextive"] = "Contextive.LanguageServer",

    -- nvim-lspconfig does not provide `cmd` for elixirls.
    -- user configuration is required to figure out how to start the server.
    ["elixirls"] = false,

    -- gdscript is started via RPC function rather than a command string.
    -- it's hard to check if it's available without actually starting it,
    -- so always setup by default and leave it up to lspconfig.
    ["gdscript"] = true,

    -- automatically setup if rust-analyzer is installed, disabled if not.
    ["rust_analyzer"] = "rust-analyzer",
  },
}
