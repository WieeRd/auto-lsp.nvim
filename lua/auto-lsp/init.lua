local vim = vim

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local M = {}

M.MAPPINGS_PATH = vim.fn.stdpath("data") .. "/auto-lsp-mappings.lua"

function M.mappings(opts)
  opts = opts or {}
  local path = opts.path or M.MAPPINGS_PATH

  if not opts.force then
    local map, _ = loadfile(path)
    if map then
      return map()
    end
  end

  package.loaded["auto-lsp.mappings"] = nil
  local map = require("auto-lsp.mappings")

  local file = assert(io.open(path, "w"))
  file:write("return ", vim.inspect(map))
  file:close()

  return map
end

function M.setup(opts)
  opts = vim.tbl_extend("error", M.mappings(), {
    global_config = opts["*"],
    server_config = opts,
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
    local subcmd = args.args
    if subcmd == "generate" then
      M.mappings({ force = true })
    elseif subcmd == "mappings" then
      vim.cmd.new(M.MAPPINGS_PATH)
    elseif subcmd == "refresh" then
      handler:refresh()
    elseif subcmd == "status" then
      vim.print({
        checked_filetypes = handler.checked_filetypes,
        checked_servers = handler.checked_servers,
      })
    else
      vim.notify(
        ("Invalid subcommand '%s'"):format(subcmd),
        vim.log.levels.ERROR
      )
    end
  end

  vim.api.nvim_create_user_command("AutoLsp", command, {
    nargs = 1,
    complete = function(arglead, _, _)
      return vim
        .iter({ "generate", "mappings", "refresh", "status" })
        :filter(function(subcmd)
          return subcmd:find(arglead) ~= nil
        end)
        :totable()
    end,
  })
end

return M
