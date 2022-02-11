require("bufferline").setup {
  options = {
    -- 使用 nvim 内置lsp
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
        or (e == "warning" and " " or "" )
        s = s .. n .. sym
      end
      return s
    end,
    -- 左侧让出 nvim-tree 的位置
    offsets = {{
      filetype = "NvimTree",
      text = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      end,
      highlight = "Directory",
      text_align = "left"
    }}
  }
}
