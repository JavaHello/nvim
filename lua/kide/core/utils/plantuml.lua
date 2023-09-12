local uv = vim.loop
local utils = require("kide.core.utils")
local plantuml_args_complete = utils.command_args_complete
local M = {}
M.config = {}

local function plantuml_jar(default_jar)
  return vim.env["PLANTUML_JAR"] or default_jar
end
M.config.jar_path = plantuml_jar("/opt/software/puml/plantuml.jar")
M.config.cmd = "java"
M.config.defaultTo = "svg"
M.types = {}
M.types["-tpng"] = "png"
M.types["-tsvg"] = "svg"
M.types["-teps"] = "eps"
M.types["-tpdf"] = "pdf"
M.types["-tvdx"] = "vdx"
M.types["-txmi"] = "xmi"
M.types["-tscxml"] = "scxml"
M.types["-thtml"] = "html"
M.types["-ttxt"] = "atxt"
M.types["-tutxt"] = "utxt"
M.types["-tlatex"] = "latex"
M.types["-tlatex:nopreamble"] = "latex"

local complete_list = (function()
  local cl = {}
  for k, _ in pairs(M.types) do
    table.insert(cl, k)
  end
  return cl
end)()

local function to_type()
  return "-t" .. M.config.defaultTo
end

local function out_file(ot, file)
  return utils.get_filename(file) .. "." .. ot
end

local function exec(opt)
  if not vim.fn.filereadable(M.config.jar_path) then
    vim.notify("Plantuml: 没有文件 " .. M.config.jar_path, vim.log.levels.ERROR)
    return
  end
  if not vim.fn.executable("java") then
    vim.notify("Plantuml: 没有 java 环境", vim.log.levels.ERROR)
    return
  end
  local out_type = vim.tbl_filter(function(item)
    if vim.startswith(item, "-t") then
      return true
    end
  end, opt.args)
  if not out_type or vim.tbl_count(out_type) == 0 then
    local ot = to_type()
    opt.args = { ot }
    out_type = { ot }
  end
  local ot = M.types[out_type[1]]
  if not ot then
    vim.notify("Plantuml: 不支持的格式 " .. out_type[1], vim.log.levels.ERROR)
    return
  end
  local ofile = out_file(ot, opt.file)

  local p = vim.fn.expand("%:p:h")
  table.insert(opt.args, 1, "-jar")
  table.insert(opt.args, 2, M.config.jar_path)
  table.insert(opt.args, opt.file)
  table.insert(opt.args, "-o" .. p)
  local process = {
    cmd = M.config.cmd,
    args = opt.args,
    errors = "\n",
    stderr = uv.new_pipe(false),
  }
  process.handle, process.pid = uv.spawn(
    process.cmd,
    { args = process.args, stdio = { nil, nil, process.stderr }, detached = true },
    function(code)
      process.handle:close()
      if code ~= 0 then
        uv.read_start(process.stderr, function(_, data)
          process.stderr:read_stop()
          process.stderr:close()
          if data then
            vim.notify("Plantuml: " .. data, vim.log.levels.WARN)
          else
            vim.notify("Plantuml: export error " .. code, vim.log.levels.WARN)
          end
        end)
      else
        vim.notify("Plantuml: export success", vim.log.levels.INFO)
        utils.open_fn(ofile)
      end
    end
  )
end

local function init()
  local group = vim.api.nvim_create_augroup("plantuml_export", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "plantuml" },
    desc = "Export Plantuml file",
    callback = function(o)
      vim.api.nvim_buf_create_user_command(o.buf, "Plantuml", function(opts)
        exec({
          args = opts.fargs,
          file = o.file,
        })
      end, {
        nargs = "*",
        complete = plantuml_args_complete(complete_list, { single = true }),
      })
    end,
  })
end

M.setup = function(config)
  if config then
    M.config = vim.tbl_deep_extend("force", M.config, config)
  end
  init()
end
return M
