local utils = require("core.utils")
local M = {}
M.config = {}

M.config.jar_path = "/opt/software/puml/plantuml.jar"
M.config.cmd = "java -jar " .. M.config.jar_path
M.config.defaultTo = "svg"
M.types = {}
M.types["png"] = true
M.types["svg"] = true
M.types["eps"] = true
M.types["pdf"] = true
M.types["vdx"] = true
M.types["xmi"] = true
M.types["scxml"] = true
M.types["html"] = true
M.types["txt"] = true
M.types["utxt"] = true
M.types["latex"] = true
M.types["latex:nopreamble"] = true

local function to_type(type)
	if M.types[type] then
		return "-t" .. type
	end
	return "-t" .. M.config.defaultTo
end

local function exec(cmd)
	if not vim.fn.filereadable(M.config.jar_path) then
		vim.notify("Plantuml: 没有文件 " .. M.config.jar_path, vim.log.levels.ERROR)
		return
	end
	if not vim.fn.executable("java") then
		vim.notify("Plantuml: 没有 java 环境", vim.log.levels.ERROR)
		return
	end
	local p = vim.fn.expand("%:p:h")
	local res = utils.run_cmd("cd " .. p .. " && " .. cmd)
	if vim.fn.trim(res) == "" then
		vim.notify("Plantuml: export success", vim.log.levels.INFO)
	else
		vim.notify("Plantuml: export error, " .. res, vim.log.levels.WARN)
	end
end

M.run_export_opt = function(filename, args)
	exec(M.config.cmd .. " " .. args .. " " .. filename)
end

M.run_export_to = function(filename, type)
	exec(M.config.cmd .. " " .. to_type(type) .. " " .. filename)
end

local function init()
	local group = vim.api.nvim_create_augroup("plantuml_export", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = { "puml" },
		desc = "Export Plantuml file",
		callback = function(o)
			vim.api.nvim_buf_create_user_command(o.buf, "Plantuml", function(opts)
				M.run_export_to(vim.fn.expand("%"), opts.args)
			end, {})
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
