local vim = vim
local _ = require("lspconfig") -- make sure nvim-lspconfig is loaded

local M = {
  generic_servers = {},
  filetype_servers = {},
  server_executable = {},
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

  if config.cmd then
    if type(config.cmd) == "table" then
      M.server_executable[name] = config.cmd[1]
    else
      M.server_executable[name] = true
    end
  else
    M.server_executable[name] = false
  end
end

return M
