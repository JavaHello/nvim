require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig', 'williamboman/nvim-lsp-installer'}

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
  use 'feline-nvim/feline.nvim'

  -- blankline
  use "lukas-reineke/indent-blankline.nvim"

  -- <>()等匹配插件
  use 'andymass/vim-matchup'
  -- 大纲插件
  use 'liuchengxu/vista.vim'

end)

require('plugins/config/bufferline')
require('plugins/config/nvim-tree')
require('plugins/config/nvim-treesitter')
require('plugins/config/nvim-cmp')
require('plugins/config/LeaderF')
require('plugins/config/gitsigns-nvim')
require('plugins/config/vim-floaterm')
require('plugins/config/asynctasks')
require('plugins/config/feline')
require('plugins/config/indent-blankline')
require('plugins/config/vista')
