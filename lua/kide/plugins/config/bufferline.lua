local bufferline = require("bufferline")
bufferline.setup({
  options = {
    mode = "buffers",
    style_preset = bufferline.style_preset.minimal,
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
        filetype = "flutterToolsOutline",
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
    indicator = {
      style = "none",
    },
    color_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
  },
})
