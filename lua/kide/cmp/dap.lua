---@type blink.cmp.Source
local M = {}
function M.new()
  return setmetatable({}, { __index = M })
end

local kinds = require "nvchad.icons.lspkind"

local kind_map = {
  method = kinds.Method,
  ["function"] = kinds.Function,
  constructor = kinds.Constructor,
  field = kinds.Field,
  variable = kinds.Variable,
  class = kinds.Class,
  interface = kinds.Interface,
  module = kinds.Module,
  property = kinds.Property,
  unit = kinds.Unit,
  value = kinds.Value,
  enum = kinds.Enum,
  keyword = kinds.Keyword,
  snippet = kinds.Snippet,
  text = kinds.Text,
  color = kinds.Color,
  file = kinds.File,
  reference = kinds.Reference,
  customcolor = kinds.Color,
}

local dap_repl = require "dap.repl"
local dap = require "dap"

function M:get_trigger_characters()
  print "get_trigger_characters"
  local session = require("dap").session()
  local trigger_characters = session.capabilities.completionTriggerCharacters or {}
  local contains_dot = vim.tbl_contains(trigger_characters, ".")
  if not contains_dot then
    table.insert(trigger_characters, ".") -- always add '.' as nvim-dap adds custom commands starting with .
  end
  return trigger_characters
end

function M:enabled()
  print("enabled dap")
  local session = dap.session()
  if not session then
    return false
  end

  local supportsCompletionsRequest = ((session or {}).capabilities or {}).supportsCompletionsRequest
  if not supportsCompletionsRequest then
    return false
  end
  print(vim.bo.filetype)
  return vim.startswith(vim.bo.filetype, "dap-repl")
end

function M:get_completions(ctx, callback)
  local session = assert(dap.session())
  local col = ctx.cursor[2]
  local line = ctx.line

  local offset = vim.startswith(line, "dap> ") and 5 or 0
  local typed = line:sub(offset + 1, col)

  local completions = {}
  local _add = function(val)
    table.insert(completions, {
      label = val,
      dup = 0,
      insertText = val,
      labelDetails = nil,
      documentation = "",
      kind = kinds.Keyword,
    })
  end

  -- REPL Commands (including custom commands)
  if vim.startswith(typed, ".") then
    for _, values in pairs(dap_repl.commands) do
      for _, directive in pairs(values) do
        if type(directive) == "string" and vim.startswith(directive, typed) then
          _add(directive)
        end
      end
    end
    for command, _ in pairs(dap_repl.commands.custom_commands or {}) do
      if vim.startswith(command, typed) then
        _add(command)
      end
    end
  end

  local transformed_callback = function(items)
    callback {
      context = ctx,
      is_incomplete_forward = true,
      is_incomplete_backward = true,
      items = items,
    }
  end
  session:request("completions", {
    frameId = (session.current_frame or {}).id,
    text = typed,
    column = col + 1 - offset,
  }, function(err, response)
    if err then
      return
    end
    for _, item in pairs(response.targets) do
      if item.type then
        item.kind = kind_map[item.type]
      end
      item.insertText = item.text or item.label
      table.insert(completions, item)
    end

    transformed_callback(completions)
  end)
end

return M
