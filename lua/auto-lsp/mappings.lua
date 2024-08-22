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

-- Filter out language / package manager executables e.g. `python3 -m <module>`
-- Use the previously generated filetype mapping as a language names database.
local excluded_executables = setmetatable({
  R = true,
  dotnet = true,
  nc = true,
  npx = true,
  python3 = true,
}, { __index = M.filetype_servers })

-- Some languages come with official language server as a subcommand.
-- They should not be filtered out by the above the heuristics.
local allowed_servers = {
  dartls = true,
  nushell = true,
}

local uncheckable_servers = {}
for name, exec in pairs(M.server_executable) do
  if excluded_executables[exec] and not allowed_servers[name] then
    uncheckable_servers[name] = exec
  end
end

for name, _ in pairs(uncheckable_servers) do
  M.server_executable[name] = nil
end

if _G.AUTO_LSP_DEBUG then
  vim.print(uncheckable_servers)
end

return M
