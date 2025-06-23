local M = {}
local me = require("kide.melspconfig")
local function ls_path()
  local path = vim.env["JDTLS_SPRING_TOOLS_PATH"]
  if path == nil or path == "" then
    return nil
  end
  return require("spring_boot").get_boot_ls(path .. "/language-server")
end
local lspath = ls_path()
if lspath == nil then
  return M
end
M.config = require("spring_boot.launch").update_ls_config(require("spring_boot").setup({
  ls_path = lspath,
  server = {
    on_attach = function(client, bufnr)
      me.on_attach(client, bufnr)
      M.bootls_user_command(bufnr)
    end,
    on_init = function(client, ctx)
      client.server_capabilities.documentHighlightProvider = false
      me.on_init(client, ctx)
    end,
    capabilities = me.capabilities(),
  },
  autocmd = false,
}))

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
