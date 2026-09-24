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
    if vim.g.enable_spring_boot == true then
      local sb = require("kide.lsp.spring-boot")
      vim.list_extend(
        config["init_options"].bundles,
        sb.jars() or require("spring_boot").java_extensions()
      )
    end
  end
  jc.start(config)
end

-- see mfussenegger/dotfiles
local checkstyle_config = vim.fs.joinpath(vim.uv.cwd(), "checkstyle.xml")
local has_checkstyle = vim.fn.filereadable(checkstyle_config) == 1
local checkstyle_bin = vim.fn.executable("checkstyle") == 1
local is_main = vim.api.nvim_buf_get_name(0):find("src/main/java") ~= nil
if has_checkstyle and checkstyle_bin and is_main then
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
