local M = {}
local me = require("kide.melspconfig")

local function spring_tools_path()
  local path = vim.env["JDTLS_SPRING_TOOLS_PATH"]
  if path == nil or path == "" then
    return nil
  end
  return path
end

-- 语言服务器路径: 优先取 env 指定的目录, 否则由插件从 mason / vscode 扩展目录查找
local function ls_path()
  local path = spring_tools_path()
  if path == nil then
    return nil
  end
  return require("spring_boot").get_boot_ls(vim.fs.joinpath(path, "language-server"))
end

-- jdtls 扩展 jar: env 指定目录优先, 否则交给插件自己查找
M.jars = function()
  local path = spring_tools_path()
  if path == nil then
    return nil
  end
  return require("spring_boot").get_jars(vim.fs.joinpath(path, "jars"))
end

-- 0.2 起客户端由 vim.lsp.config/vim.lsp.enable 接管, 只需要配置一次
M.setup = function()
  if M.done then
    return
  end
  M.done = true
  require("spring_boot").setup({
    ls_path = ls_path(),
    jars = M.jars(),
    project_filter = function(root_dir)
      return require("spring_boot.util").has_spring_boot_dependency(root_dir)
    end,
    server = {
      on_attach = function(client, bufnr)
        me.on_attach(client, bufnr)
        M.bootls_user_command(bufnr)
      end,
      on_init = function(client, init_result)
        client.server_capabilities.documentHighlightProvider = false
        -- server 是合并链最高层, 会整个替换插件自带的 on_init, 需要自己调用
        require("spring_boot.util").boot_ls_init(client, init_result)
        me.on_init(client, init_result)
      end,
    },
  })
end

M.bootls_user_command = function(buf)
  local create_command = vim.api.nvim_buf_create_user_command
  create_command(buf, "SpringBoot", function(opt)
    local on_choice = function(choice)
      if choice == "Annotations" then
        vim.lsp.buf.workspace_symbol("@")
      elseif choice == "Beans" then
        vim.lsp.buf.workspace_symbol("@+")
      elseif choice == "RequestMappings" then
        vim.lsp.buf.workspace_symbol("@/")
      elseif choice == "Prototype" then
        vim.lsp.buf.workspace_symbol("@>")
      end
    end
    if opt.args and opt.args ~= "" then
      on_choice(opt.args)
    else
      vim.ui.select({ "Annotations", "Beans", "RequestMappings", "Prototype" }, {
        prompt = "Spring Symbol:",
        format_item = function(item)
          if item == "Annotations" then
            return "shows all Spring annotations in the code"
          elseif item == "Beans" then
            return "shows all defined beans"
          elseif item == "RequestMappings" then
            return "shows all defined request mappings"
          elseif item == "Prototype" then
            return "shows all functions (prototype implementation)"
          end
          return item
        end,
      }, on_choice)
    end
  end, {
    desc = "Spring Boot",
    nargs = "?",
    range = false,
    complete = function()
      return { "Annotations", "Beans", "RequestMappings", "Prototype" }
    end,
  })
end

return M
