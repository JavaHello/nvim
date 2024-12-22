local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.8
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
    opts = {
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      view = {
        signcolumn = "no",
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * WIDTH_RATIO
            local window_h = screen_h * HEIGHT_RATIO
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
        width = function()
          return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
        end,
      },
    },
  },
  {
    "folke/which-key.nvim",
    enabled = false,
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
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },

        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
        kind_icons = require "nvchad.icons.lspkind",
      },
      sources = {
        completion = {
          enabled_providers = { "lsp", "path", "snippets", "buffer", "dadbod", "daprepl" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          daprepl = { name = "DapRepl", module = "kide.cmp.dap" },
        },
      },
      completion = {
        menu = {
          border = "rounded",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
          update_delay_ms = 50,
          window = {
            min_width = 10,
            max_width = 60,
            max_height = 20,
            border = "rounded",
          },
        },
      },
    },
    opts_extend = { "sources.completion.enabled_providers" },
    config = function(_, opts)
      require("blink.cmp").setup(opts)
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "mfussenegger/nvim-fzy",
    config = function()
      local fzy = require "fzy"
      fzy.new_popup = function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_keymap(buf, "t", "<ESC>", "<C-\\><C-c>", {})
        vim.bo[buf].bufhidden = "wipe"
        local columns = vim.o.columns
        local lines = vim.o.lines
        local width = math.floor(columns * 0.8)
        local height = math.floor(lines * 0.8)
        local opts = {
          relative = "editor",
          style = "minimal",
          row = math.floor((lines - height) * 0.5),
          col = math.floor((columns - width) * 0.5),
          width = width,
          height = height,
          border = "rounded",
        }
        local win = vim.api.nvim_open_win(buf, true, opts)
        return win, buf
      end
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
    "JavaHello/quarkus.nvim",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "JavaHello/microprofile.nvim",
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
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = {
      "mfussenegger/nvim-fzy",
    },
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension "ui-select"
    end,
  },
  {
    "nvim-telescope/telescope-fzy-native.nvim",
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension "fzy_native"
    end,
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
    "hedyhli/outline.nvim",
    cmd = {
      "Outline",
    },
    opts = {
      symbols = {
        icon_fetcher = function(k)
          return require("nvchad.icons.lspkind")[k]
        end,
      },
      providers = {
        lsp = {
          blacklist_clients = { "spring-boot" },
        },
      },
    },
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
          endpoint = vim.env["DEEPSEEK_API_ENDPOINT"],
          secret = vim.env["DEEPSEEK_API_KEY"],
        },
      },
      cmd_prefix = "Gp",
      chat_topic_gen_model = "deepseek-chat",
      agents = {
        {
          name = "DeepseekChat",
          chat = true,
          command = false,
          model = { model = "deepseek-chat", temperature = 1.3, top_p = 1 },
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
        {
          name = "DeepseekCoder",
          chat = false,
          command = true,
          model = { model = "deepseek-coder", temperature = 0.0, top_p = 1 },
          system_prompt = "You are an AI working as a code editor.\n\n"
            .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
            .. "START AND END YOUR ANSWER WITH:\n\n```",
        },
      },
      hooks = {
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by writing table driven unit tests for the code above."
          local agent = gp.get_command_agent "DeepseekCoder"
          gp.Prompt(params, gp.Target.vnew, agent, template)
        end,
      },
    },
    config = function(_, opts)
      require("gp").setup(opts)
    end,
  },

  -- rust
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
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

  -- 翻译插件
  {
    "uga-rosa/translate.nvim",
    -- see ai.translate
    enabled = false,
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
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "tpope/vim-dadbod" },
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
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
    ft = { "html" },
    config = function()
      require("nvim-ts-autotag").setup {}
    end,
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
      cmake_runner = {
        name = "overseer",
      },
    },
  },

  {
    "stevearc/overseer.nvim",
    event = "VeryLazy",
    opts = {
      task_list = {
        min_height = 16,
      },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      require("overseer").register_template {
        name = "Maven",
        params = function()
          return {
            subcommand = {
              desc = "Maven subcommand",
              type = "list",
              delimiter = " ",
              subtype = {
                type = "enum",
                choices = {
                  "clean",
                  "compile",
                  "package",
                  "install",
                  "test",
                  "verify",
                  "deploy",
                  "dependency:tree",
                  "-DskipTests",
                  "-Dmaven.test.skip=true",
                },
              },
            },
          }
        end,
        builder = function(params)
          local maven = require "kide.core.utils.maven"
          local settings = maven.get_maven_settings()
          local file = vim.fn.expand "%"
          local cmd = { "mvn" }
          vim.list_extend(cmd, params.subcommand)
          if settings then
            table.insert(cmd, "-s")
            table.insert(cmd, settings)
          end
          if maven.is_pom_file(file) then
            table.insert(cmd, "-f")
            table.insert(cmd, file)
          end
          return {
            cmd = cmd,
          }
        end,
        condition = {
          filetype = { "java", "xml" },
          callback = function(param)
            if param.filetype == "xml" then
              local maven = require "kide.core.utils.maven"
              return maven.is_pom_file(vim.fn.expand "%")
            end
            return true
          end,
        },
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    opts = {
      enabled = true,
      file_types = { "markdown", "Avante" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "JavaHello/java-deps.nvim",
    ft = "java",
    config = function()
      require("java-deps").setup {}
    end,
  },
  {
    "rest-nvim/rest.nvim",
    enabled = vim.env["REST_NVIM_ENABLE"] == "Y",
    ft = "http",
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    enabled = vim.env["AVANTE_NVIM_ENABLE"] == "Y",
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local opts = {
        provider = "deepseek",
        vendors = {
          ---@class AvanteProviderFunctor
          deepseek = {
            endpoint = "https://api.deepseek.com/chat/completions",
            model = "deepseek-coder",
            api_key_name = "DEEPSEEK_API_KEY",
            parse_curl_args = function(opts, code_opts)
              return {
                url = opts.endpoint,
                headers = {
                  ["Accept"] = "application/json",
                  ["Content-Type"] = "application/json",
                  ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
                },
                body = {
                  model = opts.model,
                  messages = {
                    { role = "system", content = code_opts.system_prompt },
                    { role = "user", content = table.concat(code_opts.user_prompts, "\n") },
                  },
                  temperature = 0,
                  max_tokens = 4096,
                  stream = true,
                },
              }
            end,
            parse_response_data = function(data_stream, event_state, opts)
              require("avante.providers").copilot.parse_response(data_stream, event_state, opts)
            end,
          },
        },
      }
      require("avante").setup(opts)
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    cmd = { "PasteImage" },
    opts = {},
  },
}
