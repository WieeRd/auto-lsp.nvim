local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}

-- nil: unchecked
-- true: successfully loaded
-- false: server unavailable
M.checked_servers = {}

local function doautocmd(event, opts)
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    opts.buffer = bufnr
    vim.api.nvim_exec_autocmds(event, opts)
  end
end

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
  for _, name in ipairs(servers) do
    M.setup_server(name, nil)
  end

  doautocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.setup_filetype(ft)
  if M.checked_filetypes[ft] then
    return
  end
  M.checked_filetypes[ft] = true

  local servers = reg.filetype_servers[ft]
  if not servers then
    return
  end

  for _, name in ipairs(servers) do
    M.setup_server(name, nil)
  end

  doautocmd("FileType", {
    group = vim.api.nvim_create_augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

-- FEAT: apply user configs, global and server-specific
function M.setup(_)
  vim.schedule(M.setup_generics)
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local ft = args.match
      M.setup_filetype(ft)
    end,
    group = vim.api.nvim_create_augroup("auto-lsp", { clear = true }),
  })

  -- If auto-lsp.nvim is loaded after the startup (lazy loading),
  -- check the existing buffers by retriggering the FileType event.
  if vim.v.vim_did_enter == 1 then
    doautocmd("FileType", {
      group = "auto-lsp",
      modeline = false,
    })
  end
end

return M
