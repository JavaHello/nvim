local config = require("kide.config")
local utils = require("kide.core.utils")

local M = {}

function M.setup(opts)
  if not config.env.rime_ls_bin then
    return
  end
  -- global status
  vim.g.rime_enabled = false

  -- update lualine
  local function rime_status()
    if vim.g.rime_enabled then
      return "ㄓ"
    else
      return ""
    end
  end

  require("lualine").setup({
    sections = {
      lualine_x = { rime_status, "encoding", "fileformat", "filetype" },
    },
  })

  -- add rime-ls to lspconfig as a custom server
  -- see `:h lspconfig-new`
  local lspconfig = require("lspconfig")
  local configs = require("lspconfig.configs")
  if not configs.rime_ls then
    configs.rime_ls = {
      default_config = {
        name = "rime_ls",
        cmd = { config.env.rime_ls_bin },
        -- cmd = vim.lsp.rpc.connect('127.0.0.1', 9257),
        filetypes = { "*" },
        single_file_support = true,
      },
      settings = {},
      docs = {
        description = [[
https://www.github.com/wlh320/rime-ls

A language server for librime
]],
      },
    }
  end

  local rime_on_attach = function(client, _)
    local toggle_rime = function()
      client.request("workspace/executeCommand", { command = "rime-ls.toggle-rime" }, function(_, result, ctx, _)
        if ctx.client_id == client.id then
          vim.g.rime_enabled = result
        end
      end)
    end
    -- keymaps for executing command
    vim.keymap.set("n", "<C-space>", function()
      toggle_rime()
    end)
    vim.keymap.set("i", "<C-x>", function()
      toggle_rime()
    end)
    vim.keymap.set("n", "<leader>rs", function()
      vim.lsp.buf.execute_command({ command = "rime-ls.sync-user-data" })
    end)
  end

  local shared_data_dir = nil
  if utils.is_mac then
    shared_data_dir = "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
  else
    shared_data_dir = "/usr/share/rime-data"
  end

  lspconfig.rime_ls.setup({
    init_options = {
      enabled = vim.g.rime_enabled,
      shared_data_dir = shared_data_dir,
      user_data_dir = "~/.local/share/rime-ls",
      log_dir = "~/.local/share/rime-ls",
      max_candidates = 9,
      trigger_characters = {},
      schema_trigger_character = "&", -- [since v0.2.0] 当输入此字符串时请求补全会触发 “方案选单”
    },
    on_attach = rime_on_attach,
    flags = opts.flags,
    capabilities = opts.capabilities,
  })
end

return M
