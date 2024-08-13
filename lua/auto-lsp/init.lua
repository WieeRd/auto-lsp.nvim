local M = {}

local vim = vim
local reg = require("auto-lsp.registry")

M.checked_filetypes = {}
M.checked_servers = {}

M.global_opts = {}
M.server_opts = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- FIX: ASAP: should have used `pattern` instead of `buffer`
local function doautoall(event, opts)
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    opts.buffer = bufnr
    vim.api.nvim_exec_autocmds(event, opts)
  end
end

function M.setup_server(name, recheck)
  -- nil: unchecked
  -- true: checked, already setup
  -- false: checked, was unavailable
  local checked = M.checked_servers[name]
  if checked == true or (checked == false and not recheck) then
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
  end

  M.checked_servers[name] = setup
end

function M.setup_generics(recheck)
  local servers = reg.generic_servers
  for _, name in ipairs(servers) do
    M.setup_server(name, recheck)
  end

  doautoall("BufReadPost", {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.setup_filetype(ft, recheck)
  if M.checked_filetypes[ft] == true and not recheck then
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

  doautoall("FileType", {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.setup(opts)
  M.global_opts = opts.global_opts or {}
  M.server_opts = opts.server_opts or {}

  -- If the user specified the `filetypes` list through `server_opts`,
  -- update `filetype_servers` to trigger setup on the additional filetypes
  for name, opts in pairs(M.server_opts) do
    if not (opts and opts.filetypes) then
      goto continue
    end

    for _, ft in ipairs(opts.filetypes) do
      local servers = reg.filetype_servers[ft] or {}
      if not vim.list_contains(servers, name) then
        servers[#servers + 1] = name
      end
      reg.filetype_servers[ft] = servers
    end

    ::continue::
  end

  M.setup_generics()

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
    doautoall("FileType", {
      group = group,
      modeline = false,
    })
  end
end

-- FEAT: auto refresh on new installation
-- | Option #1 - Watch each directory in $PATH (`:h uv_fs_event_t`)
-- | Option #2 - Autocmd on FocusGained, TermLeave, CmdlineLeave, etc
function M.refresh()
  for name, setup in pairs(M.checked_servers) do
    if not setup then
      M.setup_server(name, true)
    end
  end

  doautoall({ "FileType", "BufReadPost" }, {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

return M
