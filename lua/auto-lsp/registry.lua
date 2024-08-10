return {
  generic_servers = {
    "contextive",
  },
  filetype_servers = {
    ["elixir"] = { "elixirls" },
    ["gd"] = { "gdscript" },
    ["rust"] = { "rust_analyzer" },
  },
  server_executable = {
    ["contextive"] = "Contextive.LanguageServer",
    ["elixirls"] = false, -- no `cmd` given: explicit user config required
    ["gdscript"] = true, -- no easy way to check availability: always setup
    ["rust_analyzer"] = "rust-analyzer",
  },
}
