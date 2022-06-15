require("bufferline").setup {
  options = {
    -- 使用 nvim 内置lsp
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
            or (e == "warning" and " " or "")
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
          return vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        end,
        padding = 1,
        highlight = "Directory",
        -- text_align = "center"
        text_align = "left"
      }, {
        filetype = "Outline",
        text = "Outline",
        padding = 1,
        highlight = "Directory",
        text_align = "left"
      },
    },
  },
  color_icons = true,
  show_buffer_close_icons = true,
  show_buffer_default_icon = true,
  show_close_icon = false,
  show_tab_indicators = true,
  -- separator_style = "slant" | "thick" | "thin" | { 'any', 'any' },
  separator_style = "slant",
}
