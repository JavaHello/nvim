-- vim._extui 在 Neovim 0.12 已被移除, 只剩 ui2 (新的消息 UI), 需显式开启
local ok, ui2 = pcall(require, "vim._core.ui2")
if ok then
  ui2.enable()
end
