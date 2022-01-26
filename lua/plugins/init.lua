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

	-- 主题
	use 'morhetz/gruvbox'


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

    use {
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim'
      },
      -- tag = 'release' -- To use the latest release
    }
end)

require('plugins/config/bufferline')
require('plugins/config/nvim-tree')
require('plugins/config/nvim-treesitter')
require('plugins/config/nvim-cmp')
require('plugins/config/LeaderF')
require('plugins/config/gitsigns-nvim')
