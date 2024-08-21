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

  if not config.cmd then
    M.server_executable[name] = false
  elseif type(config.cmd) == "table" then
    M.server_executable[name] = config.cmd[1]
  elseif type(config.cmd) == "function" then
    M.server_executable[name] = nil
  end
end

return M
