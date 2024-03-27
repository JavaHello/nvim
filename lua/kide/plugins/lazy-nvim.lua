local config = require("kide.config")

require("lazy").setup({

  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "williamboman/mason.nvim",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy", "BufNewFile", "BufReadPost" },
    config = function()
      require("kide.lsp")
    end,
  },

  -- 代码片段
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    config = function()
      require("kide.plugins.config.luasnip")
    end,
  },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = { "L3MON4D3/LuaSnip" },
    lazy = true,
  },
  -- lspkind
  {
    "onsails/lspkind-nvim",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      require("lspkind").init({
        -- preset = "codicons",
        symbol_map = {
          Copilot = "",
        },
      })
      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    end,
  },
  -- nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "VeryLazy" },
    keys = { ":", "/", "?" },
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
      "rcarriga/cmp-dap",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
    },
    lazy = true,
    config = function()
      require("kide.plugins.config.nvim-cmp")
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    "hrsh7th/cmp-cmdline",
    lazy = true,
  },
  {
    "hrsh7th/cmp-buffer",
    lazy = true,
  },
  {
    "hrsh7th/cmp-path",
    lazy = true,
  },
  {
    "rcarriga/cmp-dap",
    lazy = true,
  },
  {
    "hrsh7th/cmp-nvim-lsp-document-symbol",
    lazy = true,
  },
  {
    "nvimtools/none-ls.nvim",
    lazy = true,
    event = { "VeryLazy", "BufNewFile", "BufReadPost" },
    dependencies = {
      "gbprod/none-ls-shellcheck.nvim",
    },
    config = function()
      require("kide.plugins.config.null-ls")
    end,
  },

  -- 主题
  -- use 'morhetz/gruvbox'
  {
    "ellisonleao/gruvbox.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        transparent_mode = vim.g.transparent_mode,
      })
      vim.opt.background = "dark"
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
  {
    "sainnhe/gruvbox-material",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "medium"
      vim.g.gruvbox_material_disable_italic_comment = 0
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_cursor = "auto"
      if vim.g.transparent_mode then
        vim.g.gruvbox_material_transparent_background = 2
      end
      vim.g.gruvbox_material_dim_inactive_windows = 0
      vim.g.gruvbox_material_visual = "grey background" -- reverse
      vim.g.gruvbox_material_menu_selection_background = "grey"
      vim.g.gruvbox_material_sign_column_background = "none"
      vim.g.gruvbox_material_spell_foreground = "none"
      vim.g.gruvbox_material_ui_contrast = "low"
      vim.g.gruvbox_material_show_eob = 1
      vim.g.gruvbox_material_float_style = "bright"
      vim.g.gruvbox_material_diagnostic_text_highlight = 0
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_current_word = "grey background"
      vim.g.gruvbox_material_disable_terminal_colors = 1
      vim.g.gruvbox_material_statusline_style = "original"
      vim.g.gruvbox_material_lightline_disable_bold = 0
      -- gruvbox_material_colors_override
      vim.cmd([[colorscheme gruvbox-material]])

      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "Orange" })
      -- #fe8019, #fabd2f
      vim.api.nvim_set_hl(0, "CurrentWord", { fg = "#fe8019", ctermbg = 237, bg = "#3c3836", bold = true })
    end,
  },

  -- 文件管理
  {
    "kyazdani42/nvim-tree.lua",
    lazy = true,
    cmd = "NvimTreeToggle",
    version = "*",
    config = function()
      require("kide.plugins.config.nvim-tree")
    end,
  },

  -- using packer.nvim
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = { "UIEnter" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("kide.plugins.config.bufferline")
    end,
  },
  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete" },
  },

  -- treesitter (新增)
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VeryLazy", "BufNewFile", "BufReadPost" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "markdown",
        },
        sync_install = false,
        ignore_install = {},

        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[o"] = "@loop.*",
              ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            },
          },
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            selection_modes = {
              ["@parameter.outer"] = "v", -- charwise
              ["@function.outer"] = "V", -- linewise
              ["@class.outer"] = "<c-v>", -- blockwise
            },
            include_surrounding_whitespace = false,
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },
      })
      -- 开启 Folding see nvim-ufo
      -- vim.wo.foldmethod = "expr"
      -- vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "VeryLazy", "BufNewFile", "BufReadPost" },
  },

  -- java
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
    ft = "java",
  },
  {
    "JavaHello/java-deps.nvim",
    lazy = true,
    ft = "java",
    dependencies = "mfussenegger/nvim-jdtls",
    config = function()
      require("java-deps").setup({})
    end,
  },
  {
    "scalameta/nvim-metals",
    lazy = true,
    ft = "scala",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  -- debug
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      require("kide.dap")
      -- require("telescope").load_extension("dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap" },
    event = { "VeryLazy" },
    config = function()
      require("kide.plugins.config.nvim-dap-ui")
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    event = { "VeryLazy" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({})
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    ft = "java",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup(config.env.py_bin)
    end,
  },
  {
    "sakhnik/nvim-gdb",
    lazy = true,
    cmd = {
      "GdbStart",
      "GdbStartLLDB",
      "GdbStartPDB",
      "GdbStartBashDB",
      "GdbStartRR",
    },
    init = function()
      vim.g.nvimgdb_disable_start_keymaps = 1
      vim.g.nvimgdb_use_find_executables = 0
      vim.g.nvimgdb_use_cmake_to_find_executables = 0
    end,
    config = function() end,
    build = ":!./install.sh",
  },

  {
    "klen/nvim-test",
    lazy = true,
    ft = {
      "go",
      "javascript",
      "typescript",
      "lua",
      "python",
      "rust",
    },
    config = function()
      require("nvim-test").setup({
        term = "toggleterm",
      })
    end,
  },

  -- 搜索插件
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    event = { "VeryLazy" },
    cmd = { "Telescope" },
    config = function()
      require("kide.plugins.config.telescope")
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    lazy = true,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    lazy = true,
  },

  {
    "LinArcX/telescope-env.nvim",
    lazy = true,
  },
  -- 项目管理
  {
    "nvim-telescope/telescope-project.nvim",
    lazy = true,
  },

  -- git
  {
    "tpope/vim-fugitive",
    lazy = true,
    cmd = { "Git" },
  },
  {
    "sindrets/diffview.nvim",
    layz = true,
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    config = function()
      require("diffview").setup({})
    end,
  },

  -- git edit 状态显示插件
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "VeryLazy", "BufReadPost" },
    config = function()
      require("kide.plugins.config.gitsigns-nvim")
    end,
  },
  {
    "SuperBo/fugit2.nvim",
    opts = {},
    enabled = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      {
        "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
        dependencies = { "stevearc/dressing.nvim" },
      },
    },
    cmd = { "Fugit2", "Fugit2Graph" },
    keys = {
      { "<leader>F", mode = "n", "<cmd>Fugit2<cr>" },
    },
  },

  -- 浮动窗口插件
  {
    "akinsho/toggleterm.nvim",
    lazy = true,
    version = "*",
    cmd = { "ToggleTerm" },
    config = function()
      require("toggleterm").setup({
        shade_terminals = true,
        direction = "horizontal",
        close_on_exit = true,
        float_opts = {
          border = "single",
        },
      })
    end,
  },

  -- 异步任务执行插件
  {
    "jedrzejboczar/toggletasks.nvim",
    lazy = true,
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("toggletasks").setup({
        search_paths = {
          ".tasks",
          ".toggletasks",
          ".nvim/toggletasks",
          ".nvim/tasks",
        },
        toggleterm = {
          close_on_exit = true,
        },
      })

      require("telescope").load_extension("toggletasks")
    end,
  },

  -- 多光标插件
  {
    "mg979/vim-visual-multi",
    lazy = true,
    keys = {
      { "<C-n>", mode = { "n", "x" }, desc = "visual multi" },
    },
  },

  -- 状态栏插件
  {
    "nvim-lualine/lualine.nvim",
    lazy = true,
    event = { "UIEnter" },
    config = function()
      require("kide.plugins.config.lualine")
    end,
  },

  -- blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    main = "ibl",
    event = { "UIEnter" },
    config = function()
      require("kide.plugins.config.indent-blankline")
    end,
  },

  -- 大纲插件
  {
    "simrat39/symbols-outline.nvim",
    lazy = true,
    cmd = {
      "SymbolsOutline",
      "SymbolsOutlineOpen",
      "SymbolsOutlineClose",
    },
    config = function()
      require("kide.plugins.config.symbols-outline")
    end,
  },

  -- 消息通知
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        stages = "fade_in_slide_out",
        on_open = nil,
        on_close = nil,
        render = "default",
        timeout = 3000,
        minimum_width = 50,
        background_colour = "#000000",
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
      })

      vim.notify = notify
    end,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      -- options
    },
  },
  {
    "folke/noice.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        messages = {
          enabled = true, -- enables the Noice messages UI
          view = "notify", -- default view for messages
          view_error = "notify", -- view for errors
          view_warn = "notify", -- view for warnings
          view_history = "messages", -- view for :messages
          view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            ["vim.lsp.util.stylize_markdown"] = false,
            ["cmp.entry.get_documentation"] = false,
          },
          hover = {
            enabled = false,
          },
          signature = {
            enabled = false,
          },
        },
      })
      require("kide.theme.gruvbox").load_noice_highlights()
      require("telescope").load_extension("noice")
    end,
  },

  -- 颜色显示
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "InsertEnter", "VeryLazy" },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true, -- #RGB hex codes
          RRGGBB = true, -- #RRGGBB hex codes
          names = false, -- "Name" codes like Blue or blue
          RRGGBBAA = false, -- #RRGGBBAA hex codes
          AARRGGBB = false, -- 0xAARRGGBB hex codes
          rgb_fn = false, -- CSS rgb() and rgba() functions
          hsl_fn = false, -- CSS hsl() and hsla() functions
          css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = "background", -- Set the display mode.
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = false, -- Enable tailwind colors
          -- parsers can contain values used in |user_default_options|
          sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = false,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      })
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = { "n" }, desc = "Comment" },
      { "gc", mode = { "x" }, desc = "Comment" },
    },
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "danymat/neogen",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      require("neogen").setup({
        snippet_engine = "luasnip",
        enabled = true,
        input_after_comment = true,
      })
    end,
  },

  -- mackdown 预览插件
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = "markdown",
    build = "cd app && yarn install",
    config = function()
      vim.g.mkdp_page_title = "${name}"
    end,
  },
  -- mackdown cli 预览插件
  {
    "ellisonleao/glow.nvim",
    lazy = true,
    ft = "markdown",
    config = function()
      require("glow").setup({
        style = "dark",
        width = 120,
      })
    end,
  },
  -- pandoc 命令插件(用于md转pdf)
  {
    "aspeddro/pandoc.nvim",
    lazy = true,
    ft = "markdown",
    config = function()
      require("kide.plugins.config.pandoc")
    end,
  },

  -- 快捷键查看
  {
    "folke/which-key.nvim",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      require("kide.plugins.config.which-key")
    end,
  },

  -- 仪表盘
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
        " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
        " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
        " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
        " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
        " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      }
      local opt = { noremap = true, silent = true }
      dashboard.section.buttons.val = {
        dashboard.button("<leader>  ff", "󰈞  Find File", ":Telescope find_files<CR>", opt),
        dashboard.button("<leader>  fg", "󰈭  Find Word  ", ":Telescope live_grep<CR>", opt),
        dashboard.button(
          "<leader>  fp",
          "  Recent Projects",
          ":lua require'telescope'.extensions.project.project{ display_type = 'full' }<CR>",
          opt
        ),
        dashboard.button("<leader>  fo", "  Recent File", ":Telescope oldfiles<CR>", opt),
        dashboard.button("<leader>  ns", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>", opt),
        dashboard.button("<leader>  q ", "󰅙  Quit NVIM", ":qa<CR>", opt),
      }
      alpha.setup(dashboard.opts)
    end,
  },

  -- 翻译插件
  {
    "uga-rosa/translate.nvim",
    lazy = true,
    cmd = "Translate",
    config = function()
      require("translate").setup({
        default = {
          command = "translate_shell",
        },
        preset = {
          output = {
            split = {
              append = true,
            },
          },
        },
      })
    end,
  },
  -- StartupTime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },
  -- 自动对齐插件
  {
    "junegunn/vim-easy-align",
    lazy = true,
    cmd = "EasyAlign",
  },

  -- 表格模式插件
  {
    "dhruvasagar/vim-table-mode",
    lazy = true,
    cmd = { "TableModeEnable" },
  },

  -- () 自动补全
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter", "VeryLazy" },
    config = function()
      local autopairs = require("nvim-autopairs")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      autopairs.setup({})
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- 任务插件
  {
    "itchyny/calendar.vim",
    lazy = true,
    cmd = {
      "Calendar",
    },
  },

  -- rust
  {
    "simrat39/rust-tools.nvim",
    lazy = true,
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    opt = {
      rocks = { "md5" },
    },
    config = true,
  },
  {
    "rest-nvim/rest.nvim",
    dependencies = { "luarocks.nvim" },
    lazy = true,
    ft = "http",
    config = function()
      require("rest-nvim").setup({})
    end,
  },

  -- 选中高亮插件
  {
    "RRethy/vim-illuminate",
    lazy = true,
    event = { "BufReadPost" },
    config = function()
      require("kide.plugins.config.vim-illuminate")
    end,
  },

  -- 快速跳转
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
      },
    },
    -- stylua: ignore
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- 查找替换
  {
    "windwp/nvim-spectre",
    lazy = true,
    config = function()
      require("spectre").setup()
    end,
  },

  -- ASCII 图
  {
    "jbyuki/venn.nvim",
    lazy = true,
    cmd = { "VBox" },
  },

  {
    "tversteeg/registers.nvim",
    lazy = true,
    cmd = { "Registers" },
    keys = '"',
    config = function()
      require("registers").setup()
    end,
  },

  -- databases
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    lazy = true,
    dependencies = { "tpope/vim-dadbod" },
    cmd = {
      "DBUI",
      "DBUIToggle",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    lazy = true,
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("kide_vim_dadbod_completion", { clear = true }),
        pattern = { "sql", "mysql", "plsql" },
        callback = function(_)
          require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
        end,
      })
    end,
    config = function() end,
  },

  {
    "aklt/plantuml-syntax",
    lazy = true,
    ft = "plantuml",
  },

  -- 浏览器搜索
  {
    "lalitmee/browse.nvim",
    lazy = true,
    cmd = {
      "Browse",
    },
    config = function()
      require("kide.plugins.config.browse-nvim")
    end,
  },

  -- 环绕输入
  {
    "kylechui/nvim-surround",
    lazy = true,
    version = "*",
    event = { "VeryLazy" },
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  --  Create custom submodes and menus
  {
    "anuvyklack/hydra.nvim",
    lazy = true,
  },

  -- 代码状态栏导航
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    config = function()
      local navic = require("nvim-navic")
      local symbol_map = require("kide.lsp.lsp_ui").symbol_map
      navic.setup({
        icons = {
          File = symbol_map.File.icon .. " ",
          Module = symbol_map.Module.icon .. " ",
          Namespace = symbol_map.Namespace.icon .. " ",
          Package = symbol_map.Package.icon .. " ",
          Class = symbol_map.Class.icon .. " ",
          Method = symbol_map.Method.icon .. " ",
          Property = symbol_map.Property.icon .. " ",
          Field = symbol_map.Field.icon .. " ",
          Constructor = symbol_map.Constructor.icon .. " ",
          Enum = symbol_map.Enum.icon .. "",
          Interface = symbol_map.Interface.icon .. "",
          Function = symbol_map.Function.icon .. " ",
          Variable = symbol_map.Variable.icon .. " ",
          Constant = symbol_map.Constant.icon .. " ",
          String = symbol_map.String.icon .. " ",
          Number = symbol_map.Number.icon .. " ",
          Boolean = symbol_map.Boolean.icon .. " ",
          Array = symbol_map.Array.icon .. " ",
          Object = symbol_map.Object.icon .. " ",
          Key = symbol_map.Key.icon .. " ",
          Null = symbol_map.Null.icon .. " ",
          EnumMember = symbol_map.EnumMember.icon .. " ",
          Struct = symbol_map.Struct.icon .. " ",
          Event = symbol_map.Event.icon .. " ",
          Operator = symbol_map.Operator.icon .. " ",
          TypeParameter = symbol_map.TypeParameter.icon .. " ",
        },
        lazy_update_context = true,
        highlight = true,
        safe_output = true,
        separator = " > ",
        -- depth_limit = 0,
        -- depth_limit_indicator = "..",
      })
    end,
  },

  -- 笔记
  {
    "zk-org/zk-nvim",
    lazy = true,
    cmd = {
      "ZkIndex",
      "ZkNew",
      "ZkNotes",
    },
    config = function()
      require("kide.plugins.config.zk-nvim")
    end,
  },

  -- 折叠
  {
    "kevinhwang91/promise-async",
    lazy = true,
  },
  {
    "kevinhwang91/nvim-ufo",
    lazy = true,
    event = { "VeryLazy" },
    config = function()
      -- lsp->treesitter->indent
      local ftMap = {
        vim = "indent",
        python = { "indent" },
        git = "",
      }

      local function customizeSelector(bufnr)
        local function handleFallbackException(err, providerName)
          if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        return require("ufo").getFolds(bufnr, "lsp")
          :catch(function(err)
            return handleFallbackException(err, "treesitter")
          end)
          :catch(function(err)
            return handleFallbackException(err, "indent")
          end)
      end
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
      require("ufo").setup({
        provider_selector = function(_, filetype, _)
          return ftMap[filetype] or customizeSelector
        end,
        fold_virt_text_handler = handler,
      })
      require("kide.core.keybindings").ufo_mapkey()
    end,
  },

  {
    "ethanholz/nvim-lastplace",
    lazy = true,
    event = { "BufReadPost" },
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
        lastplace_open_folds = true,
      })
    end,
  },

  {
    "akinsho/flutter-tools.nvim",
    lazy = true,
    ft = { "dart" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("kide_FlutterOutlineToggle", { clear = true }),
        pattern = "dart",
        callback = function(event)
          vim.keymap.set("n", "<leader>o", "<CMD>FlutterOutlineToggle<CR>", { buffer = event.buf, silent = true })
        end,
      })
      vim.api.nvim_create_autocmd("BufNewFile", {
        group = vim.api.nvim_create_augroup("kide__FlutterOutlineToggle", { clear = true }),
        pattern = "Flutter Outline",
        callback = function(event)
          vim.keymap.set("n", "<leader>o", "<CMD>FlutterOutlineToggle<CR>", { buffer = event.buf, silent = true })
        end,
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("kide.plugins.config.flutter-tools")
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    lazy = true,
    ft = {
      "typescript",
      "javascript",
      "lua",
      "c",
      "cpp",
      "go",
      "python",
      "java",
      "php",
      "ruby",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({})
    end,
  },

  -- ui
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- chatgpt
  {
    "robitx/gp.nvim",
    lazy = true,
    cmd = {
      "GpNew",
      "GpChatNew",
    },
    config = function()
      require("gp").setup({
        openai_api_endpoint = vim.env["OPENAI_API_ENDPOINT"],
      })
    end,
  },
  {
    "folke/todo-comments.nvim",
    lazy = true,
    cmd = {
      "TodoTelescope",
      "TodoLocList",
      "TodoQuickFix",
    },
    config = function()
      require("todo-comments").setup({})
    end,
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   enabled = config.plugin.copilot.enable,
  --   lazy = true,
  --   cmd = "Copilot",
  --   config = function()
  --     require("copilot").setup({})
  --   end,
  -- },
  {
    "github/copilot.vim",
    enabled = config.plugin.copilot.enable,
    config = function()
      vim.g.copilot_enabled = true
      vim.g.copilot_no_tab_map = true
      vim.cmd('imap <silent><script><expr> <C-C> copilot#Accept("")')
      vim.cmd([[
			let g:copilot_filetypes = {
	       \ 'TelescopePrompt': v:false,
	     \ }
			]])
    end,
  },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    enabled = config.plugin.codeium.enable,
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set("i", "<C-c>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-;>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-,>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-x>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      mode = "split",
      prompts = {
        Explain = "Explain how it works. Answer in Chinese",
        Review = "Review the following code and provide concise suggestions. Answer in Chinese",
        Tests = "Briefly explain how the selected code works, then generate unit tests. Answer in Chinese",
        Refactor = "Refactor the code to improve clarity and readability. Answer in Chinese",
      },
    },
    build = function()
      vim.defer_fn(function()
        vim.cmd("UpdateRemotePlugins")
        vim.notify("CopilotChat - Updated remote plugins. Please restart Neovim.")
      end, 3000)
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>ccR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    opts = {},
    event = "VeryLazy",
    keys = {
      {
        "<leader>vs",
        "<cmd>:VenvSelect<cr>",
        "<leader>vc",
        "<cmd>:VenvSelectCached<cr>",
      },
    },
  },

  {
    "eandrju/cellular-automaton.nvim",
    cmd = {
      "CellularAutomaton",
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = {
      "FzfLua",
    },
    config = function()
      require("fzf-lua").setup({
        git_diff = {
          pager = "delta --width=$FZF_PREVIEW_COLUMNS",
        },
        git = {
          status = {
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
          commits = {
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
          bcommits = {
            preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
          },
        },
      })
    end,
  },

  {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    ft = { "java" },
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      })
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = {
      "java",
      "rust",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-java")({
            ignore_wrapper = false, -- whether to ignore maven/gradle wrapper
          }),
          require("neotest-rust"),
        },
      })
    end,
  },
  {
    "rcasia/neotest-java",
    ft = { "java" },
  },
  {
    "rouge8/neotest-rust",
    ft = { "rust" },
  },
  {
    "kawre/leetcode.nvim",
    lazy = "leetcode.nvim" ~= vim.fn.argv()[1],
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "c",
      cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },
      directory = vim.fn.stdpath("data") .. "/leetcode/",
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")

      -- REQUIRED
      harpoon:setup({})
      -- REQUIRED
      vim.keymap.set("n", "<leader>fa", function()
        harpoon:list():append()
      end, { desc = "Harpoon Append" })
      vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)
    end,
  },

  -- {
  --   "xbase-lab/xbase",
  --   build = "make install",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "neovim/nvim-lspconfig",
  --   },
  --   config = function()
  --     require("xbase").setup({
  --       mappings = {
  --         enable = true,
  --         build_picker = 0,
  --         run_picker = 0,
  --         watch_picker = 0,
  --         all_picker = 0,
  --         toggle_split_log_buffer = 0,
  --         toggle_vsplit_log_buffer = 0,
  --       },
  --     })
  --   end,
  -- },

  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      hint_prefix = "󰏚 ",
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)

      vim.keymap.set({ "n" }, "<Leader>k", function()
        vim.lsp.buf.signature_help()
      end, { silent = true, noremap = true, desc = "toggle signature" })
    end,
  },
  {
    "lambdalisue/suda.vim",
    lazy = true,
    cmd = {
      "SudaWrite",
      "SudaRead",
    },
  },
  {
    "chrisbra/csv.vim",
    lazy = true,
    ft = { "csv" },
  },
}, {
  ui = {
    icons = {
      task = "✓ ",
    },
  },
})
