-- code from https://github.com/mfussenegger/nvim-jdtls/blob/f8fb45e05e/lua/jdtls.lua
local api = vim.api
local M = {}
function M.execute_command(command, callback, bufnr)
  local clients = {}
  local candidates = bufnr and vim.lsp.buf_get_clients(bufnr) or vim.lsp.get_active_clients()
  for _, c in pairs(candidates) do
    local command_provider = c.server_capabilities.executeCommandProvider
    local commands = type(command_provider) == "table" and command_provider.commands or {}
    if vim.tbl_contains(commands, command.command) then
      table.insert(clients, c)
    end
  end
  local num_clients = vim.tbl_count(clients)
  if num_clients == 0 then
    if bufnr then
      -- User could've switched buffer to non-java file, try all clients
      return M.execute_command(command, callback, nil)
    else
      vim.notify("No LSP client found that supports " .. command.command, vim.log.levels.ERROR)
      return
    end
  end

  if num_clients > 1 then
    vim.notify(
      "Multiple LSP clients found that support "
        .. command.command
        .. " you should have at most one JDTLS server running",
      vim.log.levels.WARN
    )
  end

  local co
  if not callback then
    co = coroutine.running()
    if co then
      callback = function(err, resp)
        coroutine.resume(co, err, resp)
      end
    end
  end
  clients[1].request("workspace/executeCommand", command, callback)
  if co then
    return coroutine.yield()
  end
end
--- Open `jdt://` uri or decompile class contents and load them into the buffer
---
--- nvim-jdtls by defaults configures a `BufReadCmd` event which uses this function.
--- You shouldn't need to call this manually.
---
---@param fname string
function M.open_classfile(fname, buf, timeout_ms)
  local uri
  local use_cmd
  if vim.startswith(fname, "jdt://") then
    uri = fname
    use_cmd = false
  else
    uri = vim.uri_from_fname(fname)
    use_cmd = true
    if not vim.startswith(uri, "file://") then
      return
    end
  end
  vim.bo[buf].modifiable = true
  vim.bo[buf].swapfile = false
  vim.bo[buf].buftype = "nofile"
  -- This triggers FileType event which should fire up the lsp client if not already running
  vim.bo[buf].filetype = "java"
  vim.wait(timeout_ms, function()
    return next(vim.lsp.get_active_clients({ name = "jdtls" })) ~= nil
  end)
  local client = vim.lsp.get_active_clients({ name = "jdtls" })[1]
  assert(client, "Must have a `jdtls` client to load class file or jdt uri")

  local content
  local function handler(err, result)
    assert(not err, vim.inspect(err))
    content = result
    api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n", { plain = true }))
    vim.bo[buf].modifiable = false
  end

  if use_cmd then
    local command = {
      command = "java.decompile",
      arguments = { uri },
    }
    M.execute_command(command, handler)
  else
    local params = {
      uri = uri,
    }
    client.request("java/classFileContents", params, handler, buf)
  end
  -- Need to block. Otherwise logic could run that sets the cursor to a position
  -- that's still missing.
  vim.wait(timeout_ms, function()
    return content ~= nil
  end)
end
return M
