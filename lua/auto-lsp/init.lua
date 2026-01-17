assert(vim.fn.has('nvim-0.7') == 1, 'requires Neovim 0.7 or newer')

local M = {}

local uv = vim.uv or vim.loop

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

M.MAPPINGS_FILE = vim.fn.stdpath("data") .. "/auto-lsp-mappings.lua"
M.LSPCONFIG_DIR = assert(
  vim.api.nvim_get_runtime_file("lsp/", false)[1] or
  vim.api.nvim_get_runtime_file("lua/lspconfig/configs/", false)[1] or
  vim.api.nvim_get_runtime_file("lua/lspconfig/server_configurations/", false)[1],
  "Could not find `lsp/`, `lua/lspconfig/configs/`, or `lua/lspconfig/server_configurations/` directory in the 'runtimepath'"
)

function M.build()
  vim.notify("[auto-lsp.nvim] Updating the server mappings...")

  local mappings = require("auto-lsp.generate")(M.LSPCONFIG_DIR)
  local file = assert(io.open(M.MAPPINGS_FILE, "w"))
  file:write("return ", vim.inspect(mappings))
  file:close()

  vim.notify("[auto-lsp.nvim] Server mappings has been updated")
  return mappings
end

function M.setup(opts)
  local mtime = uv.fs_stat(M.LSPCONFIG_DIR).mtime.sec
  local ok, mappings = pcall(dofile, M.MAPPINGS_FILE)

  local valid = ok
    and mappings.source.path == M.LSPCONFIG_DIR
    and mappings.source.mtime == mtime

  if not valid then
    mappings = M.build()
  end

  local global_config = opts["*"] or {}
  local server_config = opts
  server_config["*"] = nil

  opts = vim.tbl_extend("error", mappings, {
    global_config = global_config,
    server_config = server_config,
  })

  local handler = require("auto-lsp.handler"):new(opts)
  local group = augroup("auto-lsp", { clear = true })

  handler:check_generics()

  autocmd("FileType", {
    group = group,
    callback = function(args)
      handler:check_filetype(args.match)
    end,
  })

  autocmd({ "FocusGained", "TermLeave" }, {
    group = group,
    callback = function(_)
      handler:refresh()
    end,
  })

  if vim.v.vim_did_enter == 1 then
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
      handler:check_filetype(vim.bo[bufnr].filetype)
    end
  end

  local function command(args)
    local subcmd = args.fargs[1]
    if subcmd == "info" or subcmd == nil then
      print(vim.inspect({
        checked_filetypes = handler.checked_filetypes,
        checked_servers = handler.checked_servers,
      }))
    elseif subcmd == "mappings" then
      vim.cmd("new " .. M.MAPPINGS_FILE)
    elseif subcmd == "build" then
      M.build()
    elseif subcmd == "refresh" then
      handler:refresh()
    else
      vim.notify(("[auto-lsp.nvim] Invalid subcmd '%s'"):format(subcmd))
    end
  end

  local function complete(arglead, _, _)
    local subcmds = { "info", "build", "mappings", "refresh" }
    if not vim.iter then
      return subcmds
    end
    return vim
      .iter(subcmds)
      :filter(function(subcmd)
        return subcmd:find(arglead) == 1
      end)
      :totable()
  end

  vim.api.nvim_create_user_command(
    "AutoLsp",
    command,
    { nargs = "?", complete = complete }
  )

  M.handler = handler
end

return M
