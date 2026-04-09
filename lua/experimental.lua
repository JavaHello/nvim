local ok, tui = pcall(require, "vim._extui")
if ok then
  tui.enable({})
end
local ok2, ui2 = pcall(require, "vim._core.ui2")
if ok2 then
  ui2.enable()
end
