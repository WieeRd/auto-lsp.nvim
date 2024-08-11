local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}
M.checked_servers = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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
    group = augroup("lspconfig", { clear = false }),
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
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

-- FEAT: apply user configs, global and server-specific
function M.setup(_)
  local group = augroup("auto-lsp", { clear = true })

  vim.schedule(M.setup_generics)
  autocmd("FileType", {
    group = group,
    callback = function(args)
      M.setup_filetype(args.match)
    end,
  })

  -- If auto-lsp.nvim is loaded after the startup (lazy loading),
  -- retrigger the FileType event to check the existing buffers
  if vim.v.vim_did_enter == 1 then
    doautocmd("FileType", {
      group = group,
      modeline = false,
    })
  end
end

return M
