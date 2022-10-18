local M = {}
M.open_jdt_link = function(uri, buf, timeout)
  local client
  for _, c in ipairs(vim.lsp.get_active_clients()) do
    if
      c.config.init_options
      and c.config.init_options.extendedClientCapabilities
      and c.config.init_options.extendedClientCapabilities.classFileContentsSupport
    then
      client = c
      break
    end
  end
  assert(client, "Must have a buffer open with a language client connected to eclipse.jdt.ls to load JDT URI")
  local params = {
    uri = uri,
  }
  local response = nil
  local cb = function(err, result)
    response = { err, result }
  end
  local ok, request_id = client.request("java/classFileContents", params, cb, buf)
  assert(ok, "Request to `java/classFileContents` must succeed to open JDT URI. Client shutdown?")
  local timeout_ms = timeout or 500
  local wait_ok, reason = vim.wait(timeout_ms, function()
    return response
  end)
  local log_path = require("jdtls.path").join(vim.fn.stdpath("cache"), "lsp.log")
  local buf_content
  if wait_ok and #response == 2 and response[2] then
    local content = response[2]
    if content == "" then
      buf_content = {
        "Received response from server, but it was empty. Check the log file for errors",
        log_path,
      }
    else
      buf_content = vim.split(response[2], "\n", true)
    end
  else
    local error_msg
    if not wait_ok then
      client.cancel_request(request_id)
      local wait_failure = {
        [-1] = "timeout",
        [-2] = "interrupted",
        [-3] = "error",
      }
      error_msg = wait_failure[reason]
    else
      error_msg = response[1]
    end
    buf_content = {
      "Failed to load content for uri",
      uri,
      "",
      "Error was: ",
    }
    vim.list_extend(buf_content, vim.split(vim.inspect(error_msg), "\n"))
    vim.list_extend(buf_content, { "", "Check the log file for errors", log_path })
  end
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buf_content)
  vim.api.nvim_buf_set_option(buf, "filetype", "java")
  -- vim.api.nvim_buf_set_option(buf, "syntax", "java")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end
return M
