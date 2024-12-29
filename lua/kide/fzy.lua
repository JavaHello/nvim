--- 插件: mfussenegger/nvim-fzy
---@brief [[
--- Neovim integration for the `fzy` fuzzy finder
---
--- nvim-fzy provides an implementation for |vim.ui.select()| and a
--- |fzy.execute()| function to run arbitrary commands and select one entry from the output.
---
---@brief ]]

---@mod fzy

local api = vim.api
local vfn = vim.fn
local uv = vim.uv or vim.loop
local M = {}

--- Generate the `fzy` shell command.
---
--- `opts.prompt` if present is already shell escaped.
---
--- Must return a command as string that:
---   - Receives choices as newline delimited strings via stdin
---   - Returns the selection via stdout.
---
--- Examples:
---
--- <pre>
--- fzy.command({ height = 20 })
--- -- Result: fzy -l 20
--- </pre>
---
--- <pre>
--- fzy.command({ height = 20, prompt = "'Tag: '" })
--- -- Result: fzy -l 20 -p 'Tag: '
--- </pre>
---
---@param opts {height: integer, prompt?: string}
---@return string
function M.command(opts)
  local prompt = opts.prompt
  if prompt then
    return string.format("fzy -l %d -p %s", opts.height, prompt)
  else
    return string.format("fzy -l %d", opts.height)
  end
end

--- Create a floating window and a buffer
--- The buffer is used to run the fzy terminal
---
---@return integer win, integer buf
function M.new_popup()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_keymap(buf, "t", "<ESC>", "<C-\\><C-c>", {})
  vim.bo[buf].bufhidden = "wipe"
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(columns * 0.9)
  local height = math.floor(lines * 0.8)
  local opts = {
    relative = "editor",
    style = "minimal",
    row = math.floor((lines - height) * 0.5),
    col = math.floor((columns - width) * 0.5),
    width = width,
    height = height,
    border = "rounded",
  }
  local win = api.nvim_open_win(buf, true, opts)
  return win, buf
end

local sinks = {}
M.sinks = sinks
function sinks.edit_file(selection)
  if selection and vim.trim(selection) ~= "" then
    vim.cmd("e " .. selection)
  end
end

function sinks.edit_live_grep(selection)
  -- fzy returns search input if zero results found. This case is mapped to nil as well.
  selection = string.match(selection, ".+:%d+:.+")
  if selection then
    local parts = vim.split(selection, ":")
    local path, line = parts[1], parts[2]
    vim.cmd("e +" .. line .. " " .. path)
  end
end

--- Show a prompt to the user to pick on of many items
---
---@generic T
---@param items T[]
---@param prompt? string
---@param label_fn? fun(item: T): string
---@param on_choice fun(choice?: T, idx?: integer)
function M.pick_one(items, prompt, label_fn, on_choice)
  label_fn = label_fn or vim.inspect
  local num_digits = math.floor(math.log(math.abs(#items), 10) + 1)
  local digit_fmt = "%0" .. tostring(num_digits) .. "d"
  local inputs = vfn.tempname()
  vfn.system(string.format('mkfifo "%s"', inputs))
  local co
  if on_choice == nil then
    co = coroutine.running()
    assert(co, "If callback is nil the function must run in a coroutine")
    on_choice = function(choice, idx)
      coroutine.resume(co, choice, idx)
    end
  end

  M.execute(string.format('cat "%s"', inputs), function(selection)
    os.remove(inputs)
    if not selection or vim.trim(selection) == "" then
      on_choice(nil)
    else
      local parts = vim.split(selection, "│ ")
      local idx = tonumber(parts[1])
      on_choice(items[idx], idx)
    end
  end, prompt)
  local f = io.open(inputs, "a")
  if f then
    for i, item in ipairs(items) do
      local label = string.format(digit_fmt .. "│ %s", i, label_fn(item))
      f:write(label .. "\n")
    end
    f:flush()
    f:close()
  else
    vim.notify("Could not open tempfile", vim.log.levels.ERROR)
  end
  if co then
    return coroutine.yield()
  end
end

--- Execute `choices_cmd` in a shell and pipes the result to fzy,
--- prompting the user for a choice.
---
---@param choices_cmd string command that generates the choices
---@param on_choice fun(choice?: string) called when the user selected an entry
---@param prompt? string
function M.execute(choices_cmd, on_choice, prompt, selection)
  if api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  local tmpfile = vfn.tempname()
  local popup_win, buf = M.new_popup()
  api.nvim_create_autocmd("WinLeave", {
    callback = function()
      local w = vim.api.nvim_get_current_win()
      if w == popup_win then
        api.nvim_buf_delete(buf, { force = true })
        return true
      end
    end,
  })
  local height = api.nvim_win_get_height(popup_win)
  prompt = prompt and vim.fn.shellescape(prompt) or nil
  local cmd = M.command({ height = height, prompt = prompt })
  local fzy = string.format('%s | %s > "%s"', choices_cmd, cmd, tmpfile)
  api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    buffer = buf,
    command = "startinsert!",
    once = true,
  })

  local args = { vim.o.shell, vim.o.shellcmdflag, fzy }
  local job = vfn.jobstart(args, {
    term = true,
    on_exit = function()
      -- popup could already be gone if user closes it manually; Ignore that case
      pcall(api.nvim_win_close, popup_win, true)
      local choice = nil
      local file = io.open(tmpfile)
      if file then
        choice = file:read("*all")
        file:close()
        os.remove(tmpfile)
      end

      -- After on_exit there will be a terminal related cmdline update that would
      -- override any messages printed by the `on_choice` callback.
      -- The timer+schedule combo ensures users see messages printed within the callback
      local timer = uv.new_timer()
      if timer then
        timer:start(0, 0, function()
          timer:stop()
          timer:close()
          vim.schedule(function()
            on_choice(choice)
          end)
        end)
      else
        on_choice(choice)
      end
    end,
  })
  if selection then
    vfn.chansend(job, selection)
  end
end

return M
