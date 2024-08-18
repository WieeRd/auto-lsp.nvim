local vim = vim

local M = {
  global_opts = {},
  server_opts = {},
  auto_refresh = true,
  skip_executable_check = false,
}

local path = vim.fn.stdpath("data") .. "/auto-lsp-mappings.lua"
local ok, map = pcall(dofile, path)
if not ok then
  map = require("auto-lsp.generate")
  local file = io.open(path, "w")
  file:write("return ", vim.inspect(map))
  file:close()
end

local checked_filetypes = {}
local checked_servers = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local doautocmd = vim.api.nvim_exec_autocmds

local function doautoall(event, opts)
  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    opts.buffer = bufnr
    doautocmd(event, opts)
  end
end

function M.stats()
  return {
    checked_filetypes = checked_filetypes,
    checked_servers = checked_servers,
  }
end

function M.check_server(name, recheck)
  local did_setup = checked_servers[name]
  if did_setup == true or (did_setup == false and not recheck) then
    return
  end

  local opts = M.server_opts[name]
  local exec = map.server_executable[name]

  local setup
  if opts == false then
    setup = false
  elseif type(opts) == "table" then
    setup = true
  elseif type(exec) == "boolean" then
    setup = exec
  elseif type(exec) == "string" then
    setup = M.skip_executable_check or vim.fn.executable(exec) == 1
  end

  if setup then
    opts = vim.tbl_deep_extend("force", M.global_opts, opts or {})
    require("lspconfig")[name].setup(opts)
  end

  checked_servers[name] = setup
end

function M.check_generics(recheck)
  local servers = map.generic_servers
  for _, name in ipairs(servers) do
    M.check_server(name, recheck)
  end

  doautoall("BufReadPost", {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.check_filetype(ft, recheck)
  if checked_filetypes[ft] == true and not recheck then
    return
  end
  checked_filetypes[ft] = true

  local servers = map.filetype_servers[ft]
  if not servers then
    return
  end

  for _, name in ipairs(servers) do
    M.check_server(name)
  end

  local buffers = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buffers) do
    if vim.bo[bufnr].filetype == ft then
      doautocmd("FileType", {
        group = augroup("lspconfig", { clear = false }),
        modeline = false,
      })
    end
  end
end

function M.refresh()
  for name, setup in pairs(checked_servers) do
    if not setup then
      M.check_server(name, true)
    end
  end

  doautoall({ "FileType", "BufReadPost" }, {
    group = augroup("lspconfig", { clear = false }),
    modeline = false,
  })
end

function M.setup(opts)
  for key, value in pairs(opts) do
    M[key] = value
  end

  -- If the user specified the `filetypes` list through `server_opts`,
  -- update `filetype_servers` to trigger setup on the additional filetypes
  for name, opts in pairs(M.server_opts) do
    if not (opts and opts.filetypes) then
      goto continue
    end

    for _, ft in ipairs(opts.filetypes) do
      local servers = map.filetype_servers[ft] or {}
      if not vim.list_contains(servers, name) then
        servers[#servers + 1] = name
      end
      map.filetype_servers[ft] = servers
    end

    ::continue::
  end

  local group = augroup("auto-lsp", { clear = true })

  M.check_generics()
  autocmd("FileType", {
    group = group,
    callback = function(args)
      M.check_filetype(args.match)
    end,
  })

  -- Attempt to detect servers that are newly installed while Neovim is running
  -- that would normally be ignored due to `checked_{filetype, servers}` caching
  if M.auto_refresh then
    autocmd({ "FocusGained", "TermLeave" }, {
      group = group,
      callback = function(_)
        M.refresh()
      end,
    })
  end

  -- If auto-lsp.nvim is loaded after the startup (lazy loading),
  -- check the filetypes of the buffers that are already open
  if vim.v.vim_did_enter == 1 then
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
      M.check_filetype(vim.bo[bufnr].filetype)
    end
  end
end

return M
