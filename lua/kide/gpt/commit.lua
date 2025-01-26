local M = {}
local request_json = {
  messages = {
    {
      content = "",
      role = "system",
    },
    {
      content = "Hi",
      role = "user",
    },
  },
  model = "deepseek-chat",
  frequency_penalty = 0,
  max_tokens = 4096 * 2,
  presence_penalty = 0,
  response_format = {
    type = "text",
  },
  stop = nil,
  stream = true,
  stream_options = nil,
  temperature = 1.3,
  top_p = 1,
  tools = nil,
  tool_choice = "none",
  logprobs = false,
  top_logprobs = nil,
}

function M.commit_message(diff, callback)
  local json = request_json
  json.messages[1].content =
    "I want you to act as a commit message generator. I will provide you with information about the task and the prefix for the task code, and I would like you to generate an appropriate commit message using the conventional commit format. Do not write any explanations or other words, just reply with the commit message."
  json.messages[2].content = diff
  require("kide.gpt.sse").request(json, callback)
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
    end,
  })

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
