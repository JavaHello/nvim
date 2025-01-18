local M = {}
local state = {}
local function open_file(open)
  if vim.fn.filereadable(vim.fn.expand(state.chooserfile)) == 1 then
    local filenames = vim.fn.readfile(state.chooserfile)
    for _, filename in ipairs(filenames) do
      if vim.fn.filereadable(filename) == 1 then
        vim.cmd(open .. " " .. filename)
      end
    end
  end
end
local function yazi_close()
  if state.chooserfile then
    vim.fn.delete(state.chooserfile)
    state.chooserfile = nil
  end
end

function M.yazi(open)
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  open = open or "edit"
  state.path = vim.fn.getcwd()
  state.filename = vim.api.nvim_buf_get_name(0)
  if state.filename == "" then
    state.filename = state.path
  end
  state.chooserfile = vim.fn.tempname()

  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.9)
  local opts = {
    relative = "editor",
    style = "minimal",
    row = math.floor((lines - height) * 0.5),
    col = math.floor((columns - width) * 0.5),
    width = width,
    height = height,
    focusable = true,
    border = "rounded",
    title = "Yazi",
    title_pos = "center",
  }

  state.buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(state.buf, true, opts)
  vim.bo[state.buf].modified = false

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = state.buf,
    callback = function()
      vim.api.nvim_buf_delete(state.buf, { force = true })
      state.buf = nil
    end,
  })
  vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    buffer = state.buf,
    command = "startinsert!",
    once = true,
  })

  vim.fn.jobstart({ "yazi", state.filename, "--chooser-file", state.chooserfile }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(state.win) then
        pcall(vim.api.nvim_win_close, state.win, true)
        state.winid = nil
        open_file(open)
      end
      yazi_close()
    end,
  })
end
return M
