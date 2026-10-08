local outfmt = "\n"
  .. "┌─────────────────────────\n"
  .. "│ dnslookup     : %{time_namelookup}\n"
  .. "│ connect       : %{time_connect}\n"
  .. "│ appconnect    : %{time_appconnect}\n"
  .. "│ pretransfer   : %{time_pretransfer}\n"
  .. "│ starttransfer : %{time_starttransfer}\n"
  .. "│ total         : %{time_total}\n"
  .. "│ size          : %{size_download}\n"
  .. "│ HTTPCode=%{http_code}\n\n"
local M = {}
local hurl_ns = vim.api.nvim_create_namespace("kide_hurl")

local exec = function(cmd)
  require("kide.term").toggle(cmd)
end

---右侧开一列结果窗口 (焦点不变), 关窗即销毁
local function result_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "httpResult"
  vim.api.nvim_buf_set_name(buf, ("hurl://response/%d"):format(buf))

  -- split 显式给出新窗口方位, 不受 'splitright'/'splitbelow' 影响, 焦点也不变
  local current_win = vim.api.nvim_get_current_win()
  vim.api.nvim_open_win(buf, false, { split = "right", win = current_win })

  return buf
end

local function set_lines(buf, lines)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_clear_namespace(buf, hurl_ns, 0, -1)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end
end

local function set_elapsed(buf, elapsed_ms)
  if vim.api.nvim_buf_is_valid(buf) then
    local line = math.max(vim.api.nvim_buf_line_count(buf) - 1, 0)
    vim.api.nvim_buf_set_extmark(buf, hurl_ns, line, 0, {
      virt_text = { { (" process elapsed: %.2f ms"):format(elapsed_ms), "Comment" } },
      virt_text_pos = "eol",
    })
  end
end

local function run_http_file()
  local source = vim.api.nvim_buf_get_name(0)
  if source == "" then
    vim.notify("hurl: current buffer has no file path", vim.log.levels.ERROR)
    return
  end

  local file_root = vim.fn.fnamemodify(source, ":p:h")

  local cmd = {
    "hurl",
    "--include",
    "--pretty",
    "--file-root",
    file_root,
    source,
  }

  local buf = result_buffer()
  set_lines(buf, {
    "Running...",
  })

  local started_at = vim.uv.hrtime()
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      local elapsed_ms = (vim.uv.hrtime() - started_at) / 1e6
      local output = {}

      if result.stdout and result.stdout ~= "" then
        vim.list_extend(output, vim.split(result.stdout, "\n", { plain = true }))
      end

      if result.stderr and result.stderr ~= "" then
        if #output > 0 then
          table.insert(output, "")
        end
        table.insert(output, "stderr:")
        vim.list_extend(output, vim.split(result.stderr, "\n", { plain = true }))
      end

      if result.code ~= 0 then
        table.insert(output, "")
        table.insert(output, ("exit code: %d"):format(result.code))
      end

      set_lines(buf, output)
      set_elapsed(buf, elapsed_ms)
    end)
  end)
end

---Hurl 仅在 http/hurl 文件中提供, 避免污染全局命令
local function init_hurl()
  local group = vim.api.nvim_create_augroup("kide_hurl", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "http", "hurl" },
    desc = "Run current http/hurl file with hurl",
    callback = function(o)
      vim.api.nvim_buf_create_user_command(o.buf, "Hurl", run_http_file, {
        desc = "Run current .http/.hurl file with hurl and show response on the right",
      })
      -- 缓冲区局部缩写, 离开该 buffer 后不再生效
      vim.api.nvim_buf_call(o.buf, function()
        vim.cmd(
          [[cnoreabbrev <buffer> <expr> hurl getcmdtype() == ':' && getcmdline() ==# 'hurl' ? 'Hurl' : 'hurl']]
        )
      end)
    end,
  })
end

M.setup = function()
  vim.api.nvim_create_user_command("Curl", function(opt)
    if opt.args == "" then
      local ok, url = pcall(vim.fn.input, "URL: ")
      if ok then
        exec({
          "curl",
          "-w",
          outfmt,
          url,
        })
      end
    else
      local cmd = {
        "curl",
        "-w",
        outfmt,
      }
      vim.list_extend(cmd, vim.split(opt.args, " "))
      exec(cmd)
    end
  end, {
    nargs = "*",
    complete = function()
      return { "-vvv", "--no-sessionid" }
    end,
  })

  init_hurl()
end

return M
