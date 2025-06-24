local ok, tui = pcall(require, "vim._extui")
if ok then
  tui.enable({})
end
