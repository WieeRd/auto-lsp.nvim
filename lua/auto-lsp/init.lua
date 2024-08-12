local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}
M.checked_servers = {}

M.global_opts = {}
M.server_opts = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function doautocmd(event, opts)
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    opts.buffer = bufnr
    vim.api.nvim_exec_autocmds(event, opts)
  end
end

function M.setup_server(name)
  if M.checked_servers[name] ~= nil then
    return
  end

  local opts = M.server_opts[name]
  local exec = reg.server_executable[name]

  local setup
  if opts == false then
    setup = false
  elseif type(opts) == "table" then
    setup = true
  elseif type(exec) == "boolean" then
    setup = exec
  elseif type(exec) == "string" then
    setup = vim.fn.executable(exec) == 1
  end

  if setup then
    opts = vim.tbl_deep_extend("force", M.global_opts, opts or {})
    require("lspconfig")[name].setup(opts)
    M.checked_servers[name] = true
  else
    M.checked_servers[name] = false
  end
end

function M.setup_generics()
  local servers = reg.generic_servers
  for _, name in ipairs(servers) do
    M.setup_server(name)
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
    M.setup_server(name)
  end

  doautocmd("FileType", {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.setup(opts)
  M.global_opts = opts.global_opts or {}
  M.server_opts = opts.server_opts or {}

  vim.schedule(M.setup_generics)

  local group = augroup("auto-lsp", { clear = true })
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
