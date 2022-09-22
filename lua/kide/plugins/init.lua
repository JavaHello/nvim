local bootstrap = require("packer_bootstrap")
vim.cmd("packadd packer.nvim")

require("packer").startup({
  function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")
    use({
      "nvim-lua/plenary.nvim",
      module = "plenary",
      opt = true,
    })

    use({
      "kyazdani42/nvim-web-devicons",
      module = "nvim-web-devicons",
      opt = true,
    })
    use({
      "williamboman/mason.nvim",
      opt = true,
      module = "mason",
      setup = function()
        require("kide.core.layz_load").async_load("mason.nvim")
      end,
      config = function()
        require("kide.plugins.config.mason-nvim")
      end,
    })
    use({
      "williamboman/mason-lspconfig.nvim",
      after = "mason.nvim",
      module = "mason-lspconfig",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("mason-lspconfig.nvim")
      end,
    })
    use({
      "neovim/nvim-lspconfig",
      after = "mason-lspconfig.nvim",
      module = "lspconfig",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-lspconfig")
      end,
      config = function()
        require("kide.lsp")
      end,
    })

    -- 代码片段
    use({
      "rafamadriz/friendly-snippets",
      event = "InsertEnter",
    })
    -- nvim-cmp
    use({
      "hrsh7th/nvim-cmp",
      module = "cmp",
      after = "friendly-snippets",
    })
    -- LuaSnip
    use({
      "L3MON4D3/LuaSnip",
      module = "luasnip",
      wants = "friendly-snippets",
      after = "nvim-cmp",
      config = function()
        require("kide.plugins.config.luasnip")
      end,
    })
    use({
      "saadparwaiz1/cmp_luasnip",
      after = "LuaSnip",
    })

    use({
      "hrsh7th/cmp-nvim-lsp",
      module = "cmp_nvim_lsp",
      after = "cmp_luasnip",
    })
    use({
      "hrsh7th/cmp-buffer",
      after = "cmp-nvim-lsp",
    })
    use({
      "hrsh7th/cmp-path",
      after = "cmp-buffer",
    })
    -- lspkind
    use({
      "onsails/lspkind-nvim",
      after = "cmp-path",
      config = function()
        require("kide.plugins.config.nvim-cmp")
      end,
    })
    -- use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }

    -- vsnip
    -- use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
    -- use 'hrsh7th/vim-vsnip'

    -- lsp 相关
    -- use 'folke/lsp-colors.nvim'
    -- use("folke/trouble.nvim")

    -- java 不友好
    -- use({ "glepnir/lspsaga.nvim", branch = "main" })
    -- use 'arkav/lualine-lsp-progress'
    -- use 'nvim-lua/lsp-status.nvim'

    -- use 'ray-x/lsp_signature.nvim'

    -- use 'RishabhRD/popfix'
    -- use 'RishabhRD/nvim-lsputils'

    use({
      "jose-elias-alvarez/null-ls.nvim",
      opt = true,
      setup = function()
        -- on_file_open("null-ls.nvim")
        require("kide.core.layz_load").async_load("null-ls.nvim")
      end,
      config = function()
        require("kide.plugins.config.null-ls")
      end,
      requires = { "nvim-lua/plenary.nvim" },
    })

    -- 主题
    -- use 'morhetz/gruvbox'
    use({
      "ellisonleao/gruvbox.nvim",
      opt = true,
      module = "gruvbox",
      setup = function()
        require("kide.core.layz_load").sync_load("gruvbox.nvim")
      end,
      config = function()
        require("kide.plugins.config.gruvbox")
      end,
    })
    -- use 'sainnhe/gruvbox-material'

    -- 文件管理
    use({
      "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons", -- optional, for file icon
      },

      opt = true,
      tag = "nightly",
      wants = "gruvbox.nvim",
      after = "gruvbox.nvim",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-tree.lua")
      end,
      config = function()
        require("kide.plugins.config.nvim-tree")
      end,
    })

    -- using packer.nvim
    use({
      "akinsho/bufferline.nvim",
      opt = true,
      tag = "v2.*",
      wants = "gruvbox.nvim",
      after = "gruvbox.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      setup = function()
        require("kide.core.layz_load").sync_load("bufferline.nvim")
      end,
      config = function()
        require("kide.plugins.config.bufferline")
      end,
    })

    -- treesitter (新增)
    use({
      "nvim-treesitter/nvim-treesitter",
      module = "nvim-treesitter",
      wants = "gruvbox.nvim",
      after = "gruvbox.nvim",
      run = ":TSUpdate",
      config = function()
        require("kide.plugins.config.nvim-treesitter")
      end,
    })
    use({
      "nvim-treesitter/nvim-treesitter-textobjects",
      opt = true,
      after = "nvim-treesitter",
      setup = function()
        require("kide.core.layz_load").sync_load("nvim-treesitter-textobjects")
      end,
    })
    use({
      "nvim-treesitter/nvim-treesitter-context",
      opt = true,
      after = "nvim-treesitter",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-treesitter-context")
      end,
      config = function()
        require("kide.plugins.config.nvim-treesitter-context")
      end,
    })

    -- java
    use({
      "mfussenegger/nvim-jdtls",
      opt = true,
      ft = "java",
      config = function()
        require("kide.lsp.java").init()
      end,
    })
    -- use 'NiYanhhhhh/lighttree-java'

    -- debug
    use({
      "mfussenegger/nvim-dap",
      opt = true,
      module = "dap",
    })
    use({
      "rcarriga/nvim-dap-ui",
      opt = true,
      module = "dapui",
      after = "nvim-dap",
    })
    use({
      "theHamsta/nvim-dap-virtual-text",
      after = "nvim-dap-ui",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-dap-virtual-text")
      end,
      config = function()
        require("kide.plugins.config.nvim-dap")
        require("kide.dap")
      end,
    })

    -- 搜索插件
    use({
      "nvim-telescope/telescope.nvim",
      opt = true,
      module = "telescope",
      wants = "gruvbox.nvim",
      after = "gruvbox.nvim",
      requires = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("kide.plugins.config.telescope")
      end,
    })
    use({
      "nvim-telescope/telescope-ui-select.nvim",
      after = "telescope.nvim",
      setup = function()
        require("kide.core.layz_load").async_load("telescope-ui-select.nvim")
      end,
      config = function()
        require("telescope").load_extension("ui-select")
      end,
    })
    use({
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
      after = "telescope.nvim",
      setup = function()
        require("kide.core.layz_load").async_load("telescope-fzf-native.nvim")
      end,
      config = function()
        require("telescope").load_extension("fzf")
      end,
    })
    use({
      "nvim-telescope/telescope-dap.nvim",
      after = "telescope.nvim",
      opt = true,
    })

    -- use 'GustavoKatel/telescope-asynctasks.nvim'
    -- use 'aloussase/telescope-gradle.nvim'
    -- use 'aloussase/telescope-mvnsearch'
    use({
      "LinArcX/telescope-env.nvim",
      opt = true,
      after = "telescope.nvim",
      setup = function()
        require("kide.core.layz_load").async_load("telescope-env.nvim")
      end,
      config = function()
        require("telescope").load_extension("env")
      end,
    })

    -- git
    use({
      "tpope/vim-fugitive",
      opt = true,
      cmd = { "Git" },
    })
    use({
      "sindrets/diffview.nvim",
      opt = true,
      module = "diffview",
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
    })
    use({
      "TimUntersberger/neogit",
      after = "diffview.nvim",
      opt = true,
      cmd = "Neogit",
      config = function()
        require("kide.plugins.config.neogit")
      end,
      requires = "nvim-lua/plenary.nvim",
    })

    -- LeaderF
    -- use 'Yggdroot/LeaderF'

    -- git edit 状态显示插件
    use({
      "lewis6991/gitsigns.nvim",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("gitsigns.nvim")
      end,
      requires = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("kide.plugins.config.gitsigns-nvim")
      end,
    })

    -- 浮动窗口插件
    -- use 'voldikss/vim-floaterm'
    -- use 'voldikss/LeaderF-floaterm'
    use({
      "akinsho/toggleterm.nvim",
      module = "toggleterm",
      opt = true,
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
    })

    -- 异步任务执行插件
    -- use 'skywind3000/asynctasks.vim'
    -- use 'skywind3000/asyncrun.vim'
    use({
      "jedrzejboczar/toggletasks.nvim",
      opt = true,
      after = "toggleterm.nvim",
      setup = function()
        require("kide.core.layz_load").async_load("toggletasks.nvim")
      end,
      requires = {
        "nvim-lua/plenary.nvim",
        "akinsho/toggleterm.nvim",
        "nvim-telescope/telescope.nvim",
      },
      config = function()
        require("kide.plugins.config.toggletasks")
      end,
    })

    -- 多光标插件
    use({
      "mg979/vim-visual-multi",
      opt = true,
      setup = function()
        -- on_file_open("vim-visual-multi")
        require("kide.core.layz_load").async_load("vim-visual-multi")
      end,
    })

    -- 状态栏插件
    -- use 'feline-nvim/feline.nvim'
    use({
      "nvim-lualine/lualine.nvim",
      opt = true,
      wants = "gruvbox.nvim",
      after = "gruvbox.nvim",
      setup = function()
        require("kide.core.layz_load").sync_load("lualine.nvim")
      end,
      config = function()
        require("kide.plugins.config.lualine")
      end,
    })

    -- blankline
    use({
      "lukas-reineke/indent-blankline.nvim",
      opt = true,
      setup = function()
        -- on_file_open("indent-blankline.nvim")
        require("kide.core.layz_load").async_load("indent-blankline.nvim")
      end,
      config = function()
        require("kide.plugins.config.indent-blankline")
      end,
    })

    -- <>()等匹配插件
    -- use({
    --   "andymass/vim-matchup",
    --   opt = true,
    --   after = "nvim-treesitter",
    --   setup = function()
    --     -- on_file_open("vim-matchup")
    --     require("kide.core.layz_load").async_load("vim-matchup")
    --   end,
    -- })
    -- 大纲插件
    -- use 'liuchengxu/vista.vim'
    use({
      "simrat39/symbols-outline.nvim",
      opt = true,
      cmd = { "SymbolsOutline" },
      config = function()
        require("kide.plugins.config.symbols-outline")
      end,
    })
    -- use {
    -- 'stevearc/aerial.nvim',
    -- }

    -- 消息通知
    use({
      "rcarriga/nvim-notify",
      opt = true,
      setup = function()
        require("kide.core.layz_load").sync_load("nvim-notify")
      end,
      config = function()
        require("kide.plugins.config.nvim-notify")
      end,
    })

    -- wildmenu 补全美化
    use({
      "gelguy/wilder.nvim",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("wilder.nvim")
      end,
      config = function()
        require("kide.plugins.config.wilder")
      end,
    })

    -- 颜色显示
    use({
      "norcalli/nvim-colorizer.lua",
      opt = true,
      setup = function()
        -- on_file_open("nvim-colorizer.lua")
        require("kide.core.layz_load").async_load("nvim-colorizer.lua")
      end,
      config = function()
        require("kide.plugins.config.nvim-colorizer")
      end,
    })

    use({
      "numToStr/Comment.nvim",
      opt = true,
      keys = { "gc", "gb" },
      config = function()
        require("kide.plugins.config.comment")
      end,
    })
    use({
      "danymat/neogen",
      opt = true,
      module = "neogen",
      config = function()
        require("kide.plugins.config.neogen")
      end,
    })

    -- mackdown 预览插件
    use({
      "iamcco/markdown-preview.nvim",
      opt = true,
      ft = "markdown",
      run = "cd app && yarn install",
      config = function()
        require("kide.plugins.config.markdown-preview")
      end,
    })
    -- mackdown cli 预览插件
    use({
      "ellisonleao/glow.nvim",
      opt = true,
      ft = "markdown",
      config = function()
        require("glow").setup({
          style = "dark",
          width = 120,
        })
      end,
    })

    -- 格式化插件 -> 使用 null-ls
    -- use 'mhartington/formatter.nvim'
    -- use 'sbdchd/neoformat'

    -- 快捷键查看
    use({
      "folke/which-key.nvim",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("which-key.nvim")
      end,
      config = function()
        require("kide.plugins.config.which-key")
      end,
    })

    -- 仪表盘
    -- use {'glepnir/dashboard-nvim'}
    use({
      "goolord/alpha-nvim",
      opt = true,
      requires = { "kyazdani42/nvim-web-devicons" },
      setup = function()
        require("kide.core.layz_load").sync_load("alpha-nvim")
      end,
      config = function()
        require("kide.plugins.config.alpha-nvim")
      end,
    })

    -- 翻译插件
    -- use 'voldikss/vim-translator'
    use({
      "uga-rosa/translate.nvim",
      opt = true,
      setup = function()
        -- on_file_open("translate.nvim")
        require("kide.core.layz_load").async_load("translate.nvim")
      end,
      config = function()
        require("kide.plugins.config.translate")
      end,
    })

    -- 自动对齐插件
    use({
      "junegunn/vim-easy-align",
      opt = true,
      setup = function()
        -- on_file_open("vim-easy-align")
        require("kide.core.layz_load").async_load("vim-easy-align")
      end,
    })

    -- 表格模式插件
    use({
      "dhruvasagar/vim-table-mode",
      opt = true,
      cmd = { "TableModeEnable" },
    })

    -- () 自动补全
    use({
      "windwp/nvim-autopairs",
      opt = true,
      after = "nvim-cmp",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-autopairs")
      end,
      config = function()
        require("kide.plugins.config.nvim-autopairs")
      end,
    })

    -- 任务插件
    use({
      "itchyny/calendar.vim",
      opt = true,
      cmd = {
        "Calendar",
      },
    })

    -- rust
    use({
      "simrat39/rust-tools.nvim",
      opt = true,
      module = "rust-tools",
    })

    -- use "Pocco81/AutoSave.nvim"

    use({
      "NTBBloodbath/rest.nvim",
      ft = "http",
      opt = true,
      requires = {
        "nvim-lua/plenary.nvim",
      },
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
    })

    -- 选中高亮插件
    use({
      "RRethy/vim-illuminate",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("vim-illuminate")
      end,
      config = function()
        require("kide.plugins.config.vim-illuminate")
      end,
    })

    -- 快速跳转
    use({
      "phaazon/hop.nvim",
      opt = true,
      branch = "v2",
      setup = function()
        -- on_file_open("hop.nvim")
        require("kide.core.layz_load").async_load("hop.nvim")
      end,
      config = function()
        require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
        require("kide.core.keybindings").hop_mapkey()
      end,
    })

    -- LSP 进度
    use({
      "j-hui/fidget.nvim",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("fidget.nvim")
      end,
      config = function()
        require("fidget").setup({})
      end,
    })

    -- 查找替换
    use({
      "windwp/nvim-spectre",
      opt = true,
      setup = function()
        -- on_file_open("nvim-spectre")
        require("kide.core.layz_load").async_load("nvim-spectre")
      end,
      config = function()
        require("spectre").setup()
      end,
    })

    -- ASCII 图
    use({
      "jbyuki/venn.nvim",
      opt = true,
      cmd = { "VBox" },
    })

    use({
      "tversteeg/registers.nvim",
      opt = true,
      cmd = { "Registers" },
      keys = '"',
    })

    -- databases
    use({
      "nanotee/sqls.nvim",
      ft = { "sql", "mysql" },
      opt = true,
    })
    use({
      "tpope/vim-dadbod",
      opt = true,
    })
    use({
      "kristijanhusak/vim-dadbod-ui",
      opt = true,
      wants = "vim-dadbod",
      after = "vim-dadbod",
      cmd = {
        "DBUI",
        "DBUIToggle",
      },
      setup = function()
        require("kide.plugins.config.vim-dadbod")
      end,
    })

    -- 项目管理
    use({
      "ahmedkhalf/project.nvim",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("project.nvim")
      end,
      config = function()
        require("project_nvim").setup({})
        require("telescope").load_extension("projects")
      end,
    })

    use({
      "aklt/plantuml-syntax",
      opt = true,
      ft = "plantuml",
    })

    -- UI 美化
    -- use({
    --   "stevearc/dressing.nvim",
    --   opt = true,
    --   module = "dressing",
    --   config = function()
    --     require("kide.plugins.config.dressing-nvim")
    --   end,
    -- })

    -- 浏览器搜索
    use({
      "lalitmee/browse.nvim",
      opt = true,
      cmd = {
        "Browse",
      },
      config = function()
        require("kide.plugins.config.browse-nvim")
      end,
    })

    -- 环绕输入
    use({
      "kylechui/nvim-surround",
      opt = true,
      setup = function()
        require("kide.core.layz_load").async_load("nvim-surround")
      end,
      config = function()
        require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
        })
      end,
    })

    --  Create custom submodes and menus
    use({
      "anuvyklack/hydra.nvim",
      opt = true,
      module = "hydra",
    })

    -- 代码状态栏导航
    use({
      "SmiteshP/nvim-navic",
      opt = true,
      module = "nvim-navic",
      config = function()
        require("kide.plugins.config.nvim-navic")
      end,
    })

    -- markdown 背景设置
    -- use({
    --   "lukas-reineke/headlines.nvim",
    --   opt = true,
    --   ft = { "markdown", "norg", "org" },
    --   config = function()
    --     require("headlines").setup()
    --   end,
    -- })

    -- 笔记
    use({
      "mickael-menu/zk-nvim",
      opt = true,
      cmd = {
        "ZkIndex",
        "ZkNew",
        "ZkNotes",
      },
      config = function()
        require("kide.plugins.config.zk-nvim")
      end,
    })

    -- 折叠
    use({
      "kevinhwang91/promise-async",
      opt = true,
      module = "promise",
    })
    use({
      "kevinhwang91/nvim-ufo",
      opt = true,
      require = "kevinhwang91/promise-async",
      after = "promise-async",
      setup = function()
        require("kide.core.layz_load").async_load("nvim-ufo")
      end,
      config = function()
        require("kide.plugins.config.nvim-ufo")
      end,
    })

    if bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
    max_jobs = 10,
  },
})

vim.schedule(function()
  require("kide.core.keybindings").setup()
end)
