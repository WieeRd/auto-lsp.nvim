local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}
M.checked_servers = {}

-- FEAT: implement setup_{generics, filetype}()
-- | 1. Get the list of servers
-- | 2. Check if the server has already been checked
-- | 3. Check if the server's executable is available on the $PATH
-- | 4. Setup available servers via lspconfig
-- | 5. Retrigger events to make the servers attach to existing buffers

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
