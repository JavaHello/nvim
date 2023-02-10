require("lazy").setup({

  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  {
    "kyazdani42/nvim-web-devicons",
    lazy = true,
  },
  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall" },
    config = function()
      require("kide.plugins.config.mason-nvim")
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    config = function()
      require("kide.lsp")
    end,
  },

  -- 代码片段
  {
    "rafamadriz/friendly-snippets",
    event = { "InsertEnter" },
    lazy = true,
  },
  -- nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter" },
    lazy = true,
    config = function()
      require("kide.plugins.config.nvim-cmp")
    end,
  },
  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    event = { "InsertEnter" },
    dependencies = { "friendly-snippets" },
    config = function()
      require("kide.plugins.config.luasnip")
    end,
  },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = { "LuaSnip" },
    event = { "InsertEnter" },
    lazy = true,
  },
  -- lspkind
  {
    "onsails/lspkind-nvim",
    lazy = true,
    event = { "InsertEnter" },
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
    event = { "InsertEnter" },
  },
  {
    "hrsh7th/cmp-buffer",
    lazy = true,
    event = { "InsertEnter" },
  },
  {
    "hrsh7th/cmp-path",
    lazy = true,
    event = { "InsertEnter" },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    lazy = true,
    event = { "BufReadPost" },
    config = function()
      require("kide.plugins.config.null-ls")
    end,
  },

  -- 主题
  -- use 'morhetz/gruvbox'
  {
    "ellisonleao/gruvbox.nvim",
    priority = 100,
    config = function()
      require("kide.plugins.config.gruvbox")
    end,
  },
  -- use 'sainnhe/gruvbox-material'

  -- 文件管理
  {
    "kyazdani42/nvim-tree.lua",
    lazy = true,
    cmd = "NvimTreeToggle",
    tag = "nightly",
    config = function()
      require("kide.plugins.config.nvim-tree")
    end,
  },

  -- using packer.nvim
  {
    "akinsho/bufferline.nvim",
    tag = "v3.0.1",
    dependencies = { "gruvbox.nvim" },
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("kide.plugins.config.bufferline")
    end,
  },

  -- treesitter (新增)
  {
    "nvim-treesitter/nvim-treesitter",
    priority = 90,
    dependencies = { "gruvbox.nvim" },
    build = ":TSUpdate",
    config = function()
      require("kide.plugins.config.nvim-treesitter")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("kide.plugins.config.nvim-treesitter-context")
    end,
  },

  -- java
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
    ft = "java",
    init = function()
      -- 不加载 nvim-jdtls.vim
      vim.g.nvim_jdtls = 1
    end,
    config = function()
      require("kide.lsp.java").setup()
    end,
  },
  {
    "JavaHello/java-deps.nvim",
    lazy = true,
    ft = { "java" },
    config = function()
      require("java-deps").setup()
    end,
  },

  -- debug
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    config = function()
      require("kide.plugins.config.nvim-dap")
      require("kide.dap")
    end,
  },

  -- 搜索插件
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    dependencies = { "gruvbox.nvim" },
    cmd = { "Telescope" },
    tag = "0.1.1",
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
    layz = true,
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
      require("kide.plugins.config.diffview-nvim")
    end,
  },
  {
    "TimUntersberger/neogit",
    layz = true,
    cmd = "Neogit",
    config = function()
      require("kide.plugins.config.neogit")
    end,
  },

  -- git edit 状态显示插件
  {
    "lewis6991/gitsigns.nvim",
    layz = true,
    config = function()
      require("kide.plugins.config.gitsigns-nvim")
    end,
  },

  -- 浮动窗口插件
  {
    "akinsho/toggleterm.nvim",
    lazy = true,
    cmd = { "ToggleTerm" },
    config = function()
      require("toggleterm").setup({
        shade_terminals = true,
        -- shade_filetypes = { "none", "fzf" },
        direction = "float",
        close_on_exit = true,
        float_opts = {
          border = "double",
          winblend = 0,
        },
      })
    end,
  },

  -- 异步任务执行插件
  {
    "jedrzejboczar/toggletasks.nvim",
    lazy = true,
    config = function()
      require("kide.plugins.config.toggletasks")
    end,
  },

  -- 多光标插件
  {
    "mg979/vim-visual-multi",
    lazy = true,
    keys = { "<C-n>" },
  },

  -- 状态栏插件
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "gruvbox.nvim" },
    config = function()
      require("kide.plugins.config.lualine")
    end,
  },

  -- blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost" },
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
      require("kide.plugins.config.nvim-notify")
    end,
  },

  -- wildmenu 补全美化
  {
    "gelguy/wilder.nvim",
    config = function()
      require("kide.plugins.config.wilder")
    end,
  },

  -- 颜色显示
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "InsertEnter" },
    config = function()
      require("kide.plugins.config.nvim-colorizer")
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = { "gc", "gb" },
    config = function()
      require("kide.plugins.config.comment")
    end,
  },
  {
    "danymat/neogen",
    lazy = true,
    config = function()
      require("kide.plugins.config.neogen")
    end,
  },

  -- mackdown 预览插件
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    ft = "markdown",
    build = "cd app && yarn install",
    config = function()
      require("kide.plugins.config.markdown-preview")
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
    config = function()
      require("kide.plugins.config.which-key")
    end,
  },

  -- 仪表盘
  {
    "goolord/alpha-nvim",
    config = function()
      require("kide.plugins.config.alpha-nvim")
    end,
  },

  -- 翻译插件
  {
    "uga-rosa/translate.nvim",
    lazy = true,
    config = function()
      require("kide.plugins.config.translate")
    end,
  },

  -- 自动对齐插件
  {
    "junegunn/vim-easy-align",
    lazy = true,
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
    event = { "InsertEnter" },
    config = function()
      require("kide.plugins.config.nvim-autopairs")
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
    "NTBBloodbath/rest.nvim",
    lazy = true,
    ft = "http",
    config = function()
      vim.cmd([[
          function! s:http_rest_init() abort
            lua require('kide.plugins.config.rest-nvim')
            lua require('kide.core.keybindings').rest_nvim()
          endfunction
          augroup http_rest
              autocmd!
              autocmd FileType http call s:http_rest_init()
          augroup end
         ]])
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
    "ggandor/leap.nvim",
    lazy = true,
    keys = { "s", "S" },
    config = function()
      require("leap").add_default_mappings()
      require("leap").opts.safe_labels = {}
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },

  -- LSP 进度
  {
    "j-hui/fidget.nvim",
    lazy = true,
    config = function()
      require("fidget").setup({})
    end,
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
  },

  -- databases
  {
    "nanotee/sqls.nvim",
    lazy = true,
    ft = { "sql", "mysql" },
  },
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    lazy = true,
    cmd = {
      "DBUI",
      "DBUIToggle",
    },
    init = function()
      require("kide.plugins.config.vim-dadbod")
    end,
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
    event = { "InsertEnter" },
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
      require("kide.plugins.config.nvim-navic")
    end,
  },

  -- 笔记
  {
    "mickael-menu/zk-nvim",
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
    event = { "BufReadPost" },
    config = function()
      require("kide.plugins.config.nvim-ufo")
    end,
  },

  -- ui
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- chatgpt
  {
    "jackMort/ChatGPT.nvim",
    lazy = true,
    cmd = {
      "ChatGPT",
    },
    config = function()
      require("chatgpt").setup({})
    end,
  },
})
