return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "kyazdani42/nvim-tree.lua",
    opts = function()
      local config = require "nvchad.configs.nvimtree"
      config.actions.open_file.quit_on_open = true
      return config
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  -- cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "rcarriga/cmp-dap" },
    },
    opts = {
      enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end,
    },
    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })
    end,
  },

  -- tools
  {
    "ibhagwan/fzf-lua",
    event = { "VeryLazy" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup {}
    end,
  },
  -- java
  {
    "mfussenegger/nvim-jdtls",
  },
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "ibhagwan/fzf-lua", -- 可选
    },
  },
  {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
  },
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },

  -- dap
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      require "nvim-dap-virtual-text"

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dap.repl.open()
      end
      dap.listeners.after.event_terminated["dapui_config"] = function()
        dap.repl.close()
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup {}
    end,
  },

  -- python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local function get_python_path()
        if vim.env.VIRTUAL_ENV then
          if vim.fn.has "nvim-0.10" == 1 then
            return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
          end
          return vim.env.VIRTUAL_ENV .. "/bin" .. "/python"
        end
        if vim.env.PY_BIN then
          return vim.env.PY_BIN
        end
        local python = vim.fn.exepath "python3"
        if python == nil or python == "" then
          python = vim.fn.exepath "python"
        end
        return python
      end
      require("dap-python").setup(get_python_path())
    end,
  },
  -- Git
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    opts = {},
  },

  -- Note
  {
    "zk-org/zk-nvim",
    cmd = {
      "ZkIndex",
      "ZkNew",
      "ZkNotes",
    },
    config = function()
      require("zk").setup {
        picker = "telescope",
        lsp = {
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
          },
          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      }
    end,
  },

  -- 大纲插件
  {
    "simrat39/symbols-outline.nvim",
    cmd = {
      "SymbolsOutline",
      "SymbolsOutlineOpen",
      "SymbolsOutlineClose",
    },
    config = function()
      local lspkind = require("kide.icons.lspkind").symbol_map
      require("symbols-outline").setup {
        highlight_hovered_item = false,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = "Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { "", "" },
        wrap = false,
        keymaps = {
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
          File = lspkind.File,
          Module = lspkind.Module,
          Namespace = lspkind.Namespace,
          Package = lspkind.Package,
          Class = lspkind.Class,
          Method = lspkind.Method,
          Property = lspkind.Property,
          Field = lspkind.Field,
          Constructor = lspkind.Constructor,
          Enum = lspkind.Enum,
          Interface = lspkind.Interface,
          Function = lspkind.Function,
          Variable = lspkind.Variable,
          Constant = lspkind.Constant,
          String = lspkind.String,
          Number = lspkind.Number,
          Boolean = lspkind.Boolean,
          Array = lspkind.Array,
          Object = lspkind.Object,
          Key = lspkind.Keyword,
          Null = lspkind.Null,
          EnumMember = lspkind.EnumMember,
          Struct = lspkind.Struct,
          Event = lspkind.Event,
          Operator = lspkind.Operator,
          TypeParameter = lspkind.TypeParameter,
          Component = lspkind.Component,
          Fragment = lspkind.Fragment,
        },
      }
    end,
  },

  -- mackdown 预览插件
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && yarn install",
    config = function()
      vim.g.mkdp_page_title = "${name}"
    end,
  },

  -- chatgpt You, 2023-02-11 01:14:46 - lazy-nvim
  {
    "robitx/gp.nvim",
    cmd = {
      "GpNew",
      "GpChatNew",
      "GpChatToggle",
    },
    opts = {
      openai_api_endpoint = vim.env["OPENAI_API_ENDPOINT"],
    },
    config = function(_, opts)
      require("gp").setup(opts)
    end,
  },
}
