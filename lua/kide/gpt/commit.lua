local M = {}

local gpt_provide = require("kide.gpt.provide")
---@type gpt.Client
local client = nil

function M.commit_message(diff, callback)
  local messages = {
    {
      content = "",
      role = "system",
    },
    {
      content = "",
      role = "user",
    },
  }
  messages[1].content =
  "I want you to act as a commit message generator. I will provide you with information about the task and the prefix for the task code, and I would like you to generate an appropriate commit message using the conventional commit format. Do not write any explanations or other words, just reply with the commit message."
  messages[2].content = diff
  client = gpt_provide.new_client("commit")
  client:request(messages, callback)
end

M.commit_diff_msg = function()
  local diff = vim.system({ "git", "diff", "--cached" }):wait()
  if diff.code ~= 0 then
    return
  end
  local codebuf = vim.api.nvim_get_current_buf()
  if "gitcommit" ~= vim.bo[codebuf].filetype then
    return
  end
  local closed = false
  vim.cmd("normal! gg0")

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = codebuf,
    callback = function()
      closed = true
      if client then
        client:close()
      end
    end,
  })
  vim.keymap.set("n", "<C-c>", function()
    closed = true
    if client then
      client:close()
    end
    vim.keymap.del("n", "<C-c>", { buffer = codebuf })
  end, { buffer = codebuf, noremap = true, silent = true })

  local callback = function(opt)
    local data = opt.data
    if closed then
      vim.fn.jobstop(opt.job)
      return
    end
    if opt.done then
      return
    end

    local put_data = {}
    if vim.api.nvim_buf_is_valid(codebuf) then
      if data:match("\n") then
        put_data = vim.split(data, "\n")
      else
        put_data = { data }
      end
      vim.api.nvim_put(put_data, "c", true, true)
    end
  end
  M.commit_message(diff.stdout, callback)
end

M.setup = function()
  local command = vim.api.nvim_buf_create_user_command
  local autocmd = vim.api.nvim_create_autocmd
  local function augroup(name)
    return vim.api.nvim_create_augroup("kide" .. name, { clear = true })
  end
  autocmd("FileType", {
    group = augroup("gpt_commit_msg"),
    pattern = "gitcommit",
    callback = function(event)
      command(event.buf, "GptCommitMsg", function(_)
        M.commit_diff_msg()
      end, {
        desc = "Gpt Commit Message",
        nargs = 0,
        range = false,
      })

      vim.keymap.set("n", "<leader>cm", function()
        M.commit_diff_msg()
      end, { buffer = event.buf, noremap = true, silent = true })
    end,
  })
end

return M
