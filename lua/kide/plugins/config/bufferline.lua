require("bufferline").setup({
  options = {
    -- 使用 nvim 内置lsp
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " " or (e == "warning" and " " or " ")
        s = s .. n .. sym
      end
      return s
    end,
    -- 左侧让出 nvim-tree 的位置
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          -- return "File Explorer"
          -- git symbolic-ref --short -q HEAD
          -- git --no-pager rev-parse --show-toplevel --absolute-git-dir --abbrev-ref HEAD
          -- git --no-pager rev-parse --short HEAD
          -- local b = vim.fn.trim(vim.fn.system("git symbolic-ref --short -q HEAD"))
          -- if string.match(b, "fatal") then
          -- 	b = ""
          -- else
          -- 	b = "  " .. b
          -- end
          -- return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") .. b
          return "File Explorer"
        end,
        padding = 1,
        highlight = "Directory",
        -- text_align = "center"
        text_align = "left",
      },
      {
        filetype = "DiffviewFiles",
        text = function()
          return "DiffviewFilePanel"
        end,
        padding = 1,
        highlight = "Directory",
        -- text_align = "center"
        text_align = "left",
      },
      {
        filetype = "Outline",
        text = " Outline",
        padding = 1,
        highlight = "Directory",
        text_align = "left",
      },
      {
        filetype = "dapui_watches",
        text = "Debug",
        padding = 1,
        highlight = "Directory",
        text_align = "left",
      },
      {
        filetype = "dbui",
        text = "Databases",
        padding = 1,
        highlight = "Directory",
        text_align = "left",
      },
      {
        filetype = "JavaProjects",
        text = " JavaProjects",
        padding = 1,
        highlight = "Directory",
        text_align = "left",
      },
    },
    color_icons = true,
    show_buffer_close_icons = true,
    -- show_buffer_default_icon = true,
    show_close_icon = false,
    show_tab_indicators = true,
    -- separator_style = "slant" | "thick" | "thin" | { 'any', 'any' },
    -- separator_style = "slant",
  },
})
