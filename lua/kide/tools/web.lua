-- DeepSeek 网页搜索/抓取
-- https://api-docs.deepseek.com/zh-cn/api/search
-- https://api-docs.deepseek.com/zh-cn/api/fetch
local M = {}

local base_url = "https://api.deepseek.com/v1/tools"
local ns = vim.api.nvim_create_namespace("kide_web")

---@class web.SearchOpts
---@field query string
---@field count integer?
---@field ori_question string?
---@field need_content boolean?

---@class web.SearchResult
---@field title string
---@field url string
---@field snippet string
---@field summary string
---@field content string
---@field site_name string?
---@field date string?
---@field rerank_score number
---@field authority integer

---@param path string
---@param payload table
---@param callback fun(err: string?, resp: table?)
local function post(path, payload, callback)
  local api_key = vim.env["DEEPSEEK_API_KEY"]
  if not api_key or api_key == "" then
    callback("DEEPSEEK_API_KEY 未设置")
    return
  end
  local cmd = {
    "curl",
    "-sS",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. api_key,
    -- body 走 stdin, 避免网页 URL/查询词里的特殊字符和命令行长度问题
    "--data-binary",
    "@-",
    -- 末尾追加状态码, 用来区分错误响应
    "-w",
    "\n%{http_code}",
    base_url .. path,
  }
  local sid = require("kide").timer_stl_status("")
  vim.system(cmd, { text = true, stdin = vim.json.encode(payload) }, function(result)
    vim.schedule(function()
      require("kide").clean_stl_status(sid, result.code)
      if result.code ~= 0 then
        callback(("curl exit %d: %s"):format(result.code, vim.trim(result.stderr or "")))
        return
      end
      local body, status = (result.stdout or ""):match("^(.*)\n(%d+)$")
      local ok, resp = pcall(vim.json.decode, body or "", { luanil = { object = true, array = true } })
      if not ok or type(resp) ~= "table" then
        callback(("HTTP %s: %s"):format(status or "?", body or result.stdout))
        return
      end
      if resp.error then
        local err = resp.error
        callback(("HTTP %s: %s"):format(status, type(err) == "table" and err.message or tostring(err)))
        return
      end
      callback(nil, resp)
    end)
  end)
end

---@param opts web.SearchOpts
---@param callback fun(err: string?, results: web.SearchResult[]?)
function M.search(opts, callback)
  post("/search", {
    query = opts.query,
    count = opts.count or 10,
    ori_question = opts.ori_question,
    need_content = opts.need_content or false,
  }, function(err, resp)
    callback(err, resp and resp.results)
  end)
end

---@param url string
---@param callback fun(err: string?, page: {title: string, content: string}?)
function M.fetch(url, callback)
  post("/fetch", { url = url }, callback)
end

---右侧开一列 markdown 结果窗口; 已在 web 结果窗口中则复用当前窗口
---@param name string
local function result_buffer(name)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, ("web://%d/%s"):format(buf, name))
  if vim.w.kide_web then
    vim.api.nvim_win_set_buf(0, buf)
  else
    local current_win = vim.api.nvim_get_current_win()
    local win = vim.api.nvim_open_win(buf, true, { split = "right", win = current_win })
    vim.w[win].kide_web = true
  end
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, desc = "Close web result" })
  return buf
end

local function set_lines(buf, lines)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end
end

local function split_lines(text)
  return vim.split(text or "", "\n", { plain = true })
end

---光标所在搜索结果的 url, 否则取光标下的 url
---@param buf integer
local function url_at_cursor(buf)
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { lnum, 0 }, 0, { limit = 1 })
  local results = vim.b[buf].kide_web_results
  if marks[1] and results then
    return results[tostring(marks[1][1])]
  end
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    return cfile
  end
end

---@param url string
function M.open_fetch(url)
  local buf = result_buffer(url)
  vim.bo[buf].bufhidden = "wipe"
  set_lines(buf, { "Fetching " .. url .. " ..." })
  M.fetch(url, function(err, page)
    if err then
      set_lines(buf, { "# Fetch failed", "", url, "", err })
      return
    end
    local lines = { "<!-- " .. url .. " -->", "" }
    if page.title ~= "" and not vim.startswith(page.content, "# ") then
      vim.list_extend(lines, { "# " .. page.title, "" })
    end
    vim.list_extend(lines, split_lines(page.content))
    set_lines(buf, lines)
  end)
end

---@param opts web.SearchOpts
function M.open_search(opts)
  local buf = result_buffer(opts.query)
  -- 抓取页面会替换到同一窗口, 保留搜索结果以便 <C-o> 返回
  vim.bo[buf].bufhidden = "hide"
  set_lines(buf, { "Searching " .. opts.query .. " ..." })
  M.search(opts, function(err, results)
    if err then
      set_lines(buf, { "# Search failed", "", err })
      return
    end
    local lines = { "# " .. opts.query, "" }
    local starts = {}
    if #results == 0 then
      table.insert(lines, "_无结果_")
    end
    for i, r in ipairs(results) do
      starts[i] = #lines
      local meta = { ("score %.2f"):format(r.rerank_score) }
      if r.site_name then
        table.insert(meta, r.site_name)
      end
      if r.date then
        table.insert(meta, r.date:sub(1, 10))
      end
      vim.list_extend(lines, {
        ("## %d. %s"):format(i, r.title),
        "",
        r.url,
        "",
        "_" .. table.concat(meta, " · ") .. "_",
        "",
      })
      vim.list_extend(lines, split_lines(r.summary ~= "" and r.summary or r.snippet))
      if r.content ~= "" then
        vim.list_extend(lines, { "", "<details>", "" })
        vim.list_extend(lines, split_lines(r.content))
        vim.list_extend(lines, { "", "</details>" })
      end
      table.insert(lines, "")
    end
    set_lines(buf, lines)
    -- 每条结果标题处打个 extmark, 记录 id -> url
    local map = {}
    for i, r in ipairs(results) do
      local id = vim.api.nvim_buf_set_extmark(buf, ns, starts[i], 0, {})
      map[tostring(id)] = r.url
    end
    vim.b[buf].kide_web_results = map
  end)
  vim.keymap.set("n", "<CR>", function()
    local url = url_at_cursor(buf)
    if url then
      M.open_fetch(url)
    end
  end, { buffer = buf, desc = "Fetch web page of search result" })
end

M.setup = function()
  vim.api.nvim_create_user_command("WebSearch", function(opt)
    local query = opt.args
    if query == "" then
      local ok, input = pcall(vim.fn.input, "Search: ")
      if not ok or vim.trim(input) == "" then
        return
      end
      query = input
    end
    M.open_search({
      query = query,
      count = opt.count > 0 and opt.count or nil,
      -- :WebSearch! 返回全文
      need_content = opt.bang,
    })
  end, {
    nargs = "*",
    bang = true,
    count = 0,
    desc = "DeepSeek web search ([count]WebSearch[!] query, ! 返回全文)",
  })

  vim.api.nvim_create_user_command("WebFetch", function(opt)
    local url = opt.args
    if url == "" then
      local cfile = vim.fn.expand("<cfile>")
      url = cfile:match("^https?://") and cfile or ""
    end
    if url == "" then
      local ok, input = pcall(vim.fn.input, "URL: ")
      if not ok or vim.trim(input) == "" then
        return
      end
      url = vim.trim(input)
    end
    M.open_fetch(url)
  end, {
    nargs = "?",
    desc = "DeepSeek fetch web page as markdown (默认光标下 URL)",
  })
end

return M
