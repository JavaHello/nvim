require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig', 'williamboman/nvim-lsp-installer'}

  use 'kyazdani42/nvim-web-devicons'

  -- nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp' -- { name = nvim_lsp }
  use 'hrsh7th/cmp-buffer'   -- { name = 'buffer' },
  use 'hrsh7th/cmp-path'     -- { name = 'path' }
  use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }
  use 'hrsh7th/nvim-cmp'

  -- vsnip
  use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'
  -- lspkind
  use 'onsails/lspkind-nvim'
  -- use 'glepnir/lspsaga.nvim'

  -- lsp 相关
  use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'


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
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}

  -- 格式化插件
  -- use 'mhartington/formatter.nvim'
  use 'sbdchd/neoformat'

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

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use { 
    'glepnir/dashboard-nvim',
  }

end)

require('plugins/config/bufferline')
require('plugins/config/nvim-tree')
require('plugins/config/nvim-treesitter')
require('plugins/config/nvim-cmp')
require('plugins/config/LeaderF')
require('plugins/config/gitsigns-nvim')
require('plugins/config/vim-floaterm')
require('plugins/config/asynctasks')
-- require('plugins/config/feline')
require('plugins/config/lualine')
require('plugins/config/indent-blankline')
require('plugins/config/vista')
require('plugins/config/lsp-colors')
require('plugins/config/trouble')
require('plugins/config/nvim-notify')
require('plugins/config/wilder')
require('plugins/config/nvim-colorizer')
require('plugins/config/comment')
-- require('plugins/config/lspsaga')
-- require('plugins/config/formatter')
require('plugins/config/telescope')
require('plugins/config/dashboard-nvim')

