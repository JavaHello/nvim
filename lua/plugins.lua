local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.8
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({

        ensure_installed = { "lua", "luadoc", "printf", "vim", "vimdoc" },
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },

        indent = { enable = true },
      })
    end,
  },
  {
    "nvimdev/indentmini.nvim",
    event = "BufRead",
    config = function()
      require("indentmini").setup({
        exclude = { "markdown", "text" },
      })
      vim.api.nvim_set_hl(0, "IndentLine", { fg = "#3e3e3e" })
      vim.api.nvim_set_hl(0, "IndentLineCurrent", { fg = "#fb4934" })
    end,
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ui = {
        icons = {
          package_pending = " ",
          package_installed = " ",
          package_uninstalled = " ",
        },
      },

      max_concurrent_installers = 10,
    },
  },
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        sql = { "sql_formatter" },
        python = { "black" },
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {

      filters = { dotfiles = false },
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
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

      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            default = "󰈚",
            folder = {
              default = "",
              empty = "",
              empty_open = "",
              open = "",
              symlink = "",
            },
            git = { unmerged = "" },
          },
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        delete = { text = "󰍵" },
        changedelete = { text = "" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("kide.melspconfig").init_lsp_clients()
    end,
  },
  {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
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
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "dadbod",
          -- "daprepl",
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          -- daprepl = { name = "DapRepl", module = "kide.cmp.dap" },
        },
        cmdline = {},
      },
      completion = {
        menu = {
          border = "rounded",
          draw = {
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return require("kide.lspkind").symbol_map[ctx.kind].icon
                end,
                highlight = function(ctx)
                  return require("kide.lspkind").symbol_map[ctx.kind].hl
                end,
              },
            },
          },
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
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
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
    config = false,
  },
  {
    "JavaHello/quarkus.nvim",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "JavaHello/microprofile.nvim",
    },
  },
  {
    "JavaHello/java-deps.nvim",
    config = function()
      require("java-deps").setup({})
    end,
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
      local dap = require("dap")
      require("nvim-dap-virtual-text")

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
      require("nvim-dap-virtual-text").setup({})
    end,
  },

  -- python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local function get_python_path()
        if vim.env.VIRTUAL_ENV then
          if vim.fn.has("nvim-0.10") == 1 then
            return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
          end
          return vim.env.VIRTUAL_ENV .. "/bin" .. "/python"
        end
        if vim.env.PY_BIN then
          return vim.env.PY_BIN
        end
        local python = vim.fn.exepath("python3")
        if python == nil or python == "" then
          python = vim.fn.exepath("python")
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
            vim.cmd("tabclose")
          end,
        },
        file_panel = {
          ["q"] = function()
            vim.cmd("tabclose")
          end,
        },
        file_history_panel = {
          ["q"] = function()
            vim.cmd("tabclose")
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
      require("zk").setup({
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
      })
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
          return require("kide.icons")[k]
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
    init = function()
      vim.g.mkdp_page_title = "${name}"
    end,
    config = function() end,
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
            require("kide.melspconfig").on_attach(client, buffer)
            vim.keymap.set("n", "<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
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
    config = function()
      require("bqf").setup({
        preview = {
          auto_preview = true,
          should_preview_cb = function(pbufnr, win)
            local fname = vim.fn.bufname(pbufnr)
            if vim.startswith(fname, "jdt://") then
              -- 未加载时不预览
              return vim.fn.bufloaded(pbufnr) == 1
            end
            return true
          end,
        },
        filter = {
          fzf = {
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
          },
        },
      })
    end,
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
      require("nvim-ts-autotag").setup({})
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
    },
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
    "HakonHarnes/img-clip.nvim",
    cmd = { "PasteImage" },
    opts = {},
  },
}
