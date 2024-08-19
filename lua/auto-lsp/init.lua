local vim = vim

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local M = {}

function M.mappings(force)
  local path = vim.fn.stdpath("data") .. "/auto-lsp-mappings.lua"

  if not force then
    local ok, map = pcall(dofile, path)
    if ok then
      return map
    end
  end

  local map = require("auto-lsp.mappings")
  local file = io.open(path, "w")
  file:write("return ", vim.inspect(map))
  file:close()

  return map
end

function M.build()
  local _ = M.mappings(true)
end

function M.setup(opts)
  local map = M.mappings()
  local opts = vim.tbl_extend("keep", opts or {}, {
    global_config = {},
    server_config = {},
    auto_refresh = true,
    skip_executable_check = false,
  })

  local handler = require("auto-lsp.handler"):new(map, opts)
  local group = augroup("auto-lsp", { clear = true })

  handler:check_generics()

  autocmd("FileType", {
    group = group,
    callback = function(args)
      handler:check_filetype(args.match)
    end,
  })

  if handler.auto_refresh then
    autocmd({ "FocusGained", "TermLeave" }, {
      group = group,
      callback = function(_)
        handler:refresh()
      end,
    })
  end

  if vim.v.vim_did_enter == 1 then
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
      handler:check_filetype(vim.bo[bufnr].filetype)
    end
  end
end

return M
