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
  -- java
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
  },
  {
    "JavaHello/spring-boot.nvim",
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
    enabled = true,
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
  {
    "brenoprata10/nvim-highlight-colors",
    cmd = {
      "HighlightColors",
    },
    config = function()
      require("nvim-highlight-colors").setup({
        ---@usage 'background'|'foreground'|'virtual'
        render = "virtual",
        virtual_symbol = "󱓻",
      })
      local last_status
      vim.api.nvim_create_autocmd("InsertEnter", {
        group = vim.api.nvim_create_augroup("hl_colors_i", { clear = true }),
        pattern = "*",
        callback = function()
          last_status = require("nvim-highlight-colors").is_active()
          require("nvim-highlight-colors").turnOff()
        end,
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
        group = vim.api.nvim_create_augroup("hl_colors_n", { clear = true }),
        pattern = "*",
        callback = function()
          if last_status then
            require("nvim-highlight-colors").turnOn()
          end
        end,
      })
    end,
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
              { win = "preview", title = "{preview}", height = 0.6, border = "top" },
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
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
