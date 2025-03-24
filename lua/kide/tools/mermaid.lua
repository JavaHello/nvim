local M = {}

local function exec(opt)
  if not vim.fn.executable("mmdc") then
    vim.notify("Mermaid: 没有 mmdc 命令", vim.log.levels.ERROR)
    return
  end

  local p = vim.fn.expand("%:p:r")
  local cmd
  if opt.args and #opt.args > 0 then
    cmd = vim.deepcopy(opt.args)
  else
    local args = {
      "-i",
      opt.file,
      "-o",
      p .. ".svg",
    }
    cmd = args
  end
  table.insert(cmd, 1, "mmdc")
  print(vim.inspect(cmd))
  local sid = require("kide").timer_stl_status("")
  local result = vim.system(cmd):wait()
  require("kide").clean_stl_status(sid, result.code)
  if result.code == 0 then
    vim.notify("Mermaid: export success", vim.log.levels.INFO)
  else
    vim.notify("Mermaid: export error", vim.log.levels.ERROR)
  end
end

local function init()
  local group = vim.api.nvim_create_augroup("mermaid_export", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "mermaid" },
    desc = "Export Mermaid file",
    callback = function(o)
      vim.api.nvim_buf_create_user_command(o.buf, "Mmdc", function(opts)
        exec({
          args = opts.fargs,
          file = o.file,
        })
      end, {
        nargs = "*",
      })
    end,
  })
end

M.setup = function()
  init()
end
return M
