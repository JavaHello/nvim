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
      local boot_jar_path = vim.env["JDTLS_SPRING_TOOLS_PATH"]
      if boot_jar_path then
        vim.list_extend(config["init_options"].bundles, require("spring_boot").get_jars(boot_jar_path .. "/jars"))
      else
        vim.list_extend(config["init_options"].bundles, require("spring_boot").java_extensions())
      end
    end

    if vim.g.enable_quarkus == true then
      -- 添加 jdtls 扩展 jar 包
      local ok_microprofile, microprofile = pcall(require, "microprofile")
      if ok_microprofile then
        vim.list_extend(config["init_options"].bundles, microprofile.java_extensions())
      end

      local ok_quarkus, quarkus = pcall(require, "quarkus")
      if ok_quarkus then
        vim.list_extend(config["init_options"].bundles, quarkus.java_extensions())
      end
      local on_init = config.on_init
      config.on_init = function(client, ctx)
        if ok_quarkus then
          require("quarkus.bind").try_bind_qute_all_request()
        end
        if ok_microprofile then
          require("microprofile.bind").try_bind_microprofile_all_request()
        end
        if on_init then
          on_init(client, ctx)
        end
      end
    end
  end
  require("jdtls").start_or_attach(config, { dap = { config_overrides = {}, hotcodereplace = "auto" } })

  if vim.g.enable_spring_boot == true then
    local sc = require("kide.lsp.spring-boot").config
    require("spring_boot.launch").start(sc)
  end
  if vim.g.enable_quarkus == true then
    local qc = require("kide.lsp.quarkus").config
    vim.lsp.start(qc)
    local mc = require("kide.lsp.microprofile").config
    vim.lsp.start(mc)
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
