local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}

-- nil: unchecked
-- true: successfully loaded
-- false: server unavailable
M.checked_servers = {}

-- FEAT: implement setup_{generics, filetype}()
-- | 1. Get the list of servers
-- | 2. Check if the server has already been checked
-- | 3. Check if the server's executable is available on the $PATH
-- | 4. Setup available servers via lspconfig
-- | 5. Retrigger events to make the servers attach to existing buffers

function M.setup_server(name, opts)
  -- NOTE: should this check happen inside or outside this function?
  if M.checked_servers[name] ~= nil then
    return
  end

  local exec = reg.server_executable[name]
  if
    exec == true
    or (exec == false and opts)
    or vim.fn.executable(exec) == 1
  then
    require("lspconfig")[name].setup(opts or {})
    M.checked_servers[name] = true
  else
    M.checked_servers[name] = false
  end
end

function M.setup_generics()
  local servers = reg.generic_servers
end

function M.setup_filetype(ft)
  local servers = reg.filetype_servers[ft]
end

function M.setup(_)
  -- FEAT: create autocmds in setup()
  -- | 1. setup_filetype() upon FileType
  -- | 2. setup_generics() upon VimEnter
end

return M
