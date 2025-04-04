vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

if vim.env["JDTLS_NVIM_ENABLE"] == "Y" then
  local spring_boot = vim.env["SPRING_BOOT_NVIM_ENABLE"] == "Y"
  local jc = require("kide.lsp.jdtls")
  local config
  -- 防止 start_or_attach 重复修改 config
  if jc.init then
    config = {
      cmd = {},
    }
  else
    config = jc.config
    jc.init = true

    if spring_boot then
      vim.list_extend(config["init_options"].bundles, require("spring_boot").java_extensions())
    end
  end
  require("jdtls").start_or_attach(config, { dap = { config_overrides = {}, hotcodereplace = "auto" } })

  if spring_boot then
    require("spring_boot.launch").start(require("kide.lsp.spring-boot").config)
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
