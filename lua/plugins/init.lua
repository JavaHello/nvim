return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
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
  -- LSP progress messages
  {
    "j-hui/fidget.nvim",
    event = { "VeryLazy" },
    opts = {
      -- options
    },
  },
  -- cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "rcarriga/cmp-dap", "hrsh7th/cmp-cmdline" },
    },
    keys = { ":", "/", "?" },
    opts = {
      enabled = function()
        return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end,
      completion = {
        completeopt = "menu,menuone",
      },
    },
    config = function(_, opts)
      local cmp = require "cmp"
      opts.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }
      cmp.setup(opts)
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })
      cmp.setup.cmdline({ "/", "?" }, {
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },

  -- java
  {
    "mfussenegger/nvim-jdtls",
  },
  {
    "JavaHello/spring-boot.nvim",
    dependencies = {
      "mfussenegger/nvim-jdtls",
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
      -- dap.listeners.after.event_terminated["dapui_config"] = function()
      -- dap.repl.close()
      -- end
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
    opts = {
      keymaps = {
        view = {
          ["q"] = function()
            vim.cmd "tabclose"
          end,
        },
        file_panel = {
          ["q"] = function()
            vim.cmd "tabclose"
          end,
        },
        file_history_panel = {
          ["q"] = function()
            vim.cmd "tabclose"
          end,
        },
      },
    },
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
    enabled = vim.env["GP_CHAT_ENABLE"] == "Y",
    cmd = {
      "GpNew",
      "GpChatNew",
      "GpChatToggle",
    },
    opts = {
      providers = {
        openai = {
          endpoint = vim.env["OPENAI_API_ENDPOINT"],
          secret = vim.env["OPENAI_API_KEY"],
        },
      },
      cmd_prefix = "Gp",
      chat_topic_gen_model = "deepseek-chat",
      agents = {
        {
          name = "DeepseekChat",
          chat = true,
          command = false,
          model = { model = "deepseek-chat", temperature = 1.0, top_p = 1 },
          system_prompt = "You are a general AI assistant.\n\n"
            .. "The user provided the additional info about how they would like you to respond:\n\n"
            .. "- If you're unsure don't guess and say you don't know instead.\n"
            .. "- Ask question if you need clarification to provide better answer.\n"
            .. "- Think deeply and carefully from first principles step by step.\n"
            .. "- Zoom out first to see the big picture and then zoom in to details.\n"
            .. "- Use Socratic method to improve your thinking and coding skills.\n"
            .. "- Don't elide any code from your output if the answer requires coding.\n"
            .. "- Take a deep breath; You've got this!\n",
        },
      },
    },
    config = function(_, opts)
      require("gp").setup(opts)
    end,
  },

  -- rust
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, buffer)
            -- 配色方案错误, 禁用 semanticTokensProvider
            client.server_capabilities.semanticTokensProvider = nil
            require("nvchad.configs.lspconfig").on_attach(client, buffer)
            vim.keymap.set("n", "<leader>ca", function()
              vim.cmd.RustLsp "codeAction"
            end, { silent = true, buffer = buffer, desc = "Rust Code Action" })
          end,
        },
        tools = {
          hover_actions = {
            replace_builtin_hover = false,
          },
        },
      }
    end,
  },

  -- copilot
  {
    "github/copilot.vim",
    enabled = vim.env["COPILOT_ENABLE"] == "Y",
    lazy = false,
    config = function()
      vim.g.copilot_enabled = true
      vim.g.copilot_no_tab_map = true
      vim.cmd 'imap <silent><script><expr> <C-C> copilot#Accept("")'
      vim.cmd [[
			let g:copilot_filetypes = {
	       \ 'TelescopePrompt': v:false,
	     \ }
			]]
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true,
      mappings = {
        close = {
          insert = "",
        },
      },
    },
  },

  -- 翻译插件
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    config = function()
      require("translate").setup {
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
      }
    end,
  },

  -- databases
  {
    "tpope/vim-dadbod",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
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
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("kide_vim_dadbod_completion", { clear = true }),
        pattern = { "sql", "mysql", "plsql" },
        callback = function(_)
          require("cmp").setup.buffer { sources = { { name = "vim-dadbod-completion" } } }
        end,
      })
    end,
    config = function() end,
  },

  -- bqf
  {
    "kevinhwang91/nvim-bqf",
    enabled = true,
    ft = "qf",
    opts = {
      preview = {
        auto_preview = true,
      },
      filter = {
        fzf = {
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
        },
      },
    },
  },
  {
    "huggingface/llm.nvim",
    enabled = vim.env["LLM_NVIM_ENABLE"] == "Y",
    event = "VeryLazy",
    opts = {
      api_token = vim.env["LLM_NVIM_TOKEN"], -- cf Install paragraph
      model = vim.env["LLM_NVIM_MODEL"], -- the model ID, behavior depends on backend
      backend = vim.env["LLM_NVIM_BACKEND"],
      accept_keymap = "<C-c>",
      dismiss_keymap = "<C-e>",
      url = vim.env["LLM_NVIM_URL"],
      disable_url_path_completion = true,
      request_body = {
        parameters = {
          -- max_new_tokens = 60,
          temperature = 1,
          top_p = 1,
        },
      },
      lsp = {
        bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
      },
    },
  },
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod" },
    config = function()
      require("go").setup()
    end,
  },
  {
    "NStefan002/screenkey.nvim",
    cmd = {
      "Screenkey",
    },
    version = "*",
  },
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  -- ASCII 图
  {
    "jbyuki/venn.nvim",
    lazy = true,
    cmd = { "VBox" },
  },
  {
    "windwp/nvim-ts-autotag",
    -- event = { "BufReadPre", "BufNewFile" },
    ft = { "html" },
    config = function()
      require("nvim-ts-autotag").setup {}
    end,
  },
  -- 更好的生成注释
  {
    "danymat/neogen",
    event = "VeryLazy",
    config = function()
      require("neogen").setup { snippet_engine = "luasnip" }
    end,
  },

  -- 快速选择
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
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  {
    "Civitasv/cmake-tools.nvim",
    cmd = {
      "CMakeRun",
      "CMakeDebug",
      "CMakeRunTest",
    },
    opts = {
      cmake_build_directory = "build", -- this is used to specify generate directory for cmake, allows macro expansion
    },
  },
}
