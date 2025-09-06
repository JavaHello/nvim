-- 不保存 jumps 列表 '0
vim.opt.shada = "!,'0,<50,s10,h"
vim.opt_global.jumpoptions = "stack"
vim.opt_global.encoding = "UTF-8"
vim.opt.fileencoding = "UTF-8"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
local g = vim.g
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- 禁用内置插件
g.loaded_tohtml_plugin = 1

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

vim.opt_global.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt_global.grepformat = "%f:%l:%c:%m,%f:%l:%m"

local x = vim.diagnostic.severity
vim.diagnostic.config({
  virtual_text = { prefix = "" },
  signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
  float = {
    border = "rounded",
  },
})

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "Debug", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "Debug", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "Debug", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "Debug", linehl = "", numhl = "" })

if vim.g.neovide then
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.opt_global.guifont = vim.env["NVIM_GUI_FONT"] or "CaskaydiaMono Nerd Font Mono:h15"
  vim.g.neovide_fullscreen = true
  vim.g.transparency = 1.0
  local alpha = function()
    return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8)))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_opacity = 1.0
  vim.g.neovide_background_color = "#282828" .. alpha()

  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_profiler = false
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
end
require("global")
require("experimental")

require("options")
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }):wait()
  if out.code ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out.stdout, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  defaults = {
    lazy = false,
  },
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "gruvboxl" } },
  checker = { enabled = false },
  rocks = {
    enabled = false,
  },
})

vim.o.background = "dark"
vim.cmd.colorscheme("gruvboxl")
require("mappings")
require("autocmds")
