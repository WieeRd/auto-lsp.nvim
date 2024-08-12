return {
  generic_servers = {
    "contextive",
  },
  filetype_servers = {
    ["elixir"] = { "elixirls" },
    ["gdscript"] = { "gdscript" },
    ["python"] = { "pyright" },
    ["rust"] = { "rust_analyzer" },
  },
  server_executable = {
    ["contextive"] = "Contextive.LanguageServer",
    ["elixirls"] = false, -- no `cmd` given: explicit user config required
    ["gdscript"] = true, -- no easy way to check availability: always setup
    ["pyright"] = "pyright-langserver",
    ["rust_analyzer"] = "rust-analyzer",
  },
}
