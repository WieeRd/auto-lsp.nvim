local vim = vim

-- filter out language / package manager commands e.g. python -m <module>
local ignored_executables = {
  R = true,
  dotnet = true,
  java = true,
  julia = true,
  nc = true,
  node = true,
  npx = true,
  perl = true,
  python = true,
  python3 = true,
  racket = true,
}

local function generate(config_dir)
  local generic_servers = {}
  local filetype_servers = {}
  local server_executable = {}

  local config_files = vim.fn.readdir(config_dir)
  for _, file in ipairs(config_files) do
    local name = vim.fn.fnamemodify(file, ":r")
    local path = vim.fs.joinpath(config_dir, file)
    local config = dofile(path).default_config

    if config.filetypes then
      for _, ft in ipairs(config.filetypes) do
        filetype_servers[ft] = filetype_servers[ft] or {}
        table.insert(filetype_servers[ft], name)
      end
    else
      table.insert(generic_servers, name)
    end

    if type(config.cmd) == "table" then
      local exec = config.cmd[1]
      if not ignored_executables[exec] then
        server_executable[name] = exec
      end
    end
  end

  return {
    generic_servers = generic_servers,
    filetype_servers = filetype_servers,
    server_executable = server_executable,
  }
end

return generate
