local function get_python_path()
  if vim.env.VIRTUAL_ENV then
    if vim.fn.has("nvim-0.10") == 1 then
      return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
    end
    return vim.env.VIRTUAL_ENV .. "/bin" .. "/python"
  end
  if vim.env.PY_BIN then
    return vim.env.PY_BIN
  end
  local python = vim.fn.exepath("python3")
  if python == nil or python == "" then
    python = vim.fn.exepath("python")
  end
  return python
end

local M = {
  env = {
    py_bin = get_python_path(),
    rime_ls_bin = vim.env["RIME_LS_BIN"],
  },
  plugin = {
    copilot = {
      enable = vim.env["COPILOT_ENABLE"] == "Y" and true or false,
    },
  },
}
return M
