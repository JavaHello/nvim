vim.g.nvim_jdtls = 1
if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.opt_global.guifont = "CaskaydiaCove Nerd Font Mono:h15"
  vim.g.neovide_fullscreen = true
  vim.g.transparency = 1.0
  local alpha = function()
    return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8)))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_transparency = 1.0
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

vim.schedule(function()
  require "kide.autocmds"
  require("kide.core.utils").camel_case_init()
  require("kide.core.utils.plantuml").setup()
  require("kide.core.utils.maven").setup()
  require("kide.core.utils.jdtls").setup()
  require("kide.core.utils.curl").setup()
end)
