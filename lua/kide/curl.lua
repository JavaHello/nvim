-- curl -vvv 'https://google.com' \
local outfmt =
  '-w "\n==============\n\n | dnslookup: %{time_namelookup}\n | connect: %{time_connect}\n | appconnect: %{time_appconnect}\n | pretransfer: %{time_pretransfer}\n | starttransfer: %{time_starttransfer}\n | total: %{time_total}\n | size: %{size_download}\n | HTTPCode=%{http_code}\n\n"'
local M = {}

local exec = function(cmd)
  local ok, overseer = pcall(require, "overseer")
  if ok then
    local task = overseer.new_task({
      cmd = cmd,
    })
    task:start()
  else
    require("nvchad.term").runner({
      pos = "sp",
      cmd = cmd,
      id = "curl",
      clear_cmd = true,
    })
  end
end

M.setup = function()
  vim.api.nvim_create_user_command("Curl", function(opt)
    local ok, url = pcall(vim.fn.input, "URL: ")
    if ok then
      if url ~= "" then
        exec("curl " .. opt.args .. " '" .. url .. "' " .. outfmt)
      else
        exec("curl " .. opt.args .. " " .. outfmt)
      end
    end
  end, {
    nargs = "*",
    complete = function()
      return { "-vvv" }
    end,
  })
end
return M
