local M = {}
local extension_path = "/Users/luokai/.vscode/extensions/vadimcn.vscode-lldb-1.7.2"
M.config = {}
M.config.codelldb_path = extension_path .. "/adapter/codelldb"
M.config.liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"

M.setup = function(config)
  if config then
    M.config = vim.tbl_deep_extend("force", M.config, config)
  end
  local dap = require("dap")
  dap.adapters.codelldb = function(on_adapter)
    -- This asks the system for a free port
    local tcp = vim.loop.new_tcp()
    tcp:bind("127.0.0.1", 0)
    local port = tcp:getsockname().port
    tcp:shutdown()
    tcp:close()

    -- Start codelldb with the port
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)
    local opts = {
      stdio = { nil, stdout, stderr },
      args = { "--port", tostring(port), "--liblldb", M.config.liblldb_path },
    }
    local handle
    local pid_or_err
    handle, pid_or_err = vim.loop.spawn(M.config.codelldb_path, opts, function(code)
      stdout:close()
      stderr:close()
      handle:close()
      if code ~= 0 then
        print("codelldb exited with code", code)
      end
    end)
    if not handle then
      vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
      stdout:close()
      stderr:close()
      return
    end
    vim.notify("codelldb started. pid=" .. pid_or_err)
    stderr:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require("dap.repl").append(chunk)
        end)
      end
    end)
    local adapter = {
      type = "server",
      host = "127.0.0.1",
      port = port,
    }
    -- 💀
    -- Wait for codelldb to get ready and start listening before telling nvim-dap to connect
    -- If you get connect errors, try to increase 500 to a higher value, or check the stderr (Open the REPL)
    vim.defer_fn(function()
      on_adapter(adapter)
    end, 500)
  end

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = true,
    },
  }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end
return M
