local outfmt = "\n┌─────────────────────────\n"
  .. "│ dnslookup     : %{time_namelookup}\n"
  .. "│ connect       : %{time_connect}\n"
  .. "│ appconnect    : %{time_appconnect}\n"
  .. "│ pretransfer   : %{time_pretransfer}\n"
  .. "│ starttransfer : %{time_starttransfer}\n"
  .. "│ total         : %{time_total}\n"
  .. "│ size          : %{size_download}\n"
  .. "│ HTTPCode=%{http_code}\n\n"
local M = {}

local exec = function(cmd)
  require("kide.term").toggle(cmd)
end

M.setup = function()
  vim.api.nvim_create_user_command("Curl", function(opt)
    if opt.args == "" then
      local ok, url = pcall(vim.fn.input, "URL: ")
      if ok then
        exec({
          "curl",
          "-w",
          outfmt,
          url,
        })
      end
    else
      local cmd = {
        "curl",
        "-w",
        outfmt,
      }
      vim.list_extend(cmd, vim.split(opt.args, " "))
      exec(cmd)
    end
  end, {
    nargs = "*",
    complete = function()
      return { "-vvv", "--no-sessionid" }
    end,
  })
end

return M
