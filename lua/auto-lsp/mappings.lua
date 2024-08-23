local vim = vim
local _ = require("lspconfig") -- make sure nvim-lspconfig is loaded

local M = {
  generic_servers = {},
  filetype_servers = {},
  server_executable = {},
}

-- Filter out language / package manager executables e.g. java -jar <server.jar>
-- Languages with builtin language server as a subcommand should be excluded.
local ignored_executables = {
  R = true,
  dotnet = true,
  java = true,
  julia = true,
  nc = true,
  node = true,
  npx = true,
  perl = true,
  python = true,
  python3 = true,
  racket = true,
}

local server_configs = vim.api.nvim_get_runtime_file(
  "lua/lspconfig/server_configurations/*.lua",
  true
)

for _, file in ipairs(server_configs) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  local config = dofile(file).default_config

  if config.filetypes then
    for _, ft in ipairs(config.filetypes) do
      M.filetype_servers[ft] = M.filetype_servers[ft] or {}
      table.insert(M.filetype_servers[ft], name)
    end
  else
    table.insert(M.generic_servers, name)
  end

  if type(config.cmd) == "table" then
    local exec = config.cmd[1]
    if not ignored_executables[exec] then
      M.server_executable[name] = exec
    end
  end
end

return M
