require("pandoc").setup({
  commands = {
    enable = false,
  },
})

-- pandoc --pdf-engine=xelatex --highlight-style tango -N --toc -V CJKmainfont="Yuanti SC" -V mainfont="Hack" -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" test.md -o out.pdf
local function markdown_to_pdf()
  local group = vim.api.nvim_create_augroup("kide_utils_pandoc", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "markdown" },
    desc = "Markdown to PDF",
    callback = function(o)
      vim.api.nvim_buf_create_user_command(o.buf, "PandocMdToPdf", function(_)
        require("pandoc.render").file({
          { "--pdf-engine", "xelatex" },
          { "--highlight-style", "tango" },
          { "--number-sections" },
          { "--toc" },
          { "--variable", "CJKmainfont=Yuanti SC" },
          { "--variable", "mainfont=Hack" },
          { "--variable", "geometry:top=2cm, bottom=1.5cm, left=2cm, right=2cm" },
        })
      end, {
        nargs = "*",
        complete = require("pandoc.utils").complete,
      })
    end,
  })
end
markdown_to_pdf()

local uv = vim.loop
require("pandoc.process").spawn = function(bin, args, callback)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local p = vim.fn.expand("%:p:h")
  local spawn_opts = {
    args = args,
    cwd = p,
    stdio = { nil, stdout, stderr },
  }

  local result = {}

  local handle, pid
  handle, pid = uv.spawn(
    bin,
    spawn_opts,
    vim.schedule_wrap(function(exit_code, signal)
      stdout:read_stop()
      stderr:read_stop()
      stdout:close()
      stderr:close()
      handle:close()
      callback(result, exit_code, signal)
    end)
  )

  if handle == nil then
    error(("Failed to spawn process: cmd = %s, error = %s"):format(bin, pid))
  end

  local function on_read(err, data)
    if err then
      error(err)
    end
    if data then
      table.insert(result, data)
    end
  end

  stderr:read_start(on_read)
  stdout:read_start(on_read)
end
