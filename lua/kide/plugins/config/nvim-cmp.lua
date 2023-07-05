local lspkind = require("lspkind")
local cmp = require("cmp")
local config = require("kide.config")

local function sorting()
  local comparators = {
    cmp.config.compare.sort_text,
    -- Below is the default comparitor list and order for nvim-cmp
    cmp.config.compare.offset,
    -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
    cmp.config.compare.exact,
    cmp.config.compare.score,
    cmp.config.compare.recently_used,
    cmp.config.compare.locality,
    cmp.config.compare.kind,
    cmp.config.compare.length,
    cmp.config.compare.order,
  }
  if config.plugin.copilot.enable then
    table.insert(comparators, 1, require("copilot_cmp.comparators").prioritize)
  end
  return {
    priority_weight = 2,
    comparators = comparators,
  }
end

local menu = {
  nvim_lsp = "[LSP]",
  luasnip = "[Lsnip]",
  path = "[Path]",
  copilot = "[Copilot]",
  -- buffer = "[Buffer]",
}
cmp.setup({
  enabled = function()
    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
  end,
  sorting = sorting(),
  -- 指定 snippet 引擎
  snippet = {
    expand = function(args)
      -- For `vsnip` users.
      -- vim.fn["vsnip#anonymous"](args.body)

      -- For `luasnip` users.
      require("luasnip").lsp_expand(args.body)

      -- For `ultisnips` users.
      -- vim.fn["UltiSnips#Anon"](args.body)

      -- For `snippy` users.
      -- require'snippy'.expand_snippet(args.body)
    end,
  },
  -- 来源
  sources = cmp.config.sources({
    { name = "copilot" },
    { name = "nvim_lsp" },
    -- For vsnip users.
    -- { name = 'vsnip' },
    -- For luasnip users.
    { name = "luasnip" },
    --For ultisnips users.
    -- { name = 'ultisnips' },
    -- -- For snippy users.
    -- { name = 'snippy' },
  }, {
    { name = "path" },
    { name = "buffer" },
  }),

  -- 快捷键
  mapping = require("kide.core.keybindings").cmp(cmp),
  -- 使用lspkind-nvim显示类型图标
  formatting = {
    format = lspkind.cmp_format({
      with_text = true, -- do not show text alongside icons
      maxwidth = 50,
      before = function(entry, vim_item)
        -- Source 显示提示来源
        vim_item.kind = lspkind.symbolic(vim_item.kind, {})
        local m = vim_item.kind and vim_item.kind .. " " or ""
        local ms = menu[entry.source.name] and m .. menu[entry.source.name] or m
        vim_item.kind = ms
        return vim_item
      end,
    }),
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
  }, {
    { name = "buffer" },
  }),
})
cmp.setup.cmdline({ "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
})
