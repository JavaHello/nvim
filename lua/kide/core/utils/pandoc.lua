local utils = require("kide.core.utils")
local M = {}
local cjk_mainfont = function()
  if utils.is_win then
    return "Microsoft YaHei UI"
  elseif utils.is_linux then
    return "Noto Sans CJK SC"
  else
    return "Yuanti SC"
  end
end

-- pandoc --pdf-engine=xelatex --highlight-style tango -N --toc -V CJKmainfont="Yuanti SC" -V mainfont="Hack" -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" test.md -o out.pdf
M.markdown_to_pdf = function()
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
          { "--variable", "CJKmainfont=" .. cjk_mainfont() },
          { "--variable", "mainfont=Hack" },
          { "--variable", "sansfont=Hack" },
          { "--variable", "monofont=Hack" },
          { "--variable", "geometry:top=2cm, bottom=1.5cm, left=2cm, right=2cm" },
        })
      end, {
        nargs = "*",
        complete = require("pandoc.utils").complete,
      })
    end,
  })
end

M.setup = function()
  M.markdown_to_pdf()
end
return M
