local M = {}

local vim = vim
local uv = vim.uv

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

M.MAPPINGS_FILE = vim.fn.stdpath("data") .. "/auto-lsp-mappings.lua"
M.LSPCONFIG_DIR = assert(
  vim.api.nvim_get_runtime_file("lua/lspconfig/server_configurations/", false)[1],
  "Could not find `lua/lspconfig/` directory in the 'runtimepath'"
)

local function get_mappings(source, cache)
  local mtime = uv.fs_stat(source).mtime.sec
  local ok, mappings = pcall(dofile, cache)

  if
    ok
    and mappings.source.path == source
    and mappings.source.mtime == mtime
  then
    return mappings
  end

  vim.notify("[AutoLSP] updating server mappings...")
  mappings = require("auto-lsp.generate")(source)

  local file = assert(io.open(cache, "w"))
  file:write("return ", vim.inspect(mappings))
  file:close()

  return mappings
end

function M.setup(opts)
  local mappings = get_mappings(M.LSPCONFIG_DIR, M.MAPPINGS_FILE)

  local global_config = opts["*"]
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

  M.handler = handler
end

return M
