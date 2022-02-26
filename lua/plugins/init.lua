require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig', 'williamboman/nvim-lsp-installer'}

  use 'kyazdani42/nvim-web-devicons'

  -- nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp' -- { name = nvim_lsp }
  use 'hrsh7th/cmp-buffer'   -- { name = 'buffer' },
  use 'hrsh7th/cmp-path'     -- { name = 'path' }
  -- use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }
  use 'hrsh7th/nvim-cmp'

  -- vsnip
  -- use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
  -- use 'hrsh7th/vim-vsnip'

  use 'rafamadriz/friendly-snippets'
  -- LuaSnip
  use 'L3MON4D3/LuaSnip'
  use { 'saadparwaiz1/cmp_luasnip' }

  -- lspkind
  use 'onsails/lspkind-nvim'

  -- lsp 相关
  -- use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'
  use 'glepnir/lspsaga.nvim'

  -- use 'ray-x/lsp_signature.nvim'

  -- use 'RishabhRD/popfix'
  -- use 'RishabhRD/nvim-lsputils'

  -- 主题
  use 'morhetz/gruvbox'


  -- 文件管理
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    }
  }

  -- using packer.nvim
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}


  -- treesitter (新增)
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- java
  use 'mfussenegger/nvim-jdtls'
  use 'NiYanhhhhh/lighttree-java'

  -- debug
  use 'mfussenegger/nvim-dap'
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

  -- git
  use 'tpope/vim-fugitive'

  -- LeaderF
  use 'Yggdroot/LeaderF'

  -- git edit 状态显示插件
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    -- tag = 'release' -- To use the latest release
  }

  -- 异步任务执行插件
  use 'skywind3000/asynctasks.vim'
  use 'skywind3000/asyncrun.vim'

  -- 浮动窗口插件
  use 'voldikss/vim-floaterm'
  use 'voldikss/LeaderF-floaterm'

  -- 多光标插件
  use 'mg979/vim-visual-multi'

  -- 状态栏插件
  -- use 'feline-nvim/feline.nvim'
  use {
  'nvim-lualine/lualine.nvim',
  }

  -- blankline
  use "lukas-reineke/indent-blankline.nvim"

  -- <>()等匹配插件
  use 'andymass/vim-matchup'
  -- 大纲插件
  use 'liuchengxu/vista.vim'

  -- 消息通知
  use 'rcarriga/nvim-notify'

  -- wildmenu 补全美化
  use 'gelguy/wilder.nvim'

  -- 颜色显示
  use 'norcalli/nvim-colorizer.lua'

  use {
    'numToStr/Comment.nvim',
  }

  -- mackdown 预览插件
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install'}

  -- 格式化插件
  -- use 'mhartington/formatter.nvim'
  use 'sbdchd/neoformat'


  -- 快捷键查看
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- 搜索插件
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-ui-select.nvim' }

  -- 仪表盘
  use {'glepnir/dashboard-nvim'}

  -- 翻译插件
  use 'voldikss/vim-translator'

  -- 自动对齐插件
  use 'junegunn/vim-easy-align'

  -- 表格模式插件
  use 'dhruvasagar/vim-table-mode'

  -- () 自动补全
  use 'windwp/nvim-autopairs'

  -- 任务插件
  use 'itchyny/calendar.vim'

  -- rust
  use 'simrat39/rust-tools.nvim'
end)

require('plugins/config/bufferline')
require('plugins/config/nvim-tree')
require('plugins/config/nvim-treesitter')

require('plugins/config/luasnip')
require('plugins/config/nvim-cmp')
require('plugins/config/LeaderF')
require('plugins/config/gitsigns-nvim')
require('plugins/config/vim-floaterm')
require('plugins/config/asynctasks')
-- require('plugins/config/feline')
require('plugins/config/lualine')
require('plugins/config/indent-blankline')
require('plugins/config/vista')
-- require('plugins/config/lsp-colors')
require('plugins/config/trouble')
require('plugins/config/nvim-notify')
require('plugins/config/wilder')
require('plugins/config/nvim-colorizer')
require('plugins/config/comment')
require('plugins/config/lspsaga')
-- require('plugins/config/formatter')
require('plugins/config/telescope')
require('plugins/config/dashboard-nvim')
-- require('plugins/config/nvim-lsputils')
require('plugins/config/nvim-autopairs')
-- require('plugins/config/lsp_signature')
require('plugins/config/nvim-dap')
require('plugins/config/markdown-preview')
require('plugins/config/rust-tools')

