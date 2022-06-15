require('plugins/config/symbols-outline')
require('packer').startup({ function()


  use { 'nvim-lua/plenary.nvim' }
  use { 'lewis6991/impatient.nvim' }
  use { 'nathom/filetype.nvim' }
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use { 'neovim/nvim-lspconfig', 'williamboman/nvim-lsp-installer' }

  use 'kyazdani42/nvim-web-devicons'

  -- nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp' -- { name = nvim_lsp }
  use 'hrsh7th/cmp-buffer' -- { name = 'buffer' },
  use 'hrsh7th/cmp-path' -- { name = 'path' }
  -- use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }
  use 'hrsh7th/nvim-cmp'

  -- vsnip
  -- use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
  -- use 'hrsh7th/vim-vsnip'

  -- 代码片段
  use 'rafamadriz/friendly-snippets'
  -- LuaSnip
  use 'L3MON4D3/LuaSnip'
  use { 'saadparwaiz1/cmp_luasnip' }

  -- lspkind
  use 'onsails/lspkind-nvim'

  -- lsp 相关
  -- use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'

  -- java 不友好
  -- use 'glepnir/lspsaga.nvim'
  -- use 'arkav/lualine-lsp-progress'
  -- use 'nvim-lua/lsp-status.nvim'

  -- use 'ray-x/lsp_signature.nvim'

  -- use 'RishabhRD/popfix'
  -- use 'RishabhRD/nvim-lsputils'

  use({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("null-ls").setup()
    end,
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- 主题
  -- use 'morhetz/gruvbox'
  use { "ellisonleao/gruvbox.nvim" }
  -- use 'sainnhe/gruvbox-material'


  -- 文件管理
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    }
  }

  -- using packer.nvim
  use { 'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons' }


  -- treesitter (新增)
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- java
  use 'mfussenegger/nvim-jdtls'
  -- use 'NiYanhhhhh/lighttree-java'

  -- debug
  use 'mfussenegger/nvim-dap'
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use 'theHamsta/nvim-dap-virtual-text'

  -- git
  use 'tpope/vim-fugitive'

  -- LeaderF
  -- use 'Yggdroot/LeaderF'

  -- git edit 状态显示插件
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
  }

  -- 异步任务执行插件
  use 'skywind3000/asynctasks.vim'
  use 'skywind3000/asyncrun.vim'

  -- 浮动窗口插件
  -- use 'voldikss/vim-floaterm'
  -- use 'voldikss/LeaderF-floaterm'
  use { "akinsho/toggleterm.nvim", tag = 'v2.*', config = function()
    require("toggleterm").setup()
  end }

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
  -- use 'liuchengxu/vista.vim'
  use 'simrat39/symbols-outline.nvim'

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
  use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' }
  -- mackdown cli 预览插件
  use {"ellisonleao/glow.nvim", branch = 'main'}

  -- 格式化插件
  use 'mhartington/formatter.nvim'
  -- use 'sbdchd/neoformat'


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
    requires = {
      'nvim-lua/plenary.nvim'
    },
  }
  use { 'nvim-telescope/telescope-ui-select.nvim' }
  -- use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'nvim-telescope/telescope-dap.nvim' }

  use 'GustavoKatel/telescope-asynctasks.nvim'
  -- use 'aloussase/telescope-gradle.nvim'
  -- use 'aloussase/telescope-mvnsearch'
  use { "LinArcX/telescope-env.nvim" }



  -- 仪表盘
  -- use {'glepnir/dashboard-nvim'}
  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
  }

  -- 翻译插件
  -- use 'voldikss/vim-translator'
  use 'uga-rosa/translate.nvim'

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

  use "Pocco81/AutoSave.nvim"


  use {
    "NTBBloodbath/rest.nvim",
    requires = {
      'nvim-lua/plenary.nvim'
    },
  }

  -- 选中高亮插件
  use "RRethy/vim-illuminate"

  -- 快速跳转
  use {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  }

  -- LSP 进度
  use { 'j-hui/fidget.nvim',
    config = function()
      require "fidget".setup {}
    end
  }

  -- 查找替换
  use { 'windwp/nvim-spectre',
    config = function()
      require('spectre').setup()
    end
  }

  -- ASCII 图
  use 'jbyuki/venn.nvim'

  use "tversteeg/registers.nvim"
end,
config = {
  display = {
    open_fn = require('packer.util').float,
  }
} })


require('plugins/config/bufferline')
require('plugins/config/indent-blankline')
-- require('plugins/config/dashboard-nvim')
require('plugins/config/alpha-nvim')
require('plugins/config/lualine')
require('plugins/config/nvim-tree')
require('plugins/config/vim-illuminate')
-- 异步加载
vim.defer_fn(function()
  require('plugins/config/nvim-treesitter')

  require('plugins/config/luasnip')
  require('plugins/config/nvim-cmp')
  -- require('plugins/config/LeaderF')
  require('plugins/config/gitsigns-nvim')
  -- require('plugins/config/vim-floaterm')
  require('plugins/config/asynctasks')
  -- require('plugins/config/feline')
  -- require('plugins/config/vista')
  -- require('plugins/config/lsp-colors')
  require('plugins/config/trouble')
  require('plugins/config/nvim-notify')
  require('plugins/config/wilder')
  require('plugins/config/nvim-colorizer')
  require('plugins/config/comment')
  -- require('plugins/config/lspsaga')
  require('plugins/config/formatter')
  require('plugins/config/telescope')
  -- require('plugins/config/nvim-lsputils')
  require('plugins/config/nvim-autopairs')
  -- require('plugins/config/lsp_signature')
  require('plugins/config/nvim-dap')
  require('plugins/config/markdown-preview')
  require('plugins/config/translate')
  require('plugins/config/autosave')
  -- require('plugins/config/nvim-neorg')
  vim.cmd [[
function! s:http_rest_init() abort
  lua require('plugins/config/rest-nvim')
  lua require('core.keybindings').rest_nvim()
endfunction
augroup http_rest
    autocmd!
    autocmd FileType http call s:http_rest_init()
augroup end
]]

  require('core.keybindings').setup()
end, 0)
