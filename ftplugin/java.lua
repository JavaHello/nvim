vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

local jc = require("kide.lsp.jdtls")
if jc.config then
  local config
  -- 防止 start_or_attach 重复修改 config
  if jc.init then
    config = {
      cmd = {},
    }
  else
    config = jc.config
    jc.init = true
    local boot_jar_path = vim.env["JDTLS_SPRING_TOOLS_PATH"]
    if boot_jar_path then
      vim.list_extend(
        config["init_options"].bundles,
        require("spring_boot").get_jars(vim.env["JDTLS_SPRING_TOOLS_PATH"] .. "/jars")
      )
    else
      vim.list_extend(config["init_options"].bundles, require("spring_boot").java_extensions())
    end
  end
  require("jdtls").start_or_attach(config, { dap = { config_overrides = {}, hotcodereplace = "auto" } })

  local sc = require("kide.lsp.spring-boot").config
  if sc then
    require("spring_boot.launch").start(sc)
  end
end

-- see mfussenegger/dotfiles
local checkstyle_config = vim.uv.cwd() .. "/checkstyle.xml"
local has_checkstyle = vim.uv.fs_stat(checkstyle_config) and vim.fn.executable("checkstyle")
local is_main = vim.api.nvim_buf_get_name(0):find("src/main/java") ~= nil
if has_checkstyle and is_main then
  local bufnr = vim.api.nvim_get_current_buf()
  require("lint.linters.checkstyle").config_file = checkstyle_config
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    buffer = bufnr,
    group = vim.api.nvim_create_augroup("checkstyle-" .. bufnr, { clear = true }),
    callback = function()
      if not vim.bo[bufnr].modified then
        require("lint").try_lint("checkstyle")
      end
    end,
  })
end
