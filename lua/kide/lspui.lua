local M = {}

function M.open_info()
  -- 获取当前窗口的高度
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.8)
  local height = math.floor(lines * 0.8)

  local opts = {
    row = math.floor((lines - height) * 0.5),
    col = math.floor((columns - width) * 0.5),
    relative = "editor",
    width = width, -- 窗口的宽度
    height = height, -- 窗口的高度
    style = "minimal", -- 最小化样式
    border = "rounded", -- 窗口边框样式
  }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].number = false

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { noremap = true, silent = true, buffer = buf })
  local clients = vim.lsp.get_clients()

  local client_info = {
    "Lsp Clients:",
    "",
  }
  for _, client in pairs(clients) do
    vim.list_extend(client_info, {
      "Name: " .. client.name,
      "  Id: " .. client.id,
      "  buffers: " .. vim.inspect(vim.lsp.get_buffers_by_client_id(client.id)),
      "  filetype: " .. vim.inspect(client.config.filetypes),
      "  root_dir: " .. vim.inspect(client.config.root_dir),
      "  cmd: " .. vim.inspect(client.config.cmd),
      "",
    })
  end
  vim.api.nvim_put(client_info, "c", true, true)
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

return M
