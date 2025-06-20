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
            local max_filesize = 1024 * 1024 -- 1MB
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
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "stevearc/conform.nvim",
    lazy = false,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "jq" },
        json5 = { "prettier" },
        markdown = { "prettier" },
        sql = { "sql_formatter" },
        python = { "black" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        toml = { "taplo" },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      signs = {
        delete = { text = "󰍵" },
        changedelete = { text = "" },
      },
    },
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
      },
      cmdline = {
        keymap = {
          preset = "enter",
          ["<Tab>"] = {
            "show",
            "select_next",
            "fallback",
          },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          -- Search forward and backward
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          -- Commands
          if type == ":" or type == "@" then
            return { "cmdline" }
          end
          return {}
        end,
      },
      completion = {
        menu = {
          auto_show = function(ctx)
            return ctx.mode ~= "cmdline"
          end,
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
    opts_extend = { "sources.default" },
    config = function(_, opts)
      require("blink.cmp").setup(opts)
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "mfussenegger/nvim-lint",
    lazy = true,
  },
  -- java
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
  },
  {
    "JavaHello/spring-boot.nvim",
    enabled = vim.g.enable_spring_boot == true,
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    config = false,
  },
  {
    "JavaHello/java-deps.nvim",
    lazy = true,
    config = function()
      require("java-deps").setup({})
    end,
  },
  {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
    lazy = false,
    enabled = vim.env["SONARLINT_ENABLE"] == "Y",
    config = function()
      require("kide.lsp.sonarlint").setup()
    end,
  },
  {
    "JavaHello/microprofile.nvim",
    enabled = vim.g.enable_quarkus == true,
    lazy = true,
    config = function()
      require("microprofile").setup({
        ls_path = vim.env["NVIM_MICROPROFILE_LS_PATH"],
        jdt_extensions_path = vim.env["NVIM_MICROPROFILE_JDT_EXTENSIONS_PATH"],
      })
    end,
  },
  {
    "JavaHello/quarkus.nvim",
    enabled = vim.g.enable_quarkus == true,
    ft = { "java", "yaml", "jproperties", "html" },
    dependencies = {
      "JavaHello/microprofile.nvim",
      "mfussenegger/nvim-jdtls",
    },
    config = function()
      require("quarkus").setup({
        ls_path = vim.env["NVIM_QUARKUS_LS_PATH"],
        jdt_extensions_path = vim.env["NVIM_QUARKUS_JDT_EXTENSIONS_PATH"],
        microprofile_ext_path = vim.env["NVIM_QUARKUS_MICROPROFILE_EXT_PATH"],
      })
    end,
  },
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },

  -- dap
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = { "theHamsta/nvim-dap-virtual-text" },
    config = function()
      local dap = require("dap")
      dap.defaults.fallback.focus_terminal = true
      require("nvim-dap-virtual-text").setup({})
      -- dap.listeners.after.event_initialized["dapui_config"] = function()
      --   dap.repl.open()
      -- end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    config = false,
  },

  -- python
  {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap" },
    config = false,
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
        picker = "select",
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

  -- databases
  {
    "tpope/vim-dadbod",
    lazy = true,
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
    ft = "qf",
    config = function()
      require("bqf").setup({
        preview = {
          auto_preview = true,
          should_preview_cb = function(pbufnr, _)
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
    "NStefan002/screenkey.nvim",
    cmd = {
      "Screenkey",
    },
    version = "*",
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
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {},
  },
  {
    "HakonHarnes/img-clip.nvim",
    cmd = { "PasteImage" },
    opts = {},
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      styles = {
        input = {
          relative = "cursor",
          row = 1,
          col = 0,
          keys = {
            i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
          },
        },
      },
      bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = {
        enabled = true,
        filter = function(buf)
          -- return not vim.g.snacks_indent
          --   and not vim.b[buf].snacks_indent
          --   and vim.bo[buf].buftype == ""
          local ft = vim.bo[buf].filetype
          if
            ft == "snacks_picker_preview"
            or ft == "snacks_picker_list"
            or ft == "snacks_picker_input"
            or ft == "Outline"
            or ft == "JavaProjects"
            or ft == "text"
            or ft == ""
            or ft == "lazy"
            or ft == "help"
            or ft == "markdown"
          then
            return false
          end
          return true
        end,
      },
      input = { enabled = true },
      picker = {
        enabled = true,
        layout = {
          cycle = false,
          preset = "dropdown",
        },
        layouts = {
          dropdown = {
            layout = {
              backdrop = false,
              width = 0.8,
              min_width = 80,
              height = 0.8,
              min_height = 30,
              box = "vertical",
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", height = 0.6, border = "top" },
            },
          },
        },
        formatters = {
          file = {
            truncate = 80,
          },
        },
        sources = {
          explorer = {
            auto_close = true,
            layout = {
              layout = {
                backdrop = false,
                width = 0.8,
                min_width = 120,
                height = 0.8,
                border = "rounded",
                box = "vertical",
                { win = "list", border = "none" },
                {
                  win = "input",
                  height = 1,
                  border = "none",
                },
              },
            },
            win = {
              list = {
                keys = {
                  ["s"] = "explorer_open", -- open with system application
                  ["o"] = "confirm",
                },
              },
            },
          },
        },
      },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      scope = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      words = { enabled = true },
      image = {
        enabled = true,
      },
    },
  },

  -- copilot
  {
    "github/copilot.vim",
    enabled = vim.env["COPILOT_ENABLE"] == "Y",
    lazy = false,
    config = function()
      vim.g.copilot_no_tab_map = true

      vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
}
