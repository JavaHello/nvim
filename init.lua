-- math.randomseed(os.time())
-- 判断终端是否配置了透明背景
if vim.env["TRANSPARENT_MODE"] == "Y" then
  vim.g.transparent_mode = true
else
  vim.g.transparent_mode = false
end

if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.opt_global.guifont = "Hack Nerd Font Mono,Hack:h13"
  vim.g.neovide_fullscreen = false
  vim.g.neovide_input_use_logo = true
  local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_transparency = 0.0
  vim.g.transparency = 0.8
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

require("kide.core")
require("kide.plugins")
