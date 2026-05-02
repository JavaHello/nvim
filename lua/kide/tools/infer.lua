local M = {
  infer = vim.fn.exepath("infer"),
  mvn = vim.fn.exepath("mvn"),
  config = {
    report_file = "infer-out/report.json",
  },
}

local function project_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local root = vim.fs.root(name, { "pom.xml" })
  if root then
    return root
  end
  return vim.fs.root(name, { ".git" }) or vim.fn.getcwd()
end

local function severity_type(severity)
  if severity == "ERROR" then
    return "E"
  elseif severity == "WARNING" then
    return "W"
  elseif severity == "INFO" then
    return "I"
  end
  return "N"
end

local function bug_text(item)
  local parts = {}
  if item.bug_type_hum and item.bug_type_hum ~= "" then
    table.insert(parts, item.bug_type_hum)
  elseif item.bug_type and item.bug_type ~= "" then
    table.insert(parts, item.bug_type)
  end
  if item.qualifier and item.qualifier ~= "" then
    table.insert(parts, item.qualifier)
  end
  return table.concat(parts, ": ")
end

local function report_path(root, arg)
  if arg and vim.trim(arg) ~= "" then
    if vim.startswith(arg, "/") then
      return arg
    end
    return vim.fs.joinpath(root, arg)
  end
  return vim.fs.joinpath(root, M.config.report_file)
end

local function parse_report(report, root)
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(report), "\n"))
  if not ok or type(decoded) ~= "table" then
    vim.notify("Infer: report.json 解析失败", vim.log.levels.ERROR)
    return
  end

  local items = {}
  for _, issue in ipairs(decoded) do
    local filename = issue.file or issue.filename
    if filename and filename ~= "" then
      if not vim.startswith(filename, "/") then
        filename = vim.fs.joinpath(root, filename)
      end
      table.insert(items, {
        filename = filename,
        lnum = math.max(tonumber(issue.line) or 1, 1),
        col = math.max(tonumber(issue.column) or 1, 1),
        type = severity_type(issue.severity),
        text = bug_text(issue),
      })
    end
  end

  vim.fn.setqflist({}, "r", {
    title = "Infer",
    items = items,
  })
  if #items == 0 then
    vim.notify("Infer: 没有检查出问题", vim.log.levels.INFO)
    vim.cmd("cclose")
    return
  end
  vim.cmd("botright copen")
  vim.notify(("Infer: 已加载 %d 个问题到 quickfix"):format(#items), vim.log.levels.INFO)
end

local function infer_run(opts)
  if vim.fn.executable("infer") ~= 1 then
    vim.notify("Infer: 没有 infer 命令", vim.log.levels.ERROR)
    return
  end

  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local root = project_root(buf)
  local args = vim.split(opts.args or "", " ", { trimempty = true })
  if #args == 0 then
    vim.notify("Infer: 请输入要执行的命令，例如 InferRun mvn clean compile", vim.log.levels.WARN)
    return
  end
  if args[1] == "mvn" then
    if vim.fn.executable("mvn") ~= 1 then
      vim.notify("Infer: 没有 mvn 命令", vim.log.levels.ERROR)
      return
    end
    local settings = require("kide.tools.maven").get_maven_settings()
    if settings then
      table.insert(args, 2, "-s")
      table.insert(args, 3, settings)
    end
  end
  local cmd = { "infer", "run", "--" }
  vim.list_extend(cmd, args)
  local sid = require("kide").timer_stl_status("")

  vim.system(cmd, { cwd = root }, function(result)
    vim.schedule(function()
      require("kide").clean_stl_status(sid, result.code)
      local report = report_path(root)
      if vim.fn.filereadable(report) == 1 then
        parse_report(report, root)
      elseif result.code == 0 then
        vim.notify("Infer: 执行成功，但未找到 infer-out/report.json", vim.log.levels.WARN)
      else
        local msg = vim.trim(result.stderr or result.stdout or "")
        if msg == "" then
          msg = "Infer: 执行失败"
        end
        vim.notify(msg, vim.log.levels.ERROR)
      end
    end)
  end)
end

M.setup = function()
  vim.api.nvim_create_user_command("InferQf", function(opts)
    local root = project_root(vim.api.nvim_get_current_buf())
    local report = report_path(root, opts.args)
    if vim.fn.filereadable(report) ~= 1 then
      vim.notify("Infer: 没有文件 " .. report, vim.log.levels.ERROR)
      return
    end
    parse_report(report, root)
  end, {
    nargs = "?",
    complete = "file",
  })

  vim.api.nvim_create_user_command("InferRun", function(opts)
    infer_run({
      args = opts.args,
      buf = vim.api.nvim_get_current_buf(),
    })
  end, {
    nargs = "*",
    complete = function(arglead, cmdline, cursorpos)
      return require("kide.term").complete(arglead, cmdline, cursorpos, { command_name = "InferRun" })
    end,
  })
end

return M
